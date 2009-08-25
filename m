Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 7C9A86B00F4
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 19:31:38 -0400 (EDT)
Received: by iwn13 with SMTP id 13so1315227iwn.12
        for <linux-mm@kvack.org>; Tue, 25 Aug 2009 16:31:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <2f11576a0908232113w71676aatf22eb6d431501fd0@mail.gmail.com>
References: <82e12e5f0908220954p7019fb3dg15f9b99bb7e55a8c@mail.gmail.com>
	 <28c262360908231844o3df95b14v15b2d4424465f033@mail.gmail.com>
	 <20090824105139.c2ab8403.kamezawa.hiroyu@jp.fujitsu.com>
	 <2f11576a0908232113w71676aatf22eb6d431501fd0@mail.gmail.com>
Date: Tue, 25 Aug 2009 13:46:19 +0900
Message-ID: <82e12e5f0908242146uad0f314hcbb02fcc999a1d32@mail.gmail.com>
Subject: Re: [PATCH] mm: make munlock fast when mlock is canceled by sigkill
From: Hiroaki Wakabayashi <primulaelatior@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Paul Menage <menage@google.com>, Ying Han <yinghan@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Lee Schermerhorn <lee.schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

Thank you for reviews.

>>> > @@ -254,6 +254,7 @@ static inline void
>>> > mminit_validate_memmodel_limits(unsigned long *start_pfn,
>>> > =A0#define GUP_FLAGS_FORCE =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A00x2
>>> > =A0#define GUP_FLAGS_IGNORE_VMA_PERMISSIONS 0x4
>>> > =A0#define GUP_FLAGS_IGNORE_SIGKILL =A0 =A0 =A0 =A0 0x8
>>> > +#define GUP_FLAGS_ALLOW_NULL =A0 =A0 =A0 =A0 =A0 =A0 0x10
>>> >
>>>
>>> I am worried about adding new flag whenever we need it.
>>> But I think this case makes sense to me.
>>> In addition, I guess ZERO page can also use this flag.
>>>
>>> Kame. What do you think about it?
>>>
>> I do welcome this !
>> Then, I don't have to take care of mlock/munlock in ZERO_PAGE patch.
>>
>> And without this patch, munlock() does copy-on-write just for unpinning =
memory.
>> So, this patch shows some right direction, I think.
>>
>> One concern is flag name, ALLOW_NULL sounds not very good.
>>
>> =A0GUP_FLAGS_NOFAULT ?
>>
>> I wonder we can remove a hack of FOLL_ANON for core-dump by this flag, t=
oo.
>
> Yeah, GUP_FLAGS_NOFAULT is better.

Me too.
I will change this flag name.

> Plus, this patch change __get_user_pages() return value meaning IOW.
> after this patch, it can return following value,
>
> =A0return value: 3
> =A0pages[0]: hoge-page
> =A0pages[1]: null
> =A0pages[2]: fuga-page
>
> but, it can be
>
> =A0return value: 2
> =A0pages[0]: hoge-page
> =A0pages[1]: fuga-page
>
> no?

I did misunderstand mean of get_user_pages()'s return value.

When I try to change __get_user_pages(), I got problem.
If remove NULLs from pages,
__mlock_vma_pages_range() cannot know how long __get_user_pages() readed.
So, I have to get the virtual address of the page from vma and page.
Because __mlock_vma_pages_range() have to call
__get_user_pages() many times with different `start' argument.

I try to use page_address_in_vma(), but it failed.
(page_address_in_vma() returned -EFAULT)
I cannot find way to solve this problem.
Are there good ideas?
Please give me some ideas.

Thanks.
--
Hiroaki Wakabayashi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
