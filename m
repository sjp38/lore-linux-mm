Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 51E296B006E
	for <linux-mm@kvack.org>; Tue,  4 Sep 2012 19:40:03 -0400 (EDT)
Received: by pbbro12 with SMTP id ro12so10939929pbb.14
        for <linux-mm@kvack.org>; Tue, 04 Sep 2012 16:40:02 -0700 (PDT)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH] mm: fix potential anon_vma locking issue in mprotect()
Date: Tue,  4 Sep 2012 16:39:49 -0700
Message-Id: <1346801989-18274-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, akpm@linux-foundation.org
Cc: aarcange@redhat.com

This change fixes an anon_vma locking issue in the following situation:
- vma has no anon_vma
- next has an anon_vma
- vma is being shrunk / next is being expanded, due to an mprotect call

We need to take next's anon_vma lock to avoid races with rmap users
(such as page migration) while next is being expanded.

Signed-off-by: Michel Lespinasse <walken@google.com>
---
 mm/mmap.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index 3edfcdfa42d9..6fd7afa0e651 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -578,8 +578,12 @@ again:			remove_next = 1 + (end > next->vm_end);
 	 */
 	if (vma->anon_vma && (importer || start != vma->vm_start)) {
 		anon_vma = vma->anon_vma;
+		VM_BUG_ON(adjust_next && next->anon_vma &&
+			  anon_vma != next->anon_vma);
+	} else if (adjust_next && next->anon_vma)
+		anon_vma = next->anon_vma;
+	if (anon_vma)
 		anon_vma_lock(anon_vma);
-	}
 
 	if (root) {
 		flush_dcache_mmap_lock(mapping);
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
