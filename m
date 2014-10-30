From: Davidlohr Bueso <dave@stgolabs.net>
Subject: [PATCH 08/10] mm/mremap: share the i_mmap_rwsem
Date: Thu, 30 Oct 2014 12:34:15 -0700
Message-ID: <1414697657-1678-9-git-send-email-dave@stgolabs.net>
References: <1414697657-1678-1-git-send-email-dave@stgolabs.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1414697657-1678-1-git-send-email-dave@stgolabs.net>
Sender: linux-kernel-owner@vger.kernel.org
To: akpm@linux-foundation.org
Cc: hughd@google.com, riel@redhat.com, mgorman@suse.de, peterz@infradead.org, mingo@kernel.org, linux-kernel@vger.kernel.org, dbueso@suse.de, linux-mm@kvack.org, Davidlohr Bueso <dave@stgolabs.net>
List-Id: linux-mm.kvack.org

As per the comment in move_ptes(), we only require taking the
anon vma and i_mmap locks to ensure that rmap will always observe
either the old or new ptes, in the case of need_rmap_lock=true.
No modifications to the tree itself, thus share the i_mmap_rwsem.

Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
Acked-by: Kirill A. Shutemov <kirill.shutemov@intel.linux.com>
---
 mm/mremap.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/mremap.c b/mm/mremap.c
index c929324..09bd644 100644
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
 		anon_vma_unlock_read(anon_vma);
 	if (mapping)
-		i_mmap_unlock_write(mapping);
+		i_mmap_unlock_read(mapping);
 }
 
 #define LATENCY_LIMIT	(64 * PAGE_SIZE)
-- 
1.8.4.5
