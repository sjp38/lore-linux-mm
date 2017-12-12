Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6F9476B0033
	for <linux-mm@kvack.org>; Tue, 12 Dec 2017 12:11:43 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id z12so26973971qti.4
        for <linux-mm@kvack.org>; Tue, 12 Dec 2017 09:11:43 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id o63si7695140qkf.281.2017.12.12.09.11.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Dec 2017 09:11:42 -0800 (PST)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id vBCH9KWo016300
	for <linux-mm@kvack.org>; Tue, 12 Dec 2017 12:11:41 -0500
Received: from e16.ny.us.ibm.com (e16.ny.us.ibm.com [129.33.205.206])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2ethhwdr3a-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 12 Dec 2017 12:11:40 -0500
Received: from localhost
	by e16.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Tue, 12 Dec 2017 12:11:39 -0500
Date: Tue, 12 Dec 2017 09:11:33 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH -mm] mm, swap: Fix race between swapoff and some swap
 operations
Reply-To: paulmck@linux.vnet.ibm.com
References: <20171207011426.1633-1-ying.huang@intel.com>
 <20171207162937.6a179063a7c92ecac77e44af@linux-foundation.org>
 <20171208014346.GA8915@bbox>
 <87po7pg4jt.fsf@yhuang-dev.intel.com>
 <20171208082644.GA14361@bbox>
 <87k1xxbohp.fsf@yhuang-dev.intel.com>
 <20171208140909.4e31ba4f1235b638ae68fd5c@linux-foundation.org>
 <87609dvnl0.fsf@yhuang-dev.intel.com>
 <20171211170449.GS7829@linux.vnet.ibm.com>
 <87374grbpn.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87374grbpn.fsf@yhuang-dev.intel.com>
Message-Id: <20171212171133.GC7829@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Tim Chen <tim.c.chen@linux.intel.com>, Shaohua Li <shli@fb.com>, Mel Gorman <mgorman@techsingularity.net>, =?utf-8?B?Su+/vXLvv71tZQ==?= Glisse <jglisse@redhat.com>, Michal Hocko <mhocko@suse.com>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, Dave Jiang <dave.jiang@intel.com>, Aaron Lu <aaron.lu@intel.com>

On Tue, Dec 12, 2017 at 09:12:20AM +0800, Huang, Ying wrote:
> Hi, Pual,
> 
> "Paul E. McKenney" <paulmck@linux.vnet.ibm.com> writes:
> 
> > On Mon, Dec 11, 2017 at 01:30:03PM +0800, Huang, Ying wrote:
> >> Andrew Morton <akpm@linux-foundation.org> writes:
> >> 
> >> > On Fri, 08 Dec 2017 16:41:38 +0800 "Huang\, Ying" <ying.huang@intel.com> wrote:
> >> >
> >> >> > Why do we need srcu here? Is it enough with rcu like below?
> >> >> >
> >> >> > It might have a bug/room to be optimized about performance/naming.
> >> >> > I just wanted to show my intention.
> >> >> 
> >> >> Yes.  rcu should work too.  But if we use rcu, it may need to be called
> >> >> several times to make sure the swap device under us doesn't go away, for
> >> >> example, when checking si->max in __swp_swapcount() and
> >> >> add_swap_count_continuation().  And I found we need rcu to protect swap
> >> >> cache radix tree array too.  So I think it may be better to use one
> >> >> calling to srcu_read_lock/unlock() instead of multiple callings to
> >> >> rcu_read_lock/unlock().
> >> >
> >> > Or use stop_machine() ;)  It's very crude but it sure is simple.  Does
> >> > anyone have a swapoff-intensive workload?
> >> 
> >> Sorry, I don't know how to solve the problem with stop_machine().
> >> 
> >> The problem we try to resolved is that, we have a swap entry, but that
> >> swap entry can become invalid because of swappoff between we check it
> >> and we use it.  So we need to prevent swapoff to be run between checking
> >> and using.
> >> 
> >> I don't know how to use stop_machine() in swapoff to wait for all users
> >> of swap entry to finish.  Anyone can help me on this?
> >
> > You can think of stop_machine() as being sort of like a reader-writer
> > lock.  The readers can be any section of code with preemption disabled,
> > and the writer is the function passed to stop_machine().
> >
> > Users running real-time applications on Linux don't tend to like
> > stop_machine() much, but perhaps it is nevertheless the right tool
> > for this particular job.
> 
> Thanks a lot for explanation!  Now I understand this.
> 
> Another question, for this specific problem, I think both stop_machine()
> based solution and rcu_read_lock/unlock() + synchronize_rcu() based
> solution work.  If so, what is the difference between them?  I guess rcu
> based solution will be a little better for real-time applications?  So
> what is the advantage of stop_machine() based solution?

The stop_machine() solution places similar restrictions on readers as
does rcu_read_lock/unlock() + synchronize_rcu(), if that is what you
are asking.

More precisely, the stop_machine() solution places exactly the
same restrictions on readers as does preempt_disable/enable() and
synchronize_sched().

I would expect stop_machine() to be faster than either synchronize_rcu()
synchronize_sched(), or synchronize_srcu(), but stop_machine() operates
by making each CPU spin with interrupts until all the other CPUs arrive.
This normally does not make real-time people happy.

An compromise position is available in the form of
synchronize_rcu_expedited() and synchronize_sched_expedited().  These
are faster than their non-expedited counterparts, and only momentarily
disturb each CPU, rather than spinning with interrupts disabled.  However,
stop_machine() is probably a bit faster.

Finally, syncrhonize_srcu_expedited() is reasonably fast, but
avoids disturbing other CPUs.  Last I checked, not quite as fast as
synchronize_rcu_expedited() and synchronize_sched_expedited(), though.

You asked!  ;-)

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
