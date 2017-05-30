Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9E03C6B02C3
	for <linux-mm@kvack.org>; Tue, 30 May 2017 03:58:33 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id p86so86010520pfl.12
        for <linux-mm@kvack.org>; Tue, 30 May 2017 00:58:33 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 64si12813262pft.307.2017.05.30.00.58.32
        for <linux-mm@kvack.org>;
        Tue, 30 May 2017 00:58:32 -0700 (PDT)
Subject: Re: [PATCH v1 00/11] mm/kasan: support per-page shadow memory to
 reduce memory consumption
References: <1494897409-14408-1-git-send-email-iamjoonsoo.kim@lge.com>
 <CACT4Y+ZVrs9XDk5QXkQyej+xFwKrgnGn-RPBC+pL5znUp2aSCg@mail.gmail.com>
 <20170516062318.GC16015@js1304-desktop>
 <CACT4Y+anOw8=7u-pZ2ceMw0xVnuaO9YKBJAr-2=KOYt_72b2pw@mail.gmail.com>
 <CACT4Y+YREmHViSMsH84bwtEqbUsqsgzaa76eWzJXqmSgqKbgvg@mail.gmail.com>
 <20170524074539.GA9697@js1304-desktop>
 <CACT4Y+ZwL+iTMvF5NpsovThQrdhunCc282ffjqQcgZg3tAQH4w@mail.gmail.com>
 <20170525004104.GA21336@js1304-desktop>
 <CACT4Y+YV7Rf93NOa1yi0NiELX7wfwkfQmXJ67hEVOrG7VkuJJg@mail.gmail.com>
 <CACT4Y+ZrUi_YGkwmbuGV2_6wC7Q54at1_xyYeT3dQQ=cNm1NsQ@mail.gmail.com>
 <CACT4Y+bT=aaC+XTMwoON-Rc5gOheAj702anXKJMXDJ5FtLDRMw@mail.gmail.com>
From: Vladimir Murzin <vladimir.murzin@arm.com>
Message-ID: <1131ff71-eb7a-8396-9a72-211f7077e5ec@arm.com>
Date: Tue, 30 May 2017 08:58:07 +0100
MIME-Version: 1.0
In-Reply-To: <CACT4Y+bT=aaC+XTMwoON-Rc5gOheAj702anXKJMXDJ5FtLDRMw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>, Joonsoo Kim <js1304@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, kernel-team@lge.com

On 29/05/17 16:29, Dmitry Vyukov wrote:
> I have an alternative proposal. It should be conceptually simpler and
> also less arch-dependent. But I don't know if I miss something
> important that will render it non working.
> Namely, we add a pointer to shadow to the page struct. Then, create a
> slab allocator for 512B shadow blocks. Then, attach/detach these
> shadow blocks to page structs as necessary. It should lead to even
> smaller memory consumption because we won't need a whole shadow page
> when only 1 out of 8 corresponding kernel pages are used (we will need
> just a single 512B block). I guess with some fragmentation we need
> lots of excessive shadow with the current proposed patch.
> This does not depend on TLB in any way and does not require hooking
> into buddy allocator.
> The main downside is that we will need to be careful to not assume
> that shadow is continuous. In particular this means that this mode
> will work only with outline instrumentation and will need some ifdefs.
> Also it will be slower due to the additional indirection when
> accessing shadow, but that's meant as "small but slow" mode as far as
> I understand.
> 
> But the main win as I see it is that that's basically complete support
> for 32-bit arches. People do ask about arm32 support:
> https://groups.google.com/d/msg/kasan-dev/Sk6BsSPMRRc/Gqh4oD_wAAAJ
> https://groups.google.com/d/msg/kasan-dev/B22vOFp-QWg/EVJPbrsgAgAJ
> and probably mips32 is relevant as well.
> Such mode does not require a huge continuous address space range, has
> minimal memory consumption and requires minimal arch-dependent code.
> Works only with outline instrumentation, but I think that's a
> reasonable compromise.

.. or you can just keep shadow in page extension. It was suggested back in
2015 [1], but seems that lack of stack instrumentation was "no-way"... 

[1] https://lkml.org/lkml/2015/8/24/573 

Cheers
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
