Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id BD5B26B0279
	for <linux-mm@kvack.org>; Tue, 30 May 2017 04:31:44 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id a66so86996054pfl.6
        for <linux-mm@kvack.org>; Tue, 30 May 2017 01:31:44 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 11si12995877pfj.272.2017.05.30.01.31.43
        for <linux-mm@kvack.org>;
        Tue, 30 May 2017 01:31:43 -0700 (PDT)
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
 <1131ff71-eb7a-8396-9a72-211f7077e5ec@arm.com>
 <CACT4Y+b-EB19HU+=Uj=EXx5-S9sBAnqRKcCDk+TVYEkKcH6Tfw@mail.gmail.com>
From: Vladimir Murzin <vladimir.murzin@arm.com>
Message-ID: <b6a95df3-902c-befa-808b-bdbd1d33175c@arm.com>
Date: Tue, 30 May 2017 09:31:38 +0100
MIME-Version: 1.0
In-Reply-To: <CACT4Y+b-EB19HU+=Uj=EXx5-S9sBAnqRKcCDk+TVYEkKcH6Tfw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, kernel-team@lge.com

On 30/05/17 09:15, Dmitry Vyukov wrote:
> On Tue, May 30, 2017 at 9:58 AM, Vladimir Murzin
> <vladimir.murzin@arm.com> wrote:
>> On 29/05/17 16:29, Dmitry Vyukov wrote:
>>> I have an alternative proposal. It should be conceptually simpler and
>>> also less arch-dependent. But I don't know if I miss something
>>> important that will render it non working.
>>> Namely, we add a pointer to shadow to the page struct. Then, create a
>>> slab allocator for 512B shadow blocks. Then, attach/detach these
>>> shadow blocks to page structs as necessary. It should lead to even
>>> smaller memory consumption because we won't need a whole shadow page
>>> when only 1 out of 8 corresponding kernel pages are used (we will need
>>> just a single 512B block). I guess with some fragmentation we need
>>> lots of excessive shadow with the current proposed patch.
>>> This does not depend on TLB in any way and does not require hooking
>>> into buddy allocator.
>>> The main downside is that we will need to be careful to not assume
>>> that shadow is continuous. In particular this means that this mode
>>> will work only with outline instrumentation and will need some ifdefs.
>>> Also it will be slower due to the additional indirection when
>>> accessing shadow, but that's meant as "small but slow" mode as far as
>>> I understand.
>>>
>>> But the main win as I see it is that that's basically complete support
>>> for 32-bit arches. People do ask about arm32 support:
>>> https://groups.google.com/d/msg/kasan-dev/Sk6BsSPMRRc/Gqh4oD_wAAAJ
>>> https://groups.google.com/d/msg/kasan-dev/B22vOFp-QWg/EVJPbrsgAgAJ
>>> and probably mips32 is relevant as well.
>>> Such mode does not require a huge continuous address space range, has
>>> minimal memory consumption and requires minimal arch-dependent code.
>>> Works only with outline instrumentation, but I think that's a
>>> reasonable compromise.
>>
>> .. or you can just keep shadow in page extension. It was suggested back in
>> 2015 [1], but seems that lack of stack instrumentation was "no-way"...
>>
>> [1] https://lkml.org/lkml/2015/8/24/573
> 
> Right. It describes basically the same idea.
> 
> How is page_ext better than adding data page struct?

page_ext is already here along with some other debug options ;)

> It seems that memory for all page_ext is preallocated along with page
> structs; but just the lookup is slower.
> 

Yup. Lookup would look like (based on v4.0):

...
page_ext = lookup_page_ext_begin(virt_to_page(start));

do {
	page_ext->shadow[idx++] = value;
} while (idx < bound);

lookup_page_ext_end((void *)page_ext);

...

Cheers
Vladimir


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
