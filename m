Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id D70716B0035
	for <linux-mm@kvack.org>; Wed, 13 Aug 2014 08:20:13 -0400 (EDT)
Received: by mail-wg0-f48.google.com with SMTP id x13so11124901wgg.31
        for <linux-mm@kvack.org>; Wed, 13 Aug 2014 05:20:13 -0700 (PDT)
Received: from mail-we0-f177.google.com (mail-we0-f177.google.com [74.125.82.177])
        by mx.google.com with ESMTPS id ey16si2360222wid.15.2014.08.13.05.20.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 13 Aug 2014 05:20:12 -0700 (PDT)
Received: by mail-we0-f177.google.com with SMTP id w62so11211641wes.22
        for <linux-mm@kvack.org>; Wed, 13 Aug 2014 05:20:12 -0700 (PDT)
Message-ID: <53EB57FA.3030705@plexistor.com>
Date: Wed, 13 Aug 2014 15:20:10 +0300
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
Subject: [RFC 7/9] SQUASHME: prd: Support of multiple memory regions
References: <53EB5536.8020702@gmail.com>
In-Reply-To: <53EB5536.8020702@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Matthew Wilcox <willy@linux.intel.com>, Sagi Manole <sagi@plexistor.com>, Yigal Korman <yigal@plexistor.com>

From: Boaz Harrosh <boaz@plexistor.com>

After the last patch this is easy.

The API to prd module is changed. We now have a single string
parameter named "map" of the form:
		 map=mapS[,mapS...]

		 where mapS=nn[KMG]$ss[KMG],
		 or    mapS=nn[KMG]@ss[KMG],

		 nn=size, ss=offset

Just like the Kernel command line map && memmap parameters,
so anything you did at grub just copy/paste to here.

The "@" form is exactly the same as the "$" form only that
at bash prompt we need to escape the "$" with \$ so also
support the '@' char for convenience.

For each specified mapS there will be a device created.

So needless to say that all the previous prd_XXX params are
removed as well as the Kconfig defaults.

Signed-off-by: Boaz Harrosh <boaz@plexistor.com>
---
 drivers/block/Kconfig | 28 -----------------------
 drivers/block/prd.c   | 62 ++++++++++++++++++++++++++++++++++-----------------
 2 files changed, 41 insertions(+), 49 deletions(-)

diff --git a/drivers/block/Kconfig b/drivers/block/Kconfig
index 463c45e..8f0c225 100644
--- a/drivers/block/Kconfig
+++ b/drivers/block/Kconfig
@@ -416,34 +416,6 @@ config BLK_DEV_PMEM
 	  Most normal users won't need this functionality, and can thus say N
 	  here.
 
-config BLK_DEV_PMEM_START
-	int "Offset in GiB of where to start claiming space"
-	default "0"
-	depends on BLK_DEV_PMEM
-	help
-	  Starting offset in GiB that PRD should use when claiming memory.  This
-	  memory needs to be reserved from the OS at boot time using the
-	  "memmap" kernel parameter.
-
-	  If you provide PRD with volatile memory it will act as a volatile
-	  RAM disk and your data will not be persistent.
-
-config BLK_DEV_PMEM_COUNT
-	int "Default number of PMEM disks"
-	default "4"
-	depends on BLK_DEV_PMEM
-	help
-	  Number of equal sized block devices that PRD should create.
-
-config BLK_DEV_PMEM_SIZE
-	int "Size in GiB of space to claim"
-	depends on BLK_DEV_PMEM
-	default "0"
-	help
-	  Amount of memory in GiB that PRD should use when creating block
-	  devices.  This memory needs to be reserved from the OS at
-	  boot time using the "memmap" kernel parameter.
-
 config CDROM_PKTCDVD
 	tristate "Packet writing on CD/DVD media"
 	depends on !UML
diff --git a/drivers/block/prd.c b/drivers/block/prd.c
index 6d96e6c..36b8fe4 100644
--- a/drivers/block/prd.c
+++ b/drivers/block/prd.c
@@ -228,21 +228,15 @@ static const struct block_device_operations prd_fops = {
 };
 
 /* Kernel module stuff */
-static int prd_start_gb = CONFIG_BLK_DEV_PMEM_START;
-module_param(prd_start_gb, int, S_IRUGO);
-MODULE_PARM_DESC(prd_start_gb, "Offset in GB of where to start claiming space");
-
-static int prd_size_gb = CONFIG_BLK_DEV_PMEM_SIZE;
-module_param(prd_size_gb,  int, S_IRUGO);
-MODULE_PARM_DESC(prd_size_gb,  "Total size in GB of space to claim for all disks");
-
 static int prd_major;
 module_param(prd_major, int, 0);
 MODULE_PARM_DESC(prd_major,  "Major number to request for this driver");
 
-static int prd_count = CONFIG_BLK_DEV_PMEM_COUNT;
-module_param(prd_count, int, S_IRUGO);
-MODULE_PARM_DESC(prd_count, "Number of prd devices to evenly split allocated space");
+static char *map;
+module_param(map, charp, S_IRUGO);
+MODULE_PARM_DESC(map,
+	"pmem device mapping: map=mapS[,mapS...] where:\n"
+	"mapS=nn[KMG]$ss[KMG] or mapS=nn[KMG]@ss[KMG], nn=size, ss=offset.");
 
 static LIST_HEAD(prd_devices);
 static DEFINE_MUTEX(prd_devices_mutex);
@@ -292,6 +286,13 @@ static struct prd_device *prd_alloc(phys_addr_t phys_addr, size_t disk_size,
 	struct gendisk *disk;
 	int err;
 
+	if (unlikely((phys_addr & ~PAGE_MASK) || (disk_size & ~PAGE_MASK))) {
+		pr_err("phys_addr=0x%llx disk_size=0x%zx must be 4k aligned\n",
+		       phys_addr, disk_size);
+		err = -EINVAL;
+		goto out;
+	}
+
 	prd = kzalloc(sizeof(*prd), GFP_KERNEL);
 	if (unlikely(!prd)) {
 		err = -ENOMEM;
@@ -388,22 +389,30 @@ out:
 	return kobj;
 }
 
+static int prd_parse_map_one(char *map, phys_addr_t *start, size_t *size)
+{
+	char *p = map;
+
+	*size = (phys_addr_t)memparse(p, &p);
+	if ((p == map) || ((*p != '$') && (*p != '@')))
+		return -EINVAL;
+
+	*start = (size_t)memparse(p + 1, &p);
+
+	return *p == '\0' ? 0 : -EINVAL;
+}
+
 static int __init prd_init(void)
 {
 	int result, i;
 	struct prd_device *prd, *next;
-	phys_addr_t phys_addr;
-	size_t total_size, disk_size;
+	char *p, *prd_map = map;
 
-	if (unlikely(!prd_start_gb || !prd_size_gb || !prd_count)) {
-		pr_err("prd: prd_start_gb || prd_size_gb || prd_count are 0!!\n");
+	if (!prd_map) {
+		pr_err("prd: must specify map parameter.\n");
 		return -EINVAL;
 	}
 
-	phys_addr = (phys_addr_t) prd_start_gb * 1024 * 1024 * 1024;
-	total_size = (size_t)	   prd_size_gb  * 1024 * 1024 * 1024;
-	disk_size = total_size / prd_count;
-
 	result = register_blkdev(prd_major, "prd");
 	if (result < 0) {
 		result = -EIO;
@@ -411,13 +420,24 @@ static int __init prd_init(void)
 	} else if (result > 0)
 		prd_major = result;
 
-	for (i = 0; i < prd_count; i++) {
-		prd = prd_alloc(phys_addr + i * disk_size, disk_size, i);
+	i = 0;
+	while ((p = strsep(&prd_map, ",")) != NULL) {
+		phys_addr_t phys_addr;
+		size_t disk_size;
+
+		if (!*p)
+			continue;
+		result = prd_parse_map_one(p, &phys_addr, &disk_size);
+		if (result)
+			goto out_free;
+
+		prd = prd_alloc(phys_addr, disk_size, i);
 		if (IS_ERR(prd)) {
 			result = PTR_ERR(prd);
 			goto out_free;
 		}
 		list_add_tail(&prd->prd_list, &prd_devices);
+		++i;
 	}
 
 	list_for_each_entry(prd, &prd_devices, prd_list)
-- 
1.9.3


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
