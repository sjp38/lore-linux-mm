Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 4958A6B004A
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 11:45:42 -0400 (EDT)
Message-ID: <4F67546A.9060803@redhat.com>
Date: Mon, 19 Mar 2012 17:44:42 +0200
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 00/26] sched/numa
References: <20120316144028.036474157@chello.nl>   <4F670325.7080700@redhat.com> <1332155527.18960.292.camel@twins>  <4F671B90.3010209@redhat.com> <1332159657.18960.321.camel@twins> <4F67257F.4030803@redhat.com>
In-Reply-To: <4F67257F.4030803@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Dan Smith <danms@us.ibm.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 03/19/2012 02:24 PM, Avi Kivity wrote:
> On 03/19/2012 02:20 PM, Peter Zijlstra wrote:
> > On Mon, 2012-03-19 at 13:42 +0200, Avi Kivity wrote:
> > > It's the standard space/time tradeoff.  Once solution wants more
> > > storage, the other wants more faults.
> > > 
> > > Note scanners can use A/D bits which are cheaper than faults.
> >
> > I'm not convinced.. the scanner will still consume time even if the
> > system is perfectly balanced -- it has to in order to determine this.
> >
> > So sure, A/D/other page table magic can make scanners faster than faults
> > however you only need faults when you're actually going to migrate a
> > task. Whereas you always need to scan, even in the stable state.
> >
> > So while the per-instance times might be in favour of scanning, I'm
> > thinking the accumulated time is in favour of faults.
>
> When you migrate a vnode, you don't need the faults at all.  You know
> exactly which pages need to be migrated, you can just queue them
> immediately when you make that decision.
>
> The scanning therefore only needs to pick up the stragglers and can be
> set to a very low frequency.

Running the numbers, 4GB = 1Mpages, at 2us per page migration that's 2
seconds to migrate an entire process, perhaps 2x-3x that for kvm.  So as
long numa balancing happens at a lower frequency than once every few
minutes, the gains should be higher than the loss.  If those numbers are
not too wrong then migrate on fault should be a win.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
