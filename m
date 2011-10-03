Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id ED2159000DF
	for <linux-mm@kvack.org>; Mon,  3 Oct 2011 17:47:57 -0400 (EDT)
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by e9.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p93LC5kv020673
	for <linux-mm@kvack.org>; Mon, 3 Oct 2011 17:12:05 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p93LlgvK958636
	for <linux-mm@kvack.org>; Mon, 3 Oct 2011 17:47:46 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p93LlfVU012736
	for <linux-mm@kvack.org>; Mon, 3 Oct 2011 17:47:42 -0400
Date: Mon, 3 Oct 2011 14:47:39 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: lockdep recursive locking detected (rcu_kthread / __cache_free)
Message-ID: <20111003214739.GK2403@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20111003175322.GA26122@sucs.org>
 <20111003203139.GH2403@linux.vnet.ibm.com>
 <alpine.DEB.2.00.1110031540560.11713@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1110031540560.11713@router.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>
Cc: Sitsofe Wheeler <sitsofe@yahoo.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, penberg@kernel.org, mpm@selenic.com, linux-mm@kvack.org

On Mon, Oct 03, 2011 at 03:46:11PM -0500, Christoph Lameter wrote:
> On Mon, 3 Oct 2011, Paul E. McKenney wrote:
> 
> > The first lock was acquired here in an RCU callback.  The later lock that
> > lockdep complained about appears to have been acquired from a recursive
> > call to __cache_free(), with no help from RCU.  This looks to me like
> > one of the issues that arise from the slab allocator using itself to
> > allocate slab metadata.
> 
> Right. However, this is a false positive since the slab cache with
> the metadata is different from the slab caches with the slab data. The slab
> cache with the metadata does not use itself any metadata slab caches.

Wouldn't it be possible to pass a new flag to the metadata slab caches
upon creation so that their locks could be placed in a separate lock
class?  Just allocate a separate lock_class_key structure for each such
lock in that case, and then use lockdep_set_class_and_name to associate
that structure with the corresponding lock.  I do this in kernel/rcutree.c
in order to allow the rcu_node tree's locks to nest properly.

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
