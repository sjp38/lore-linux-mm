Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f174.google.com (mail-pf0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id EC8C66B0003
	for <linux-mm@kvack.org>; Tue,  5 Jan 2016 22:17:24 -0500 (EST)
Received: by mail-pf0-f174.google.com with SMTP id 78so233652507pfw.2
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 19:17:24 -0800 (PST)
Received: from mail-pa0-x22a.google.com (mail-pa0-x22a.google.com. [2607:f8b0:400e:c03::22a])
        by mx.google.com with ESMTPS id bs10si66736495pad.73.2016.01.05.19.17.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Jan 2016 19:17:23 -0800 (PST)
Received: by mail-pa0-x22a.google.com with SMTP id uo6so206546339pac.1
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 19:17:23 -0800 (PST)
Subject: Re: [RFC][PATCH 0/7] Sanitization of slabs based on grsecurity/PaX
References: <1450755641-7856-1-git-send-email-laura@labbott.name>
 <alpine.DEB.2.20.1512220952350.2114@east.gentwo.org>
 <5679ACE9.70701@labbott.name>
 <CAGXu5jJQKaA1qgLEV9vXEVH4QBC__Vg141BX22ZsZzW6p9yk4Q@mail.gmail.com>
From: Laura Abbott <laura@labbott.name>
Message-ID: <568C8741.4040709@labbott.name>
Date: Tue, 5 Jan 2016 19:17:21 -0800
MIME-Version: 1.0
In-Reply-To: <CAGXu5jJQKaA1qgLEV9vXEVH4QBC__Vg141BX22ZsZzW6p9yk4Q@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>

On 1/5/16 4:09 PM, Kees Cook wrote:
> On Tue, Dec 22, 2015 at 12:04 PM, Laura Abbott <laura@labbott.name> wrote:
>> On 12/22/15 8:08 AM, Christoph Lameter wrote:
>>>
>>> On Mon, 21 Dec 2015, Laura Abbott wrote:
>>>
>>>> The biggest change from PAX_MEMORY_SANTIIZE is that this feature
>>>> sanitizes
>>>> the SL[AOU]B allocators only. My plan is to work on the buddy allocator
>>>> santization after this series gets picked up. A side effect of this is
>>>> that allocations which go directly to the buddy allocator (i.e. large
>>>> allocations) aren't sanitized. I'd like feedback about whether it's worth
>>>> it to add sanitization on that path directly or just use the page
>>>> allocator sanitization when that comes in.
>
> This looks great! I love the added lkdtm tests, too. Very cool.
>
>>> I am not sure what the point of this patchset is. We have a similar effect
>>> to sanitization already in the allocators through two mechanisms:
>>>
>>> 1. Slab poisoning
>>> 2. Allocation with GFP_ZERO
>>>
>>> I do not think we need a third one. You could accomplish your goals much
>>> easier without this code churn by either
>>>
>>> 1. Improve the existing poisoning mechanism. Ensure that there are no
>>>      gaps. Security sensitive kernel slab caches can then be created with
>>>      the  POISONING flag set. Maybe add a Kconfig flag that enables
>>>      POISONING for each cache? What was the issue when you tried using
>>>      posining for sanitization?
>>
>> The existing poisoning does work for sanitization but it's still a debug
>> feature. It seemed more appropriate to keep debug features and non-debug
>> features separate hence the separate option and configuration.
>
> What stuff is intertwined in the existing poisoning that makes it
> incompatible/orthogonal?
>

It's not the poisoning per se that's incompatible, it's how the poisoning is
set up. At least for slub, the current poisoning is part of SLUB_DEBUG which
enables other consistency checks on the allocator. Trying to pull out just
the poisoning for use when SLUB_DEBUG isn't on would result in roughly what
would be here anyway. I looked at trying to reuse some of the existing poisoning
and came to the conclusion it was less intrusive to the allocator to keep it
separate.

Thanks,
Laura

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
