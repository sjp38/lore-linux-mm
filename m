Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f180.google.com (mail-pf0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 1648982F64
	for <linux-mm@kvack.org>; Tue, 22 Dec 2015 15:05:00 -0500 (EST)
Received: by mail-pf0-f180.google.com with SMTP id o64so111009289pfb.3
        for <linux-mm@kvack.org>; Tue, 22 Dec 2015 12:05:00 -0800 (PST)
Received: from mail-pa0-x229.google.com (mail-pa0-x229.google.com. [2607:f8b0:400e:c03::229])
        by mx.google.com with ESMTPS id 21si13534010pfj.91.2015.12.22.12.04.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Dec 2015 12:04:59 -0800 (PST)
Received: by mail-pa0-x229.google.com with SMTP id uo6so16900761pac.1
        for <linux-mm@kvack.org>; Tue, 22 Dec 2015 12:04:59 -0800 (PST)
Subject: Re: [RFC][PATCH 0/7] Sanitization of slabs based on grsecurity/PaX
References: <1450755641-7856-1-git-send-email-laura@labbott.name>
 <alpine.DEB.2.20.1512220952350.2114@east.gentwo.org>
From: Laura Abbott <laura@labbott.name>
Message-ID: <5679ACE9.70701@labbott.name>
Date: Tue, 22 Dec 2015 12:04:57 -0800
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1512220952350.2114@east.gentwo.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kees Cook <keescook@chromium.org>, kernel-hardening@lists.openwall.com

On 12/22/15 8:08 AM, Christoph Lameter wrote:
> On Mon, 21 Dec 2015, Laura Abbott wrote:
>
>> The biggest change from PAX_MEMORY_SANTIIZE is that this feature sanitizes
>> the SL[AOU]B allocators only. My plan is to work on the buddy allocator
>> santization after this series gets picked up. A side effect of this is
>> that allocations which go directly to the buddy allocator (i.e. large
>> allocations) aren't sanitized. I'd like feedback about whether it's worth
>> it to add sanitization on that path directly or just use the page
>> allocator sanitization when that comes in.
>
> I am not sure what the point of this patchset is. We have a similar effect
> to sanitization already in the allocators through two mechanisms:
>
> 1. Slab poisoning
> 2. Allocation with GFP_ZERO
>
> I do not think we need a third one. You could accomplish your goals much
> easier without this code churn by either
>
> 1. Improve the existing poisoning mechanism. Ensure that there are no
>     gaps. Security sensitive kernel slab caches can then be created with
>     the  POISONING flag set. Maybe add a Kconfig flag that enables
>     POISONING for each cache? What was the issue when you tried using
>     posining for sanitization?

The existing poisoning does work for sanitization but it's still a debug
feature. It seemed more appropriate to keep debug features and non-debug
features separate hence the separate option and configuration.

>
> 2. Add a mechanism that ensures that GFP_ZERO is set for each allocation.
>     That way every object you retrieve is zeroed and thus you have implied
>     sanitization. This also can be done in a rather simple way by changing
>     the  GFP_KERNEL etc constants to include __GFP_ZERO depending on a
>     Kconfig option. Or add some runtime setting of the gfp flags somewhere.
>

That's good for allocation but sanitization is done on free. The goal
is to reduce any leftover data that might be around while on an unallocated
slab.
  
> Generally I would favor option #2 if you must have sanitization because
> that is the only option to really give you a deterministic content of
> object on each allocation. Any half way measures would not work I think.
>
> Note also that most allocations are already either allocations that zero
> the content or they are immediately initializing the content of the
> allocated object. After all the object is not really usable if the
> content is random. You may be able to avoid this whole endeavor by
> auditing the kernel for locations where the object is not initialized
> after allocation.
>
> Once one recognizes the above it seems that sanitization is pretty
> useless. Its just another pass of writing zeroes before the allocator or
> uer of the allocated object sets up deterministic content of the object or
> -- in most cases -- zeroes it again.
>

The sanitization is going towards kernel hardening which is designed to
help keep the kernel secure even when programmers screwed up. Auditing
still won't catch everything. sanitization is going towards the idea
of kernel self-protection which is what Grsecurity is known for
and Kees Cook is trying to promote for mainline
(http://lwn.net/Articles/662219/)

Thanks,
Laura

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
