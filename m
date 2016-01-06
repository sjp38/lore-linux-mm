Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f174.google.com (mail-ig0-f174.google.com [209.85.213.174])
	by kanga.kvack.org (Postfix) with ESMTP id 94EE7800C7
	for <linux-mm@kvack.org>; Tue,  5 Jan 2016 19:09:47 -0500 (EST)
Received: by mail-ig0-f174.google.com with SMTP id ik10so22329065igb.1
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 16:09:47 -0800 (PST)
Received: from mail-io0-x230.google.com (mail-io0-x230.google.com. [2607:f8b0:4001:c06::230])
        by mx.google.com with ESMTPS id j192si57404126ioe.177.2016.01.05.16.09.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Jan 2016 16:09:46 -0800 (PST)
Received: by mail-io0-x230.google.com with SMTP id q21so203228105iod.0
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 16:09:46 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <5679ACE9.70701@labbott.name>
References: <1450755641-7856-1-git-send-email-laura@labbott.name>
	<alpine.DEB.2.20.1512220952350.2114@east.gentwo.org>
	<5679ACE9.70701@labbott.name>
Date: Tue, 5 Jan 2016 16:09:46 -0800
Message-ID: <CAGXu5jJQKaA1qgLEV9vXEVH4QBC__Vg141BX22ZsZzW6p9yk4Q@mail.gmail.com>
Subject: Re: [RFC][PATCH 0/7] Sanitization of slabs based on grsecurity/PaX
From: Kees Cook <keescook@chromium.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <laura@labbott.name>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>

On Tue, Dec 22, 2015 at 12:04 PM, Laura Abbott <laura@labbott.name> wrote:
> On 12/22/15 8:08 AM, Christoph Lameter wrote:
>>
>> On Mon, 21 Dec 2015, Laura Abbott wrote:
>>
>>> The biggest change from PAX_MEMORY_SANTIIZE is that this feature
>>> sanitizes
>>> the SL[AOU]B allocators only. My plan is to work on the buddy allocator
>>> santization after this series gets picked up. A side effect of this is
>>> that allocations which go directly to the buddy allocator (i.e. large
>>> allocations) aren't sanitized. I'd like feedback about whether it's worth
>>> it to add sanitization on that path directly or just use the page
>>> allocator sanitization when that comes in.

This looks great! I love the added lkdtm tests, too. Very cool.

>> I am not sure what the point of this patchset is. We have a similar effect
>> to sanitization already in the allocators through two mechanisms:
>>
>> 1. Slab poisoning
>> 2. Allocation with GFP_ZERO
>>
>> I do not think we need a third one. You could accomplish your goals much
>> easier without this code churn by either
>>
>> 1. Improve the existing poisoning mechanism. Ensure that there are no
>>     gaps. Security sensitive kernel slab caches can then be created with
>>     the  POISONING flag set. Maybe add a Kconfig flag that enables
>>     POISONING for each cache? What was the issue when you tried using
>>     posining for sanitization?
>
> The existing poisoning does work for sanitization but it's still a debug
> feature. It seemed more appropriate to keep debug features and non-debug
> features separate hence the separate option and configuration.

What stuff is intertwined in the existing poisoning that makes it
incompatible/orthogonal?

>> 2. Add a mechanism that ensures that GFP_ZERO is set for each allocation.
>>     That way every object you retrieve is zeroed and thus you have implied
>>     sanitization. This also can be done in a rather simple way by changing
>>     the  GFP_KERNEL etc constants to include __GFP_ZERO depending on a
>>     Kconfig option. Or add some runtime setting of the gfp flags
>> somewhere.
>>
>
> That's good for allocation but sanitization is done on free. The goal
> is to reduce any leftover data that might be around while on an unallocated
> slab.

Right -- we want this on free. I wonder if we could also add the
always-zero option as an additional improvement. A separate config,
since I suspect the overhead would be ugly.

>> Generally I would favor option #2 if you must have sanitization because
>> that is the only option to really give you a deterministic content of
>> object on each allocation. Any half way measures would not work I think.
>>
>> Note also that most allocations are already either allocations that zero
>> the content or they are immediately initializing the content of the
>> allocated object. After all the object is not really usable if the
>> content is random. You may be able to avoid this whole endeavor by
>> auditing the kernel for locations where the object is not initialized
>> after allocation.
>>
>> Once one recognizes the above it seems that sanitization is pretty
>> useless. Its just another pass of writing zeroes before the allocator or
>> uer of the allocated object sets up deterministic content of the object or
>> -- in most cases -- zeroes it again.
>>
>
> The sanitization is going towards kernel hardening which is designed to
> help keep the kernel secure even when programmers screwed up. Auditing
> still won't catch everything. sanitization is going towards the idea
> of kernel self-protection which is what Grsecurity is known for
> and Kees Cook is trying to promote for mainline
> (http://lwn.net/Articles/662219/)

Yup, well said. Auditing is important, and we're already doing it, but
we want to catch the mistakes during runtime, since we'll never be
free of bugs, bug lifetime is measured in years, and end users are
frequently forced to run Linux with additional non-upstream code, so
we want to protect them from those mistakes as well.

-Kees

-- 
Kees Cook
Chrome OS & Brillo Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
