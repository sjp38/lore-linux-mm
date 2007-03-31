From: Paolo 'Blaisorblade' Giarrusso <blaisorblade@yahoo.it>
Subject: [PATCH 11/11] RFP prot support: also set VM_NONLINEAR on nonuniform
	VMAs
Date: Sat, 31 Mar 2007 02:36:07 +0200
Message-ID: <20070331003606.3415.39527.stgit@americanbeauty.home.lan>
In-Reply-To: <20070331003453.3415.70825.stgit@americanbeauty.home.lan>
References: <20070331003453.3415.70825.stgit@americanbeauty.home.lan>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: mingo@redhat.com, linux-mm@kvack.org, Jeff Dike <jdike@addtoit.com>, Paolo 'Blaisorblade' Giarrusso <blaisorblade@yahoo.it>
List-ID: <linux-mm.kvack.org>

To simplify the VM code, and to reflect expected application usage, we decide
to also set VM_NONLINEAR when setting VM_MANYPROTS. Otherwise, we'd have to
possibly save nonlinear PTEs even on paths which cope with linear VMAs. It's
possible, but intrusive (it's done in one of the next patches).

Obviously, this has a performance cost, since we potentially have to handle a
linear VMA with nonlinear handling code. But I didn't know of any application
which might have this usage.

XXX: update: glibc wants to replace mprotect() with linear VM_MANYPROTS areas,
to handle guard pages and data mappings of shared objects.

Signed-off-by: Paolo 'Blaisorblade' Giarrusso <blaisorblade@yahoo.it>
---

 mm/fremap.c |   22 ++++++++++------------
 1 files changed, 10 insertions(+), 12 deletions(-)

diff --git a/mm/fremap.c b/mm/fremap.c
index f4536e9..83aaa8c 100644
--- a/mm/fremap.c
+++ b/mm/fremap.c
@@ -173,7 +173,8 @@ asmlinkage long sys_remap_file_pages(unsigned long start, unsigned long size,
 	/* Must set VM_NONLINEAR before any pages are populated. */
 	if (!(vma->vm_flags & VM_NONLINEAR)) {
 		/* Don't need a nonlinear mapping, exit success */
-		if (pgoff == linear_page_index(vma, start)) {
+		if (pgoff == linear_page_index(vma, start) &&
+				!(flags & MAP_CHGPROT)) {
 			err = 0;
 			goto out;
 		}
@@ -195,19 +196,16 @@ asmlinkage long sys_remap_file_pages(unsigned long start, unsigned long size,
 		vma_nonlinear_insert(vma, &mapping->i_mmap_nonlinear);
 		flush_dcache_mmap_unlock(mapping);
 		spin_unlock(&mapping->i_mmap_lock);
-	}
 
-	if (flags & MAP_CHGPROT && !(vma->vm_flags & VM_MANYPROTS)) {
-		if (!(vma->vm_flags & VM_SHARED))
-			goto out;
-
-		if (!has_write_lock) {
-			up_read(&mm->mmap_sem);
-			down_write(&mm->mmap_sem);
-			has_write_lock = 1;
-			goto retry;
+		if (flags & MAP_CHGPROT && !(vma->vm_flags & VM_MANYPROTS)) {
+			if (!has_write_lock) {
+				up_read(&mm->mmap_sem);
+				down_write(&mm->mmap_sem);
+				has_write_lock = 1;
+				goto retry;
+			}
+			vma->vm_flags |= VM_MANYPROTS;
 		}
-		vma->vm_flags |= VM_MANYPROTS;
 	}
 
 	if (flags & MAP_CHGPROT) {



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
