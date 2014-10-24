Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 3D2D9900017
	for <linux-mm@kvack.org>; Fri, 24 Oct 2014 18:06:53 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id lj1so1883972pab.32
        for <linux-mm@kvack.org>; Fri, 24 Oct 2014 15:06:52 -0700 (PDT)
Received: from homiemail-a38.g.dreamhost.com (homie.mail.dreamhost.com. [208.97.132.208])
        by mx.google.com with ESMTP id fz2si5161333pdb.100.2014.10.24.15.06.52
        for <linux-mm@kvack.org>;
        Fri, 24 Oct 2014 15:06:52 -0700 (PDT)
From: Davidlohr Bueso <dave@stgolabs.net>
Subject: [PATCH 08/10] mm/mremap: share the i_mmap_rwsem
Date: Fri, 24 Oct 2014 15:06:18 -0700
Message-Id: <1414188380-17376-9-git-send-email-dave@stgolabs.net>
In-Reply-To: <1414188380-17376-1-git-send-email-dave@stgolabs.net>
References: <1414188380-17376-1-git-send-email-dave@stgolabs.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: hughd@google.com, riel@redhat.com, mgorman@suse.de, peterz@infradead.org, mingo@kernel.org, linux-kernel@vger.kernel.org, dbueso@suse.de, linux-mm@kvack.org, Davidlohr Bueso <dave@stgolabs.net>

As per the comment in move_ptes(), we only require taking the
anon vma and i_mmap locks to ensure that rmap will always observe
either the old or new ptes, in the case of need_rmap_lock=true.
No modifications to the tree itself, thus share the i_mmap_rwsem.

Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
---
XXX: the same *should* apply for the anon vma, as there are
no modifications to the chain.

 mm/mremap.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/mremap.c b/mm/mremap.c
index 84aa36f..a34500c 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -119,7 +119,7 @@ static void move_ptes(struct vm_area_struct *vma, pmd_t *old_pmd,
 	if (need_rmap_locks) {
 		if (vma->vm_file) {
 			mapping = vma->vm_file->f_mapping;
-			i_mmap_lock_write(mapping);
+			i_mmap_lock_read(mapping);
 		}
 		if (vma->anon_vma) {
 			anon_vma = vma->anon_vma;
@@ -156,7 +156,7 @@ static void move_ptes(struct vm_area_struct *vma, pmd_t *old_pmd,
 	if (anon_vma)
 		anon_vma_unlock_write(anon_vma);
 	if (mapping)
-		i_mmap_unlock_write(mapping);
+		i_mmap_unlock_read(mapping);
 }
 
 #define LATENCY_LIMIT	(64 * PAGE_SIZE)
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
