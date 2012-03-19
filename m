Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 5A8536B00F2
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 08:16:45 -0400 (EDT)
Message-ID: <4F672384.1030601@redhat.com>
Date: Mon, 19 Mar 2012 14:16:04 +0200
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 00/26] sched/numa
References: <20120316144028.036474157@chello.nl>   <4F670325.7080700@redhat.com> <1332155527.18960.292.camel@twins>  <4F671B90.3010209@redhat.com> <1332158992.18960.316.camel@twins>
In-Reply-To: <1332158992.18960.316.camel@twins>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Dan Smith <danms@us.ibm.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 03/19/2012 02:09 PM, Peter Zijlstra wrote:
> On Mon, 2012-03-19 at 13:42 +0200, Avi Kivity wrote:
> > > That's intentional, it keeps the work accounted to the tasks that need
> > > it.
> > 
> > The accounting part is good, the extra latency is not.  If you have
> > spare resources (processors or dma engines) you can employ for eager
> > migration why not make use of them.
>
> Afaik we do not use dma engines for memory migration. 

We don't, but I think we should.

> In any case, if you do cross-node migration frequently enough that the
> overhead of copying pages is a significant part of your time then I'm
> guessing there's something wrong.
>
> If not, the latency should be armortised enough to not matter.

Amortization is okay for HPC style applications but not for interactive
applications (including servers).  It all depends on the numbers of
course, maybe migrate on fault is okay, we'll need to measure it somehow.

> > > > - doesn't work with dma engines
> > >
> > > How does that work anyway? You'd have to reprogram your dma engine, so
> > > either the ->migratepage() callback does that and we're good either way,
> > > or it simply doesn't work at all.
> > 
> > If it's called from the faulting task's context you have to sleep, and
> > the latency gets increased even more, plus you're dependant on the dma
> > engine's backlog.  If you do all that from a background thread you don't
> > have to block (you might have to cancel or discard a migration if the
> > page was changed while being copied). 
>
> The current MoF implementation simply bails and uses the old page. It
> will never block.

Then it can not use a dma engine.

> Its all a best effort approach, a 'few' stray pages is OK as long as the
> bulk of the pages are local.
>
> If you're concerned, we can add per mm/vma counters to track this.

These are second and third order effects.  Overall I'm happy, kvm is one
of the workloads most severely impacted by the current numa support and
this looks like it addresses most of the issues.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
