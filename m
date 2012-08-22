Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 3F5EE6B0068
	for <linux-mm@kvack.org>; Wed, 22 Aug 2012 18:20:13 -0400 (EDT)
Date: Thu, 23 Aug 2012 00:19:31 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 00/36] AutoNUMA24
Message-ID: <20120822221931.GE8107@redhat.com>
References: <1345647560-30387-1-git-send-email-aarcange@redhat.com>
 <5035325C.3070909@redhat.com>
 <20120822214048.GA3092@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120822214048.GA3092@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

On Wed, Aug 22, 2012 at 11:40:48PM +0200, Ingo Molnar wrote:
> 
> * Rik van Riel <riel@redhat.com> wrote:
> 
> > On 08/22/2012 10:58 AM, Andrea Arcangeli wrote:
> > >Hello everyone,
> > >
> > >Before the Kernel Summit, I think it's good idea to post a new
> > >AutoNUMA24 and to go through a new review cycle. The last review cycle
> > >has been fundamental in improving the patchset. Thanks!
> > 
> > Thanks for improving the code and incorporating all our 
> > feedback. The AutoNUMA codebase is now in a state where I can 
> > live with it.
> > 
> > I hope the code will be acceptable to others, too.
> 
> Lots of scheduler changes. Has all of peterz's review feedback 
> been addressed?

git diff --stat origin kernel/sched/
 kernel/sched/Makefile |    1 +
 kernel/sched/core.c   |    1 +
 kernel/sched/fair.c   |   86 ++++++-
 kernel/sched/numa.c   |  604 +++++++++++++++++++++++++++++++++++++++++++++++++
 kernel/sched/sched.h  |   19 ++
 5 files changed, 699 insertions(+), 12 deletions(-)

Lots of scheduler changes only if CONFIG_AUTONUMA=y. If
CONFIG_AUTONUMA=n it's just 107 lines of scheduler changes (numa.c
won't get built in that case).

> Hm, he isn't even Cc:-ed, how is that supposed to work?

I separately forwarded him the announcement email because I wanted to
add a few more (minor) details for him. Of course Peter's review is
fundamental and appreciated and already helped to make the code a lot
better.

His previous comments should have been addressed, the documentation of
sched_autonuma_balance has been rewritten from scratch,
PF_THREAD_BOUND is gone, etc... It's possible we'll have to go through
more rewrites of the docs if this still isn't good enough. I don't
know yet. This is what the review is about after all :).

numa.c is self contained but I see it as a plus that it's self
contained. First it's easy to nuke AutoNUMA by just deleting the .[ch]
files and fixing up the build errors as result in case a better
algorithm emerges in the future. Second it's trivial to proof those 107
lines won't regress CFS when CONFIG_AUTONUMA=n.

About the CFS integration: sched_autonuma_balance() is simply yet
another idle active load balancing method.

The idle active load balancing that with hyperthreading takes care of
distributing the threads to be sure to fill all idle cores, in
principle works identical to AutoNUMA. It also works side by side with
CFS and moves tasks under CFS control (without CFS possibly noticing)
to optimize for HT. numa.c in principle does the exact same thing (and
it also calls the very same stop_one_cpu_nowait to do the migrations)
but it optimizes for NUMA instead of HT.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
