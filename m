Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 722126B006A
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 15:36:57 -0400 (EDT)
Received: by gxk12 with SMTP id 12so4681530gxk.4
        for <linux-mm@kvack.org>; Tue, 25 Aug 2009 12:36:58 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090824105139.c2ab8403.kamezawa.hiroyu@jp.fujitsu.com>
References: <82e12e5f0908220954p7019fb3dg15f9b99bb7e55a8c@mail.gmail.com>
	 <28c262360908231844o3df95b14v15b2d4424465f033@mail.gmail.com>
	 <20090824105139.c2ab8403.kamezawa.hiroyu@jp.fujitsu.com>
Date: Mon, 24 Aug 2009 13:13:56 +0900
Message-ID: <2f11576a0908232113w71676aatf22eb6d431501fd0@mail.gmail.com>
Subject: Re: [PATCH] mm: make munlock fast when mlock is canceled by sigkill
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Hiroaki Wakabayashi <primulaelatior@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Paul Menage <menage@google.com>, Ying Han <yinghan@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Lee Schermerhorn <lee.schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

> This patch is for making commit 4779280d1e (mm: make get_user_pages()
> interruptible) complete.

Yes.
commit 4779280d1e (mm: make get_user_pages() interruptible) has never
works as expected since it's born.
IOW, it was totally broken.

This patch is definitely good forward step patch.


>> > @@ -254,6 +254,7 @@ static inline void
>> > mminit_validate_memmodel_limits(unsigned long *start_pfn,
>> > =A0#define GUP_FLAGS_FORCE =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A00x2
>> > =A0#define GUP_FLAGS_IGNORE_VMA_PERMISSIONS 0x4
>> > =A0#define GUP_FLAGS_IGNORE_SIGKILL =A0 =A0 =A0 =A0 0x8
>> > +#define GUP_FLAGS_ALLOW_NULL =A0 =A0 =A0 =A0 =A0 =A0 0x10
>> >
>>
>> I am worried about adding new flag whenever we need it.
>> But I think this case makes sense to me.
>> In addition, I guess ZERO page can also use this flag.
>>
>> Kame. What do you think about it?
>>
> I do welcome this !
> Then, I don't have to take care of mlock/munlock in ZERO_PAGE patch.
>
> And without this patch, munlock() does copy-on-write just for unpinning m=
emory.
> So, this patch shows some right direction, I think.
>
> One concern is flag name, ALLOW_NULL sounds not very good.
>
> =A0GUP_FLAGS_NOFAULT ?
>
> I wonder we can remove a hack of FOLL_ANON for core-dump by this flag, to=
o.

Yeah, GUP_FLAGS_NOFAULT is better.

Plus, this patch change __get_user_pages() return value meaning IOW.
after this patch, it can return following value,

 return value: 3
 pages[0]: hoge-page
 pages[1]: null
 pages[2]: fuga-page

but, it can be

 return value: 2
 pages[0]: hoge-page
 pages[1]: fuga-page

no?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
