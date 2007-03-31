From: Paolo 'Blaisorblade' Giarrusso <blaisorblade@yahoo.it>
Subject: [PATCH 10/11] RFP prot support: support private vma for MAP_POPULATE
Date: Sat, 31 Mar 2007 02:36:01 +0200
Message-ID: <20070331003601.3415.86694.stgit@americanbeauty.home.lan>
In-Reply-To: <20070331003453.3415.70825.stgit@americanbeauty.home.lan>
References: <20070331003453.3415.70825.stgit@americanbeauty.home.lan>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Ingo Molnar <mingo@elte.hu>
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: mingo@redhat.com, linux-mm@kvack.org, Jeff Dike <jdike@addtoit.com>, Paolo 'Blaisorblade' Giarrusso <blaisorblade@yahoo.it>
List-ID: <linux-mm.kvack.org>

Fix mmap(MAP_POPULATE | MAP_PRIVATE). We don't need the VMA to be shared if we
don't rearrange pages around. And it's trivial to do.

Signed-off-by: Paolo 'Blaisorblade' Giarrusso <blaisorblade@yahoo.it>
---

 mm/fremap.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/mm/fremap.c b/mm/fremap.c
index b1a4c34..f4536e9 100644
--- a/mm/fremap.c
+++ b/mm/fremap.c
@@ -158,7 +158,7 @@ asmlinkage long sys_remap_file_pages(unsigned long start, unsigned long size,
 	 * the single existing vma.  vm_private_data is used as a
 	 * swapout cursor in a VM_NONLINEAR vma.
 	 */
-	if (!vma || !(vma->vm_flags & VM_SHARED))
+	if (!vma)
 		goto out;
 
 	if (vma->vm_private_data && !(vma->vm_flags & VM_NONLINEAR))
@@ -178,6 +178,9 @@ asmlinkage long sys_remap_file_pages(unsigned long start, unsigned long size,
 			goto out;
 		}
 
+		if (!(vma->vm_flags & VM_SHARED))
+			goto out;
+
 		if (!has_write_lock) {
 			up_read(&mm->mmap_sem);
 			down_write(&mm->mmap_sem);
@@ -195,6 +198,9 @@ asmlinkage long sys_remap_file_pages(unsigned long start, unsigned long size,
 	}
 
 	if (flags & MAP_CHGPROT && !(vma->vm_flags & VM_MANYPROTS)) {
+		if (!(vma->vm_flags & VM_SHARED))
+			goto out;
+
 		if (!has_write_lock) {
 			up_read(&mm->mmap_sem);
 			down_write(&mm->mmap_sem);



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
