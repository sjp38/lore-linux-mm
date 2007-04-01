From: Paolo 'Blaisorblade' Giarrusso <blaisorblade@yahoo.it>
Subject: [PATCH] rfp: move prot checking before any change, as needed
Date: Sun, 01 Apr 2007 21:42:36 +0200
Message-ID: <20070401194228.7625.10288.stgit@americanbeauty.home.lan>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This bug was introduced during the recent port over Nick Piggin's
remap_file_pages rewrite.

Signed-off-by: Paolo 'Blaisorblade' Giarrusso <blaisorblade@yahoo.it>
---

 mm/fremap.c |   28 ++++++++++++++--------------
 1 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/mm/fremap.c b/mm/fremap.c
index 83aaa8c..9befb12 100644
--- a/mm/fremap.c
+++ b/mm/fremap.c
@@ -170,6 +170,20 @@ asmlinkage long sys_remap_file_pages(unsigned long start, unsigned long size,
 	if (end <= start || start < vma->vm_start || end > vma->vm_end)
 		goto out;
 
+	if (flags & MAP_CHGPROT) {
+		unsigned long vm_prots = calc_vm_prot_bits(prot);
+
+		/* vma->vm_flags >> 4 shifts VM_MAY% in place of VM_% */
+		if ((vm_prots & ~(vma->vm_flags >> 4)) &
+				(VM_READ | VM_WRITE | VM_EXEC)) {
+			err = -EPERM;
+			goto out;
+		}
+
+		pgprot = protection_map[vm_prots | VM_SHARED];
+	} else
+		pgprot = vma->vm_page_prot;
+
 	/* Must set VM_NONLINEAR before any pages are populated. */
 	if (!(vma->vm_flags & VM_NONLINEAR)) {
 		/* Don't need a nonlinear mapping, exit success */
@@ -208,20 +222,6 @@ asmlinkage long sys_remap_file_pages(unsigned long start, unsigned long size,
 		}
 	}
 
-	if (flags & MAP_CHGPROT) {
-		unsigned long vm_prots = calc_vm_prot_bits(prot);
-
-		/* vma->vm_flags >> 4 shifts VM_MAY% in place of VM_% */
-		if ((vm_prots & ~(vma->vm_flags >> 4)) &
-				(VM_READ | VM_WRITE | VM_EXEC)) {
-			err = -EPERM;
-			goto out;
-		}
-
-		pgprot = protection_map[vm_prots | VM_SHARED];
-	} else
-		pgprot = vma->vm_page_prot;
-
 	err = populate_range(mm, vma, start, size, pgoff, pgprot);
 	if (!err && !(flags & MAP_NONBLOCK)) {
 		if (unlikely(has_write_lock)) {



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
