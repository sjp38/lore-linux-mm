Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id B1E396B0035
	for <linux-mm@kvack.org>; Thu, 14 Aug 2014 09:16:56 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id lf10so1629733pab.29
        for <linux-mm@kvack.org>; Thu, 14 Aug 2014 06:16:56 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id gz9si4191605pbc.144.2014.08.14.06.16.55
        for <linux-mm@kvack.org>;
        Thu, 14 Aug 2014 06:16:55 -0700 (PDT)
Date: Thu, 14 Aug 2014 09:16:32 -0400
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [RFC 5/9] SQUASHME: prd: Last fixes for partitions
Message-ID: <20140814131632.GF6754@linux.intel.com>
References: <53EB5536.8020702@gmail.com>
 <53EB5709.4090401@plexistor.com>
 <53ECB3F5.9020001@plexistor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53ECB3F5.9020001@plexistor.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boaz Harrosh <boaz@plexistor.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Sagi Manole <sagi@plexistor.com>, Yigal Korman <yigal@plexistor.com>

On Thu, Aug 14, 2014 at 04:04:53PM +0300, Boaz Harrosh wrote:
> > @@ -218,13 +218,13 @@ static long prd_direct_access(struct block_device *bdev, sector_t sector,
> >  {
> >  	struct prd_device *prd = bdev->bd_disk->private_data;
> >  
> > -	if (!prd)
> > +	if (unlikely(!prd))
> >  		return -ENODEV;
> >  
> >  	*kaddr = prd_lookup_pg_addr(prd, sector);
> >  	*pfn = prd_lookup_pfn(prd, sector);
> >  
> > -	return size;
> > +	return min_t(long, size, prd->size);
> 
> This is off course a BUG need to subtract offset, will send version 2

I was wondering about simplifying the return value for the drivers
a little.  Something like this:

diff --git a/arch/powerpc/sysdev/axonram.c b/arch/powerpc/sysdev/axonram.c
index 741293f..8709b9f 100644
--- a/arch/powerpc/sysdev/axonram.c
+++ b/arch/powerpc/sysdev/axonram.c
@@ -149,7 +149,7 @@ axon_ram_direct_access(struct block_device *device, sector_t sector,
 	*kaddr = (void *)(bank->ph_addr + offset);
 	*pfn = virt_to_phys(*kaddr) >> PAGE_SHIFT;
 
-	return min_t(long, size, bank->size - offset);
+	return bank->size - offset;
 }
 
 static const struct block_device_operations axon_ram_devops = {
diff --git a/drivers/block/brd.c b/drivers/block/brd.c
index 3483458..344681a 100644
--- a/drivers/block/brd.c
+++ b/drivers/block/brd.c
@@ -384,9 +384,9 @@ static long brd_direct_access(struct block_device *bdev, sector_t sector,
 	*kaddr = page_address(page);
 	*pfn = page_to_pfn(page);
 
-	/* Could optimistically check to see if the next page in the
-	 * file is mapped to the next page of physical RAM */
-	return min_t(long, PAGE_SIZE, size);
+	/* If size > PAGE_SIZE, we could look to see if the next page in the
+	 * file happens to be mapped to the next page of physical RAM */
+	return PAGE_SIZE;
 }
 #else
 #define brd_direct_access NULL
diff --git a/drivers/block/prd.c b/drivers/block/prd.c
index cc0aabf..1cfbd5b 100644
--- a/drivers/block/prd.c
+++ b/drivers/block/prd.c
@@ -216,7 +216,7 @@ static long prd_direct_access(struct block_device *bdev, sector_t sector,
 	*kaddr = prd_lookup_pg_addr(prd, sector);
 	*pfn = prd_lookup_pfn(prd, sector);
 
-	return size;
+	return size - (sector * 512);
 }
 
 static const struct block_device_operations prd_fops = {
diff --git a/drivers/s390/block/dcssblk.c b/drivers/s390/block/dcssblk.c
index 2ee5556..96bc411 100644
--- a/drivers/s390/block/dcssblk.c
+++ b/drivers/s390/block/dcssblk.c
@@ -881,7 +881,7 @@ dcssblk_direct_access (struct block_device *bdev, sector_t secnum,
 	*kaddr = (void *) (dev_info->start + offset);
 	*pfn = virt_to_phys(*kaddr) >> PAGE_SHIFT;
 
-	return min_t(long, size, dev_sz - offset);
+	return dev_sz - offset;
 }
 
 static void
diff --git a/fs/block_dev.c b/fs/block_dev.c
index 93ebdd53..ce3e69c 100644
--- a/fs/block_dev.c
+++ b/fs/block_dev.c
@@ -447,6 +447,7 @@ EXPORT_SYMBOL_GPL(bdev_write_page);
 long bdev_direct_access(struct block_device *bdev, sector_t sector,
 			void **addr, unsigned long *pfn, long size)
 {
+	long max;
 	const struct block_device_operations *ops = bdev->bd_disk->fops;
 	if (!ops->direct_access)
 		return -EOPNOTSUPP;
@@ -456,8 +457,10 @@ long bdev_direct_access(struct block_device *bdev, sector_t sector,
 	sector += get_start_sect(bdev);
 	if (sector % (PAGE_SIZE / 512))
 		return -EINVAL;
-	size = ops->direct_access(bdev, sector, addr, pfn, size);
-	return size ? size : -ERANGE;
+	max = ops->direct_access(bdev, sector, addr, pfn, size);
+	if (!max)
+		return -ERANGE;
+	return min(max, size);
 }
 EXPORT_SYMBOL_GPL(bdev_direct_access);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
