Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f179.google.com (mail-yk0-f179.google.com [209.85.160.179])
	by kanga.kvack.org (Postfix) with ESMTP id 789206B0036
	for <linux-mm@kvack.org>; Tue, 13 May 2014 16:24:54 -0400 (EDT)
Received: by mail-yk0-f179.google.com with SMTP id 19so767401ykq.24
        for <linux-mm@kvack.org>; Tue, 13 May 2014 13:24:54 -0700 (PDT)
Received: from e38.co.us.ibm.com (e38.co.us.ibm.com. [32.97.110.159])
        by mx.google.com with ESMTPS id a24si21700789yha.151.2014.05.13.13.24.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 13 May 2014 13:24:53 -0700 (PDT)
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Tue, 13 May 2014 14:24:53 -0600
Received: from b03cxnp08028.gho.boulder.ibm.com (b03cxnp08028.gho.boulder.ibm.com [9.17.130.20])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id EA8A73E40040
	for <linux-mm@kvack.org>; Tue, 13 May 2014 14:24:49 -0600 (MDT)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b03cxnp08028.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s4DKOnpK48693340
	for <linux-mm@kvack.org>; Tue, 13 May 2014 22:24:49 +0200
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id s4DKSfxa002739
	for <linux-mm@kvack.org>; Tue, 13 May 2014 14:28:42 -0600
Date: Tue, 13 May 2014 13:24:48 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 19/19] mm: filemap: Avoid unnecessary barries and
 waitqueue lookups in unlock_page fastpath
Message-ID: <20140513202448.GR18164@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <1399974350-11089-1-git-send-email-mgorman@suse.de>
 <1399974350-11089-20-git-send-email-mgorman@suse.de>
 <20140513125313.GR23991@suse.de>
 <20140513141748.GD2485@laptop.programming.kicks-ass.net>
 <20140513152719.GF18164@linux.vnet.ibm.com>
 <20140513154435.GG2485@laptop.programming.kicks-ass.net>
 <20140513161418.GH18164@linux.vnet.ibm.com>
 <20140513185742.GD12123@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140513185742.GD12123@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, David Howells <dhowells@redhat.com>

On Tue, May 13, 2014 at 08:57:42PM +0200, Oleg Nesterov wrote:
> On 05/13, Paul E. McKenney wrote:
> >
> > On Tue, May 13, 2014 at 05:44:35PM +0200, Peter Zijlstra wrote:
> > >
> > > Ah, yes, so I'll defer to Oleg and Linus to explain that one. As per the
> > > name: smp_mb__before_spinlock() should of course imply a full barrier.
> >
> > How about if I queue a name change to smp_wmb__before_spinlock()?
> 
> I agree, this is more accurate, simply because it describes what it
> actually does.
> 
> But just in case, as for try_to_wake_up() it does not actually need
> wmb() between "CONDITION = T" and "task->state = RUNNING". It would
> be fine if these 2 STORE's are re-ordered, we can rely on rq->lock.
> 
> What it actually needs is a barrier between "CONDITION = T" and
> "task->state & state" check. But since we do not have a store-load
> barrier, wmb() was added to ensure that "CONDITION = T" can't leak
> into the critical section.
> 
> But it seems that set_tlb_flush_pending() already assumes that it
> acts as wmb(), so probably smp_wmb__before_spinlock() is fine.

Except that when I go to make the change, I find the following in
the documentation:

     Memory operations issued before the ACQUIRE may be completed after
     the ACQUIRE operation has completed.  An smp_mb__before_spinlock(),
     combined with a following ACQUIRE, orders prior loads against
     subsequent loads and stores and also orders prior stores against
     subsequent stores.  Note that this is weaker than smp_mb()!  The
     smp_mb__before_spinlock() primitive is free on many architectures.

Which means that either the documentation is wrong or the implementation
is.  Yes, smp_wmb() has the semantics called out above on many platforms,
but not on Alpha or ARM.

So, as you say, set_tlb_flush_pending() only relies on smp_wmb().
The comment in try_to_wake_up() seems to be assuming a full memory
barrier.  The comment in __schedule() also seems to be relying on
a full memory barrier (prior write against subsequent read).  Yow!

So maybe barrier() on TSO systems like x86 and mainframe and stronger
barriers on other systems, depending on what their lock acquisition
looks like?

Or am I misinterpreting try_to_wake_up() and __schedule()?

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
