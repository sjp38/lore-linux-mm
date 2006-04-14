Date: Thu, 13 Apr 2006 17:36:53 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 2/5] Swapless V2: Add migration swap entries
In-Reply-To: <20060413171331.1752e21f.akpm@osdl.org>
Message-ID: <Pine.LNX.4.64.0604131735550.15910@schroedinger.engr.sgi.com>
References: <20060413235406.15398.42233.sendpatchset@schroedinger.engr.sgi.com>
 <20060413235416.15398.49978.sendpatchset@schroedinger.engr.sgi.com>
 <20060413171331.1752e21f.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: hugh@veritas.com, linux-kernel@vger.kernel.org, lee.schermerhorn@hp.com, linux-mm@kvack.org, taka@valinux.co.jp, marcelo.tosatti@cyclades.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

1. Add explanation for the yield

2. Move unlikely to is_migration_entry (Does that really work??)

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.17-rc1-mm2/mm/memory.c
===================================================================
--- linux-2.6.17-rc1-mm2.orig/mm/memory.c	2006-04-13 16:43:10.000000000 -0700
+++ linux-2.6.17-rc1-mm2/mm/memory.c	2006-04-13 17:32:36.000000000 -0700
@@ -1880,7 +1880,11 @@ static int do_swap_page(struct mm_struct
 
 	entry = pte_to_swp_entry(orig_pte);
 
-	if (unlikely(is_migration_entry(entry))) {
+	if (is_migration_entry(entry)) {
+		/*
+		 * We cannot access the page because of ongoing page
+		 * migration. See if we can do something else.
+		 */
 		yield();
 		goto out;
 	}
Index: linux-2.6.17-rc1-mm2/include/linux/swapops.h
===================================================================
--- linux-2.6.17-rc1-mm2.orig/include/linux/swapops.h	2006-04-13 16:43:10.000000000 -0700
+++ linux-2.6.17-rc1-mm2/include/linux/swapops.h	2006-04-13 17:32:58.000000000 -0700
@@ -77,7 +77,7 @@ static inline swp_entry_t make_migration
 
 static inline int is_migration_entry(swp_entry_t entry)
 {
-	return swp_type(entry) == SWP_TYPE_MIGRATION;
+	return unlikely(swp_type(entry) == SWP_TYPE_MIGRATION);
 }
 
 static inline struct page *migration_entry_to_page(swp_entry_t entry)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
