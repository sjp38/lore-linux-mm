Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id BBC886B0069
	for <linux-mm@kvack.org>; Thu, 21 Dec 2017 20:30:28 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id e135so3035806qka.10
        for <linux-mm@kvack.org>; Thu, 21 Dec 2017 17:30:28 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id p1si571386qte.49.2017.12.21.17.30.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Dec 2017 17:30:28 -0800 (PST)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id vBM1Si4H108588
	for <linux-mm@kvack.org>; Thu, 21 Dec 2017 20:30:27 -0500
Received: from e14.ny.us.ibm.com (e14.ny.us.ibm.com [129.33.205.204])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2f0myr8a3m-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 21 Dec 2017 20:30:26 -0500
Received: from localhost
	by e14.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Thu, 21 Dec 2017 20:30:25 -0500
Date: Thu, 21 Dec 2017 17:30:36 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] Move kfree_call_rcu() to slab_common.c
Reply-To: paulmck@linux.vnet.ibm.com
References: <1513844387-2668-1-git-send-email-rao.shoaib@oracle.com>
 <20171221155434.GT7829@linux.vnet.ibm.com>
 <20171221170628.GA25009@bombadil.infradead.org>
 <20171222012741.GZ7829@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171222012741.GZ7829@linux.vnet.ibm.com>
Message-Id: <20171222013036.GB21720@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: rao.shoaib@oracle.com, linux-kernel@vger.kernel.org, brouer@redhat.com, linux-mm@kvack.org

On Thu, Dec 21, 2017 at 05:27:41PM -0800, Paul E. McKenney wrote:
> On Thu, Dec 21, 2017 at 09:06:28AM -0800, Matthew Wilcox wrote:
> > On Thu, Dec 21, 2017 at 07:54:34AM -0800, Paul E. McKenney wrote:
> > > > +/* Queue an RCU callback for lazy invocation after a grace period.
> > > > + * Currently there is no way of tagging the lazy RCU callbacks in the
> > > > + * list of pending callbacks. Until then, this function may only be
> > > > + * called from kfree_call_rcu().
> > > 
> > > But now we might have a way.
> > > 
> > > If the value in ->func is too small to be a valid function, RCU invokes
> > > a fixed function name.  This function can then look at ->func and do
> > > whatever it wants, for example, maintaining an array indexed by the
> > > ->func value that says what function to call and what else to pass it,
> > > including for example the slab pointer and offset.
> > > 
> > > Thoughts?
> > 
> > Thought 1 is that we can force functions to be quad-byte aligned on all
> > architectures (gcc option -falign-functions=...), so we can have more
> > than the 4096 different values we currently use.  We can get 63.5 bits of
> > information into that ->func argument if we align functions to at least
> > 4 bytes, or 63 if we only force alignment to a 2-byte boundary.  I'm not
> > sure if we support any architecture other than x86 with byte-aligned
> > instructions.  (I'm assuming that function descriptors as used on POWER
> > and ia64 will also be sensibly aligned).
> 
> I do like this approach, especially should some additional subsystems
> need this sort of special handling from RCU.  It is also much faster
> to demultiplex than alternative schemes based on address ranges and
> the like.

Oh, and having four-byte alignment would allow making laziness orthogonal
to special handling, which should improve energy efficiency of callback
handling by allowing normal call_rcu() callbacks to invoke laziness.
(And would require renaming the call_rcu_lazy() API yet again, sorry Rao!)

							Thanx, Paul

> How many bits are required by slab?  Would ~56 bits (less the bottom
> bit pattern reserved for function pointers) suffice on 64-bit systems
> and ~24 bits on 32-bit systems?  That would allow up to 256 specially
> handled situations, which should be enough.  (Famous last words!)
> 
> > Thought 2 is that the slab is quite capable of getting the slab pointer
> > from the address of the object -- virt_to_head_page(p)->slab_cache
> > So sorting objects by address is as good as storing their slab caches
> > and offsets.
> 
> Different slabs can in some cases interleave their slabs of objects,
> right?  It might well be that grouping together different slabs from
> the same slab cache doesn't help, but seems worth my asking the question.
> 
> > Thought 3 is that we probably don't want to overengineer this.
> > Just allocating a 14-entry buffer (along with an RCU head) is probably
> > enough to give us at least 90% of the wins that a more complex solution
> > would give.
> 
> Can we benchmark this?  After all, memory allocation can sometimes
> counter one's intuition.
> 
> One alternative approach would be to allocate such a buffer per
> slab cache, and run each slab caches through RCU independently.
> Seems like this should allow some savings.  Might not be worthwhile,
> but again seemed worth asking the question.
> 
> 							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
