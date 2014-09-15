Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f47.google.com (mail-qg0-f47.google.com [209.85.192.47])
	by kanga.kvack.org (Postfix) with ESMTP id E971F6B0038
	for <linux-mm@kvack.org>; Mon, 15 Sep 2014 10:25:38 -0400 (EDT)
Received: by mail-qg0-f47.google.com with SMTP id i50so3981605qgf.6
        for <linux-mm@kvack.org>; Mon, 15 Sep 2014 07:25:37 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o43si14935729qge.17.2014.09.15.07.25.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Sep 2014 07:25:35 -0700 (PDT)
From: "Jerome Marchand" <jmarchan@redhat.com>
Subject: [RFC PATCH v2 3/5] mm, shmem: Add shmem_locate function
Date: Mon, 15 Sep 2014 16:24:35 +0200
Message-Id: <1410791077-5300-4-git-send-email-jmarchan@redhat.com>
In-Reply-To: <1410791077-5300-1-git-send-email-jmarchan@redhat.com>
References: <1410791077-5300-1-git-send-email-jmarchan@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Randy Dunlap <rdunlap@infradead.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux390@de.ibm.com, Hugh Dickins <hughd@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Mackerras <paulus@samba.org>, Ingo Molnar <mingo@redhat.com>, Arnaldo Carvalho de Melo <acme@kernel.org>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-s390@vger.kernel.org, Oleg Nesterov <oleg@redhat.com>

The shmem subsytem is kind of a black box: the generic mm code can't
always know where a specific page physically is. This patch adds the
shmem_locate() function to find out the physical location of shmem
pages (resident, in swap or swapcache). If the optional argument count
isn't NULL and the page is resident, it also returns the mapcount value
of this page.
This is intended to allow finer accounting of shmem/tmpfs pages.

Signed-off-by: Jerome Marchand <jmarchan@redhat.com>
---
 include/linux/shmem_fs.h |  6 ++++++
 mm/shmem.c               | 29 +++++++++++++++++++++++++++++
 2 files changed, 35 insertions(+)

diff --git a/include/linux/shmem_fs.h b/include/linux/shmem_fs.h
index 50777b5..99992cf 100644
--- a/include/linux/shmem_fs.h
+++ b/include/linux/shmem_fs.h
@@ -42,6 +42,11 @@ static inline struct shmem_inode_info *SHMEM_I(struct inode *inode)
 	return container_of(inode, struct shmem_inode_info, vfs_inode);
 }
 
+#define SHMEM_NOTPRESENT	1 /* page is not present in memory */
+#define SHMEM_RESIDENT		2 /* page is resident in RAM */
+#define SHMEM_SWAPCACHE		3 /* page is in swap cache */
+#define SHMEM_SWAP		4 /* page is paged out */
+
 /*
  * Functions in mm/shmem.c called directly from elsewhere:
  */
@@ -59,6 +64,7 @@ extern struct page *shmem_read_mapping_page_gfp(struct address_space *mapping,
 					pgoff_t index, gfp_t gfp_mask);
 extern void shmem_truncate_range(struct inode *inode, loff_t start, loff_t end);
 extern int shmem_unuse(swp_entry_t entry, struct page *page);
+extern int shmem_locate(struct vm_area_struct *vma, pgoff_t pgoff, int *count);
 
 static inline struct page *shmem_read_mapping_page(
 				struct address_space *mapping, pgoff_t index)
diff --git a/mm/shmem.c b/mm/shmem.c
index d547345..134a422 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1350,6 +1350,35 @@ static int shmem_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 	return ret;
 }
 
+int shmem_locate(struct vm_area_struct *vma, pgoff_t pgoff, int *count)
+{
+	struct address_space *mapping = file_inode(vma->vm_file)->i_mapping;
+	struct page *page;
+	swp_entry_t swap;
+	int ret;
+
+	page = find_get_entry(mapping, pgoff);
+	if (!page) /* Not yet initialised? */
+		return SHMEM_NOTPRESENT;
+
+	if (!radix_tree_exceptional_entry(page)) {
+		ret = SHMEM_RESIDENT;
+		if (count)
+			*count = page_mapcount(page);
+		goto out;
+	}
+
+	swap = radix_to_swp_entry(page);
+	page = find_get_page(swap_address_space(swap), swap.val);
+	if (!page)
+		return SHMEM_SWAP;
+	ret = SHMEM_SWAPCACHE;
+
+out:
+	page_cache_release(page);
+	return ret;
+}
+
 #ifdef CONFIG_NUMA
 static int shmem_set_policy(struct vm_area_struct *vma, struct mempolicy *mpol)
 {
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
