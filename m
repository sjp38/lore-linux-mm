Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id B31BA6B00CE
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 23:13:57 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9J3DsVq008351
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 19 Oct 2010 12:13:54 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3999D45DE7D
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 12:13:54 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id F2DCF45DE7B
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 12:13:53 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9DFD91DB803B
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 12:13:53 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 383CAEF8003
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 12:13:53 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: Deadlock possibly caused by too_many_isolated.
In-Reply-To: <AANLkTinvcGjF2-dvu8kpDY4V7kGkRJjHTWDtQPNRKMU_@mail.gmail.com>
References: <20101019030515.GB11924@localhost> <AANLkTinvcGjF2-dvu8kpDY4V7kGkRJjHTWDtQPNRKMU_@mail.gmail.com>
Message-Id: <20101019121321.A1E1.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Date: Tue, 19 Oct 2010 12:13:52 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Neil Brown <neilb@suse.de>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Li, Shaohua" <shaohua.li@intel.com>
List-ID: <linux-mm.kvack.org>

> On Tue, Oct 19, 2010 at 12:05 PM, Wu Fengguang <fengguang.wu@intel.com> w=
rote:
> > On Tue, Oct 19, 2010 at 10:52:47AM +0800, Minchan Kim wrote:
> >> Hi Wu,
> >>
> >> On Tue, Oct 19, 2010 at 11:35 AM, Wu Fengguang <fengguang.wu@intel.com=
> wrote:
> >> >> @@ -2054,10 +2069,11 @@ rebalance:
> >> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto got_pg;
> >> >>
> >> >> =A0 =A0 =A0 =A0 /*
> >> >> - =A0 =A0 =A0 =A0* If we failed to make any progress reclaiming, th=
en we are
> >> >> - =A0 =A0 =A0 =A0* running out of options and have to consider goin=
g OOM
> >> >> + =A0 =A0 =A0 =A0* If we failed to make any progress reclaiming and=
 there aren't
> >> >> + =A0 =A0 =A0 =A0* many parallel reclaiming, then we are unning out=
 of options and
> >> >> + =A0 =A0 =A0 =A0* have to consider going OOM
> >> >> =A0 =A0 =A0 =A0 =A0*/
> >> >> - =A0 =A0 =A0 if (!did_some_progress) {
> >> >> + =A0 =A0 =A0 if (!did_some_progress && !too_many_isolated_zone(pre=
ferred_zone)) {
> >> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if ((gfp_mask & __GFP_FS) && !(gfp_=
mask & __GFP_NORETRY)) {
> >> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (oom_killer_disa=
bled)
> >> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 got=
o nopage;
> >> >
> >> > This is simply wrong.
> >> >
> >> > It disabled this block for 99% system because there won't be enough
> >> > tasks to make (!too_many_isolated_zone =3D=3D true). As a result the=
 LRU
> >> > will be scanned like mad and no task get OOMed when it should be.
> >>
> >> If !too_many_isolated_zone is false, it means there are already many
> >> direct reclaiming tasks.
> >> So they could exit reclaim path and !too_many_isolated_zone will be tr=
ue.
> >> What am I missing now?
> >
> > Ah sorry, my brain get short circuited.. but I still feel uneasy with
> > this change. It's not fixing the root cause and won't prevent too many
> > LRU pages be isolated. It's too late to test too_many_isolated_zone()
> > after direct reclaim returns (after sleeping for a long time).
> >
>=20
> Intend to agree.
> I think root cause is a infinite looping in too_many_isolated holding FS =
lock.
> Would it be simple that too_many_isolated would be bail out after some tr=
y?

How?
A lot of caller don't have good recover logic when memory allocation fail o=
ccur.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
