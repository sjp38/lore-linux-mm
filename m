Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id B93DF6B00B6
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 22:03:40 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9J23bv5008811
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 19 Oct 2010 11:03:37 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id E334445DE6F
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 11:03:36 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id A4AA945DE7A
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 11:03:36 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 66AA6EF8006
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 11:03:36 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 05FFBEF800A
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 11:03:36 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: Deadlock possibly caused by too_many_isolated.
In-Reply-To: <AANLkTinU9qHEGgK5NDLi-zBSXJZmRDoZEnyLOHRYe8rd@mail.gmail.com>
References: <20101019102114.A1B9.A69D9226@jp.fujitsu.com> <AANLkTinU9qHEGgK5NDLi-zBSXJZmRDoZEnyLOHRYe8rd@mail.gmail.com>
Message-Id: <20101019105257.A1C6.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Date: Tue, 19 Oct 2010 11:03:35 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Neil Brown <neilb@suse.de>, Wu Fengguang <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Li, Shaohua" <shaohua.li@intel.com>
List-ID: <linux-mm.kvack.org>

> On Tue, Oct 19, 2010 at 10:21 AM, KOSAKI Motohiro
> <kosaki.motohiro@jp.fujitsu.com> wrote:
> >> On Tue, Oct 19, 2010 at 9:57 AM, KOSAKI Motohiro
> >> <kosaki.motohiro@jp.fujitsu.com> wrote:
> >> >> > I think there are two bugs here.
> >> >> > The raid1 bug that Torsten mentions is certainly real (and has be=
en around
> >> >> > for an embarrassingly long time).
> >> >> > The bug that I identified in too_many_isolated is also a real bug=
 and can be
> >> >> > triggered without md/raid1 in the mix.
> >> >> > So this is not a 'full fix' for every bug in the kernel :-), but =
it could
> >> >> > well be a full fix for this particular bug.
> >> >> >
> >> >>
> >> >> Can we just delete the too_many_isolated() logic? =A0(Crappy commen=
t
> >> >> describes what the code does but not why it does it).
> >> >
> >> > if my remember is correct, we got bug report that LTP may makes mist=
erious
> >> > OOM killer invocation about 1-2 years ago. because, if too many paro=
cess are in
> >> > reclaim path, all of reclaimable pages can be isolated and last recl=
aimer found
> >> > the system don't have any reclaimable pages and lead to invoke OOM k=
iller.
> >> > We have strong motivation to avoid false positive oom. then, some di=
scusstion
> >> > made this patch.
> >> >
> >> > if my remember is incorrect, I hope Wu or Rik fix me.
> >>
> >> AFAIR, it's right.
> >>
> >> How about this?
> >>
> >> It's rather aggressive throttling than old(ie, it considers not lru
> >> type granularity but zone )
> >> But I think it can prevent unnecessary OOM problem and solve deadlock =
problem.
> >
> > Can you please elaborate your intention? Do you think Wu's approach is =
wrong?
>=20
> No. I think Wu's patch may work well. But I agree Andrew.
> Couldn't we remove the too_many_isolated logic? If it is, we can solve
> the problem simply.
> But If we remove the logic, we will meet long time ago problem, again.
> So my patch's intention is to prevent OOM and deadlock problem with
> simple patch without adding new heuristic in too_many_isolated.

But your patch is much false positive/negative chance because isolated page=
s timing=20
and too_many_isolated_zone() call site are in far distance place.
So, if anyone don't say Wu's one is wrong, I like his one.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
