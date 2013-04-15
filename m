Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 9AF576B0002
	for <linux-mm@kvack.org>; Mon, 15 Apr 2013 08:51:51 -0400 (EDT)
From: Libin <huawei.libin@huawei.com>
Subject: [PATCH 1/6] mm: use vma_pages() to replace (vm_end - vm_start) >> PAGE_SHIFT
Date: Mon, 15 Apr 2013 20:48:53 +0800
Message-ID: <1366030138-71292-1-git-send-email-huawei.libin@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, David Airlie <airlied@linux.ie>, Bjorn Helgaas <bhelgaas@google.com>, "Hans J. Koch" <hjk@hansjkoch.de>, Petr Vandrovec <petr@vandrovec.name>, Andrew Morton <akpm@linux-foundation.org>
Cc: Konstantin Khlebnikov <khlebnikov@openvz.org>, Thomas Hellstrom <thellstrom@vmware.com>, Dave Airlie <airlied@redhat.com>, Nadia Yvette Chambers <nyc@holomorphy.com>, Jiri Kosina <jkosina@suse.cz>, Al Viro <viro@zeniv.linux.org.uk>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Michel Lespinasse <walken@google.com>, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, guohanjun@huawei.com, wangyijing@huawei.com

(*->vm_end - *->vm_start) >> PAGE_SHIFT operation is implemented
as a inline funcion vma_pages() in linux/mm.h, so using it.

Signed-off-by: Libin <huawei.libin@huawei.com>
---
 mm/memory.c | 2 +-
 mm/mmap.c   | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 13cbc42..8b8ae1c 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2866,7 +2866,7 @@ static inline void unmap_mapping_range_tree(struct rb_root *root,
 			details->first_index, details->last_index) {
 
 		vba = vma->vm_pgoff;
-		vea = vba + ((vma->vm_end - vma->vm_start) >> PAGE_SHIFT) - 1;
+		vea = vba + vma_pages(vma) - 1;
 		/* Assume for now that PAGE_CACHE_SHIFT == PAGE_SHIFT */
 		zba = details->first_index;
 		if (zba < vba)
diff --git a/mm/mmap.c b/mm/mmap.c
index 0db0de1..118bfcb 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -919,7 +919,7 @@ can_vma_merge_after(struct vm_area_struct *vma, unsigned long vm_flags,
 	if (is_mergeable_vma(vma, file, vm_flags) &&
 	    is_mergeable_anon_vma(anon_vma, vma->anon_vma, vma)) {
 		pgoff_t vm_pglen;
-		vm_pglen = (vma->vm_end - vma->vm_start) >> PAGE_SHIFT;
+		vm_pglen = vma_pages(vma);
 		if (vma->vm_pgoff + vm_pglen == vm_pgoff)
 			return 1;
 	}
-- 
1.8.2.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
