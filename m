Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 800596B00E8
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 08:10:25 -0400 (EDT)
Message-ID: <1332158992.18960.316.camel@twins>
Subject: Re: [RFC][PATCH 00/26] sched/numa
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Mon, 19 Mar 2012 13:09:52 +0100
In-Reply-To: <4F671B90.3010209@redhat.com>
References: <20120316144028.036474157@chello.nl>
	  <4F670325.7080700@redhat.com> <1332155527.18960.292.camel@twins>
	 <4F671B90.3010209@redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Avi Kivity <avi@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E.
 McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Dan Smith <danms@us.ibm.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 2012-03-19 at 13:42 +0200, Avi Kivity wrote:
> > That's intentional, it keeps the work accounted to the tasks that need
> > it.
>=20
> The accounting part is good, the extra latency is not.  If you have
> spare resources (processors or dma engines) you can employ for eager
> migration why not make use of them.

Afaik we do not use dma engines for memory migration.=20

In any case, if you do cross-node migration frequently enough that the
overhead of copying pages is a significant part of your time then I'm
guessing there's something wrong.

If not, the latency should be armortised enough to not matter.

> > > - doesn't work with dma engines
> >
> > How does that work anyway? You'd have to reprogram your dma engine, so
> > either the ->migratepage() callback does that and we're good either way=
,
> > or it simply doesn't work at all.
>=20
> If it's called from the faulting task's context you have to sleep, and
> the latency gets increased even more, plus you're dependant on the dma
> engine's backlog.  If you do all that from a background thread you don't
> have to block (you might have to cancel or discard a migration if the
> page was changed while being copied).=20

The current MoF implementation simply bails and uses the old page. It
will never block.

Its all a best effort approach, a 'few' stray pages is OK as long as the
bulk of the pages are local.

If you're concerned, we can add per mm/vma counters to track this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
