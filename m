Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f52.google.com (mail-qa0-f52.google.com [209.85.216.52])
	by kanga.kvack.org (Postfix) with ESMTP id C802A6B0039
	for <linux-mm@kvack.org>; Tue, 22 Jul 2014 09:44:53 -0400 (EDT)
Received: by mail-qa0-f52.google.com with SMTP id j15so6322852qaq.25
        for <linux-mm@kvack.org>; Tue, 22 Jul 2014 06:44:53 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a50si915720qgf.6.2014.07.22.06.44.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Jul 2014 06:44:52 -0700 (PDT)
From: "Jerome Marchand" <jmarchan@redhat.com>
Subject: [PATCH 3/5] mm, shmem: Add shmem_vma() helper
Date: Tue, 22 Jul 2014 15:43:50 +0200
Message-Id: <1406036632-26552-4-git-send-email-jmarchan@redhat.com>
In-Reply-To: <1406036632-26552-1-git-send-email-jmarchan@redhat.com>
References: <1406036632-26552-1-git-send-email-jmarchan@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-s390@vger.kernel.org, linux-doc@vger.kernel.org, Hugh Dickins <hughd@google.com>, Arnaldo Carvalho de Melo <acme@kernel.org>, Ingo Molnar <mingo@redhat.com>, Paul Mackerras <paulus@samba.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux390@de.ibm.com, Heiko Carstens <heiko.carstens@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Randy Dunlap <rdunlap@infradead.org>

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
index 8aa4892..7d16227 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1483,6 +1483,14 @@ bool shmem_mapping(struct address_space *mapping)
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
