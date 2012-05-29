Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 6B37D6B005C
	for <linux-mm@kvack.org>; Tue, 29 May 2012 18:21:46 -0400 (EDT)
Message-ID: <1338330077.26856.187.camel@twins>
Subject: Re: [PATCH 22/35] autonuma: sched_set_autonuma_need_balance
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Wed, 30 May 2012 00:21:17 +0200
In-Reply-To: <20120529173347.GJ21339@redhat.com>
References: <1337965359-29725-1-git-send-email-aarcange@redhat.com>
	 <1337965359-29725-23-git-send-email-aarcange@redhat.com>
	 <1338307942.26856.111.camel@twins> <20120529173347.GJ21339@redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>

On Tue, 2012-05-29 at 19:33 +0200, Andrea Arcangeli wrote:

> No worries, I didn't mean to leave it like this forever. I was
> considering using the stop cpu _nowait variant but I didn't have
> enough time to realize if it would work for my case. I need to rethink
> about that.

No, you're not going to use any stop_cpu variant at all. Nothing is
_that_ urgent. Your whole strict mode needs to go, it completely wrecks
the regular balancer.

> The moment I gave up on the _nowait variant before releasing is when I
> couldn't understand what is tlb_migrate_finish doing, and why it's not
> present in the _nowait version in fair.c. Can you explain me that?

Its an optional tlb flush, I guess they didn't find the active_balance
worth the effort -- it should be fairly rare anyway.

> I'm glad you acknowledge load_balance already takes a bulk of the time
> as it needs to find the busiest runqueue checking other CPU runqueues
> too...

I've never said otherwise, its always been about where you do it, in the
middle of schedule() just isn't it. And I'm getting very tired of having
to repeat myself.

Also for regular load-balance only 2 cpus will ever scan all cpus, the
rest will only scan smaller ranges. Your thing does n-1 nodes worth of
cpus for every cpu.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
