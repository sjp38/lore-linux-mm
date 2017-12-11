Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id F298E6B0033
	for <linux-mm@kvack.org>; Mon, 11 Dec 2017 12:04:55 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id 18so21948136qtt.10
        for <linux-mm@kvack.org>; Mon, 11 Dec 2017 09:04:55 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id x15si119628qth.269.2017.12.11.09.04.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Dec 2017 09:04:54 -0800 (PST)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id vBBH44vY082761
	for <linux-mm@kvack.org>; Mon, 11 Dec 2017 12:04:53 -0500
Received: from e14.ny.us.ibm.com (e14.ny.us.ibm.com [129.33.205.204])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2eswub0tvf-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 11 Dec 2017 12:04:52 -0500
Received: from localhost
	by e14.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Mon, 11 Dec 2017 12:04:51 -0500
Date: Mon, 11 Dec 2017 09:04:49 -0800
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
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87609dvnl0.fsf@yhuang-dev.intel.com>
Message-Id: <20171211170449.GS7829@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Tim Chen <tim.c.chen@linux.intel.com>, Shaohua Li <shli@fb.com>, Mel Gorman <mgorman@techsingularity.net>, =?utf-8?B?Su+/vXLvv71tZQ==?= Glisse <jglisse@redhat.com>, Michal Hocko <mhocko@suse.com>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, Dave Jiang <dave.jiang@intel.com>, Aaron Lu <aaron.lu@intel.com>

On Mon, Dec 11, 2017 at 01:30:03PM +0800, Huang, Ying wrote:
> Andrew Morton <akpm@linux-foundation.org> writes:
> 
> > On Fri, 08 Dec 2017 16:41:38 +0800 "Huang\, Ying" <ying.huang@intel.com> wrote:
> >
> >> > Why do we need srcu here? Is it enough with rcu like below?
> >> >
> >> > It might have a bug/room to be optimized about performance/naming.
> >> > I just wanted to show my intention.
> >> 
> >> Yes.  rcu should work too.  But if we use rcu, it may need to be called
> >> several times to make sure the swap device under us doesn't go away, for
> >> example, when checking si->max in __swp_swapcount() and
> >> add_swap_count_continuation().  And I found we need rcu to protect swap
> >> cache radix tree array too.  So I think it may be better to use one
> >> calling to srcu_read_lock/unlock() instead of multiple callings to
> >> rcu_read_lock/unlock().
> >
> > Or use stop_machine() ;)  It's very crude but it sure is simple.  Does
> > anyone have a swapoff-intensive workload?
> 
> Sorry, I don't know how to solve the problem with stop_machine().
> 
> The problem we try to resolved is that, we have a swap entry, but that
> swap entry can become invalid because of swappoff between we check it
> and we use it.  So we need to prevent swapoff to be run between checking
> and using.
> 
> I don't know how to use stop_machine() in swapoff to wait for all users
> of swap entry to finish.  Anyone can help me on this?

You can think of stop_machine() as being sort of like a reader-writer
lock.  The readers can be any section of code with preemption disabled,
and the writer is the function passed to stop_machine().

Users running real-time applications on Linux don't tend to like
stop_machine() much, but perhaps it is nevertheless the right tool
for this particular job.

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
