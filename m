Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id AF3F56B0211
	for <linux-mm@kvack.org>; Thu,  8 Apr 2010 17:33:10 -0400 (EDT)
Date: Thu, 8 Apr 2010 23:32:45 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 56 of 67] Memory compaction core
Message-ID: <20100408213245.GF5749@random.random>
References: <patchbomb.1270691443@v2.random>
 <a86f1d01d86dffb4ab53.1270691499@v2.random>
 <20100408161814.GC28964@cmpxchg.org>
 <20100408164630.GL5749@random.random>
 <20100408170948.GQ5749@random.random>
 <20100408171458.GS5749@random.random>
 <20100408175604.GD28964@cmpxchg.org>
 <20100408175847.GV5749@random.random>
 <20100408184842.GE28964@cmpxchg.org>
 <20100408212332.GD5749@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100408212332.GD5749@random.random>
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>
List-ID: <linux-mm.kvack.org>

Hi Johannes,

I changed it like this.

-------
Subject: transhuge isolate_migratepages()

From: Andrea Arcangeli <aarcange@redhat.com>

It's not worth migrating transparent hugepages during compaction. Those
hugepages don't create fragmentation.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---

diff --git a/mm/compaction.c b/mm/compaction.c
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -265,10 +265,23 @@ static unsigned long isolate_migratepage
 		if (PageBuddy(page))
 			continue;
 
+		if (!PageLRU(page))
+			continue;
+
+		/*
+		 * PageLRU is set, and lru_lock excludes isolation,
+		 * splitting and collapsing (collapsing has already
+		 * happened if PageLRU is set).
+		 */
+		if (PageTransHuge(page))
+			continue;
+
 		/* Try isolate the page */
 		if (__isolate_lru_page(page, ISOLATE_BOTH, 0) != 0)
 			continue;
 
+		VM_BUG_ON(PageTransCompound(page));
+
 		/* Successfully isolated */
 		del_page_from_lru_list(zone, page, page_lru(page));
 		list_add(&page->lru, migratelist);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
