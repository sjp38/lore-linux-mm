Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id C715B6B7B61
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 13:42:00 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id i3so1027217pfj.4
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 10:42:00 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y17sor1811434pll.68.2018.12.06.10.41.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 06 Dec 2018 10:41:59 -0800 (PST)
Date: Fri, 7 Dec 2018 00:15:45 +0530
From: Souptick Joarder <jrdr.linux@gmail.com>
Subject: [PATCH v3 9/9] xen/privcmd-buf.c: Convert to use vm_insert_range
Message-ID: <20181206184545.GA847@jordon-HP-15-Notebook-PC>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, willy@infradead.org, mhocko@suse.com, boris.ostrovsky@oracle.com, jgross@suse.com
Cc: xen-devel@lists.xenproject.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Convert to use vm_insert_range() to map range of kernel
memory to user vma.

Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
Reviewed-by: Matthew Wilcox <willy@infradead.org>
Reviewed-by: Boris Ostrovsky <boris.ostrovsky@oracle.com>
---
 drivers/xen/privcmd-buf.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/drivers/xen/privcmd-buf.c b/drivers/xen/privcmd-buf.c
index df1ed37..8d8255b 100644
--- a/drivers/xen/privcmd-buf.c
+++ b/drivers/xen/privcmd-buf.c
@@ -180,12 +180,8 @@ static int privcmd_buf_mmap(struct file *file, struct vm_area_struct *vma)
 	if (vma_priv->n_pages != count)
 		ret = -ENOMEM;
 	else
-		for (i = 0; i < vma_priv->n_pages; i++) {
-			ret = vm_insert_page(vma, vma->vm_start + i * PAGE_SIZE,
-					     vma_priv->pages[i]);
-			if (ret)
-				break;
-		}
+		ret = vm_insert_range(vma, vma->vm_start, vma_priv->pages,
+				vma_priv->n_pages);
 
 	if (ret)
 		privcmd_buf_vmapriv_free(vma_priv);
-- 
1.9.1
