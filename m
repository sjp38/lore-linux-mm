Received: by wf-out-1314.google.com with SMTP id 25so900339wfc.11
        for <linux-mm@kvack.org>; Fri, 07 Mar 2008 20:33:50 -0800 (PST)
Message-ID: <6934efce0803072033idf51aa4rf211eece44c679e7@mail.gmail.com>
Date: Fri, 7 Mar 2008 20:33:50 -0800
From: "Jared Hulbert" <jaredeh@gmail.com>
Subject: [RFC][PATCH 2/3] xip: no struct pages -- direct_access
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Carsten Otte <cotte@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Maxim Shchetynin <maxim@de.ibm.com>
List-ID: <linux-mm.kvack.org>

[RFC][PATCH 2/3] xip: no struct pages -- direct_access

Altering the block device ->direct_access() API to fix with the new
get_xip_mem() API.  Allows devices to specify a kaddr and pfn.

Signed-off-by: Jared Hulbert <jaredeh@gmail.com>
---

arch/powerpc/sysdev/axonram.c |    5 +++--
drivers/block/brd.c           |    5 +++--
drivers/s390/block/dcssblk.c  |    7 +++++--
include/linux/fs.h            |    3 ++-
4 files changed, 13 insertions(+), 7 deletions(-)

diff --git a/arch/powerpc/sysdev/axonram.c b/arch/powerpc/sysdev/axonram.c
index d359d6e..7f59188 100644
--- a/arch/powerpc/sysdev/axonram.c
+++ b/arch/powerpc/sysdev/axonram.c
@@ -143,7 +143,7 @@ axon_ram_make_request(struct request_queue *queue,
struct bio *bio)
  */
 static int
 axon_ram_direct_access(struct block_device *device, sector_t sector,
-		       unsigned long *data)
+		       void **kaddr, unsigned long *pfn)
 {
 	struct axon_ram_bank *bank = device->bd_disk->private_data;
 	loff_t offset;
@@ -154,7 +154,8 @@ axon_ram_direct_access(struct block_device
*device, sector_t sector,
 		return -ERANGE;
 	}

-	*data = bank->ph_addr + offset;
+	*kaddr = (void *)(bank->ph_addr + offset);
+	*pfn = virt_to_phys(kaddr) >> PAGE_SHIFT;

 	return 0;
 }
diff --git a/drivers/block/brd.c b/drivers/block/brd.c
index 8536480..ec56f3c 100644
--- a/drivers/block/brd.c
+++ b/drivers/block/brd.c
@@ -319,7 +319,7 @@ out:

 #ifdef CONFIG_BLK_DEV_XIP
 static int brd_direct_access (struct block_device *bdev, sector_t sector,
-			unsigned long *data)
+			void **kaddr, unsigned long *pfn)
 {
 	struct brd_device *brd = bdev->bd_disk->private_data;
 	struct page *page;
@@ -333,7 +333,8 @@ static int brd_direct_access (struct block_device
*bdev, sector_t sector,
 	page = brd_insert_page(brd, sector);
 	if (!page)
 		return -ENOMEM;
-	*data = (unsigned long)page_address(page);
+	*kaddr = page_address(page);
+	*pfn = page_to_pfn(page);

 	return 0;
 }
diff --git a/drivers/s390/block/dcssblk.c b/drivers/s390/block/dcssblk.c
index e6c94db..59c1949 100644
--- a/drivers/s390/block/dcssblk.c
+++ b/drivers/s390/block/dcssblk.c
@@ -687,7 +687,7 @@ fail:

 static int
 dcssblk_direct_access (struct block_device *bdev, sector_t secnum,
-			unsigned long *data)
+			void **kaddr, unsigned long *pfn)
 {
 	struct dcssblk_dev_info *dev_info;
 	unsigned long pgoff;
@@ -700,7 +700,10 @@ dcssblk_direct_access (struct block_device *bdev,
sector_t secnum,
 	pgoff = secnum / (PAGE_SIZE / 512);
 	if ((pgoff+1)*PAGE_SIZE-1 > dev_info->end - dev_info->start)
 		return -ERANGE;
-	*data = (unsigned long) (dev_info->start+pgoff*PAGE_SIZE);
+
+	*kaddr = (void *)(dev_info->start + pgoff * PAGE_SIZE);
+	*pfn = virt_to_phys(*kaddr) >> PAGE_SHIFT;
+
 	return 0;
 }

diff --git a/include/linux/fs.h b/include/linux/fs.h
index b84b848..27f9a74 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1129,7 +1129,8 @@ struct block_device_operations {
 	int (*ioctl) (struct inode *, struct file *, unsigned, unsigned long);
 	long (*unlocked_ioctl) (struct file *, unsigned, unsigned long);
 	long (*compat_ioctl) (struct file *, unsigned, unsigned long);
-	int (*direct_access) (struct block_device *, sector_t, unsigned long *);
+	int (*direct_access) (struct block_device *, sector_t, void **,
+			unsigned long *);
 	int (*media_changed) (struct gendisk *);
 	int (*revalidate_disk) (struct gendisk *);
 	int (*getgeo)(struct block_device *, struct hd_geometry *);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
