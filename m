Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f70.google.com (mail-vk0-f70.google.com [209.85.213.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1746C6B0038
	for <linux-mm@kvack.org>; Tue, 18 Oct 2016 11:29:49 -0400 (EDT)
Received: by mail-vk0-f70.google.com with SMTP id t22so164124223vkb.7
        for <linux-mm@kvack.org>; Tue, 18 Oct 2016 08:29:49 -0700 (PDT)
Received: from mail-vk0-x241.google.com (mail-vk0-x241.google.com. [2607:f8b0:400c:c05::241])
        by mx.google.com with ESMTPS id n127si18080850vkb.55.2016.10.18.08.29.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Oct 2016 08:29:48 -0700 (PDT)
Received: by mail-vk0-x241.google.com with SMTP id b186so9909035vkb.3
        for <linux-mm@kvack.org>; Tue, 18 Oct 2016 08:29:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAMJBoFPnpdG7ddR7LTKNYNZZzNo0t3tP+o0004gf7x26BOWNVQ@mail.gmail.com>
References: <20161015135632.541010b55bec496e2cae056e@gmail.com>
 <20161015140520.ee52a80c92c50214a6614977@gmail.com> <CALZtONBWyX0OjJUcyyj23vqpJtbx-8fHakdDzrywvgZDZyVq6w@mail.gmail.com>
 <CAMJBoFPORDkVnpX5tf6zoYPxQWXA1Aayvff5s8iRWw0mLSg7OQ@mail.gmail.com>
 <CALZtONC4_aJwqhQ5W9AzHZS6_yUQk-w50E+gY=xHuwCYpi2Jfg@mail.gmail.com> <CAMJBoFPnpdG7ddR7LTKNYNZZzNo0t3tP+o0004gf7x26BOWNVQ@mail.gmail.com>
From: Dan Streetman <ddstreet@ieee.org>
Date: Tue, 18 Oct 2016 11:29:07 -0400
Message-ID: <CALZtONCSBC+gxDHrCrQkyx0+eUwejLJJBvzsnPBtiKr58LJtLA@mail.gmail.com>
Subject: Re: [PATCH v5 3/3] z3fold: add shrinker
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Wool <vitalywool@gmail.com>
Cc: Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>

On Tue, Oct 18, 2016 at 10:51 AM, Vitaly Wool <vitalywool@gmail.com> wrote:
> On Tue, Oct 18, 2016 at 4:27 PM, Dan Streetman <ddstreet@ieee.org> wrote:
>> On Mon, Oct 17, 2016 at 10:45 PM, Vitaly Wool <vitalywool@gmail.com> wrote:
>>> Hi Dan,
>>>
>>> On Tue, Oct 18, 2016 at 4:06 AM, Dan Streetman <ddstreet@ieee.org> wrote:
>>>> On Sat, Oct 15, 2016 at 8:05 AM, Vitaly Wool <vitalywool@gmail.com> wrote:
>>>>> This patch implements shrinker for z3fold. This shrinker
>>>>> implementation does not free up any pages directly but it allows
>>>>> for a denser placement of compressed objects which results in
>>>>> less actual pages consumed and higher compression ratio therefore.
>>>>>
>>>>> This update removes z3fold page compaction from the freeing path
>>>>> since we can rely on shrinker to do the job. Also, a new flag
>>>>> UNDER_COMPACTION is introduced to protect against two threads
>>>>> trying to compact the same page.
>>>>
>>>> i'm completely unconvinced that this should be a shrinker.  The
>>>> alloc/free paths are much, much better suited to compacting a page
>>>> than a shrinker that must scan through all the unbuddied pages.  Why
>>>> not just improve compaction for the alloc/free paths?
>>>
>>> Basically the main reason is performance, I want to avoid compaction on hot
>>> paths as much as possible. This patchset brings both performance and
>>> compression ratio gain, I'm not sure how to achieve that with improving
>>> compaction on alloc/free paths.
>>
>> It seems like a tradeoff of slight improvement in hot paths, for
>> significant decrease in performance by adding a shrinker, which will
>> do a lot of unnecessary scanning.  The alloc/free/unmap functions are
>> working directly with the page at exactly the point where compaction
>> is needed - when adding or removing a bud from the page.
>
> I can see that sometimes there are substantial amounts of pages that
> are non-compactable synchronously due to the MIDDLE_CHUNK_MAPPED
> bit set. Picking up those seems to be a good job for a shrinker, and those
> end up in the beginning of respective unbuddied lists, so the shrinker is set
> to find them. I can slightly optimize that by introducing a
> COMPACT_DEFERRED flag or something like that to make shrinker find
> those pages faster, would that make sense to you?

Why not just compact the page in z3fold_unmap()?

>
>> Sorry if I missed it in earlier emails, but have you done any
>> performance measurements comparing with/without the shrinker?  The
>> compression ratio gains may be possible with only the
>> z3fold_compact_page() improvements, and performance may be stable (or
>> better) with only a per-z3fold-page lock, instead of adding the
>> shrinker...?
>
> I'm running some tests with per-page locks now, but according to the
> previous measurements the shrinker version always wins on multi-core
> platforms.

But that comparison is without taking the spinlock in map/unmap right?

>
>> If a shrinker really is needed, it seems like it would be better
>> suited to coalescing separate z3fold pages via migration, like
>> zsmalloc does (although that's a significant amount of work).
>
> I really don't want to go that way to keep z3fold applicable to an MMU-less
> system.
>
> ~vitaly

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
