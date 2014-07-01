Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f50.google.com (mail-qa0-f50.google.com [209.85.216.50])
	by kanga.kvack.org (Postfix) with ESMTP id B7CBB6B0031
	for <linux-mm@kvack.org>; Tue,  1 Jul 2014 09:33:56 -0400 (EDT)
Received: by mail-qa0-f50.google.com with SMTP id m5so7555043qaj.37
        for <linux-mm@kvack.org>; Tue, 01 Jul 2014 06:33:56 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p95si29573501qgd.71.2014.07.01.06.33.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Jul 2014 06:33:56 -0700 (PDT)
From: "Jerome Marchand" <jmarchan@redhat.com>
Subject: [PATCH 3/5] mm, shmem: Add shmem_vma() helper
Date: Tue,  1 Jul 2014 15:01:59 +0200
Message-Id: <1404219721-32241-4-git-send-email-jmarchan@redhat.com>
In-Reply-To: <1404219721-32241-1-git-send-email-jmarchan@redhat.com>
References: <1404219721-32241-1-git-send-email-jmarchan@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>

Add a simple helper to check if a vm area belongs to shmem.

Signed-off-by: Jerome Marchand <jmarchan@redhat.com>
---
 include/linux/mm.h | 6 ++++++
 mm/shmem.c         | 8 ++++++++
 2 files changed, 14 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 34099fa..04a58d1 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1074,11 +1074,17 @@ int shmem_zero_setup(struct vm_area_struct *);
 
 extern int shmem_locate(struct vm_area_struct *vma, pgoff_t pgoff, int *count);
 bool shmem_mapping(struct address_space *mapping);
+bool shmem_vma(struct vm_area_struct *vma);
+
 #else
 static inline bool shmem_mapping(struct address_space *mapping)
 {
 	return false;
 }
+static inline bool shmem_vma(struct vm_area_struct *vma)
+{
+	return false;
+}
 #endif
 
 extern int can_do_mlock(void);
diff --git a/mm/shmem.c b/mm/shmem.c
index 11b37a7..be87a20 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1447,6 +1447,14 @@ bool shmem_mapping(struct address_space *mapping)
 	return mapping->backing_dev_info == &shmem_backing_dev_info;
 }
 
+bool shmem_vma(struct vm_area_struct *vma)
+{
+	return (vma->vm_file &&
+		vma->vm_file->f_dentry->d_inode->i_mapping->backing_dev_info
+		== &shmem_backing_dev_info);
+
+}
+
 #ifdef CONFIG_TMPFS
 static const struct inode_operations shmem_symlink_inode_operations;
 static const struct inode_operations shmem_short_symlink_operations;
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
