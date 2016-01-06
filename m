Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f178.google.com (mail-pf0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 3A65F6B0003
	for <linux-mm@kvack.org>; Tue,  5 Jan 2016 21:46:14 -0500 (EST)
Received: by mail-pf0-f178.google.com with SMTP id q63so194460426pfb.0
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 18:46:14 -0800 (PST)
Received: from mail-pf0-x232.google.com (mail-pf0-x232.google.com. [2607:f8b0:400e:c00::232])
        by mx.google.com with ESMTPS id i13si66573972pat.171.2016.01.05.18.46.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Jan 2016 18:46:13 -0800 (PST)
Received: by mail-pf0-x232.google.com with SMTP id e65so177417826pfe.1
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 18:46:13 -0800 (PST)
Subject: Re: [kernel-hardening] [RFC][PATCH 6/7] mm: Add Kconfig option for
 slab sanitization
References: <1450755641-7856-1-git-send-email-laura@labbott.name>
 <1450755641-7856-7-git-send-email-laura@labbott.name>
 <567964F3.2020402@intel.com>
 <alpine.DEB.2.20.1512221023550.2748@east.gentwo.org>
 <567986E7.50107@intel.com>
 <alpine.DEB.2.20.1512221124230.14335@east.gentwo.org>
 <56798851.60906@intel.com>
 <alpine.DEB.2.20.1512221207230.14406@east.gentwo.org>
 <5679943C.1050604@intel.com> <5679A0CB.3060707@labbott.name>
 <CAGXu5jLe69KvVOGE2kHtJk+Ueik4OX9YyYAk_NhRufOEVkLUdQ@mail.gmail.com>
From: Laura Abbott <laura@labbott.name>
Message-ID: <568C7FF3.9070408@labbott.name>
Date: Tue, 5 Jan 2016 18:46:11 -0800
MIME-Version: 1.0
In-Reply-To: <CAGXu5jLe69KvVOGE2kHtJk+Ueik4OX9YyYAk_NhRufOEVkLUdQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Christoph Lameter <cl@linux.com>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 1/5/16 4:29 PM, Kees Cook wrote:
> On Tue, Dec 22, 2015 at 11:13 AM, Laura Abbott <laura@labbott.name> wrote:
>> On 12/22/15 10:19 AM, Dave Hansen wrote:
>>>
>>> On 12/22/2015 10:08 AM, Christoph Lameter wrote:
>>>>
>>>> On Tue, 22 Dec 2015, Dave Hansen wrote:
>>>>>>
>>>>>> Why would you use zeros? The point is just to clear the information
>>>>>> right?
>>>>>> The regular poisoning does that.
>>>>>
>>>>>
>>>>> It then allows you to avoid the zeroing at allocation time.
>>>>
>>>>
>>>> Well much of the code is expecting a zeroed object from the allocator and
>>>> its zeroed at that time. Zeroing makes the object cache hot which is an
>>>> important performance aspect.
>>>
>>>
>>> Yes, modifying this behavior has a performance impact.  It absolutely
>>> needs to be evaluated, and I wouldn't want to speculate too much on how
>>> good or bad any of the choices are.
>>>
>>> Just to reiterate, I think we have 3 real choices here:
>>>
>>> 1. Zero at alloc, only when __GFP_ZERO
>>>      (behavior today)
>>> 2. Poison at free, also Zero at alloc (when __GFP_ZERO)
>>>      (this patch's proposed behavior, also what current poisoning does,
>>>       doubles writes)
>>> 3. Zero at free, *don't* Zero at alloc (when __GFP_ZERO)
>>>      (what I'm suggesting, possibly less perf impact vs. #2)
>>>
>>>
>>
>> poisoning with non-zero memory makes it easier to determine that the error
>> came from accessing the sanitized memory vs. some other case. I don't think
>> the feature would be as strong if the memory was only zeroed vs. some other
>> data value.
>
> I would tend to agree. If there are significant perf improvements for
> "3" above, that should be easy to add on later as another choice.
>

I was looking at the sanitization for the buddy allocator that exists in
grsecurity and that does option #3 (zero at free, skip __GFP_ZERO).
I'm going to look into adding that as an option for the slab allocator
and see what the performance numbers show.

Thanks,
Laura

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
