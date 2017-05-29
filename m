Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f199.google.com (mail-ua0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id CA7906B02C3
	for <linux-mm@kvack.org>; Mon, 29 May 2017 11:29:52 -0400 (EDT)
Received: by mail-ua0-f199.google.com with SMTP id g23so18956232uac.1
        for <linux-mm@kvack.org>; Mon, 29 May 2017 08:29:52 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 1sor1614856uaz.45.2017.05.29.08.29.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 29 May 2017 08:29:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CACT4Y+ZrUi_YGkwmbuGV2_6wC7Q54at1_xyYeT3dQQ=cNm1NsQ@mail.gmail.com>
References: <1494897409-14408-1-git-send-email-iamjoonsoo.kim@lge.com>
 <CACT4Y+ZVrs9XDk5QXkQyej+xFwKrgnGn-RPBC+pL5znUp2aSCg@mail.gmail.com>
 <20170516062318.GC16015@js1304-desktop> <CACT4Y+anOw8=7u-pZ2ceMw0xVnuaO9YKBJAr-2=KOYt_72b2pw@mail.gmail.com>
 <CACT4Y+YREmHViSMsH84bwtEqbUsqsgzaa76eWzJXqmSgqKbgvg@mail.gmail.com>
 <20170524074539.GA9697@js1304-desktop> <CACT4Y+ZwL+iTMvF5NpsovThQrdhunCc282ffjqQcgZg3tAQH4w@mail.gmail.com>
 <20170525004104.GA21336@js1304-desktop> <CACT4Y+YV7Rf93NOa1yi0NiELX7wfwkfQmXJ67hEVOrG7VkuJJg@mail.gmail.com>
 <CACT4Y+ZrUi_YGkwmbuGV2_6wC7Q54at1_xyYeT3dQQ=cNm1NsQ@mail.gmail.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Mon, 29 May 2017 17:29:30 +0200
Message-ID: <CACT4Y+bT=aaC+XTMwoON-Rc5gOheAj702anXKJMXDJ5FtLDRMw@mail.gmail.com>
Subject: Re: [PATCH v1 00/11] mm/kasan: support per-page shadow memory to
 reduce memory consumption
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, kernel-team@lge.com

On Mon, May 29, 2017 at 5:12 PM, Dmitry Vyukov <dvyukov@google.com> wrote:
>>>> >> > What does make your current patch work then?
>>>> >> > Say we map a new shadow page, update the page shadow to say that there
>>>> >> > is mapped shadow. Then another CPU loads the page shadow and then
>>>> >> > loads from the newly mapped shadow. If we don't flush TLB, what makes
>>>> >> > the second CPU see the newly mapped shadow?
>>>> >>
>>>> >> /\/\/\/\/\/\
>>>> >>
>>>> >> Joonsoo, please answer this question above.
>>>> >
>>>> > Hello, I've answered it in another e-mail however it would not be
>>>> > sufficient. I try again.
>>>> >
>>>> > If the page isn't used for kernel stack, slab, and global variable
>>>> > (aka. kernel memory), black shadow is mapped for the page. We map a
>>>> > new shadow page if the page will be used for kernel memory. We need to
>>>> > flush TLB in all cpus when mapping a new shadow however it's not
>>>> > possible in some cases. So, this patch does just flushing local cpu's
>>>> > TLB. Another cpu could have stale TLB that points black shadow for
>>>> > this page. If that cpu with stale TLB try to check vailidity of the
>>>> > object on this page, result would be invalid since stale TLB points
>>>> > the black shadow and it's shadow value is non-zero. We need a magic
>>>> > here. At this moment, we cannot make sure if invalid is correct result
>>>> > or not since we didn't do full TLB flush. So fixup processing is
>>>> > started. It is implemented in check_memory_region_slow(). Flushing
>>>> > local TLB and re-checking the shadow value. With flushing local TLB,
>>>> > we will use fresh TLB at this time. Therefore, we can pass the
>>>> > validity check as usual.
>>>> >
>>>> >> I am trying to understand if there is any chance to make mapping a
>>>> >> single page for all non-interesting shadow ranges work. That would be
>>>> >
>>>> > This is what this patchset does. Mapping a single (zero/black) shadow
>>>> > page for all non-interesting (non-kernel memory) shadow ranges.
>>>> > There is only single instance of zero/black shadow page. On v1,
>>>> > I used black shadow page only so fail to get enough performance. On
>>>> > v2 mentioned in another thread, I use zero shadow for some region. I
>>>> > guess that performance problem would be gone.
>>>>
>>>>
>>>> I can't say I understand everything here, but after staring at the
>>>> patch I don't understand why we need pshadow at all now. Especially
>>>> with this commit
>>>> https://github.com/JoonsooKim/linux/commit/be36ee65f185e3c4026fe93b633056ea811120fb.
>>>> It seems that the current shadow is enough.
>>>
>>> pshadow exists for non-kernel memory like as page cache or anonymous page.
>>> This patch doesn't map a new shadow (per-byte shadow) for those pages
>>> to reduce memory consumption. However, we need to know if those page
>>> are allocated or not in order to check the validity of access to those
>>> page. We cannot utilize zero/black shadow page here since mapping
>>> single zero/black shadow page represents eight real page's shadow
>>> value. Instead, we use per-page shadow here and mark/unmark it when
>>> allocation and free happens. With it, we can know the state of the
>>> page and we can determine the validity of access to them.
>>
>> I see the problem with 8 kernel pages mapped to a single shadow page.
>>
>>
>>>> If we see bad shadow when the actual shadow value is good, we fall
>>>> onto slow path, flush tlb, reload shadow, see that it is good and
>>>> return. Pshadow is not needed in this case.
>>>
>>> For the kernel memory, if we see bad shadow due to *stale TLB*, we
>>> fall onto slow path (check_memory_region_slow()) and flush tlb and
>>> reload shadow.
>>>
>>> For the non-kernel memory, if we see bad shadow, we fall onto
>>> pshadow_val() check and we can see actual state of the page.
>>>
>>>> If we see good shadow when the actual shadow value is bad, we return
>>>> immediately and get false negative. Pshadow is not involved as well.
>>>> What am I missing?
>>>
>>> In this patchset, there is no case that we see good shadow when the
>>> actual (p)shadow value is bad. This case should not happen since we
>>> can miss actual error.
>>
>> But why is not it possible?
>> Let's say we have a real shadow page allocated for range of kernel
>> memory. Then we unmap the shadow page and map the back page (maybe
>> even unmap the black page and map another real shadow page). Then
>> another CPU reads shadow for this range. What prevents it from seeing
>> the old shadow page?
>
>
> Re the async processing in kasan_unmap_shadow_workfn. Can't it lead to
> shadow corruption? It seems that it can cause unsynchronized state of
> shadow pages and corresponding kernel pages in page alloc.
> Consider that we schedule unmap of some pages in kasan_unmap_shadow.
> Then the range is reallocated in page_alloc and we get into
> kasan_map_shadow, which tries to map shadow for these pages again, but
> since they are already mapped it bails out. Then
> kasan_unmap_shadow_workfn starts and unmaps shadow for the range.


Joonsoo,

I guess mine (and Andrey's) main concern is the amount of additional
complexity (I am still struggling to understand how it all works) and
more arch-dependent code in exchange for moderate memory win.

Joonsoo, Andrey,

I have an alternative proposal. It should be conceptually simpler and
also less arch-dependent. But I don't know if I miss something
important that will render it non working.
Namely, we add a pointer to shadow to the page struct. Then, create a
slab allocator for 512B shadow blocks. Then, attach/detach these
shadow blocks to page structs as necessary. It should lead to even
smaller memory consumption because we won't need a whole shadow page
when only 1 out of 8 corresponding kernel pages are used (we will need
just a single 512B block). I guess with some fragmentation we need
lots of excessive shadow with the current proposed patch.
This does not depend on TLB in any way and does not require hooking
into buddy allocator.
The main downside is that we will need to be careful to not assume
that shadow is continuous. In particular this means that this mode
will work only with outline instrumentation and will need some ifdefs.
Also it will be slower due to the additional indirection when
accessing shadow, but that's meant as "small but slow" mode as far as
I understand.

But the main win as I see it is that that's basically complete support
for 32-bit arches. People do ask about arm32 support:
https://groups.google.com/d/msg/kasan-dev/Sk6BsSPMRRc/Gqh4oD_wAAAJ
https://groups.google.com/d/msg/kasan-dev/B22vOFp-QWg/EVJPbrsgAgAJ
and probably mips32 is relevant as well.
Such mode does not require a huge continuous address space range, has
minimal memory consumption and requires minimal arch-dependent code.
Works only with outline instrumentation, but I think that's a
reasonable compromise.

What do you think?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
