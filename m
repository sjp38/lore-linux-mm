Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f43.google.com (mail-qa0-f43.google.com [209.85.216.43])
	by kanga.kvack.org (Postfix) with ESMTP id 60B2F6B0037
	for <linux-mm@kvack.org>; Tue,  1 Jul 2014 09:02:14 -0400 (EDT)
Received: by mail-qa0-f43.google.com with SMTP id k15so7556878qaq.2
        for <linux-mm@kvack.org>; Tue, 01 Jul 2014 06:02:14 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j90si29480399qgf.62.2014.07.01.06.02.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Jul 2014 06:02:13 -0700 (PDT)
From: "Jerome Marchand" <jmarchan@redhat.com>
Subject: [PATCH 2/5] mm, shmem: Add shmem_locate function
Date: Tue,  1 Jul 2014 15:01:58 +0200
Message-Id: <1404219721-32241-3-git-send-email-jmarchan@redhat.com>
In-Reply-To: <1404219721-32241-1-git-send-email-jmarchan@redhat.com>
References: <1404219721-32241-1-git-send-email-jmarchan@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>

The shmem subsytem is kind of a black box: the generic mm code can't
always know where a specific page physically is. This patch adds the
shmem_locate() function to find out the physical location of shmem
pages (resident, in swap or swapcache). If the optional argument count
isn't NULL and the page is resident, it also returns the mapcount value
of this page.
This is intended to allow finer accounting of shmem/tmpfs pages.

Signed-off-by: Jerome Marchand <jmarchan@redhat.com>
---
 include/linux/mm.h |  7 +++++++
 mm/shmem.c         | 29 +++++++++++++++++++++++++++++
 2 files changed, 36 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index e69ee9d..34099fa 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1066,6 +1066,13 @@ extern bool skip_free_areas_node(unsigned int flags, int nid);
 
 int shmem_zero_setup(struct vm_area_struct *);
 #ifdef CONFIG_SHMEM
+
+#define SHMEM_NOTPRESENT	1 /* page is not present in memory */
+#define SHMEM_RESIDENT		2 /* page is resident in RAM */
+#define SHMEM_SWAPCACHE		3 /* page is in swap cache */
+#define SHMEM_SWAP		4 /* page is paged out */
+
+extern int shmem_locate(struct vm_area_struct *vma, pgoff_t pgoff, int *count);
 bool shmem_mapping(struct address_space *mapping);
 #else
 static inline bool shmem_mapping(struct address_space *mapping)
diff --git a/mm/shmem.c b/mm/shmem.c
index 5e5d860..11b37a7 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1305,6 +1305,35 @@ static int shmem_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
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
