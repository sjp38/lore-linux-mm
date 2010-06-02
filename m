Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id C9D936B01B2
	for <linux-mm@kvack.org>; Wed,  2 Jun 2010 09:54:05 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o52Ds2aU021491
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 2 Jun 2010 22:54:03 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id AFEA945DE4F
	for <linux-mm@kvack.org>; Wed,  2 Jun 2010 22:54:02 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7BF3C45DE51
	for <linux-mm@kvack.org>; Wed,  2 Jun 2010 22:54:02 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3923DE08008
	for <linux-mm@kvack.org>; Wed,  2 Jun 2010 22:54:02 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id D374DE08005
	for <linux-mm@kvack.org>; Wed,  2 Jun 2010 22:54:01 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC] oom-kill: give the dying task a higher priority
In-Reply-To: <alpine.DEB.2.00.1006011347060.13136@chino.kir.corp.google.com>
References: <20100601173535.GD23428@uudg.org> <alpine.DEB.2.00.1006011347060.13136@chino.kir.corp.google.com>
Message-Id: <20100602220429.F51E.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Date: Wed,  2 Jun 2010 22:54:01 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, "Luis Claudio R. Goncalves" <lclaudio@uudg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, balbir@linux.vnet.ibm.com, Oleg Nesterov <oleg@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mel@csn.ul.ie>, williams@redhat.com
List-ID: <linux-mm.kvack.org>

> > @@ -291,9 +309,10 @@ static struct task_struct *select_bad_process(unsi=
gned long *ppoints,
> >  		 * Otherwise we could get an easy OOM deadlock.
> >  		 */
> >  		if (p->flags & PF_EXITING) {
> > -			if (p !=3D current)
> > +			if (p !=3D current) {
> > +				boost_dying_task_prio(p, mem);
> >  				return ERR_PTR(-1UL);
> > -
> > +			}
> >  			chosen =3D p;
> >  			*ppoints =3D ULONG_MAX;
> >  		}
>=20
> This has the potential to actually make it harder to free memory if p is=
=20
> waiting to acquire a writelock on mm->mmap_sem in the exit path while the=
=20
> thread holding mm->mmap_sem is trying to run.

if p is waiting, changing prio have no effect. It continue tol wait to rele=
ase mmap_sem.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
