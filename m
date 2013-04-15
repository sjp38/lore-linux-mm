Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 08A8A6B0036
	for <linux-mm@kvack.org>; Mon, 15 Apr 2013 08:52:03 -0400 (EDT)
From: Libin <huawei.libin@huawei.com>
Subject: [PATCH 3/6] ncpfs: use vma_pages() to replace (vm_end - vm_start) >> PAGE_SHIFT
Date: Mon, 15 Apr 2013 20:48:55 +0800
Message-ID: <1366030138-71292-3-git-send-email-huawei.libin@huawei.com>
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
 fs/ncpfs/mmap.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/ncpfs/mmap.c b/fs/ncpfs/mmap.c
index ee24df5..3c5dd55 100644
--- a/fs/ncpfs/mmap.c
+++ b/fs/ncpfs/mmap.c
@@ -117,7 +117,7 @@ int ncp_mmap(struct file *file, struct vm_area_struct *vma)
 		return -EINVAL;
 	/* we do not support files bigger than 4GB... We eventually 
 	   supports just 4GB... */
-	if (((vma->vm_end - vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff 
+	if (vma_pages(vma) + vma->vm_pgoff
 	   > (1U << (32 - PAGE_SHIFT)))
 		return -EFBIG;
 
-- 
1.8.2.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
