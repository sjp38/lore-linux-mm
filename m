Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 519296B0128
	for <linux-mm@kvack.org>; Wed, 12 Sep 2012 22:41:08 -0400 (EDT)
From: Bob Liu <lliubbo@gmail.com>
Subject: [PATCH] nommu: remap_pfn_range: fix addr parameter check
Date: Thu, 13 Sep 2012 10:40:57 +0800
Message-ID: <1347504057-5612-1-git-send-email-lliubbo@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, bhupesh.sharma@st.com, laurent.pinchart@ideasonboard.com, uclinux-dist-devel@blackfin.uclinux.org, linux-media@vger.kernel.org, dhowells@redhat.com, geert@linux-m68k.org, gerg@uclinux.org, stable@kernel.org, gregkh@linuxfoundation.org, Bob Liu <lliubbo@gmail.com>

The addr parameter may not page aligned eg. when it's come from
vfb_mmap():vma->vm_start in video driver.

This patch fix the check in remap_pfn_range() else some driver like v4l2 will
fail in this function while calling mmap() on nommu arch like blackfin and st.

Reported-by: Bhupesh SHARMA <bhupesh.sharma@st.com>
Reported-by: Scott Jiang <scott.jiang.linux@gmail.com>
Signed-off-by: Bob Liu <lliubbo@gmail.com>
---
 mm/nommu.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/nommu.c b/mm/nommu.c
index d4b0c10..5d6068b 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -1819,7 +1819,7 @@ struct page *follow_page(struct vm_area_struct *vma, unsigned long address,
 int remap_pfn_range(struct vm_area_struct *vma, unsigned long addr,
 		unsigned long pfn, unsigned long size, pgprot_t prot)
 {
-	if (addr != (pfn << PAGE_SHIFT))
+	if ((addr & PAGE_MASK) != (pfn << PAGE_SHIFT))
 		return -EINVAL;
 
 	vma->vm_flags |= VM_IO | VM_RESERVED | VM_PFNMAP;
-- 
1.7.9.5


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
