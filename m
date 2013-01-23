Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 0C8626B0008
	for <linux-mm@kvack.org>; Wed, 23 Jan 2013 08:18:17 -0500 (EST)
Date: Wed, 23 Jan 2013 13:18:20 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH] mm: init: Report on last-nid information stored in
 page->flags
Message-ID: <20130123131820.GH13304@suse.de>
References: <1358874762-19717-1-git-send-email-mgorman@suse.de>
 <1358874762-19717-6-git-send-email-mgorman@suse.de>
 <20130122144659.d512e05c.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130122144659.d512e05c.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>, Simon Jeons <simon.jeons@gmail.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Hugh Dickins <hughd@google.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Answering the question "how much space remains in the page->flags" is
time-consuming. mminit_loglevel can help answer the question but it does
not take last_nid information into account. This patch corrects it and
while there it corrects the messages related to page flag usage, pgshifts
and node/zone id. When applied the relevant output looks something like
this but will depend on the kernel configuration.

[    0.000000] mminit::pageflags_layout_widths Section 0 Node 9 Zone 2 Lastnid 9 Flags 25
[    0.000000] mminit::pageflags_layout_shifts Section 19 Node 9 Zone 2 Lastnid 9
[    0.000000] mminit::pageflags_layout_pgshifts Section 0 Node 55 Zone 53 Lastnid 44
[    0.000000] mminit::pageflags_layout_nodezoneid Node/Zone ID: 64 -> 53
[    0.000000] mminit::pageflags_layout_usage location: 64 -> 44 layout 44 -> 25 unused 25 -> 0 page-flags

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/mm_init.c |   31 +++++++++++++++++++------------
 1 file changed, 19 insertions(+), 12 deletions(-)

diff --git a/mm/mm_init.c b/mm/mm_init.c
index 1ffd97a..c280a02 100644
--- a/mm/mm_init.c
+++ b/mm/mm_init.c
@@ -69,34 +69,41 @@ void __init mminit_verify_pageflags_layout(void)
 	unsigned long or_mask, add_mask;
 
 	shift = 8 * sizeof(unsigned long);
-	width = shift - SECTIONS_WIDTH - NODES_WIDTH - ZONES_WIDTH;
+	width = shift - SECTIONS_WIDTH - NODES_WIDTH - ZONES_WIDTH - LAST_NID_SHIFT;
 	mminit_dprintk(MMINIT_TRACE, "pageflags_layout_widths",
-		"Section %d Node %d Zone %d Flags %d\n",
+		"Section %d Node %d Zone %d Lastnid %d Flags %d\n",
 		SECTIONS_WIDTH,
 		NODES_WIDTH,
 		ZONES_WIDTH,
+		LAST_NID_WIDTH,
 		NR_PAGEFLAGS);
 	mminit_dprintk(MMINIT_TRACE, "pageflags_layout_shifts",
-		"Section %d Node %d Zone %d\n",
+		"Section %d Node %d Zone %d Lastnid %d\n",
 		SECTIONS_SHIFT,
 		NODES_SHIFT,
-		ZONES_SHIFT);
-	mminit_dprintk(MMINIT_TRACE, "pageflags_layout_offsets",
-		"Section %lu Node %lu Zone %lu\n",
+		ZONES_SHIFT,
+		LAST_NID_SHIFT);
+	mminit_dprintk(MMINIT_TRACE, "pageflags_layout_pgshifts",
+		"Section %lu Node %lu Zone %lu Lastnid %lu\n",
 		(unsigned long)SECTIONS_PGSHIFT,
 		(unsigned long)NODES_PGSHIFT,
-		(unsigned long)ZONES_PGSHIFT);
-	mminit_dprintk(MMINIT_TRACE, "pageflags_layout_zoneid",
-		"Zone ID: %lu -> %lu\n",
-		(unsigned long)ZONEID_PGOFF,
-		(unsigned long)(ZONEID_PGOFF + ZONEID_SHIFT));
+		(unsigned long)ZONES_PGSHIFT,
+		(unsigned long)LAST_NID_PGSHIFT);
+	mminit_dprintk(MMINIT_TRACE, "pageflags_layout_nodezoneid",
+		"Node/Zone ID: %lu -> %lu\n",
+		(unsigned long)(ZONEID_PGOFF + ZONEID_SHIFT),
+		(unsigned long)ZONEID_PGOFF);
 	mminit_dprintk(MMINIT_TRACE, "pageflags_layout_usage",
-		"location: %d -> %d unused %d -> %d flags %d -> %d\n",
+		"location: %d -> %d layout %d -> %d unused %d -> %d page-flags\n",
 		shift, width, width, NR_PAGEFLAGS, NR_PAGEFLAGS, 0);
 #ifdef NODE_NOT_IN_PAGE_FLAGS
 	mminit_dprintk(MMINIT_TRACE, "pageflags_layout_nodeflags",
 		"Node not in page flags");
 #endif
+#ifdef LAST_NID_NOT_IN_PAGE_FLAGS
+	mminit_dprintk(MMINIT_TRACE, "pageflags_layout_nodeflags",
+		"Last nid not in page flags");
+#endif
 
 	if (SECTIONS_WIDTH) {
 		shift -= SECTIONS_WIDTH;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
