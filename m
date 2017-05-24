Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f200.google.com (mail-ua0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7F8DB6B0292
	for <linux-mm@kvack.org>; Wed, 24 May 2017 13:20:12 -0400 (EDT)
Received: by mail-ua0-f200.google.com with SMTP id o93so10722051uao.2
        for <linux-mm@kvack.org>; Wed, 24 May 2017 10:20:12 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id r15sor1427940uae.28.2017.05.24.10.20.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 May 2017 10:20:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170524074539.GA9697@js1304-desktop>
References: <1494897409-14408-1-git-send-email-iamjoonsoo.kim@lge.com>
 <CACT4Y+ZVrs9XDk5QXkQyej+xFwKrgnGn-RPBC+pL5znUp2aSCg@mail.gmail.com>
 <20170516062318.GC16015@js1304-desktop> <CACT4Y+anOw8=7u-pZ2ceMw0xVnuaO9YKBJAr-2=KOYt_72b2pw@mail.gmail.com>
 <CACT4Y+YREmHViSMsH84bwtEqbUsqsgzaa76eWzJXqmSgqKbgvg@mail.gmail.com> <20170524074539.GA9697@js1304-desktop>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Wed, 24 May 2017 19:19:50 +0200
Message-ID: <CACT4Y+ZwL+iTMvF5NpsovThQrdhunCc282ffjqQcgZg3tAQH4w@mail.gmail.com>
Subject: Re: [PATCH v1 00/11] mm/kasan: support per-page shadow memory to
 reduce memory consumption
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, kernel-team@lge.com

On Wed, May 24, 2017 at 9:45 AM, Joonsoo Kim <js1304@gmail.com> wrote:
>> > What does make your current patch work then?
>> > Say we map a new shadow page, update the page shadow to say that there
>> > is mapped shadow. Then another CPU loads the page shadow and then
>> > loads from the newly mapped shadow. If we don't flush TLB, what makes
>> > the second CPU see the newly mapped shadow?
>>
>> /\/\/\/\/\/\
>>
>> Joonsoo, please answer this question above.
>
> Hello, I've answered it in another e-mail however it would not be
> sufficient. I try again.
>
> If the page isn't used for kernel stack, slab, and global variable
> (aka. kernel memory), black shadow is mapped for the page. We map a
> new shadow page if the page will be used for kernel memory. We need to
> flush TLB in all cpus when mapping a new shadow however it's not
> possible in some cases. So, this patch does just flushing local cpu's
> TLB. Another cpu could have stale TLB that points black shadow for
> this page. If that cpu with stale TLB try to check vailidity of the
> object on this page, result would be invalid since stale TLB points
> the black shadow and it's shadow value is non-zero. We need a magic
> here. At this moment, we cannot make sure if invalid is correct result
> or not since we didn't do full TLB flush. So fixup processing is
> started. It is implemented in check_memory_region_slow(). Flushing
> local TLB and re-checking the shadow value. With flushing local TLB,
> we will use fresh TLB at this time. Therefore, we can pass the
> validity check as usual.
>
>> I am trying to understand if there is any chance to make mapping a
>> single page for all non-interesting shadow ranges work. That would be
>
> This is what this patchset does. Mapping a single (zero/black) shadow
> page for all non-interesting (non-kernel memory) shadow ranges.
> There is only single instance of zero/black shadow page. On v1,
> I used black shadow page only so fail to get enough performance. On
> v2 mentioned in another thread, I use zero shadow for some region. I
> guess that performance problem would be gone.


I can't say I understand everything here, but after staring at the
patch I don't understand why we need pshadow at all now. Especially
with this commit
https://github.com/JoonsooKim/linux/commit/be36ee65f185e3c4026fe93b633056ea811120fb.
It seems that the current shadow is enough.
If we see bad shadow when the actual shadow value is good, we fall
onto slow path, flush tlb, reload shadow, see that it is good and
return. Pshadow is not needed in this case.
If we see good shadow when the actual shadow value is bad, we return
immediately and get false negative. Pshadow is not involved as well.
What am I missing?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
