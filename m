Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id E54F28D0012
	for <linux-mm@kvack.org>; Mon, 25 Oct 2010 00:00:04 -0400 (EDT)
Received: by qyk34 with SMTP id 34so1085192qyk.14
        for <linux-mm@kvack.org>; Sun, 24 Oct 2010 21:00:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20101025034833.GB15933@localhost>
References: <1287974851-4064-1-git-send-email-lliubbo@gmail.com>
	<20101025114017.86ee5e54.kamezawa.hiroyu@jp.fujitsu.com>
	<20101025025703.GA13858@localhost>
	<20101025120550.45745c3d.kamezawa.hiroyu@jp.fujitsu.com>
	<20101025120901.88fdbd17.kamezawa.hiroyu@jp.fujitsu.com>
	<20101025034833.GB15933@localhost>
Date: Mon, 25 Oct 2010 12:00:01 +0800
Message-ID: <AANLkTinBTRBZFbc3+rqdKy7Ls28MOWvO46gjZ7pYcRHg@mail.gmail.com>
Subject: Re: [PATCH] do_migrate_range: avoid failure as much as possible
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mel@csn.ul.ie" <mel@csn.ul.ie>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, Oct 25, 2010 at 11:48 AM, Wu Fengguang <fengguang.wu@intel.com> wro=
te:
> On Mon, Oct 25, 2010 at 11:09:01AM +0800, KAMEZAWA Hiroyuki wrote:
>> On Mon, 25 Oct 2010 12:05:50 +0900
>> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>>
>> > This changes behavior.
>> >
>> > This "ret" can be > 0 because migrate_page()'s return code is
>> > "Return: Number of pages not migrated or error code."
>> >
>> > Then,
>> > ret < 0 =C2=A0=3D=3D=3D> maybe ebusy
>> > ret > 0 =C2=A0=3D=3D=3D> some pages are not migrated. maybe PG_writeba=
ck or some
>> > ret =3D=3D 0 =3D=3D=3D> ok, all condition green. try next chunk soon.
>> >
>> > Then, I added "yield()" and --retrym_max for !ret cases.
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0^^^^^^^^
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 wrong.
>>
>> The code here does
>>
>> ret =3D=3D 0 =3D=3D> ok, all condition green, try next chunk.
>
> It seems reasonable to remove the drain operations for "ret =3D=3D 0"
> case. =C2=A0That would help large NUMA boxes noticeably I guess.
>
>> ret > 0 =C2=A0=3D=3D> all pages are isolated but some pages cannot be mi=
grated. maybe under I/O
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0do yield.
>
> Don't know how to deal with the possible "migration fail" pages --
> sorry I have no idea about that situation at all.
>
> Perhaps, OOM while offlining pages?
>
>> ret < 0 =C2=A0=3D=3D> some pages may not be able to be isolated. reduce =
retrycount and yield()
>
> Makes good sense.
>
> Thanks,
> Fengguang
>

Hi, Wu

What about acking these two patches first which doesn't change logic too mu=
ch.
[PATCH 2/3] do_migrate_range: exit loop if not_managed is true.
[PATCH 3/3] do_migrate_range: reduce list_empty() check.

For the current, I think more work&discussion is needed and make a
clean one is better.
Thanks.
--=20
Regards,
--Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
