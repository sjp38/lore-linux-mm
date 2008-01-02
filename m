From: linux-kernel@vger.kernel.org
Subject: [patch 09/19] add newly swapped in pages to the inactive list
Date: Wed, 02 Jan 2008 17:41:53 -0500
Message-ID: <20080102224154.499729234@redhat.com>
References: <20080102224144.885671949@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759176AbYABXYJ@vger.kernel.org>
Content-Disposition: inline; filename=rvr-swapin-inactive.patch
Sender: linux-kernel-owner@vger.kernel.org
Cc: linux-mm@kvack.org, lee.schermerhorn@hp.com
List-Id: linux-mm.kvack.org

Swapin_readahead can read in a lot of data that the processes in
memory never need.  Adding swap cache pages to the inactive list
prevents them from putting too much pressure on the working set.

This has the potential to help the programs that are already in
memory, but it could also be a disadvantage to processes that
are trying to get swapped in.

In short, this patch needs testing.

Signed-off-by: Rik van Riel <riel@redhat.com>

Index: linux-2.6.24-rc6-mm1/mm/swap_state.c
===================================================================
--- linux-2.6.24-rc6-mm1.orig/mm/swap_state.c	2008-01-02 12:37:38.000000000 -0500
+++ linux-2.6.24-rc6-mm1/mm/swap_state.c	2008-01-02 12:37:52.000000000 -0500
@@ -300,7 +300,7 @@ struct page *read_swap_cache_async(swp_e
 			/*
 			 * Initiate read into locked page and return.
 			 */
-			lru_cache_add_active_anon(new_page);
+			lru_cache_add_anon(new_page);
 			swap_readpage(NULL, new_page);
 			return new_page;
 		}

-- 
All Rights Reversed

