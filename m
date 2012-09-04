Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 897D46B0069
	for <linux-mm@kvack.org>; Tue,  4 Sep 2012 05:21:14 -0400 (EDT)
Received: by pbbro12 with SMTP id ro12so9747862pbb.14
        for <linux-mm@kvack.org>; Tue, 04 Sep 2012 02:21:13 -0700 (PDT)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH 2/7] mm: fix potential anon_vma locking issue in mprotect()
Date: Tue,  4 Sep 2012 02:20:52 -0700
Message-Id: <1346750457-12385-3-git-send-email-walken@google.com>
In-Reply-To: <1346750457-12385-1-git-send-email-walken@google.com>
References: <1346750457-12385-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, riel@redhat.com, peterz@infradead.org, aarcange@redhat.com, hughd@google.com, daniel.santos@pobox.com
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org

This change fixes an anon_vma locking issue in the following situation:
- vma has no anon_vma
- next has an anon_vma
- vma is being shrunk / next is being expanded, due to an mprotect call

We need to take next's anon_vma lock to avoid races with rmap users
(such as page migration) while next is being expanded.

This change also removes an optimization which avoided taking anon_vma
lock during brk adjustments. We could probably make that optimization
work again, but the following anon rmap change would break it,
so I kept things as simple as possible here.

Signed-off-by: Michel Lespinasse <walken@google.com>
---
 mm/mmap.c |   14 ++++++--------
 1 files changed, 6 insertions(+), 8 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index cebc346ba0db..5e64c7dfc090 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -570,14 +570,12 @@ again:			remove_next = 1 + (end > next->vm_end);
 
 	vma_adjust_trans_huge(vma, start, end, adjust_next);
 
-	/*
-	 * When changing only vma->vm_end, we don't really need anon_vma
-	 * lock. This is a fairly rare case by itself, but the anon_vma
-	 * lock may be shared between many sibling processes.  Skipping
-	 * the lock for brk adjustments makes a difference sometimes.
-	 */
-	if (vma->anon_vma && (importer || start != vma->vm_start)) {
-		anon_vma = vma->anon_vma;
+	anon_vma = vma->anon_vma;
+	if (!anon_vma && adjust_next)
+		anon_vma = next->anon_vma;
+	if (anon_vma) {
+		VM_BUG_ON(adjust_next && next->anon_vma &&
+			  anon_vma != next->anon_vma);
 		anon_vma_lock(anon_vma);
 	}
 
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
