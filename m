Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l0VKH9LV030221
	for <linux-mm@kvack.org>; Wed, 31 Jan 2007 15:17:09 -0500
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l0VKH9MV172260
	for <linux-mm@kvack.org>; Wed, 31 Jan 2007 15:17:09 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l0VKH8sw010146
	for <linux-mm@kvack.org>; Wed, 31 Jan 2007 15:17:09 -0500
From: Adam Litke <agl@us.ibm.com>
Subject: [PATCH 4/6] hugetlb: hugetlbfs handles overcommit accounting privately
Date: Wed, 31 Jan 2007 12:17:07 -0800
Message-Id: <20070131201707.13810.65461.stgit@localhost.localdomain>
In-Reply-To: <20070131201624.13810.45848.stgit@localhost.localdomain>
References: <20070131201624.13810.45848.stgit@localhost.localdomain>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: agl@us.ibm.com, wli@holomorphy.com, kenchen@google.com, hugh@veritas.com, david@gibson.dropbear.id.au
List-ID: <linux-mm.kvack.org>

In do_mmap_pgoff, is_file_hugepages() is used to determine whether the default
overcommit accounting checks should be performed.  The underlying question is
whether the "device" handles the overcommit logic instead of using the generic
logic.  Add a backing_dev_info .capability flag which allows the underlying
"device" to specify the answer to this question directly.

This lets us remove another call to is_file_hugepages().

Signed-off-by: Adam Litke <agl@us.ibm.com>
---

 fs/hugetlbfs/inode.c        |    3 ++-
 include/linux/backing-dev.h |    6 ++++++
 mm/mmap.c                   |    2 +-
 3 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index c95dc47..b61592f 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -41,7 +41,8 @@ static struct inode_operations hugetlbfs_inode_operations;
 
 static struct backing_dev_info hugetlbfs_backing_dev_info = {
 	.ra_pages	= 0,	/* No readahead */
-	.capabilities	= BDI_CAP_NO_ACCT_DIRTY | BDI_CAP_NO_WRITEBACK,
+	.capabilities	= BDI_CAP_NO_ACCT_DIRTY | BDI_CAP_NO_WRITEBACK | \
+			  BDI_CAP_PRIVATE_ACCT,
 };
 
 int sysctl_hugetlb_shm_group;
diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
index 7011d62..73ef6e5 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -50,6 +50,7 @@ struct backing_dev_info {
 #define BDI_CAP_READ_MAP	0x00000010	/* Can be mapped for reading */
 #define BDI_CAP_WRITE_MAP	0x00000020	/* Can be mapped for writing */
 #define BDI_CAP_EXEC_MAP	0x00000040	/* Can be mapped for execution */
+#define BDI_CAP_PRIVATE_ACCT	0x00000080	/* Overcommit accounting handled privately */
 #define BDI_CAP_VMFLAGS \
 	(BDI_CAP_READ_MAP | BDI_CAP_WRITE_MAP | BDI_CAP_EXEC_MAP)
 
@@ -101,11 +102,16 @@ void congestion_end(int rw);
 #define bdi_cap_account_dirty(bdi) \
 	(!((bdi)->capabilities & BDI_CAP_NO_ACCT_DIRTY))
 
+#define bdi_cap_private_acct(bdi) \
+	((bdi)->capabilities & BDI_CAP_PRIVATE_ACCT)
+
 #define mapping_cap_writeback_dirty(mapping) \
 	bdi_cap_writeback_dirty((mapping)->backing_dev_info)
 
 #define mapping_cap_account_dirty(mapping) \
 	bdi_cap_account_dirty((mapping)->backing_dev_info)
 
+#define mapping_cap_private_acct(mapping) \
+	bdi_cap_private_acct((mapping)->backing_dev_info)
 
 #endif		/* _LINUX_BACKING_DEV_H */
diff --git a/mm/mmap.c b/mm/mmap.c
index cc3a208..a5cb0a5 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -994,7 +994,7 @@ unsigned long do_mmap_pgoff(struct file * file, unsigned long addr,
 					return -EPERM;
 				vm_flags &= ~VM_MAYEXEC;
 			}
-			if (is_file_hugepages(file))
+			if (mapping_cap_private_acct(file->f_mapping))
 				accountable = 0;
 
 			if (!file->f_op || !file->f_op->mmap)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
