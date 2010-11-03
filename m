Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 0B6896B00C4
	for <linux-mm@kvack.org>; Wed,  3 Nov 2010 11:30:41 -0400 (EDT)
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 62 of 66] disable transparent hugepages by default on small
	systems
Message-Id: <5791385d8111de4b5143.1288798117@v2.random>
In-Reply-To: <patchbomb.1288798055@v2.random>
References: <patchbomb.1288798055@v2.random>
Date: Wed, 03 Nov 2010 16:28:37 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>
List-ID: <linux-mm.kvack.org>

From: Rik van Riel <riel@redhat.com>

On small systems, the extra memory used by the anti-fragmentation
memory reserve and simply because huge pages are smaller than large
pages can easily outweigh the benefits of less TLB misses.

In case of the crashdump kernel, OOMs have been observed due to
the anti-fragmentation memory reserve taking up a large fraction
of the crashdump image.

This patch disables transparent hugepages on systems with less
than 1GB of RAM, but the hugepage subsystem is fully initialized
so administrators can enable THP through /sys if desired.

v2: reduce the limit to 512MB

Signed-off-by: Rik van Riel <riel@redhat.com>
Acked-by: Avi Kiviti <avi@redhat.com>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -527,6 +527,14 @@ static int __init hugepage_init(void)
 		goto out;
 	}
 
+	/*
+	 * By default disable transparent hugepages on smaller systems,
+	 * where the extra memory used could hurt more than TLB overhead
+	 * is likely to save.  The admin can still enable it through /sys.
+	 */
+	if (totalram_pages < (512 << (20 - PAGE_SHIFT)))
+		transparent_hugepage_flags = 0;
+
 	start_khugepaged();
 
 	set_recommended_min_free_kbytes();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
