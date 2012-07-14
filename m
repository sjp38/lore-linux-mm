Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 508DF6B005A
	for <linux-mm@kvack.org>; Sat, 14 Jul 2012 12:43:42 -0400 (EDT)
Date: Sat, 14 Jul 2012 18:43:13 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 25/40] autonuma: follow_page check for pte_numa/pmd_numa
Message-ID: <20120714164313.GU10186@redhat.com>
References: <1340888180-15355-1-git-send-email-aarcange@redhat.com>
 <1340888180-15355-26-git-send-email-aarcange@redhat.com>
 <4FF12013.1040208@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4FF12013.1040208@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

On Mon, Jul 02, 2012 at 12:14:11AM -0400, Rik van Riel wrote:
> On 06/28/2012 08:56 AM, Andrea Arcangeli wrote:
> > Without this, follow_page wouldn't trigger the NUMA hinting faults.
> >
> > Signed-off-by: Andrea Arcangeli<aarcange@redhat.com>
> 
> follow_page is called from many different places, not just
> the process itself. One example would be ksm.
> 
> Do you really want to trigger NUMA hinting faults when the
> mm != current->mm, or is that magically prevented somewhere?

The NUMA hinting page fault will update "current->task_autonuma"
according to the page_nid of the page triggering the numa hinting page
fault in follow_page. It doesn't matter if the page belongs to the
different mm, all we care is the page_nid that was accessed by the
"current" task through a numa hinting fault.

When I started thinking the benefit it could provide, I thought it
wouldn't be worth it because task_autonuma statistics are only used to
balance threads belonging to the same process, and mm_autonuma is used
to balance tasks belonging to different processes. And mm_autonuma
will never be able to take into account things like this.

So I converted the !current->mm check to a current->mm != mm check
here to save a bit of cpu and skip it in the autonuma branch.

void numa_hinting_fault(struct mm_struct *mm, struct page *page, int numpages)
{
	/*
	 * "current->mm" could be different from "mm" if
	 * get_user_pages() triggered the fault on some other process
	 * "mm". It wouldn't be a problem to account this NUMA hinting
	 * page fault on the current->task_autonuma statistics even if
	 * it was triggered on a page mapped on a different
	 * "mm". However task_autonuma isn't used to balance threads
	 * belonging to different processes so it wouldn't help and in
	 * turn it's not worth it.
	 */
	if (likely(current->mm == mm && !current->mempolicy && autonuma_enabled())) {

But I was thinking at the usual case of one ptracer task with a single
thread, however now I changed my mind and I think it can help when
there's just one process and a ton of threads spanning multiple nodes,
and one of the threads is ptracing an otherwise idle task and
accessing lot of ram through ptrace. So I think I'll roll it back to
autonuma21 status and allow the accounting of all page_nid even for
different mm again. But this is mostly a theoretical issue.

It can lead to a funny weighting where mm_autonuma shows 100% of the
weight in one node, and task_autonuma shows 95% of the weight to
another different node. But it should still work fine as we won't
allow the thread to go to that different node if a different process
run there. If a thread of the same process runs in the node where
task_autonuma shows 95% of the weight, then it's better to put the
thread there if it has higher weight than the other thread of the same
process so it'll be fine despite mm_autonuma and task_autonuma disagree.

Disagreement of task_autonuma and mm_autonuma happens all the time and
it's perfectly normal, just this will exacerbate a little more.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
