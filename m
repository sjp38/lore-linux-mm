Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 2BFE36B0068
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 14:07:27 -0400 (EDT)
Date: Tue, 19 Jun 2012 20:06:46 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 13/35] autonuma: add page structure fields
Message-ID: <20120619180646.GN4633@redhat.com>
References: <1337965359-29725-1-git-send-email-aarcange@redhat.com>
 <1337965359-29725-14-git-send-email-aarcange@redhat.com>
 <1338297385.26856.74.camel@twins>
 <4FC4D58A.50800@redhat.com>
 <1338303251.26856.94.camel@twins>
 <4FC5D973.3080108@gmail.com>
 <1338368763.26856.207.camel@twins>
 <20120530134953.GD21339@redhat.com>
 <1338488339.28384.106.camel@twins>
 <20120605145123.GG21339@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120605145123.GG21339@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>

Hi everyone,

On Tue, Jun 05, 2012 at 04:51:23PM +0200, Andrea Arcangeli wrote:
> The details of the solution:
> 
> struct page_autonuma {
>     short autonuma_last_nid;
>     short autonuma_migrate_nid;
>     unsigned int pfn_offset_next;
>     unsigned int pfn_offset_prev;
> } __attribute__((packed));
> 
> page_autonuma can only point to a page that belongs to the same node
> (page_autonuma is queued into the
> NODE_DATA(autonuma_migrate_nid)->autonuma_migrate_head[src_nid]) where
> src_nid is the source node that page_autonuma belongs to, so all pages
> in the autonuma_migrate_head[src_nid] lru must come from the same
> src_nid. So the next page_autonuma in the list will be
> lookup_page_autonuma(pfn_to_page(NODE_DATA(src_nid)->node_start_pfn +
> page_autonuma->pfn_offset_next)) etc..
> 
> Of course all list_add/del must be hardcoded specially for this, but
> it's not a conceptually difficult solution, just we can't use list.h
> and stright pointers anymore and some conversion must happen.

So here the above idea implemented and working fine (it seems...?!? it
has been running only for half an hour but all benchmark regression
tests passed with the same score as before and I verified memory goes
in all directions during the bench, so there's good chance it's ok).

It actually works even if a node has more than 16TB but in that case
it will WARN_ONCE on the first page that is migrated at an offset
above 16TB from the start of the node, and then it will continue
simply skipping migrating those pages with a too large offset.

Next part coming is the docs of autonuma_balance() at the top of
kernel/sched/numa.c and cleanup the autonuma_balance callout location
(if I can figure how to do an active balance on the running task from
softirq). The location at the moment is there just to be invoked after
load_balance runs so it shouldn't make a runtime difference after I
clean it up (hackbench already runs identical to upstream) but
certainly it'll be nice to microoptimize away a call and a branch from
the schedule() fast path.

After that I'll write Documentation/vm/AutoNUMA.txt and I'll finish
the THP native migration (the last one assuming nobody does it before
I get there, if somebody wants to do it sooner, we figured the locking
details with Johannes during the MM summit but it's some work to
implement it).

===
