Date: Sun, 26 Jun 2005 18:35:40 -0400 (EDT)
From: Rik Van Riel <riel@redhat.com>
Subject: [PATCH] 2/2 swap token tuning
In-Reply-To: <Pine.LNX.4.61.0506261827500.18834@chimarrao.boston.redhat.com>
Message-ID: <Pine.LNX.4.61.0506261835000.18834@chimarrao.boston.redhat.com>
References: <Pine.LNX.4.61.0506261827500.18834@chimarrao.boston.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Song Jiang <sjiang@lanl.gov>
List-ID: <linux-mm.kvack.org>

It turns out that the original swap token implementation, by Song
Jiang, only enforced the swap token while the task holding the
token is handling a page fault.  This patch approximates that,
without adding an additional flag to the mm_struct, by checking
whether the mm->mmap_sem is held for reading, like the page
fault code does.

This patch should have the effect of automatically, and gradually,
disabling the enforcement of the swap token when there is little
or no paging going on, and "turning up" the intensity of the swap
token code the more the task holding the token is thrashing.

Thanks to Song Jiang for pointing out this aspect of the token
based thrashing control concept.

Signed-off-by: Rik van Riel

--- 2.6.12-swaptoken/mm/thrash.c.orig	2005-06-17 15:48:29.000000000 -0400
+++ 2.6.12-swaptoken/mm/thrash.c	2005-06-26 17:17:04.000000000 -0400
@@ -19,7 +19,7 @@ static unsigned long swap_token_check;
 struct mm_struct * swap_token_mm = &init_mm;
 
 #define SWAP_TOKEN_CHECK_INTERVAL (HZ * 2)
-#define SWAP_TOKEN_TIMEOUT	0
+#define SWAP_TOKEN_TIMEOUT	300
 /*
  * Currently disabled; Needs further code to work at HZ * 300.
  */
--- 2.6.12-swaptoken/mm/rmap.c.orig	2005-06-26 17:16:50.000000000 -0400
+++ 2.6.12-swaptoken/mm/rmap.c	2005-06-26 17:13:17.000000000 -0400
@@ -301,7 +301,11 @@ static int page_referenced_one(struct pa
 		if (ptep_clear_flush_young(vma, address, pte))
 			referenced++;
 
-		if (mm != current->mm && !ignore_token && has_swap_token(mm))
+		/* Pretend the page is referenced if the task has the
+		   swap token and is in the middle of a page fault. */
+		if (mm != current->mm && !ignore_token &&
+				has_swap_token(mm) &&
+				sem_is_read_locked(mm->mmap_sem))
 			referenced++;
 
 		(*mapcount)--;
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
