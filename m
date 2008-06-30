From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH] mm: fix uninitialized variables for find_vma_prepare callers
Date: Mon, 30 Jun 2008 19:54:42 +0300
Message-Id: <1214844882-22560-1-git-send-email-bhalevy@panasas.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Benny Halevy <bhalevy@panasas.com>
List-ID: <linux-mm.kvack.org>

gcc 4.3.0 correctly emits the following warnings.
When a vma covering addr is found, find_vma_prepare indeed returns without
setting pprev, rb_link, and rb_parent.

/usr0/export/dev/bhalevy/git/linux-pnfs-bh-nfs41/mm/mmap.c: In function a??insert_vm_structa??:
/usr0/export/dev/bhalevy/git/linux-pnfs-bh-nfs41/mm/mmap.c:2085: warning: a??rb_parenta?? may be used uninitialized in this function
/usr0/export/dev/bhalevy/git/linux-pnfs-bh-nfs41/mm/mmap.c:2085: warning: a??rb_linka?? may be used uninitialized in this function
/usr0/export/dev/bhalevy/git/linux-pnfs-bh-nfs41/mm/mmap.c:2084: warning: a??preva?? may be used uninitialized in this function
/usr0/export/dev/bhalevy/git/linux-pnfs-bh-nfs41/mm/mmap.c: In function a??copy_vmaa??:
/usr0/export/dev/bhalevy/git/linux-pnfs-bh-nfs41/mm/mmap.c:2124: warning: a??rb_parenta?? may be used uninitialized in this function
/usr0/export/dev/bhalevy/git/linux-pnfs-bh-nfs41/mm/mmap.c:2124: warning: a??rb_linka?? may be used uninitialized in this function
/usr0/export/dev/bhalevy/git/linux-pnfs-bh-nfs41/mm/mmap.c:2123: warning: a??preva?? may be used uninitialized in this function
/usr0/export/dev/bhalevy/git/linux-pnfs-bh-nfs41/mm/mmap.c: In function a??do_brka??:
/usr0/export/dev/bhalevy/git/linux-pnfs-bh-nfs41/mm/mmap.c:1951: warning: a??rb_parenta?? may be used uninitialized in this function
/usr0/export/dev/bhalevy/git/linux-pnfs-bh-nfs41/mm/mmap.c:1951: warning: a??rb_linka?? may be used uninitialized in this function
/usr0/export/dev/bhalevy/git/linux-pnfs-bh-nfs41/mm/mmap.c:1949: warning: a??preva?? may be used uninitialized in this function
/usr0/export/dev/bhalevy/git/linux-pnfs-bh-nfs41/mm/mmap.c: In function a??mmap_regiona??:
/usr0/export/dev/bhalevy/git/linux-pnfs-bh-nfs41/mm/mmap.c:1092: warning: a??rb_parenta?? may be used uninitialized in this function
/usr0/export/dev/bhalevy/git/linux-pnfs-bh-nfs41/mm/mmap.c:1092: warning: a??rb_linka?? may be used uninitialized in this function
/usr0/export/dev/bhalevy/git/linux-pnfs-bh-nfs41/mm/mmap.c:1089: warning: a??preva?? may be used uninitialized in this function

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 mm/mmap.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index 3354fdd..81b9873 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -366,7 +366,7 @@ find_vma_prepare(struct mm_struct *mm, unsigned long addr,
 		if (vma_tmp->vm_end > addr) {
 			vma = vma_tmp;
 			if (vma_tmp->vm_start <= addr)
-				return vma;
+				break;
 			__rb_link = &__rb_parent->rb_left;
 		} else {
 			rb_prev = __rb_parent;
-- 
1.5.6.GIT

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
