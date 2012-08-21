Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 8E8FA6B005D
	for <linux-mm@kvack.org>; Tue, 21 Aug 2012 12:25:17 -0400 (EDT)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Tue, 21 Aug 2012 10:25:16 -0600
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id CB2A9C40003
	for <linux-mm@kvack.org>; Tue, 21 Aug 2012 10:25:02 -0600 (MDT)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q7LGObkP070134
	for <linux-mm@kvack.org>; Tue, 21 Aug 2012 10:24:55 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q7LGOabk003755
	for <linux-mm@kvack.org>; Tue, 21 Aug 2012 10:24:37 -0600
Date: Tue, 21 Aug 2012 09:24:32 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH v8 1/5] mm: introduce a common interface for balloon
 pages mobility
Message-ID: <20120821162432.GG2456@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <cover.1345519422.git.aquini@redhat.com>
 <e24f3073ef539985dea52943dcb84762213a0857.1345519422.git.aquini@redhat.com>
 <1345562411.23018.111.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1345562411.23018.111.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Rafael Aquini <aquini@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>, "Michael S. Tsirkin" <mst@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>

On Tue, Aug 21, 2012 at 05:20:11PM +0200, Peter Zijlstra wrote:
> On Tue, 2012-08-21 at 09:47 -0300, Rafael Aquini wrote:
> > +       mapping = rcu_access_pointer(page->mapping);
> > +       if (mapping)
> > +               mapping = mapping->assoc_mapping; 
> 
> The comment near rcu_access_pointer() explicitly says:
> 
>  * Return the value of the specified RCU-protected pointer, but omit the
>  * smp_read_barrier_depends() and keep the ACCESS_ONCE().  This is useful
>  * when the value of this pointer is accessed, but the pointer is not
>  * dereferenced,
> 
> Yet you dereference the pointer... smells like fail to me.

Indeed!

This will break DEC Alpha.  In addition, if ->mapping can transition
from non-NULL to NULL, and if you used rcu_access_pointer() rather
than rcu_dereference() to avoid lockdep-RCU from yelling at you about
not either being in an RCU read-side critical section or holding an
update-side lock, you can see failures as follows:

1.	CPU 0 runs the above code, picks up mapping, and finds it non-NULL.

2.	CPU 0 is preempted or otherwise delayed.  (Keep in mind that
	even disabling interrupts in a guest OS does not prevent the
	host hypervisor from preempting!)

3.	Some other CPU NULLs page->mapping.  Because CPU 0 isn't doing
	anything to prevent it, this other CPU frees the memory.

4.	CPU 0 resumes, and then accesses what is now the freelist.
	Arbitrarily bad things start happening.

If you are in a read-side critical section, use rcu_dereference() instead
of rcu_access_pointer().  If you are holding an update-side lock, use
rcu_dereference_protected() and say what lock you are holding.  If you
are doing something else, please say what it is.

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
