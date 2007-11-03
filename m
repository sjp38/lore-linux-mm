Date: Sat, 3 Nov 2007 19:06:00 -0400
From: Rik van Riel <riel@redhat.com>
Subject: [RFC PATCH 10/10] add swapped in pages to the inactive list
Message-ID: <20071103190600.4b47c9c0@bree.surriel.com>
In-Reply-To: <20071103184229.3f20e2f0@bree.surriel.com>
References: <20071103184229.3f20e2f0@bree.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Swapin_readahead can read in a lot of data that the processes in
memory never need.  Adding swap cache pages to the inactive list
prevents them from putting too much pressure on the working set.

This has the potential to help the programs that are already in
memory, but it could also be a disadvantage to processes that
are trying to get swapped in.

In short, this patch needs testing.

Signed-off-by: Rik van Riel <riel@redhat.com>

Index: linux-2.6.23-mm1/mm/swap_state.c
===================================================================
--- linux-2.6.23-mm1.orig/mm/swap_state.c
+++ linux-2.6.23-mm1/mm/swap_state.c
@@ -370,7 +370,7 @@ struct page *read_swap_cache_async(swp_e
 			/*
 			 * Initiate read into locked page and return.
 			 */
-			lru_cache_add_active_anon(new_page);
+			lru_cache_add_anon(new_page);
 			swap_readpage(NULL, new_page);
 			return new_page;
 		}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
