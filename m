Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1323B8D0039
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 20:31:15 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id CFFF33EE0BB
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 10:24:53 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id B6C5D45DE55
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 10:24:53 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id A1AB045DE51
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 10:24:53 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9486FE78002
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 10:24:53 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5F1D01DB803B
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 10:24:53 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] mm: skip zombie in OOM-killer
In-Reply-To: <AANLkTi=d+eZxg_NgNWa7roo=1YQS06=EaWJzjseL_Hhs@mail.gmail.com>
References: <alpine.DEB.2.00.1103061400170.23737@chino.kir.corp.google.com> <AANLkTi=d+eZxg_NgNWa7roo=1YQS06=EaWJzjseL_Hhs@mail.gmail.com>
Message-Id: <20110308102147.7E96.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Date: Tue,  8 Mar 2011 10:24:52 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Vagin <avagin@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, David Rientjes <rientjes@google.com>, Andrey Vagin <avagin@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

> 2011/3/7 David Rientjes <rientjes@google.com>:
> > On Sun, 6 Mar 2011, KOSAKI Motohiro wrote:
> >
> >> > When we check that task has flag TIF_MEMDIE, we forgot check that
> >> > it has mm. A task may be zombie and a parent may wait a memor.
> >> >
> >> > v2: Check that task doesn't have mm one time and skip it immediately
> >> >
> >> > Signed-off-by: Andrey Vagin <avagin@openvz.org>
> >>
> >> This seems incorrect. Do you have a reprodusable testcasae?
> >> Your patch only care thread group leader state, but current code
> >> care all thread in the process. Please look at oom_badness() and
> >> find_lock_task_mm().
> >>
> >
> > That's all irrelevant, the test for TIF_MEMDIE specifically makes the o=
om
> > killer a complete no-op when an eligible task is found to have been oom
> > killed to prevent needlessly killing additional tasks. =A0oom_badness()=
 and
> > find_lock_task_mm() have nothing to do with that check to return
> > ERR_PTR(-1UL) from select_bad_process().
> >
> > Andrey is patching the case where an eligible TIF_MEMDIE process is fou=
nd
> > but it has already detached its ->mm. =A0In combination with the patch
> > posted to linux-mm, oom: prevent unnecessary oom kills or kernel panics=
,
> > which makes select_bad_process() iterate over all threads, it is an
> > effective solution.
>=20
> Probably you said about the first version of my patch.
> This version is incorrect because of
> http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.git;a=3Dco=
mmit;h=3Ddd8e8f405ca386c7ce7cbb996ccd985d283b0e03
>=20
> but my first patch is correct and it has a simple reproducer(I
> attached it). You can execute it and your kernel hangs up, because the
> parent doesn't wait children, but the one child (zombie) will have
> flag TIF_MEMDIE, oom_killer will kill nobody
>=20
>=20
> The link on the first patch:
> http://groups.google.com/group/linux.kernel/browse_thread/thread/b9c6ddf3=
4d1671ab/2941e1877ca4f626?lnk=3Draot&pli=3D1

OK. I can ack this.
TIF_MEMDIE  mean the process have been receive SIGKILL therefore we can ass=
ume it
as per process flag.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
