Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2D1716B0253
	for <linux-mm@kvack.org>; Fri,  8 Dec 2017 17:09:14 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id y15so6684713wrc.6
        for <linux-mm@kvack.org>; Fri, 08 Dec 2017 14:09:14 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id q23si6575224wrc.186.2017.12.08.14.09.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Dec 2017 14:09:12 -0800 (PST)
Date: Fri, 8 Dec 2017 14:09:09 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -mm] mm, swap: Fix race between swapoff and some swap
 operations
Message-Id: <20171208140909.4e31ba4f1235b638ae68fd5c@linux-foundation.org>
In-Reply-To: <87k1xxbohp.fsf@yhuang-dev.intel.com>
References: <20171207011426.1633-1-ying.huang@intel.com>
	<20171207162937.6a179063a7c92ecac77e44af@linux-foundation.org>
	<20171208014346.GA8915@bbox>
	<87po7pg4jt.fsf@yhuang-dev.intel.com>
	<20171208082644.GA14361@bbox>
	<87k1xxbohp.fsf@yhuang-dev.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Minchan Kim <minchan@kernel.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Tim Chen <tim.c.chen@linux.intel.com>, Shaohua Li <shli@fb.com>, Mel Gorman <mgorman@techsingularity.net>, =?UTF-8?Q?J=EF=BF=BDr=EF=BF=BDme?= Glisse <jglisse@redhat.com>, Michal Hocko <mhocko@suse.com>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, Dave Jiang <dave.jiang@intel.com>, Aaron Lu <aaron.lu@intel.com>

On Fri, 08 Dec 2017 16:41:38 +0800 "Huang\, Ying" <ying.huang@intel.com> wrote:

> > Why do we need srcu here? Is it enough with rcu like below?
> >
> > It might have a bug/room to be optimized about performance/naming.
> > I just wanted to show my intention.
> 
> Yes.  rcu should work too.  But if we use rcu, it may need to be called
> several times to make sure the swap device under us doesn't go away, for
> example, when checking si->max in __swp_swapcount() and
> add_swap_count_continuation().  And I found we need rcu to protect swap
> cache radix tree array too.  So I think it may be better to use one
> calling to srcu_read_lock/unlock() instead of multiple callings to
> rcu_read_lock/unlock().

Or use stop_machine() ;)  It's very crude but it sure is simple.  Does
anyone have a swapoff-intensive workload?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
