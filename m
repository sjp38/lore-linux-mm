Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f70.google.com (mail-vk0-f70.google.com [209.85.213.70])
	by kanga.kvack.org (Postfix) with ESMTP id E87166B0279
	for <linux-mm@kvack.org>; Tue, 30 May 2017 05:27:17 -0400 (EDT)
Received: by mail-vk0-f70.google.com with SMTP id c185so18700628vkd.13
        for <linux-mm@kvack.org>; Tue, 30 May 2017 02:27:17 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 76sor1740311vkf.33.2017.05.30.02.27.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 30 May 2017 02:27:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <35288874-d800-f534-13bf-4261167ff1bd@arm.com>
References: <1494897409-14408-1-git-send-email-iamjoonsoo.kim@lge.com>
 <CACT4Y+ZVrs9XDk5QXkQyej+xFwKrgnGn-RPBC+pL5znUp2aSCg@mail.gmail.com>
 <20170516062318.GC16015@js1304-desktop> <CACT4Y+anOw8=7u-pZ2ceMw0xVnuaO9YKBJAr-2=KOYt_72b2pw@mail.gmail.com>
 <CACT4Y+YREmHViSMsH84bwtEqbUsqsgzaa76eWzJXqmSgqKbgvg@mail.gmail.com>
 <20170524074539.GA9697@js1304-desktop> <CACT4Y+ZwL+iTMvF5NpsovThQrdhunCc282ffjqQcgZg3tAQH4w@mail.gmail.com>
 <20170525004104.GA21336@js1304-desktop> <CACT4Y+YV7Rf93NOa1yi0NiELX7wfwkfQmXJ67hEVOrG7VkuJJg@mail.gmail.com>
 <CACT4Y+ZrUi_YGkwmbuGV2_6wC7Q54at1_xyYeT3dQQ=cNm1NsQ@mail.gmail.com>
 <CACT4Y+bT=aaC+XTMwoON-Rc5gOheAj702anXKJMXDJ5FtLDRMw@mail.gmail.com>
 <1131ff71-eb7a-8396-9a72-211f7077e5ec@arm.com> <CACT4Y+b-EB19HU+=Uj=EXx5-S9sBAnqRKcCDk+TVYEkKcH6Tfw@mail.gmail.com>
 <b6a95df3-902c-befa-808b-bdbd1d33175c@arm.com> <2d35bbe9-e833-1bf3-ecd0-a02da63b381a@arm.com>
 <CACT4Y+YkEMPe3uZmPO+HmpAk6JckdiGhxWq=7i8t2WG2efZgZw@mail.gmail.com> <35288874-d800-f534-13bf-4261167ff1bd@arm.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Tue, 30 May 2017 11:26:55 +0200
Message-ID: <CACT4Y+b4x47HZJUPqeGeVHpZcDie1zgC71mbZKd-y+k0Znb3Xg@mail.gmail.com>
Subject: Re: [PATCH v1 00/11] mm/kasan: support per-page shadow memory to
 reduce memory consumption
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Murzin <vladimir.murzin@arm.com>
Cc: Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, kernel-team@lge.com

On Tue, May 30, 2017 at 11:08 AM, Vladimir Murzin
<vladimir.murzin@arm.com> wrote:
>> <vladimir.murzin@arm.com> wrote:
>>> On 30/05/17 09:31, Vladimir Murzin wrote:
>>>> [This sender failed our fraud detection checks and may not be who they appear to be. Learn about spoofing at http://aka.ms/LearnAboutSpoofing]
>>>>
>>>> On 30/05/17 09:15, Dmitry Vyukov wrote:
>>>>> On Tue, May 30, 2017 at 9:58 AM, Vladimir Murzin
>>>>> <vladimir.murzin@arm.com> wrote:
>>>>>> On 29/05/17 16:29, Dmitry Vyukov wrote:
>>>>>>> I have an alternative proposal. It should be conceptually simpler and
>>>>>>> also less arch-dependent. But I don't know if I miss something
>>>>>>> important that will render it non working.
>>>>>>> Namely, we add a pointer to shadow to the page struct. Then, create a
>>>>>>> slab allocator for 512B shadow blocks. Then, attach/detach these
>>>>>>> shadow blocks to page structs as necessary. It should lead to even
>>>>>>> smaller memory consumption because we won't need a whole shadow page
>>>>>>> when only 1 out of 8 corresponding kernel pages are used (we will need
>>>>>>> just a single 512B block). I guess with some fragmentation we need
>>>>>>> lots of excessive shadow with the current proposed patch.
>>>>>>> This does not depend on TLB in any way and does not require hooking
>>>>>>> into buddy allocator.
>>>>>>> The main downside is that we will need to be careful to not assume
>>>>>>> that shadow is continuous. In particular this means that this mode
>>>>>>> will work only with outline instrumentation and will need some ifdefs.
>>>>>>> Also it will be slower due to the additional indirection when
>>>>>>> accessing shadow, but that's meant as "small but slow" mode as far as
>>>>>>> I understand.
>>>>>>>
>>>>>>> But the main win as I see it is that that's basically complete support
>>>>>>> for 32-bit arches. People do ask about arm32 support:
>>>>>>> https://groups.google.com/d/msg/kasan-dev/Sk6BsSPMRRc/Gqh4oD_wAAAJ
>>>>>>> https://groups.google.com/d/msg/kasan-dev/B22vOFp-QWg/EVJPbrsgAgAJ
>>>>>>> and probably mips32 is relevant as well.
>>>>>>> Such mode does not require a huge continuous address space range, has
>>>>>>> minimal memory consumption and requires minimal arch-dependent code.
>>>>>>> Works only with outline instrumentation, but I think that's a
>>>>>>> reasonable compromise.
>>>>>>
>>>>>> .. or you can just keep shadow in page extension. It was suggested back in
>>>>>> 2015 [1], but seems that lack of stack instrumentation was "no-way"...
>>>>>>
>>>>>> [1] https://lkml.org/lkml/2015/8/24/573
>>>>>
>>>>> Right. It describes basically the same idea.
>>>>>
>>>>> How is page_ext better than adding data page struct?
>>>>
>>>> page_ext is already here along with some other debug options ;)
>>
>>
>> But page struct is also here. What am I missing?
>>
>
> Probably, free room in page struct? I guess most of the page_ext stuff would
> love to live in page struct, but... for instance, look at page idle tracking
> which has to live in page_ext only for 32-bit.


Sorry for my ignorance. What's the fundamental problem with just
pushing everything into page struct?

I don't see anything relevant in page struct comment. Nor I see "idle"
nor "tracking" page struct. I see only 2 mentions of CONFIG_64BIT, but
both declare the same fields just with different types (int vs short).



>>>>> It seems that memory for all page_ext is preallocated along with page
>>>>> structs; but just the lookup is slower.
>>>>>
>>>>
>>>> Yup. Lookup would look like (based on v4.0):
>>>>
>>>> ...
>>>> page_ext = lookup_page_ext_begin(virt_to_page(start));
>>>>
>>>> do {
>>>>         page_ext->shadow[idx++] = value;
>>>> } while (idx < bound);
>>>>
>>>> lookup_page_ext_end((void *)page_ext);
>>>>
>>>> ...
>>>
>>> Correction: please, ignore that *_{begin,end} stuff - mainline only
>>> lookup_page_ext() is only used.
>>
>>
>> Note that this added code will be executed during handling of each and
>> every memory access in kernel. Every instruction matters on that path.
>
> I know, I know... still better than nothing.
>
>> The additional indirection via page struct will also slow down it, but
>> that's the cost for lower memory consumption and potentially 32-bit
>> support. For page_ext it looks like even more overhead for no gain.
>>
>
> eefa864 (mm/page_ext: resurrect struct page extending code for debugging)
> express some cases where keeping data in page_ext has benefit.
>
> Cheers
> Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
