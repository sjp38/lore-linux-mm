Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 547886B0006
	for <linux-mm@kvack.org>; Mon, 15 Apr 2013 08:51:54 -0400 (EDT)
From: Libin <huawei.libin@huawei.com>
Subject: [PATCH 5/6] drm: use vma_pages() to replace (vm_end - vm_start) >> PAGE_SHIFT
Date: Mon, 15 Apr 2013 20:48:57 +0800
Message-ID: <1366030138-71292-5-git-send-email-huawei.libin@huawei.com>
In-Reply-To: <1366030138-71292-1-git-send-email-huawei.libin@huawei.com>
References: <1366030138-71292-1-git-send-email-huawei.libin@huawei.com>
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
 drivers/gpu/drm/ttm/ttm_bo_vm.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/gpu/drm/ttm/ttm_bo_vm.c b/drivers/gpu/drm/ttm/ttm_bo_vm.c
index 74705f3..3df9f16 100644
--- a/drivers/gpu/drm/ttm/ttm_bo_vm.c
+++ b/drivers/gpu/drm/ttm/ttm_bo_vm.c
@@ -147,7 +147,7 @@ static int ttm_bo_vm_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 
 	page_offset = ((address - vma->vm_start) >> PAGE_SHIFT) +
 	    bo->vm_node->start - vma->vm_pgoff;
-	page_last = ((vma->vm_end - vma->vm_start) >> PAGE_SHIFT) +
+	page_last = vma_pages(vma) +
 	    bo->vm_node->start - vma->vm_pgoff;
 
 	if (unlikely(page_offset >= bo->num_pages)) {
@@ -258,7 +258,7 @@ int ttm_bo_mmap(struct file *filp, struct vm_area_struct *vma,
 
 	read_lock(&bdev->vm_lock);
 	bo = ttm_bo_vm_lookup_rb(bdev, vma->vm_pgoff,
-				 (vma->vm_end - vma->vm_start) >> PAGE_SHIFT);
+				 vma_pages(vma));
 	if (likely(bo != NULL) && !kref_get_unless_zero(&bo->kref))
 		bo = NULL;
 	read_unlock(&bdev->vm_lock);
-- 
1.8.2.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
