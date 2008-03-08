Received: by rv-out-0910.google.com with SMTP id f1so499544rvb.26
        for <linux-mm@kvack.org>; Fri, 07 Mar 2008 20:33:56 -0800 (PST)
Message-ID: <6934efce0803072033l301d39f0q909ab21f4f77657a@mail.gmail.com>
Date: Fri, 7 Mar 2008 20:33:56 -0800
From: "Jared Hulbert" <jaredeh@gmail.com>
Subject: [RFC][PATCH 3/3] xip: no struct pages -- ext2
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Carsten Otte <cotte@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Maxim Shchetynin <maxim@de.ibm.com>
List-ID: <linux-mm.kvack.org>

[RFC][PATCH 3/3] xip: no struct pages -- ext2

Patching ext2 xip functions to use both the get_xip_mem()
and the new direct_access() API.

Signed-off-by: Jared Hulbert <jaredeh@gmail.com>
---

fs/ext2/inode.c |    2 +-
fs/ext2/xip.c   |   45 ++++++++++++++++++++++++---------------------
fs/ext2/xip.h   |    9 +++++----
3 files changed, 30 insertions(+), 26 deletions(-)


diff --git a/fs/ext2/inode.c b/fs/ext2/inode.c
index c620068..0374e54 100644
--- a/fs/ext2/inode.c
+++ b/fs/ext2/inode.c
@@ -796,7 +796,7 @@ const struct address_space_operations ext2_aops = {

 const struct address_space_operations ext2_aops_xip = {
 	.bmap			= ext2_bmap,
-	.get_xip_page		= ext2_get_xip_page,
+	.get_xip_mem		= ext2_get_xip_mem,
 };

 const struct address_space_operations ext2_nobh_aops = {
diff --git a/fs/ext2/xip.c b/fs/ext2/xip.c
index ca7f003..b272ed0 100644
--- a/fs/ext2/xip.c
+++ b/fs/ext2/xip.c
@@ -15,24 +15,26 @@
 #include "xip.h"

 static inline int
-__inode_direct_access(struct inode *inode, sector_t sector,
-		      unsigned long *data)
+__inode_direct_access(struct inode *inode, sector_t block, void **kaddr,
+		      unsigned long *pfn)
 {
+	sector_t sector;
 	BUG_ON(!inode->i_sb->s_bdev->bd_disk->fops->direct_access);
+
+	sector = block * (PAGE_SIZE / 512); /* ext2 block to bdev sector */
 	return inode->i_sb->s_bdev->bd_disk->fops
-		->direct_access(inode->i_sb->s_bdev,sector,data);
+		->direct_access(inode->i_sb->s_bdev,sector,kaddr,pfn);
 }

 static inline int
-__ext2_get_sector(struct inode *inode, sector_t offset, int create,
+__ext2_get_block(struct inode *inode, pgoff_t pgoff, int create,
 		   sector_t *result)
 {
 	struct buffer_head tmp;
 	int rc;

 	memset(&tmp, 0, sizeof(struct buffer_head));
-	rc = ext2_get_block(inode, offset/ (PAGE_SIZE/512), &tmp,
-			    create);
+	rc = ext2_get_block(inode, pgoff, &tmp, create);
 	*result = tmp.b_blocknr;

 	/* did we get a sparse block (hole in the file)? */
@@ -45,15 +47,15 @@ __ext2_get_sector(struct inode *inode, sector_t
offset, int create,
 }

 int
-ext2_clear_xip_target(struct inode *inode, int block)
+ext2_clear_xip_target(struct inode *inode, sector_t block)
 {
-	sector_t sector = block * (PAGE_SIZE/512);
-	unsigned long data;
+	void *kaddr;
+	unsigned long pfn;
 	int rc;

-	rc = __inode_direct_access(inode, sector, &data);
+	rc = __inode_direct_access(inode, block, &kaddr, &pfn);
 	if (!rc)
-		clear_page((void*)data);
+		clear_page(kaddr);
 	return rc;
 }

@@ -69,25 +71,25 @@ void ext2_xip_verify_sb(struct super_block *sb)
 	}
 }

-struct page *
-ext2_get_xip_page(struct address_space *mapping, sector_t offset,
-		   int create)
+int
+ext2_get_xip_mem(struct address_space *mapping, pgoff_t pgoff, int create,
+		 void **kaddr, unsigned long *pfn)
 {
 	int rc;
-	unsigned long data;
-	sector_t sector;
+	sector_t block;

 	/* first, retrieve the sector number */
-	rc = __ext2_get_sector(mapping->host, offset, create, &sector);
+	rc = __ext2_get_block(mapping->host, pgoff, create, &block);
 	if (rc)
 		goto error;

 	/* retrieve address of the target data */
-	rc = __inode_direct_access
-		(mapping->host, sector * (PAGE_SIZE/512), &data);
-	if (!rc)
-		return virt_to_page(data);
+	rc = __inode_direct_access(mapping->host, block, kaddr, pfn);
+	if (rc)
+		goto error;
+
+	return 0;

  error:
-	return ERR_PTR(rc);
+	return rc;
 }
diff --git a/fs/ext2/xip.h b/fs/ext2/xip.h
index aa85331..53ec33d 100644
--- a/fs/ext2/xip.h
+++ b/fs/ext2/xip.h
@@ -7,19 +7,20 @@

 #ifdef CONFIG_EXT2_FS_XIP
 extern void ext2_xip_verify_sb (struct super_block *);
-extern int ext2_clear_xip_target (struct inode *, int);
+extern int ext2_clear_xip_target (struct inode *, sector_t);

 static inline int ext2_use_xip (struct super_block *sb)
 {
 	struct ext2_sb_info *sbi = EXT2_SB(sb);
 	return (sbi->s_mount_opt & EXT2_MOUNT_XIP);
 }
-struct page* ext2_get_xip_page (struct address_space *, sector_t, int);
-#define mapping_is_xip(map) unlikely(map->a_ops->get_xip_page)
+int ext2_get_xip_mem(struct address_space *, pgoff_t, int, void **,
+		unsigned long *);
+#define mapping_is_xip(map) unlikely(map->a_ops->get_xip_mem)
 #else
 #define mapping_is_xip(map)			0
 #define ext2_xip_verify_sb(sb)			do { } while (0)
 #define ext2_use_xip(sb)			0
 #define ext2_clear_xip_target(inode, chain)	0
-#define ext2_get_xip_page			NULL
+#define ext2_get_xip_mem			NULL
 #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
