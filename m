From: Paolo 'Blaisorblade' Giarrusso <blaisorblade@yahoo.it>
Subject: [PATCH RFP-V4 08/13] RFP prot support: support private vma for MAP_POPULATE
Date: Sat, 26 Aug 2006 19:42:36 +0200
Message-Id: <20060826174236.14790.79303.stgit@memento.home.lan>
In-Reply-To: <200608261933.36574.blaisorblade@yahoo.it>
References: <200608261933.36574.blaisorblade@yahoo.it>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
From: Ingo Molnar <mingo@elte.hu>
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Fix mmap(MAP_POPULATE | MAP_PRIVATE). We don't need the VMA to be shared if we
don't rearrange pages around. And it's trivial to do.

Signed-off-by: Paolo 'Blaisorblade' Giarrusso <blaisorblade@yahoo.it>
---

 mm/fremap.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/mm/fremap.c b/mm/fremap.c
index e62dc15..b1db410 100644
--- a/mm/fremap.c
+++ b/mm/fremap.c
@@ -191,9 +191,6 @@ retry:
 	if (!vma)
 		goto out_unlock;
 
-	if (!(vma->vm_flags & VM_SHARED))
-		goto out_unlock;
-
 	if (!vma->vm_ops || !vma->vm_ops->populate)
 		goto out_unlock;
 
@@ -218,6 +215,8 @@ retry:
 		/* Must set VM_NONLINEAR before any pages are populated. */
 		if (pgoff != linear_page_index(vma, start) &&
 		    !(vma->vm_flags & VM_NONLINEAR)) {
+			if (!(vma->vm_flags & VM_SHARED))
+				goto out_unlock;
 			if (!has_write_lock) {
 				up_read(&mm->mmap_sem);
 				down_write(&mm->mmap_sem);
@@ -236,6 +235,8 @@ retry:
 
 		if (pgprot_val(pgprot) != pgprot_val(vma->vm_page_prot) &&
 				!(vma->vm_flags & VM_MANYPROTS)) {
+			if (!(vma->vm_flags & VM_SHARED))
+				goto out_unlock;
 			if (!has_write_lock) {
 				up_read(&mm->mmap_sem);
 				down_write(&mm->mmap_sem);
Chiacchiera con i tuoi amici in tempo reale! 
 http://it.yahoo.com/mail_it/foot/*http://it.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
