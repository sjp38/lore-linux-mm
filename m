Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 07DDA6B0044
	for <linux-mm@kvack.org>; Wed,  8 Aug 2012 17:51:21 -0400 (EDT)
Date: Wed, 8 Aug 2012 17:45:49 -0400
From: Rik van Riel <riel@redhat.com>
Subject: [RFC][PATCH -mm 0/3] mm,vmscan: reclaim from highest score cgroup
Message-ID: <20120808174549.1b10d51a@cuia.bos.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: yinghan@google.com, hannes@cmpxchg.org, mhocko@suse.cz, Mel Gorman <mel@csn.ul.ie>

Instead of doing round robin reclaim over all the cgroups in a zone, we
reclaim from the highest score cgroup first.

Factors in the scoring are the use ratio of pages in the lruvec
(recent_rotated / recent_scanned), the size of the lru, the recent amount
of pressure applied to each lru, whether the cgroup is over its soft limit
and whether the cgroup has lots of inactive file pages.

This patch series is on top of a recent mmotm with Ying's memcg softreclaim
patches [2/2] applied.  Unfortunately it turns out that that mmmotm tree
with Ying's patches does not compile with CONFIG_MEMCG=y, so I am testing
these patches over the wall untested, as inspiration for others (hi Ying).

This still suffers from the same scalability issue the current code has,
namely a round robin iteration over all the lruvecs in a zone. We may want
to fix that in the future by sorting the memcgs/lruvecs in some sort of
tree, allowing us to find the high priority ones more easily and doing the
recalculation asynchronously and less often.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
