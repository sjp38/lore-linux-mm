Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id lAC6hA1Q020602
	for <linux-mm@kvack.org>; Mon, 12 Nov 2007 01:43:10 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.6) with ESMTP id lAC6hApx125076
	for <linux-mm@kvack.org>; Mon, 12 Nov 2007 01:43:10 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lAC6hA9i013906
	for <linux-mm@kvack.org>; Mon, 12 Nov 2007 01:43:10 -0500
Message-ID: <4737F5F1.5030907@linux.vnet.ibm.com>
Date: Mon, 12 Nov 2007 12:12:57 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH 5/6 mm] memcgroup: fix zone isolation OOM
References: <Pine.LNX.4.64.0711090700530.21638@blonde.wat.veritas.com> <Pine.LNX.4.64.0711090712180.21663@blonde.wat.veritas.com>
In-Reply-To: <Pine.LNX.4.64.0711090712180.21663@blonde.wat.veritas.com>
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, containers@lists.osdl.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> mem_cgroup_charge_common shows a tendency to OOM without good reason,
> when a memhog goes well beyond its rss limit but with plenty of swap
> available.  Seen on x86 but not on PowerPC; seen when the next patch
> omits swapcache from memcgroup, but we presume it can happen without.
> 
> mem_cgroup_isolate_pages is not quite satisfying reclaim's criteria
> for OOM avoidance.  Already it has to scan beyond the nr_to_scan limit
> when it finds a !LRU page or an active page when handling inactive or
> an inactive page when handling active.  It needs to do exactly the same
> when it finds a page from the wrong zone (the x86 tests had two zones,
> the PowerPC tests had only one).
> 
> Don't increment scan and then decrement it in these cases, just move
> the incrementation down.  Fix recent off-by-one when checking against
> nr_to_scan.  Cut out "Check if the meta page went away from under us",
> presumably left over from early debugging: no amount of such checks
> could save us if this list really were being updated without locking.
> 

It's a spill over from the old code, we do all operations under
the mem_cont's lru_lock.

> This change does make the unlimited scan while holding two spinlocks
> even worse - bad for latency and bad for containment; but that's a
> separate issue which is better left to be fixed a little later.
> 
> Signed-off-by: Hugh Dickins <hugh@veritas.com>

For the swapout test case scenario sent by Hugh

Tested-by: Balbir Singh <balbir@linux.vnet.ibm.com>

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
