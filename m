From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20070215012520.5343.55834.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20070215012449.5343.22942.sendpatchset@schroedinger.engr.sgi.com>
References: <20070215012449.5343.22942.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 6/7] Avoid putting new mlocked anonymous pages on LRU
Date: Wed, 14 Feb 2007 17:25:20 -0800 (PST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: Christoph Hellwig <hch@infradead.org>, Arjan van de Ven <arjan@infradead.org>, Nigel Cunningham <nigel@nigel.suspend2.net>, "Martin J. Bligh" <mbligh@mbligh.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>, Matt Mackall <mpm@selenic.com>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Mark new anonymous pages mlocked if they are in a mlocked VMA.

Avoid putting pages onto the LRU that are allocated in a VMA
with VM_LOCKED set. NR_MLOCK will be more accurate.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.20/mm/memory.c
===================================================================
--- linux-2.6.20.orig/mm/memory.c	2007-02-14 12:52:01.000000000 -0800
+++ linux-2.6.20/mm/memory.c	2007-02-14 12:52:36.000000000 -0800
@@ -906,7 +906,16 @@
 				unsigned long address)
 {
 	inc_mm_counter(vma->vm_mm, anon_rss);
-	lru_cache_add_active(page);
+	if (vma->vm_flags & VM_LOCKED) {
+		/*
+		 * Page is new and therefore not on the LRU
+		 * so we can directly mark it as mlocked
+		 */
+		SetPageMlocked(page);
+		ClearPageActive(page);
+		inc_zone_page_state(page, NR_MLOCK);
+	} else
+		lru_cache_add_active(page);
 	page_add_new_anon_rmap(page, vma, address);
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
