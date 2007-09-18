Date: Tue, 18 Sep 2007 09:44:34 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 04 of 24] serialize oom killer
In-Reply-To: <alpine.DEB.0.9999.0709132010050.30494@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.0.9999.0709180007420.4624@chino.kir.corp.google.com>
References: <871b7a4fd566de081120.1187786931@v2.random> <Pine.LNX.4.64.0709121658450.4489@schroedinger.engr.sgi.com> <alpine.DEB.0.9999.0709131126370.27997@chino.kir.corp.google.com> <Pine.LNX.4.64.0709131136560.9590@schroedinger.engr.sgi.com>
 <alpine.DEB.0.9999.0709131139340.30279@chino.kir.corp.google.com> <Pine.LNX.4.64.0709131152400.9999@schroedinger.engr.sgi.com> <alpine.DEB.0.9999.0709131732330.21805@chino.kir.corp.google.com> <Pine.LNX.4.64.0709131923410.12159@schroedinger.engr.sgi.com>
 <alpine.DEB.0.9999.0709132010050.30494@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrea Arcangeli <andrea@suse.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 13 Sep 2007, David Rientjes wrote:

> We have no way of locking only the nodes in the MPOL_BIND memory policy 
> like we do on a cpuset granularity.  That would require an spinlock in 
> each node which would work fine if we alter the CONSTRAINT_CPUSET case to 
> lock each node in current->cpuset->mems_allowed.  We could do that if add 
> a task_lock(current) before trying oom_test_and_set_lock() in 
> __alloc_pages().
> 
> There's also no OOM locking at the zone level for GFP_DMA constrained 
> allocations, so perhaps locking should be on the zone level.
> 

There's a way to get around adding a spinlock to struct zone by just 
saving the pointers of the zonelists passed to __alloc_pages() when the 
OOM killer is invoked.  Then, on subsequent calls to out_of_memory(), it 
is possible to scan through the list of zones that already have a 
corresponding allocation attempt that has failed and is already in the OOM 
killer.  Hopefully the OOM killer will kill a memory-hogging task, which 
the heuristics are pretty good for, and it will free up some space in 
those zones.  Thus, we should indeed be serializing on the zone level 
instead of node or cpuset level.

		David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
