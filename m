Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 85AFD6B01BE
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 16:39:45 -0400 (EDT)
Date: Mon, 21 Jun 2010 16:34:39 -0400
From: Rik van Riel <riel@redhat.com>
Subject: [PATCH -mm 3/6] ksm: fix ksm swapin time optimization
Message-ID: <20100621163439.4e76c2f8@annuminas.surriel.com>
In-Reply-To: <20100621163146.4e4e30cb@annuminas.surriel.com>
References: <20100621163146.4e4e30cb@annuminas.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, aarcange@redhat.com, linux-mm@kvack.org, avi@redhat.com
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>
Subject: fix ksm swapin time optimization

The new anon-vma code, was suboptimal and it lead to erratic invocation of
ksm_does_need_to_copy. That leads to host hangs or guest vnc lockup, or weird
behavior.  It's unclear why ksm_does_need_to_copy is unstable but the point is
that when KSM is not in use, ksm_does_need_to_copy must never run or we bounce
pages for no good reason. I suspect the same hangs will happen with KVM swaps.
But this at least fixes the regression in the new-anon-vma code and it only let
KSM bugs triggers when KSM is in use.

The code in do_swap_page likely doesn't cope well with a not-swapcache,
especially the memcg code.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Rik van Riel <riel@redhat.com>
---

diff --git a/include/linux/ksm.h b/include/linux/ksm.h
--- a/include/linux/ksm.h
+++ b/include/linux/ksm.h
@@ -78,7 +78,7 @@ static inline struct page *ksm_might_nee
 	struct anon_vma *anon_vma = page_anon_vma(page);
 
 	if (!anon_vma ||
-	    (anon_vma == vma->anon_vma &&
+	    (anon_vma->root == vma->anon_vma->root &&
 	     page->index == linear_page_index(vma, address)))
 		return page;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
