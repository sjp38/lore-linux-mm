Date: Mon, 5 Feb 2007 12:53:06 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20070205205306.4500.54337.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20070205205235.4500.54958.sendpatchset@schroedinger.engr.sgi.com>
References: <20070205205235.4500.54958.sendpatchset@schroedinger.engr.sgi.com>
Subject: [RFC 6/7] Avoid putting new mlocked anonymous pages on LRU
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: akpm@osdl.org, Christoph Hellwig <hch@infradead.org>, Arjan van de Ven <arjan@infradead.org>, Nigel Cunningham <nigel@nigel.suspend2.net>, "Martin J. Bligh" <mbligh@mbligh.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <nickpiggin@yahoo.com.au>, Christoph Lameter <clameter@sgi.com>, Matt Mackall <mpm@selenic.com>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Mark new anonymous pages mlocked if they are in a mlocked VMA.

Avoid putting pages onto the LRU that are allocated in a VMA
with VM_LOCKED set. NR_MLOCK will be more accurate.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: current/mm/memory.c
===================================================================
--- current.orig/mm/memory.c	2007-02-05 12:32:34.000000000 -0800
+++ current/mm/memory.c	2007-02-05 12:31:57.000000000 -0800
@@ -906,7 +906,15 @@ static void add_anon_page(struct vm_area
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
