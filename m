Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2EDDC6B02C3
	for <linux-mm@kvack.org>; Mon, 29 May 2017 11:08:11 -0400 (EDT)
Received: by mail-ua0-f197.google.com with SMTP id x47so18805899uab.14
        for <linux-mm@kvack.org>; Mon, 29 May 2017 08:08:11 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id c18sor1708475uah.13.2017.05.29.08.08.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 29 May 2017 08:08:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170525004104.GA21336@js1304-desktop>
References: <1494897409-14408-1-git-send-email-iamjoonsoo.kim@lge.com>
 <CACT4Y+ZVrs9XDk5QXkQyej+xFwKrgnGn-RPBC+pL5znUp2aSCg@mail.gmail.com>
 <20170516062318.GC16015@js1304-desktop> <CACT4Y+anOw8=7u-pZ2ceMw0xVnuaO9YKBJAr-2=KOYt_72b2pw@mail.gmail.com>
 <CACT4Y+YREmHViSMsH84bwtEqbUsqsgzaa76eWzJXqmSgqKbgvg@mail.gmail.com>
 <20170524074539.GA9697@js1304-desktop> <CACT4Y+ZwL+iTMvF5NpsovThQrdhunCc282ffjqQcgZg3tAQH4w@mail.gmail.com>
 <20170525004104.GA21336@js1304-desktop>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Mon, 29 May 2017 17:07:48 +0200
Message-ID: <CACT4Y+YV7Rf93NOa1yi0NiELX7wfwkfQmXJ67hEVOrG7VkuJJg@mail.gmail.com>
Subject: Re: [PATCH v1 00/11] mm/kasan: support per-page shadow memory to
 reduce memory consumption
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, kernel-team@lge.com

On Thu, May 25, 2017 at 2:41 AM, Joonsoo Kim <js1304@gmail.com> wrote:
> On Wed, May 24, 2017 at 07:19:50PM +0200, Dmitry Vyukov wrote:
>> On Wed, May 24, 2017 at 9:45 AM, Joonsoo Kim <js1304@gmail.com> wrote:
>> >> > What does make your current patch work then?
>> >> > Say we map a new shadow page, update the page shadow to say that there
>> >> > is mapped shadow. Then another CPU loads the page shadow and then
>> >> > loads from the newly mapped shadow. If we don't flush TLB, what makes
>> >> > the second CPU see the newly mapped shadow?
>> >>
>> >> /\/\/\/\/\/\
>> >>
>> >> Joonsoo, please answer this question above.
>> >
>> > Hello, I've answered it in another e-mail however it would not be
>> > sufficient. I try again.
>> >
>> > If the page isn't used for kernel stack, slab, and global variable
>> > (aka. kernel memory), black shadow is mapped for the page. We map a
>> > new shadow page if the page will be used for kernel memory. We need to
>> > flush TLB in all cpus when mapping a new shadow however it's not
>> > possible in some cases. So, this patch does just flushing local cpu's
>> > TLB. Another cpu could have stale TLB that points black shadow for
>> > this page. If that cpu with stale TLB try to check vailidity of the
>> > object on this page, result would be invalid since stale TLB points
>> > the black shadow and it's shadow value is non-zero. We need a magic
>> > here. At this moment, we cannot make sure if invalid is correct result
>> > or not since we didn't do full TLB flush. So fixup processing is
>> > started. It is implemented in check_memory_region_slow(). Flushing
>> > local TLB and re-checking the shadow value. With flushing local TLB,
>> > we will use fresh TLB at this time. Therefore, we can pass the
>> > validity check as usual.
>> >
>> >> I am trying to understand if there is any chance to make mapping a
>> >> single page for all non-interesting shadow ranges work. That would be
>> >
>> > This is what this patchset does. Mapping a single (zero/black) shadow
>> > page for all non-interesting (non-kernel memory) shadow ranges.
>> > There is only single instance of zero/black shadow page. On v1,
>> > I used black shadow page only so fail to get enough performance. On
>> > v2 mentioned in another thread, I use zero shadow for some region. I
>> > guess that performance problem would be gone.
>>
>>
>> I can't say I understand everything here, but after staring at the
>> patch I don't understand why we need pshadow at all now. Especially
>> with this commit
>> https://github.com/JoonsooKim/linux/commit/be36ee65f185e3c4026fe93b633056ea811120fb.
>> It seems that the current shadow is enough.
>
> pshadow exists for non-kernel memory like as page cache or anonymous page.
> This patch doesn't map a new shadow (per-byte shadow) for those pages
> to reduce memory consumption. However, we need to know if those page
> are allocated or not in order to check the validity of access to those
> page. We cannot utilize zero/black shadow page here since mapping
> single zero/black shadow page represents eight real page's shadow
> value. Instead, we use per-page shadow here and mark/unmark it when
> allocation and free happens. With it, we can know the state of the
> page and we can determine the validity of access to them.

I see the problem with 8 kernel pages mapped to a single shadow page.


>> If we see bad shadow when the actual shadow value is good, we fall
>> onto slow path, flush tlb, reload shadow, see that it is good and
>> return. Pshadow is not needed in this case.
>
> For the kernel memory, if we see bad shadow due to *stale TLB*, we
> fall onto slow path (check_memory_region_slow()) and flush tlb and
> reload shadow.
>
> For the non-kernel memory, if we see bad shadow, we fall onto
> pshadow_val() check and we can see actual state of the page.
>
>> If we see good shadow when the actual shadow value is bad, we return
>> immediately and get false negative. Pshadow is not involved as well.
>> What am I missing?
>
> In this patchset, there is no case that we see good shadow when the
> actual (p)shadow value is bad. This case should not happen since we
> can miss actual error.

But why is not it possible?
Let's say we have a real shadow page allocated for range of kernel
memory. Then we unmap the shadow page and map the back page (maybe
even unmap the black page and map another real shadow page). Then
another CPU reads shadow for this range. What prevents it from seeing
the old shadow page?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
