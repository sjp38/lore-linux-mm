Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 52B066B022E
	for <linux-mm@kvack.org>; Fri, 30 Apr 2010 16:53:25 -0400 (EDT)
Date: Fri, 30 Apr 2010 13:52:39 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] - New round-robin rotor for SLAB allocations
Message-Id: <20100430135239.7782f6ba.akpm@linux-foundation.org>
In-Reply-To: <20100426210041.GA6580@sgi.com>
References: <20100426210041.GA6580@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Jack Steiner <steiner@sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cl@linux-foundation.org, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Mon, 26 Apr 2010 16:00:41 -0500
Jack Steiner <steiner@sgi.com> wrote:

> We have observed several workloads running on multi-node systems where
> memory is assigned unevenly across the nodes in the system. There are
> numerous reasons for this but one is the round-robin rotor in
> cpuset_mem_spread_node().
> 
> For example, a simple test that writes a multi-page file will allocate pages
> on nodes 0 2 4 6 ... Odd nodes are skipped.  (Sometimes it allocates on
> odd nodes & skips even nodes).
> 
> An example is shown below. The program "lfile" writes a file consisting of
> 10 pages. The program then mmaps the file & uses get_mempolicy(...,
> MPOL_F_NODE) to determine the nodes where the file pages were allocated.
> The output is shown below:
> 
> 	# ./lfile
> 	 allocated on nodes: 2 4 6 0 1 2 6 0 2
> 
> 
> 
> There is a single rotor that is used for allocating both file pages & slab
> pages.  Writing the file allocates both a data page & a slab page
> (buffer_head).  This advances the RR rotor 2 nodes for each page
> allocated.
> 
> A quick confirmation seems to confirm this is the cause of the uneven
> allocation:
> 
> 	# echo 0 >/dev/cpuset/memory_spread_slab
> 	# ./lfile
> 	 allocated on nodes: 6 7 8 9 0 1 2 3 4 5
> 
> 
> This patch introduces a second rotor that is used for slab allocations.
>
>  include/linux/cpuset.h |    6 ++++++
>  include/linux/sched.h  |    1 +
>  kernel/cpuset.c        |   20 ++++++++++++++++----
>  mm/slab.c              |    2 +-
>  4 files changed, 24 insertions(+), 5 deletions(-)

Why no update to slob and slub?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
