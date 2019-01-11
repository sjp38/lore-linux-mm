Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id DC6378E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 10:08:36 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id o9so8585515pgv.19
        for <linux-mm@kvack.org>; Fri, 11 Jan 2019 07:08:36 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s20sor3526226plr.50.2019.01.11.07.08.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 11 Jan 2019 07:08:35 -0800 (PST)
Date: Fri, 11 Jan 2019 20:42:35 +0530
From: Souptick Joarder <jrdr.linux@gmail.com>
Subject: [PATCH 8/9] xen/gntdev.c: Convert to use vm_insert_range
Message-ID: <20190111151235.GA2836@jordon-HP-15-Notebook-PC>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, willy@infradead.org, mhocko@suse.com, boris.ostrovsky@oracle.com, jgross@suse.com, linux@armlinux.org.uk, robin.murphy@arm.com
Cc: xen-devel@lists.xenproject.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Convert to use vm_insert_range() to map range of kernel
memory to user vma.

Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
---
 drivers/xen/gntdev.c | 16 ++++++----------
 1 file changed, 6 insertions(+), 10 deletions(-)

diff --git a/drivers/xen/gntdev.c b/drivers/xen/gntdev.c
index b0b02a5..ca4acee 100644
--- a/drivers/xen/gntdev.c
+++ b/drivers/xen/gntdev.c
@@ -1082,18 +1082,17 @@ static int gntdev_mmap(struct file *flip, struct vm_area_struct *vma)
 {
 	struct gntdev_priv *priv = flip->private_data;
 	int index = vma->vm_pgoff;
-	int count = vma_pages(vma);
 	struct gntdev_grant_map *map;
-	int i, err = -EINVAL;
+	int err = -EINVAL;
 
 	if ((vma->vm_flags & VM_WRITE) && !(vma->vm_flags & VM_SHARED))
 		return -EINVAL;
 
 	pr_debug("map %d+%d at %lx (pgoff %lx)\n",
-			index, count, vma->vm_start, vma->vm_pgoff);
+			index, vma_pages(vma), vma->vm_start, vma->vm_pgoff);
 
 	mutex_lock(&priv->lock);
-	map = gntdev_find_map_index(priv, index, count);
+	map = gntdev_find_map_index(priv, index, vma_pages(vma));
 	if (!map)
 		goto unlock_out;
 	if (use_ptemod && map->vma)
@@ -1145,12 +1144,9 @@ static int gntdev_mmap(struct file *flip, struct vm_area_struct *vma)
 		goto out_put_map;
 
 	if (!use_ptemod) {
-		for (i = 0; i < count; i++) {
-			err = vm_insert_page(vma, vma->vm_start + i*PAGE_SIZE,
-				map->pages[i]);
-			if (err)
-				goto out_put_map;
-		}
+		err = vm_insert_range(vma, map->pages, map->count);
+		if (err)
+			goto out_put_map;
 	} else {
 #ifdef CONFIG_X86
 		/*
-- 
1.9.1
