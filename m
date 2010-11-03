Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 4D36E8D0003
	for <linux-mm@kvack.org>; Wed,  3 Nov 2010 11:31:11 -0400 (EDT)
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 01 of 66] disable lumpy when compaction is enabled
Message-Id: <ca2fea6527833aad8adc.1288798056@v2.random>
In-Reply-To: <patchbomb.1288798055@v2.random>
References: <patchbomb.1288798055@v2.random>
Date: Wed, 03 Nov 2010 16:27:36 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>

Compaction is more reliable than lumpy, and lumpy makes the system unusable
when it runs.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---

diff --git a/mm/vmscan.c b/mm/vmscan.c
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -274,6 +274,7 @@ unsigned long shrink_slab(unsigned long 
 static void set_lumpy_reclaim_mode(int priority, struct scan_control *sc,
 				   bool sync)
 {
+#ifndef CONFIG_COMPACTION
 	enum lumpy_mode mode = sync ? LUMPY_MODE_SYNC : LUMPY_MODE_ASYNC;
 
 	/*
@@ -294,11 +295,14 @@ static void set_lumpy_reclaim_mode(int p
 		sc->lumpy_reclaim_mode = mode;
 	else
 		sc->lumpy_reclaim_mode = LUMPY_MODE_NONE;
+#endif
 }
 
 static void disable_lumpy_reclaim_mode(struct scan_control *sc)
 {
+#ifndef CONFIG_COMPACTION
 	sc->lumpy_reclaim_mode = LUMPY_MODE_NONE;
+#endif
 }
 
 static inline int is_page_cache_freeable(struct page *page)
@@ -321,9 +325,11 @@ static int may_write_to_queue(struct bac
 	if (bdi == current->backing_dev_info)
 		return 1;
 
+#ifndef CONFIG_COMPACTION
 	/* lumpy reclaim for hugepage often need a lot of write */
 	if (sc->order > PAGE_ALLOC_COSTLY_ORDER)
 		return 1;
+#endif
 	return 0;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
