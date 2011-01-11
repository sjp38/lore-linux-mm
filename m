Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 77B6E6B00E7
	for <linux-mm@kvack.org>; Tue, 11 Jan 2011 02:30:44 -0500 (EST)
Received: from kpbe18.cbf.corp.google.com (kpbe18.cbf.corp.google.com [172.25.105.82])
	by smtp-out.google.com with ESMTP id p0B7UhhL026694
	for <linux-mm@kvack.org>; Mon, 10 Jan 2011 23:30:43 -0800
Received: from iyj21 (iyj21.prod.google.com [10.241.51.85])
	by kpbe18.cbf.corp.google.com with ESMTP id p0B7UMSm028633
	for <linux-mm@kvack.org>; Mon, 10 Jan 2011 23:30:41 -0800
Received: by iyj21 with SMTP id 21so18492248iyj.30
        for <linux-mm@kvack.org>; Mon, 10 Jan 2011 23:30:41 -0800 (PST)
Date: Mon, 10 Jan 2011 23:30:28 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH] ksm: drain pagevecs to lru
Message-ID: <alpine.LSU.2.00.1101102325010.25237@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, CAI Qian <caiqian@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

It was hard to explain the page counts which were causing new LTP tests
of KSM to fail: we need to drain the per-cpu pagevecs to LRU occasionally.

Reported-by: CAI Qian <caiqian@redhat.com>
Signed-off-by: Hugh Dickins <hughd@google.com>
---

 mm/ksm.c |   12 ++++++++++++
 1 file changed, 12 insertions(+)

--- 2.6.37/mm/ksm.c	2010-12-24 19:31:45.000000000 -0800
+++ linux/mm/ksm.c	2011-01-02 15:06:52.000000000 -0800
@@ -1247,6 +1247,18 @@ static struct rmap_item *scan_get_next_r
 
 	slot = ksm_scan.mm_slot;
 	if (slot == &ksm_mm_head) {
+		/*
+		 * A number of pages can hang around indefinitely on per-cpu
+		 * pagevecs, raised page count preventing write_protect_page
+		 * from merging them.  Though it doesn't really matter much,
+		 * it is puzzling to see some stuck in pages_volatile until
+		 * other activity jostles them out, and they also prevented
+		 * LTP's KSM test from succeeding deterministically; so drain
+		 * them here (here rather than on entry to ksm_do_scan(),
+		 * so we don't IPI too often when pages_to_scan is set low).
+		 */
+		lru_add_drain_all();
+
 		root_unstable_tree = RB_ROOT;
 
 		spin_lock(&ksm_mmlist_lock);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
