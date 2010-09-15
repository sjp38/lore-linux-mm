Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id D9F136B007E
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 13:18:21 -0400 (EDT)
Date: Wed, 15 Sep 2010 19:18:16 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH] unlink_anon_vmas in __split_vma in case of error
Message-ID: <20100915171816.GQ5981@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Marcelo Tosatti <mtosatti@redhat.com>
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>

If __split_vma fails because of an out of memory condition the
anon_vma_chain isn't teardown and freed potentially leading to rmap
walks accessing freed vma information plus there's a memleak.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---

diff --git a/mm/mmap.c b/mm/mmap.c
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2014,6 +2014,7 @@ static int __split_vma(struct mm_struct 
 			removed_exe_file_vma(mm);
 		fput(new->vm_file);
 	}
+	unlink_anon_vmas(new);
  out_free_mpol:
 	mpol_put(pol);
  out_free_vma:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
