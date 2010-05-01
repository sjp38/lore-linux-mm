Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 8F6296004D1
	for <linux-mm@kvack.org>; Sat,  1 May 2010 10:34:22 -0400 (EDT)
From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [PATCH v21 045/100] c/r: export shmem_getpage() to support shared memory
Date: Sat,  1 May 2010 10:15:27 -0400
Message-Id: <1272723382-19470-46-git-send-email-orenl@cs.columbia.edu>
In-Reply-To: <1272723382-19470-1-git-send-email-orenl@cs.columbia.edu>
References: <1272723382-19470-1-git-send-email-orenl@cs.columbia.edu>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Matt Helsley <matthltc@us.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, Oren Laadan <orenl@cs.columbia.edu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Export functionality to retrieve specific pages from shared memory
given an inode in shmem-fs; this will be used in the next two patches
to provide support for c/r of shared memory.

mm/shmem.c:
- shmem_getpage() and 'enum sgp_type' moved to linux/mm.h

Cc: linux-mm@kvack.org
Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
Acked-by: Serge E. Hallyn <serue@us.ibm.com>
Tested-by: Serge E. Hallyn <serue@us.ibm.com>
---
 include/linux/mm.h |   11 +++++++++++
 mm/shmem.c         |   15 ++-------------
 2 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 913c7fe..5ebb781 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -340,6 +340,17 @@ void put_pages_list(struct list_head *pages);
 
 void split_page(struct page *page, unsigned int order);
 
+/* Flag allocation requirements to shmem_getpage and shmem_swp_alloc */
+enum sgp_type {
+	SGP_READ,	/* don't exceed i_size, don't allocate page */
+	SGP_CACHE,	/* don't exceed i_size, may allocate page */
+	SGP_DIRTY,	/* like SGP_CACHE, but set new page dirty */
+	SGP_WRITE,	/* may exceed i_size, may allocate page */
+};
+
+extern int shmem_getpage(struct inode *inode, unsigned long idx,
+			 struct page **pagep, enum sgp_type sgp, int *type);
+
 /*
  * Compound pages have a destructor function.  Provide a
  * prototype for that function and accessor functions.
diff --git a/mm/shmem.c b/mm/shmem.c
index eef4ebe..d93c394 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -98,14 +98,6 @@ static struct vfsmount *shm_mnt;
 /* Pretend that each entry is of this size in directory's i_size */
 #define BOGO_DIRENT_SIZE 20
 
-/* Flag allocation requirements to shmem_getpage and shmem_swp_alloc */
-enum sgp_type {
-	SGP_READ,	/* don't exceed i_size, don't allocate page */
-	SGP_CACHE,	/* don't exceed i_size, may allocate page */
-	SGP_DIRTY,	/* like SGP_CACHE, but set new page dirty */
-	SGP_WRITE,	/* may exceed i_size, may allocate page */
-};
-
 #ifdef CONFIG_TMPFS
 static unsigned long shmem_default_max_blocks(void)
 {
@@ -118,9 +110,6 @@ static unsigned long shmem_default_max_inodes(void)
 }
 #endif
 
-static int shmem_getpage(struct inode *inode, unsigned long idx,
-			 struct page **pagep, enum sgp_type sgp, int *type);
-
 static inline struct page *shmem_dir_alloc(gfp_t gfp_mask)
 {
 	/*
@@ -1213,8 +1202,8 @@ static inline struct mempolicy *shmem_get_sbmpol(struct shmem_sb_info *sbinfo)
  * vm. If we swap it in we mark it dirty since we also free the swap
  * entry since a page cannot live in both the swap and page cache
  */
-static int shmem_getpage(struct inode *inode, unsigned long idx,
-			struct page **pagep, enum sgp_type sgp, int *type)
+int shmem_getpage(struct inode *inode, unsigned long idx,
+		  struct page **pagep, enum sgp_type sgp, int *type)
 {
 	struct address_space *mapping = inode->i_mapping;
 	struct shmem_inode_info *info = SHMEM_I(inode);
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
