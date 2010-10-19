Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 197556B00CE
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 22:16:20 -0400 (EDT)
Received: by iwn1 with SMTP id 1so2023454iwn.14
        for <linux-mm@kvack.org>; Mon, 18 Oct 2010 19:16:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20101019105257.A1C6.A69D9226@jp.fujitsu.com>
References: <20101019102114.A1B9.A69D9226@jp.fujitsu.com>
	<AANLkTinU9qHEGgK5NDLi-zBSXJZmRDoZEnyLOHRYe8rd@mail.gmail.com>
	<20101019105257.A1C6.A69D9226@jp.fujitsu.com>
Date: Tue, 19 Oct 2010 11:16:17 +0900
Message-ID: <AANLkTi=1j5ejRyki+2wmKvOitorteW6uL53wfAWiPeAs@mail.gmail.com>
Subject: Re: Deadlock possibly caused by too_many_isolated.
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Neil Brown <neilb@suse.de>, Wu Fengguang <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Li, Shaohua" <shaohua.li@intel.com>
List-ID: <linux-mm.kvack.org>

On Tue, Oct 19, 2010 at 11:03 AM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>> On Tue, Oct 19, 2010 at 10:21 AM, KOSAKI Motohiro
>> <kosaki.motohiro@jp.fujitsu.com> wrote:
>> >> On Tue, Oct 19, 2010 at 9:57 AM, KOSAKI Motohiro
>> >> <kosaki.motohiro@jp.fujitsu.com> wrote:
>> >> >> > I think there are two bugs here.
>> >> >> > The raid1 bug that Torsten mentions is certainly real (and has b=
een around
>> >> >> > for an embarrassingly long time).
>> >> >> > The bug that I identified in too_many_isolated is also a real bu=
g and can be
>> >> >> > triggered without md/raid1 in the mix.
>> >> >> > So this is not a 'full fix' for every bug in the kernel :-), but=
 it could
>> >> >> > well be a full fix for this particular bug.
>> >> >> >
>> >> >>
>> >> >> Can we just delete the too_many_isolated() logic? =A0(Crappy comme=
nt
>> >> >> describes what the code does but not why it does it).
>> >> >
>> >> > if my remember is correct, we got bug report that LTP may makes mis=
terious
>> >> > OOM killer invocation about 1-2 years ago. because, if too many par=
ocess are in
>> >> > reclaim path, all of reclaimable pages can be isolated and last rec=
laimer found
>> >> > the system don't have any reclaimable pages and lead to invoke OOM =
killer.
>> >> > We have strong motivation to avoid false positive oom. then, some d=
iscusstion
>> >> > made this patch.
>> >> >
>> >> > if my remember is incorrect, I hope Wu or Rik fix me.
>> >>
>> >> AFAIR, it's right.
>> >>
>> >> How about this?
>> >>
>> >> It's rather aggressive throttling than old(ie, it considers not lru
>> >> type granularity but zone )
>> >> But I think it can prevent unnecessary OOM problem and solve deadlock=
 problem.
>> >
>> > Can you please elaborate your intention? Do you think Wu's approach is=
 wrong?
>>
>> No. I think Wu's patch may work well. But I agree Andrew.
>> Couldn't we remove the too_many_isolated logic? If it is, we can solve
>> the problem simply.
>> But If we remove the logic, we will meet long time ago problem, again.
>> So my patch's intention is to prevent OOM and deadlock problem with
>> simple patch without adding new heuristic in too_many_isolated.
>
> But your patch is much false positive/negative chance because isolated pa=
ges timing
> and too_many_isolated_zone() call site are in far distance place.

Yes.
How about the returning *did_some_progress can imply too_many_isolated
fail by using MSB or new variable?
Then, page_allocator can check it whether it causes read reclaim fail
or parallel reclaim.
The point is let's throttle without holding FS/IO lock.

> So, if anyone don't say Wu's one is wrong, I like his one.
>

I am not against it and just want to solve the problem without adding new l=
ogic.



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
