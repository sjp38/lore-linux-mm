From: Paolo 'Blaisorblade' Giarrusso <blaisorblade@yahoo.it>
Subject: [PATCH RFP-V4 12/13] RFP prot support: also set VM_NONLINEAR on nonuniform VMAs
Date: Sat, 26 Aug 2006 19:42:49 +0200
Message-Id: <20060826174249.14790.91862.stgit@memento.home.lan>
In-Reply-To: <200608261933.36574.blaisorblade@yahoo.it>
References: <200608261933.36574.blaisorblade@yahoo.it>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
From: Paolo 'Blaisorblade' Giarrusso <blaisorblade@yahoo.it>
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
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

 mm/fremap.c |   27 ++++++++++++++-------------
 1 files changed, 14 insertions(+), 13 deletions(-)

diff --git a/mm/fremap.c b/mm/fremap.c
index b1db410..3438caf 100644
--- a/mm/fremap.c
+++ b/mm/fremap.c
@@ -213,8 +213,9 @@ retry:
 
 	if (!vma->vm_private_data || (vma->vm_flags & VM_NONLINEAR)) {
 		/* Must set VM_NONLINEAR before any pages are populated. */
-		if (pgoff != linear_page_index(vma, start) &&
-		    !(vma->vm_flags & VM_NONLINEAR)) {
+		if (!(vma->vm_flags & VM_NONLINEAR) &&
+			(pgoff != linear_page_index(vma, start) ||
+			pgprot_val(pgprot) != pgprot_val(vma->vm_page_prot))) {
 			if (!(vma->vm_flags & VM_SHARED))
 				goto out_unlock;
 			if (!has_write_lock) {
@@ -231,19 +232,19 @@ retry:
 			vma_nonlinear_insert(vma, &mapping->i_mmap_nonlinear);
 			flush_dcache_mmap_unlock(mapping);
 			spin_unlock(&mapping->i_mmap_lock);
-		}
 
-		if (pgprot_val(pgprot) != pgprot_val(vma->vm_page_prot) &&
-				!(vma->vm_flags & VM_MANYPROTS)) {
-			if (!(vma->vm_flags & VM_SHARED))
-				goto out_unlock;
-			if (!has_write_lock) {
-				up_read(&mm->mmap_sem);
-				down_write(&mm->mmap_sem);
-				has_write_lock = 1;
-				goto retry;
+			if (!(vma->vm_flags & VM_MANYPROTS) &&
+				pgprot_val(pgprot) != pgprot_val(vma->vm_page_prot)) {
+				if (!(vma->vm_flags & VM_SHARED))
+					goto out_unlock;
+				if (!has_write_lock) {
+					up_read(&mm->mmap_sem);
+					down_write(&mm->mmap_sem);
+					has_write_lock = 1;
+					goto retry;
+				}
+				vma->vm_flags |= VM_MANYPROTS;
 			}
-			vma->vm_flags |= VM_MANYPROTS;
 		}
 
 		err = vma->vm_ops->populate(vma, start, size, pgprot, pgoff,
Chiacchiera con i tuoi amici in tempo reale! 
 http://it.yahoo.com/mail_it/foot/*http://it.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
