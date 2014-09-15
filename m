Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	by kanga.kvack.org (Postfix) with ESMTP id 7B8866B003B
	for <linux-mm@kvack.org>; Mon, 15 Sep 2014 10:25:42 -0400 (EDT)
Received: by mail-qg0-f49.google.com with SMTP id j5so3935135qga.8
        for <linux-mm@kvack.org>; Mon, 15 Sep 2014 07:25:42 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f107si1146607qge.6.2014.09.15.07.25.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Sep 2014 07:25:41 -0700 (PDT)
From: "Jerome Marchand" <jmarchan@redhat.com>
Subject: [RFC PATCH v2 4/5] mm, shmem: Add shmem_vma() helper
Date: Mon, 15 Sep 2014 16:24:36 +0200
Message-Id: <1410791077-5300-5-git-send-email-jmarchan@redhat.com>
In-Reply-To: <1410791077-5300-1-git-send-email-jmarchan@redhat.com>
References: <1410791077-5300-1-git-send-email-jmarchan@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Randy Dunlap <rdunlap@infradead.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux390@de.ibm.com, Hugh Dickins <hughd@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Mackerras <paulus@samba.org>, Ingo Molnar <mingo@redhat.com>, Arnaldo Carvalho de Melo <acme@kernel.org>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-s390@vger.kernel.org, Oleg Nesterov <oleg@redhat.com>

Add a simple helper to check if a vm area belongs to shmem.

Signed-off-by: Jerome Marchand <jmarchan@redhat.com>
---
 include/linux/shmem_fs.h | 1 +
 mm/shmem.c               | 6 ++++++
 2 files changed, 7 insertions(+)

diff --git a/include/linux/shmem_fs.h b/include/linux/shmem_fs.h
index 99992cf..b1fd7c1 100644
--- a/include/linux/shmem_fs.h
+++ b/include/linux/shmem_fs.h
@@ -59,6 +59,7 @@ extern struct file *shmem_kernel_file_setup(const char *name, loff_t size,
 extern int shmem_zero_setup(struct vm_area_struct *);
 extern int shmem_lock(struct file *file, int lock, struct user_struct *user);
 extern bool shmem_mapping(struct address_space *mapping);
+extern bool shmem_vma(struct vm_area_struct *vma);
 extern void shmem_unlock_mapping(struct address_space *mapping);
 extern struct page *shmem_read_mapping_page_gfp(struct address_space *mapping,
 					pgoff_t index, gfp_t gfp_mask);
diff --git a/mm/shmem.c b/mm/shmem.c
index 134a422..e2d7be6 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1493,6 +1493,12 @@ bool shmem_mapping(struct address_space *mapping)
 	return mapping->backing_dev_info == &shmem_backing_dev_info;
 }
 
+bool shmem_vma(struct vm_area_struct *vma)
+{
+	return vma->vm_file &&
+		shmem_mapping(file_inode(vma->vm_file)->i_mapping);
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
