Received: from oscar.casa.dyndns.org ([65.92.167.49])
          by tomts5-srv.bellnexxia.net
          (InterMail vM.5.01.04.19 201-253-122-122-119-20020516) with ESMTP
          id <20020902153819.IWPU5829.tomts5-srv.bellnexxia.net@oscar.casa.dyndns.org>
          for <linux-mm@kvack.org>; Mon, 2 Sep 2002 11:38:19 -0400
Received: from oscar (localhost [127.0.0.1])
	by oscar.casa.dyndns.org (Postfix) with ESMTP id 0F02B1907A
	for <linux-mm@kvack.org>; Mon,  2 Sep 2002 11:37:42 -0400 (EDT)
Content-Type: text/plain;
  charset="iso-8859-1"
From: Ed Tomlinson <tomlins@cam.org>
Subject: Fwd: Re: slablru for 2.5.32-mm1
Date: Mon, 2 Sep 2002 11:37:40 -0400
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <200209021137.41132.tomlins@cam.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On September 2, 2002 01:26 am, Andrew Morton wrote:
> Ed,
>
> I've taken a pass through this.  It's nice and simple.  Clever, too.
>
> This is a first pass at changelogging it - I'd appreciate comments
> on accuracy, things which should be added.   Also a few questions and
> comments for you, please.

Ed Tomlinson's patch which puts slab pages on the LRU.

- The patch is huge because it adds another argument to
kmem_cache_create(): the address of that slab's application-specific
"pruner" function.

- shrink_icache_memory(), shrink_dcache_memory() and
shrink_dqcache_memory() are removed.  We now have dcache, inode and
dquot "pruner" functions which are called from the VM to age the slabs in
the relevant cache.

- Ed originally had all slab pages on the LRU, including higher-order
ones.

We ended up deciding to not do that - there are not really any
interesting slab caches which use high-order allocations, and it
didn't seem worth the (minor) compexity of managing higher-order
pages on the LRU.

If, at some time in the future, the VM at large becomes aware of
higher-order pages then we can bring this back.  But it doesn't seem
justifiable purely for slablru.

The patch which brings back the higher-order slabs is available.

Description of algorithm
========================

The pages which back slab objects may be manually marked as referenced
via kmem_touch_page(), which simply sets PG_referenced.  It _could_ use
mark_page_accessed(), but doesn't.  So slab pages will always remain on
the inactive list.

--
Since shrinking a slab is a much lower cost operation than a swap we keep
the slab pages in inactive where they age faster.  Note I did test with slabs
following the normal active/inactive cycle - we swapped more.
--

kmem_touch_page() is only ever used when a new object is allocated
within a page.  It is not used in application-specific places such as
dcache lookup.  But I think it could be.  (what's the thinking here?)

---
Simplicity.  I had touches in application specific area.  They did not seem
to make much, if any difference.  So like the high order slab the touches
got dropped.
---

During page reclaim, when a slab page reaches the tail of the LRU we
look to see if the page is referenced.  If it is not referenced, has no
pruner callback, and if it has no active slab entries then we directly
reclaim the page.  (Why don't we reclaim it even if it is referenced?)

---
For caches with a pruner functions we do reclaim referenced or not.
Idea is to have only one method of aging for a given cache.
---

If the page does have some active entries and it has a pruner callback,
then we count them up and record the count within the slab structure.

So at the end of a shrink_cache() run, each slab has within it a record
of how many live objects-within-pages were encountered at the tail of
the LRU.

In shrink_zone(), after running shrink_cache(), we take a pass across
all the slab caches, in kmem_do_prunes().  This will call out the the
pruner functions and ask them to release a number of objects, where
that number is the number of objects which were found at the tail of
the LRU.

So the net effect is that the pruning pressure against a particular
slab is driven by the number of objects which are encountered at the
tail of the LRU.

> Comments
> ========
>
> Ed, this code can be sped up a bit, I think.  We can make
> kmem_count_page() return a boolean back to shrink_cache(), telling it
> whether it needs to call kmem_do_prunes() at all.  Often, there won't
> be any work to do in there, and taking that semaphore can be quite
> costly.

I would encapsulate it using a static in slab.  Then in kmem_do_prunes() do
a test and clear this before taking the sem.  This would be a fair
 optimization. Want me to add the four lines?

> The code as-is will even run kmem_do_prunes() when we're examining
> ZONE_HIGHMEM, which certainly won't have any slab pages.  This boolean
> will fix that too.

Yes

> I reverted your
>
> BUG_ON(smp_call_function(func, arg, 1, 1));
>
> to
>
> if (smp_call_function(func, arg, 1, 1))
> BUG();
>
> because BUG_ONs should not have side-effects.  Someone may want to
> compile a kernel which has a stubbed-out BUG_ON()...

Actually the BUG_ON conversion were done by Craig Kulesa.   It would be a
good idea to credit him with the initial port to 2.5 - he did to the work.

> __kmem_cache_shrink_locked() is calling kmem_slab_destroy() with local
> irqs disabled, which is a change from the previous behaviour.  Is this
> deliberate?

Yes.  kmem_slab_destroy will call kmem_freepages and remove us from the
lru.  Interrupts during this hurt the 2.4 version - though with the current
code it may not be necessary any more.

> The patch does a zillion BUG->BUG_ON conversions in slab.c, which is a
> bit unfortunate, because it makes it a bit confusing to review.  Let's
> do that in a standalone patch next time ;)

Yes.  I would have left the BUG_ONs till later.  Craig though otherwise.  I
 do agree two patches would have been better.

>  arch/arm/mach-arc/mm.c                 |    4
>  arch/cris/drivers/usb-host.c           |    2
>  arch/i386/mm/init.c                    |    2
>  drivers/block/ll_rw_blk.c              |    2
>  drivers/ieee1394/eth1394.c             |    2
>  drivers/ieee1394/ieee1394_core.c       |    2
>  drivers/md/raid5.c                     |    2
>  drivers/scsi/scsi.c                    |    2
>  drivers/usb/host/uhci-hcd.c            |    2
>  fs/adfs/super.c                        |    2
>  fs/affs/super.c                        |    2
>  fs/aio.c                               |    4
>  fs/bfs/inode.c                         |    1
>  fs/bio.c                               |    4
>  fs/block_dev.c                         |    4
>  fs/buffer.c                            |    2
>  fs/char_dev.c                          |    4
>  fs/coda/inode.c                        |    3
>  fs/dcache.c                            |   46 +----
>  fs/devfs/base.c                        |    2
>  fs/dnotify.c                           |    2
>  fs/dquot.c                             |   20 --
>  fs/efs/super.c                         |    1
>  fs/ext2/super.c                        |    2
>  fs/ext3/super.c                        |    2
>  fs/fat/inode.c                         |    1
>  fs/fcntl.c                             |    2
>  fs/freevxfs/vxfs_super.c               |    5
>  fs/hfs/super.c                         |    1
>  fs/hpfs/super.c                        |    2
>  fs/inode.c                             |   33 +--
>  fs/intermezzo/dcache.c                 |    2
>  fs/isofs/inode.c                       |    2
>  fs/jbd/journal.c                       |    1
>  fs/jbd/revoke.c                        |    4
>  fs/jffs/inode-v23.c                    |    4
>  fs/jffs2/malloc.c                      |   14 -
>  fs/jffs2/super.c                       |    2
>  fs/jfs/jfs_metapage.c                  |    2
>  fs/jfs/super.c                         |    2
>  fs/locks.c                             |    2
>  fs/minix/inode.c                       |    2
>  fs/namespace.c                         |    2
>  fs/ncpfs/inode.c                       |    2
>  fs/nfs/inode.c                         |    2
>  fs/nfs/pagelist.c                      |    2
>  fs/nfs/read.c                          |    2
>  fs/nfs/write.c                         |    2
>  fs/ntfs/super.c                        |    9 -
>  fs/proc/inode.c                        |    2
>  fs/proc/proc_misc.c                    |    2
>  fs/qnx4/inode.c                        |    2
>  fs/reiserfs/super.c                    |    2
>  fs/romfs/inode.c                       |    2
>  fs/smbfs/inode.c                       |    2
>  fs/smbfs/request.c                     |    2
>  fs/sysv/inode.c                        |    2
>  fs/udf/super.c                         |    2
>  fs/ufs/super.c                         |    2
>  include/linux/dcache.h                 |    5
>  include/linux/page-flags.h             |    1
>  include/linux/slab.h                   |   26 ++
>  kernel/fork.c                          |   12 -
>  kernel/signal.c                        |    2
>  kernel/user.c                          |    2
>  lib/radix-tree.c                       |    2
>  mm/page_alloc.c                        |    1
>  mm/rmap.c                              |    1
>  mm/shmem.c                             |    2
>  mm/slab.c                              |  287
> +++++++++++++++++++++------------ mm/swap.c                              |
>  18 +-
>  mm/vmscan.c                            |   41 +++-
>  net/atm/clip.c                         |    2
>  net/bluetooth/af_bluetooth.c           |    2
>  net/core/neighbour.c                   |    2
>  net/core/skbuff.c                      |    2
>  net/core/sock.c                        |    2
>  net/decnet/dn_route.c                  |    2
>  net/decnet/dn_table.c                  |    2
>  net/ipv4/af_inet.c                     |    6
>  net/ipv4/fib_hash.c                    |    2
>  net/ipv4/inetpeer.c                    |    2
>  net/ipv4/ipmr.c                        |    2
>  net/ipv4/netfilter/ip_conntrack_core.c |    2
>  net/ipv4/route.c                       |    2
>  net/ipv4/tcp.c                         |    6
>  net/ipv6/af_inet6.c                    |    6
>  net/ipv6/ip6_fib.c                     |    2
>  net/ipv6/route.c                       |    2
>  net/socket.c                           |    2
>  net/unix/af_unix.c                     |    2
>  91 files changed, 401 insertions(+), 292 deletions(-)
>
> --- 2.5.33/arch/arm/mach-arc/mm.c~slablru	Sun Sep  1 21:23:12 2002
> +++ 2.5.33-akpm/arch/arm/mach-arc/mm.c	Sun Sep  1 21:23:12 2002
> @@ -173,13 +173,13 @@ void __init pgtable_cache_init(void)
>  {
>  	pte_cache = kmem_cache_create("pte-cache",
>  				sizeof(pte_t) * PTRS_PER_PTE,
> -				0, 0, pte_cache_ctor, NULL);
> +				0, 0, NULL, pte_cache_ctor, NULL);
>  	if (!pte_cache)
>  		BUG();
>
>  	pgd_cache = kmem_cache_create("pgd-cache", MEMC_TABLE_SIZE +
>  				sizeof(pgd_t) * PTRS_PER_PGD,
> -				0, 0, pgd_cache_ctor, NULL);
> +				0, 0, NULL, pgd_cache_ctor, NULL);
>  	if (!pgd_cache)
>  		BUG();
>  }
> --- 2.5.33/arch/cris/drivers/usb-host.c~slablru	Sun Sep  1 21:23:12 2002
> +++ 2.5.33-akpm/arch/cris/drivers/usb-host.c	Sun Sep  1 21:23:12 2002
> @@ -2330,7 +2330,7 @@ static int __init etrax_usb_hc_init(void
>  	hc = kmalloc(sizeof(etrax_hc_t), GFP_KERNEL);
>
>  	/* We use kmem_cache_* to make sure that all DMA desc. are dword aligned
> */ -	usb_desc_cache = kmem_cache_create("usb_desc_cache",
> sizeof(USB_EP_Desc_t), 0, 0, 0, 0); +	usb_desc_cache =
> kmem_cache_create("usb_desc_cache", sizeof(USB_EP_Desc_t), 0, 0, NULL,
> NULL, NULL); if (!usb_desc_cache) {
>  		panic("USB Desc Cache allocation failed !!!\n");
>  	}
> --- 2.5.33/arch/i386/mm/init.c~slablru	Sun Sep  1 21:23:12 2002
> +++ 2.5.33-akpm/arch/i386/mm/init.c	Sun Sep  1 21:30:42 2002
> @@ -504,7 +504,7 @@ void __init pgtable_cache_init(void)
>           * PAE pgds must be 16-byte aligned:
>           */
>          pae_pgd_cachep = kmem_cache_create("pae_pgd", 32, 0,
> -                SLAB_HWCACHE_ALIGN | SLAB_MUST_HWCACHE_ALIGN, NULL, NULL);
> +                SLAB_HWCACHE_ALIGN | SLAB_MUST_HWCACHE_ALIGN, NULL, NULL,
> NULL); if (!pae_pgd_cachep)
>                  panic("init_pae(): Cannot alloc pae_pgd SLAB cache");
>  }
> --- 2.5.33/drivers/block/ll_rw_blk.c~slablru	Sun Sep  1 21:23:12 2002
> +++ 2.5.33-akpm/drivers/block/ll_rw_blk.c	Sun Sep  1 21:23:33 2002
> @@ -2052,7 +2052,7 @@ int __init blk_dev_init(void)
>
>  	request_cachep = kmem_cache_create("blkdev_requests",
>  					   sizeof(struct request),
> -					   0, SLAB_HWCACHE_ALIGN, NULL, NULL);
> +					   0, SLAB_HWCACHE_ALIGN, NULL, NULL, NULL);
>
>  	if (!request_cachep)
>  		panic("Can't create request pool slab cache\n");
> --- 2.5.33/drivers/ieee1394/eth1394.c~slablru	Sun Sep  1 21:23:12 2002
> +++ 2.5.33-akpm/drivers/ieee1394/eth1394.c	Sun Sep  1 21:23:12 2002
> @@ -715,7 +715,7 @@ static struct hpsb_highlevel_ops hl_ops
>  static int __init ether1394_init_module (void)
>  {
>  	packet_task_cache = kmem_cache_create("packet_task", sizeof(struct
> packet_task), -					      0, 0, NULL, NULL);
> +					      0, 0, NULL, NULL, NULL);
>
>  	/* Register ourselves as a highlevel driver */
>  	hl_handle = hpsb_register_highlevel (ETHER1394_DRIVER_NAME, &hl_ops);
> --- 2.5.33/drivers/ieee1394/ieee1394_core.c~slablru	Sun Sep  1 21:23:12
> 2002 +++ 2.5.33-akpm/drivers/ieee1394/ieee1394_core.c	Sun Sep  1 21:23:12
> 2002 @@ -971,7 +971,7 @@ struct proc_dir_entry *ieee1394_procfs_e
>  static int __init ieee1394_init(void)
>  {
>  	hpsb_packet_cache = kmem_cache_create("hpsb_packet", sizeof(struct
> hpsb_packet), -					      0, 0, NULL, NULL);
> +					      0, 0, NULL, NULL, NULL);
>
>  	ieee1394_devfs_handle = devfs_mk_dir(NULL, "ieee1394", NULL);
>
> --- 2.5.33/drivers/md/raid5.c~slablru	Sun Sep  1 21:23:12 2002
> +++ 2.5.33-akpm/drivers/md/raid5.c	Sun Sep  1 21:23:12 2002
> @@ -277,7 +277,7 @@ static int grow_stripes(raid5_conf_t *co
>
>  	sc = kmem_cache_create(conf->cache_name,
>  			       sizeof(struct stripe_head)+(devs-1)*sizeof(struct r5dev),
> -			       0, 0, NULL, NULL);
> +			       0, 0, NULL, NULL, NULL);
>  	if (!sc)
>  		return 1;
>  	conf->slab_cache = sc;
> --- 2.5.33/drivers/scsi/scsi.c~slablru	Sun Sep  1 21:23:12 2002
> +++ 2.5.33-akpm/drivers/scsi/scsi.c	Sun Sep  1 21:23:12 2002
> @@ -2532,7 +2532,7 @@ static int __init init_scsi(void)
>  		struct scsi_host_sg_pool *sgp = scsi_sg_pools + i;
>  		int size = sgp->size * sizeof(struct scatterlist);
>
> -		sgp->slab = kmem_cache_create(sgp->name, size, 0, SLAB_HWCACHE_ALIGN,
> NULL, NULL); +		sgp->slab = kmem_cache_create(sgp->name, size, 0,
> SLAB_HWCACHE_ALIGN, NULL, NULL, NULL); if (!sgp->slab)
>  			panic("SCSI: can't init sg slab\n");
>
> --- 2.5.33/drivers/usb/host/uhci-hcd.c~slablru	Sun Sep  1 21:23:12 2002
> +++ 2.5.33-akpm/drivers/usb/host/uhci-hcd.c	Sun Sep  1 21:23:12 2002
> @@ -2512,7 +2512,7 @@ static int __init uhci_hcd_init(void)
>  #endif
>
>  	uhci_up_cachep = kmem_cache_create("uhci_urb_priv",
> -		sizeof(struct urb_priv), 0, 0, NULL, NULL);
> +		sizeof(struct urb_priv), 0, 0, NULL, NULL, NULL);
>  	if (!uhci_up_cachep)
>  		goto up_failed;
>
> --- 2.5.33/fs/adfs/super.c~slablru	Sun Sep  1 21:23:12 2002
> +++ 2.5.33-akpm/fs/adfs/super.c	Sun Sep  1 21:23:12 2002
> @@ -234,7 +234,7 @@ static int init_inodecache(void)
>  	adfs_inode_cachep = kmem_cache_create("adfs_inode_cache",
>  					     sizeof(struct adfs_inode_info),
>  					     0, SLAB_HWCACHE_ALIGN,
> -					     init_once, NULL);
> +					     age_icache_memory, init_once, NULL);
>  	if (adfs_inode_cachep == NULL)
>  		return -ENOMEM;
>  	return 0;
> --- 2.5.33/fs/affs/super.c~slablru	Sun Sep  1 21:23:12 2002
> +++ 2.5.33-akpm/fs/affs/super.c	Sun Sep  1 21:23:12 2002
> @@ -117,7 +117,7 @@ static int init_inodecache(void)
>  	affs_inode_cachep = kmem_cache_create("affs_inode_cache",
>  					     sizeof(struct affs_inode_info),
>  					     0, SLAB_HWCACHE_ALIGN,
> -					     init_once, NULL);
> +					     age_icache_memory, init_once, NULL);
>  	if (affs_inode_cachep == NULL)
>  		return -ENOMEM;
>  	return 0;
> --- 2.5.33/fs/aio.c~slablru	Sun Sep  1 21:23:12 2002
> +++ 2.5.33-akpm/fs/aio.c	Sun Sep  1 21:23:12 2002
> @@ -65,12 +65,12 @@ LIST_HEAD(fput_head);
>  static int __init aio_setup(void)
>  {
>  	kiocb_cachep = kmem_cache_create("kiocb", sizeof(struct kiocb),
> -				0, SLAB_HWCACHE_ALIGN, NULL, NULL);
> +				0, SLAB_HWCACHE_ALIGN, NULL, NULL, NULL);
>  	if (!kiocb_cachep)
>  		panic("unable to create kiocb cache\n");
>
>  	kioctx_cachep = kmem_cache_create("kioctx", sizeof(struct kioctx),
> -				0, SLAB_HWCACHE_ALIGN, NULL, NULL);
> +				0, SLAB_HWCACHE_ALIGN, NULL, NULL, NULL);
>  	if (!kioctx_cachep)
>  		panic("unable to create kioctx cache");
>
> --- 2.5.33/fs/bfs/inode.c~slablru	Sun Sep  1 21:23:12 2002
> +++ 2.5.33-akpm/fs/bfs/inode.c	Sun Sep  1 21:23:12 2002
> @@ -240,6 +240,7 @@ static int init_inodecache(void)
>  	bfs_inode_cachep = kmem_cache_create("bfs_inode_cache",
>  					     sizeof(struct bfs_inode_info),
>  					     0, SLAB_HWCACHE_ALIGN,
> +					     age_icache_memory,
>  					     init_once, NULL);
>  	if (bfs_inode_cachep == NULL)
>  		return -ENOMEM;
> --- 2.5.33/fs/bio.c~slablru	Sun Sep  1 21:23:12 2002
> +++ 2.5.33-akpm/fs/bio.c	Sun Sep  1 21:23:12 2002
> @@ -470,7 +470,7 @@ static void __init biovec_init_pool(void
>  						bp->size, size);
>
>  		bp->slab = kmem_cache_create(bp->name, size, 0,
> -						SLAB_HWCACHE_ALIGN, NULL, NULL);
> +						SLAB_HWCACHE_ALIGN, NULL, NULL, NULL);
>  		if (!bp->slab)
>  			panic("biovec: can't init slab cache\n");
>  		bp->pool = mempool_create(BIO_POOL_SIZE, slab_pool_alloc,
> @@ -484,7 +484,7 @@ static void __init biovec_init_pool(void
>  static int __init init_bio(void)
>  {
>  	bio_slab = kmem_cache_create("bio", sizeof(struct bio), 0,
> -					SLAB_HWCACHE_ALIGN, NULL, NULL);
> +					SLAB_HWCACHE_ALIGN, NULL, NULL, NULL);
>  	if (!bio_slab)
>  		panic("bio: can't create slab cache\n");
>  	bio_pool = mempool_create(BIO_POOL_SIZE, slab_pool_alloc, slab_pool_free,
> bio_slab); --- 2.5.33/fs/block_dev.c~slablru	Sun Sep  1 21:23:12 2002
> +++ 2.5.33-akpm/fs/block_dev.c	Sun Sep  1 21:23:12 2002
> @@ -249,8 +249,8 @@ void __init bdev_cache_init(void)
>
>  	bdev_cachep = kmem_cache_create("bdev_cache",
>  					 sizeof(struct block_device),
> -					 0, SLAB_HWCACHE_ALIGN, init_once,
> -					 NULL);
> +					 0, SLAB_HWCACHE_ALIGN,
> +				         NULL, init_once, NULL);
>  	if (!bdev_cachep)
>  		panic("Cannot create bdev_cache SLAB cache");
>  	err = register_filesystem(&bd_type);
> --- 2.5.33/fs/buffer.c~slablru	Sun Sep  1 21:23:12 2002
> +++ 2.5.33-akpm/fs/buffer.c	Sun Sep  1 21:23:12 2002
> @@ -2645,7 +2645,7 @@ void __init buffer_init(void)
>
>  	bh_cachep = kmem_cache_create("buffer_head",
>  			sizeof(struct buffer_head), 0,
> -			0, init_buffer_head, NULL);
> +			0, NULL, init_buffer_head, NULL);
>  	bh_mempool = mempool_create(MAX_UNUSED_BUFFERS, bh_mempool_alloc,
>  				bh_mempool_free, NULL);
>  	for (i = 0; i < ARRAY_SIZE(bh_wait_queue_heads); i++)
> --- 2.5.33/fs/char_dev.c~slablru	Sun Sep  1 21:23:12 2002
> +++ 2.5.33-akpm/fs/char_dev.c	Sun Sep  1 21:23:12 2002
> @@ -46,8 +46,8 @@ void __init cdev_cache_init(void)
>
>  	cdev_cachep = kmem_cache_create("cdev_cache",
>  					 sizeof(struct char_device),
> -					 0, SLAB_HWCACHE_ALIGN, init_once,
> -					 NULL);
> +					 0, SLAB_HWCACHE_ALIGN, NULL,
> +					 init_once, NULL);
>  	if (!cdev_cachep)
>  		panic("Cannot create cdev_cache SLAB cache");
>  }
> --- 2.5.33/fs/coda/inode.c~slablru	Sun Sep  1 21:23:12 2002
> +++ 2.5.33-akpm/fs/coda/inode.c	Sun Sep  1 21:23:12 2002
> @@ -73,9 +73,10 @@ int coda_init_inodecache(void)
>  	coda_inode_cachep = kmem_cache_create("coda_inode_cache",
>  					     sizeof(struct coda_inode_info),
>  					     0, SLAB_HWCACHE_ALIGN,
> -					     init_once, NULL);
> +					     age_icache_memory, init_once, NULL);
>  	if (coda_inode_cachep == NULL)
>  		return -ENOMEM;
> +
>  	return 0;
>  }
>
> --- 2.5.33/fs/dcache.c~slablru	Sun Sep  1 21:23:12 2002
> +++ 2.5.33-akpm/fs/dcache.c	Sun Sep  1 21:23:12 2002
> @@ -123,8 +123,7 @@ repeat:
>  		return;
>
>  	/* dput on a free dentry? */
> -	if (!list_empty(&dentry->d_lru))
> -		BUG();
> +	BUG_ON(!list_empty(&dentry->d_lru));
>  	/*
>  	 * AV: ->d_delete() is _NOT_ allowed to block now.
>  	 */
> @@ -329,12 +328,11 @@ static inline void prune_one_dentry(stru
>  void prune_dcache(int count)
>  {
>  	spin_lock(&dcache_lock);
> -	for (;;) {
> +	for (; count ; count--) {
>  		struct dentry *dentry;
>  		struct list_head *tmp;
>
>  		tmp = dentry_unused.prev;
> -
>  		if (tmp == &dentry_unused)
>  			break;
>  		list_del_init(tmp);
> @@ -349,12 +347,8 @@ void prune_dcache(int count)
>  		dentry_stat.nr_unused--;
>
>  		/* Unused dentry with a count? */
> -		if (atomic_read(&dentry->d_count))
> -			BUG();
> -
> +		BUG_ON(atomic_read(&dentry->d_count));
>  		prune_one_dentry(dentry);
> -		if (!--count)
> -			break;
>  	}
>  	spin_unlock(&dcache_lock);
>  }
> @@ -573,19 +567,10 @@ void shrink_dcache_anon(struct list_head
>
>  /*
>   * This is called from kswapd when we think we need some
> - * more memory, but aren't really sure how much. So we
> - * carefully try to free a _bit_ of our dcache, but not
> - * too much.
> - *
> - * Priority:
> - *   1 - very urgent: shrink everything
> - *  ...
> - *   6 - base-level: try to shrink a bit.
> + * more memory.
>   */
> -int shrink_dcache_memory(int priority, unsigned int gfp_mask)
> +int age_dcache_memory(kmem_cache_t *cachep, int entries, int gfp_mask)
>  {
> -	int count = 0;
> -
>  	/*
>  	 * Nasty deadlock avoidance.
>  	 *
> @@ -600,11 +585,11 @@ int shrink_dcache_memory(int priority, u
>  	if (!(gfp_mask & __GFP_FS))
>  		return 0;
>
> -	count = dentry_stat.nr_unused / priority;
> +	if (entries > dentry_stat.nr_unused)
> +		entries = dentry_stat.nr_unused;
>
> -	prune_dcache(count);
> -	kmem_cache_shrink(dentry_cache);
> -	return 0;
> +	prune_dcache(entries);
> +	return entries;
>  }
>
>  #define NAME_ALLOC_LEN(len)	((len+16) & ~15)
> @@ -686,7 +671,7 @@ struct dentry * d_alloc(struct dentry *
>
>  void d_instantiate(struct dentry *entry, struct inode * inode)
>  {
> -	if (!list_empty(&entry->d_alias)) BUG();
> +	BUG_ON(!list_empty(&entry->d_alias));
>  	spin_lock(&dcache_lock);
>  	if (inode)
>  		list_add(&entry->d_alias, &inode->i_dentry);
> @@ -985,7 +970,7 @@ void d_delete(struct dentry * dentry)
>  void d_rehash(struct dentry * entry)
>  {
>  	struct list_head *list = d_hash(entry->d_parent, entry->d_name.hash);
> -	if (!list_empty(&entry->d_hash)) BUG();
> +	BUG_ON(!list_empty(&entry->d_hash));
>  	spin_lock(&dcache_lock);
>  	list_add(&entry->d_hash, list);
>  	spin_unlock(&dcache_lock);
> @@ -1341,7 +1326,7 @@ static void __init dcache_init(unsigned
>  					 sizeof(struct dentry),
>  					 0,
>  					 SLAB_HWCACHE_ALIGN,
> -					 NULL, NULL);
> +					 age_dcache_memory, NULL, NULL);
>  	if (!dentry_cache)
>  		panic("Cannot create dentry cache");
>
> @@ -1401,22 +1386,23 @@ void __init vfs_caches_init(unsigned lon
>  {
>  	names_cachep = kmem_cache_create("names_cache",
>  			PATH_MAX, 0,
> -			SLAB_HWCACHE_ALIGN, NULL, NULL);
> +			SLAB_HWCACHE_ALIGN, NULL, NULL, NULL);
>  	if (!names_cachep)
>  		panic("Cannot create names SLAB cache");
>
>  	filp_cachep = kmem_cache_create("filp",
>  			sizeof(struct file), 0,
> -			SLAB_HWCACHE_ALIGN, NULL, NULL);
> +			SLAB_HWCACHE_ALIGN, NULL, NULL, NULL);
>  	if(!filp_cachep)
>  		panic("Cannot create filp SLAB cache");
>
>  #if defined (CONFIG_QUOTA)
>  	dquot_cachep = kmem_cache_create("dquot",
>  			sizeof(struct dquot), sizeof(unsigned long) * 4,
> -			SLAB_HWCACHE_ALIGN, NULL, NULL);
> +			SLAB_HWCACHE_ALIGN, age_dqcache_memory, NULL, NULL);
>  	if (!dquot_cachep)
>  		panic("Cannot create dquot SLAB cache");
> +
>  #endif
>
>  	dcache_init(mempages);
> --- 2.5.33/fs/devfs/base.c~slablru	Sun Sep  1 21:23:12 2002
> +++ 2.5.33-akpm/fs/devfs/base.c	Sun Sep  1 21:23:12 2002
> @@ -3455,7 +3455,7 @@ static int __init init_devfs_fs (void)
>  	    DEVFS_NAME, DEVFS_VERSION);
>      devfsd_buf_cache = kmem_cache_create ("devfsd_event",
>  					  sizeof (struct devfsd_buf_entry),
> -					  0, 0, NULL, NULL);
> +					  0, 0, NULL, NULL, NULL);
>      if (!devfsd_buf_cache) OOPS ("(): unable to allocate event slab\n");
>  #ifdef CONFIG_DEVFS_DEBUG
>      devfs_debug = devfs_debug_init;
> --- 2.5.33/fs/dnotify.c~slablru	Sun Sep  1 21:23:12 2002
> +++ 2.5.33-akpm/fs/dnotify.c	Sun Sep  1 21:23:12 2002
> @@ -149,7 +149,7 @@ void __inode_dir_notify(struct inode *in
>  static int __init dnotify_init(void)
>  {
>  	dn_cache = kmem_cache_create("dnotify cache",
> -		sizeof(struct dnotify_struct), 0, 0, NULL, NULL);
> +		sizeof(struct dnotify_struct), 0, 0, NULL, NULL, NULL);
>  	if (!dn_cache)
>  		panic("cannot create dnotify slab cache");
>  	return 0;
> --- 2.5.33/fs/dquot.c~slablru	Sun Sep  1 21:23:12 2002
> +++ 2.5.33-akpm/fs/dquot.c	Sun Sep  1 21:23:12 2002
> @@ -480,26 +480,18 @@ static void prune_dqcache(int count)
>
>  /*
>   * This is called from kswapd when we think we need some
> - * more memory, but aren't really sure how much. So we
> - * carefully try to free a _bit_ of our dqcache, but not
> - * too much.
> - *
> - * Priority:
> - *   1 - very urgent: shrink everything
> - *   ...
> - *   6 - base-level: try to shrink a bit.
> + * more memory
>   */
>
> -int shrink_dqcache_memory(int priority, unsigned int gfp_mask)
> +int age_dqcache_memory(kmem_cache_t *cachep, int entries, int gfp_mask)
>  {
> -	int count = 0;
> +	if (entries > dqstats.free_dquots)
> +		entries = dqstats.free_dquots;
>
>  	lock_kernel();
> -	count = dqstats.free_dquots / priority;
> -	prune_dqcache(count);
> +	prune_dqcache(entries);
>  	unlock_kernel();
> -	kmem_cache_shrink(dquot_cachep);
> -	return 0;
> +	return entries;
>  }
>
>  /*
> --- 2.5.33/fs/efs/super.c~slablru	Sun Sep  1 21:23:12 2002
> +++ 2.5.33-akpm/fs/efs/super.c	Sun Sep  1 21:23:12 2002
> @@ -58,6 +58,7 @@ static int init_inodecache(void)
>  	efs_inode_cachep = kmem_cache_create("efs_inode_cache",
>  					     sizeof(struct efs_inode_info),
>  					     0, SLAB_HWCACHE_ALIGN,
> +					     age_icache_memory,
>  					     init_once, NULL);
>  	if (efs_inode_cachep == NULL)
>  		return -ENOMEM;
> --- 2.5.33/fs/ext2/super.c~slablru	Sun Sep  1 21:23:12 2002
> +++ 2.5.33-akpm/fs/ext2/super.c	Sun Sep  1 21:23:12 2002
> @@ -181,7 +181,7 @@ static int init_inodecache(void)
>  	ext2_inode_cachep = kmem_cache_create("ext2_inode_cache",
>  					     sizeof(struct ext2_inode_info),
>  					     0, SLAB_HWCACHE_ALIGN,
> -					     init_once, NULL);
> +					     age_icache_memory, init_once, NULL);
>  	if (ext2_inode_cachep == NULL)
>  		return -ENOMEM;
>  	return 0;
> --- 2.5.33/fs/ext3/super.c~slablru	Sun Sep  1 21:23:12 2002
> +++ 2.5.33-akpm/fs/ext3/super.c	Sun Sep  1 21:30:41 2002
> @@ -480,7 +480,7 @@ static int init_inodecache(void)
>  	ext3_inode_cachep = kmem_cache_create("ext3_inode_cache",
>  					     sizeof(struct ext3_inode_info),
>  					     0, SLAB_HWCACHE_ALIGN,
> -					     init_once, NULL);
> +					     age_icache_memory, init_once, NULL);
>  	if (ext3_inode_cachep == NULL)
>  		return -ENOMEM;
>  	return 0;
> --- 2.5.33/fs/fat/inode.c~slablru	Sun Sep  1 21:23:12 2002
> +++ 2.5.33-akpm/fs/fat/inode.c	Sun Sep  1 21:23:12 2002
> @@ -597,6 +597,7 @@ int __init fat_init_inodecache(void)
>  	fat_inode_cachep = kmem_cache_create("fat_inode_cache",
>  					     sizeof(struct msdos_inode_info),
>  					     0, SLAB_HWCACHE_ALIGN,
> +					     age_icache_memory,
>  					     init_once, NULL);
>  	if (fat_inode_cachep == NULL)
>  		return -ENOMEM;
> --- 2.5.33/fs/fcntl.c~slablru	Sun Sep  1 21:23:12 2002
> +++ 2.5.33-akpm/fs/fcntl.c	Sun Sep  1 21:23:12 2002
> @@ -559,7 +559,7 @@ void kill_fasync(struct fasync_struct **
>  static int __init fasync_init(void)
>  {
>  	fasync_cache = kmem_cache_create("fasync_cache",
> -		sizeof(struct fasync_struct), 0, 0, NULL, NULL);
> +		sizeof(struct fasync_struct), 0, 0, NULL, NULL, NULL);
>  	if (!fasync_cache)
>  		panic("cannot create fasync slab cache");
>  	return 0;
> --- 2.5.33/fs/freevxfs/vxfs_super.c~slablru	Sun Sep  1 21:23:12 2002
> +++ 2.5.33-akpm/fs/freevxfs/vxfs_super.c	Sun Sep  1 21:23:12 2002
> @@ -246,9 +246,10 @@ static int __init
>  vxfs_init(void)
>  {
>  	vxfs_inode_cachep = kmem_cache_create("vxfs_inode",
> -			sizeof(struct vxfs_inode_info), 0, 0, NULL, NULL);
> -	if (vxfs_inode_cachep)
> +			sizeof(struct vxfs_inode_info), 0, 0, age_icache_memory, NULL, NULL);
> +	if (vxfs_inode_cachep) {
>  		return (register_filesystem(&vxfs_fs_type));
> +	}
>  	return -ENOMEM;
>  }
>
> --- 2.5.33/fs/hfs/super.c~slablru	Sun Sep  1 21:23:12 2002
> +++ 2.5.33-akpm/fs/hfs/super.c	Sun Sep  1 21:23:12 2002
> @@ -72,6 +72,7 @@ static int init_inodecache(void)
>  	hfs_inode_cachep = kmem_cache_create("hfs_inode_cache",
>  					     sizeof(struct hfs_inode_info),
>  					     0, SLAB_HWCACHE_ALIGN,
> +					     age_icache_memory,
>  					     init_once, NULL);
>  	if (hfs_inode_cachep == NULL)
>  		return -ENOMEM;
> --- 2.5.33/fs/hpfs/super.c~slablru	Sun Sep  1 21:23:12 2002
> +++ 2.5.33-akpm/fs/hpfs/super.c	Sun Sep  1 21:23:12 2002
> @@ -186,7 +186,7 @@ static int init_inodecache(void)
>  	hpfs_inode_cachep = kmem_cache_create("hpfs_inode_cache",
>  					     sizeof(struct hpfs_inode_info),
>  					     0, SLAB_HWCACHE_ALIGN,
> -					     init_once, NULL);
> +					     age_icache_memory, init_once, NULL);
>  	if (hpfs_inode_cachep == NULL)
>  		return -ENOMEM;
>  	return 0;
> --- 2.5.33/fs/inode.c~slablru	Sun Sep  1 21:23:12 2002
> +++ 2.5.33-akpm/fs/inode.c	Sun Sep  1 21:30:44 2002
> @@ -388,10 +388,11 @@ void prune_icache(int goal)
>
>  	count = 0;
>  	entry = inode_unused.prev;
> -	while (entry != &inode_unused)
> -	{
> +	for(; goal; goal--) {
>  		struct list_head *tmp = entry;
>
> +		if (entry == &inode_unused)
> +			break;
>  		entry = entry->prev;
>  		inode = INODE(tmp);
>  		if (inode->i_state & (I_FREEING|I_CLEAR|I_LOCK))
> @@ -405,8 +406,6 @@ void prune_icache(int goal)
>  		list_add(tmp, freeable);
>  		inode->i_state |= I_FREEING;
>  		count++;
> -		if (!--goal)
> -			break;
>  	}
>  	inodes_stat.nr_unused -= count;
>  	spin_unlock(&inode_lock);
> @@ -416,19 +415,10 @@ void prune_icache(int goal)
>
>  /*
>   * This is called from kswapd when we think we need some
> - * more memory, but aren't really sure how much. So we
> - * carefully try to free a _bit_ of our icache, but not
> - * too much.
> - *
> - * Priority:
> - *   1 - very urgent: shrink everything
> - *  ...
> - *   6 - base-level: try to shrink a bit.
> + * more memory.
>   */
> -int shrink_icache_memory(int priority, int gfp_mask)
> +int age_icache_memory(kmem_cache_t *cachep, int entries, int gfp_mask)
>  {
> -	int count = 0;
> -
>  	/*
>  	 * Nasty deadlock avoidance..
>  	 *
> @@ -439,12 +429,13 @@ int shrink_icache_memory(int priority, i
>  	if (!(gfp_mask & __GFP_FS))
>  		return 0;
>
> -	count = inodes_stat.nr_unused / priority;
> +	if (entries > inodes_stat.nr_unused)
> +		entries = inodes_stat.nr_unused;
>
> -	prune_icache(count);
> -	kmem_cache_shrink(inode_cachep);
> -	return 0;
> +	prune_icache(entries);
> +	return entries;
>  }
> +EXPORT_SYMBOL(age_icache_memory);
>
>  /*
>   * Called with the inode lock held.
> @@ -1103,8 +1094,8 @@ void __init inode_init(unsigned long mem
>
>  	/* inode slab cache */
>  	inode_cachep = kmem_cache_create("inode_cache", sizeof(struct inode),
> -					 0, SLAB_HWCACHE_ALIGN, init_once,
> -					 NULL);
> +					 0, SLAB_HWCACHE_ALIGN, age_icache_memory,
> +					 init_once, NULL);
>  	if (!inode_cachep)
>  		panic("cannot create inode slab cache");
>  }
> --- 2.5.33/fs/intermezzo/dcache.c~slablru	Sun Sep  1 21:23:12 2002
> +++ 2.5.33-akpm/fs/intermezzo/dcache.c	Sun Sep  1 21:23:12 2002
> @@ -127,7 +127,7 @@ void presto_init_ddata_cache(void)
>                  kmem_cache_create("presto_cache",
>                                    sizeof(struct presto_dentry_data), 0,
>                                    SLAB_HWCACHE_ALIGN, NULL,
> -                                  NULL);
> +                                  NULL, NULL);
>          EXIT;
>  }
>
> --- 2.5.33/fs/isofs/inode.c~slablru	Sun Sep  1 21:23:12 2002
> +++ 2.5.33-akpm/fs/isofs/inode.c	Sun Sep  1 21:23:12 2002
> @@ -111,7 +111,7 @@ static int init_inodecache(void)
>  	isofs_inode_cachep = kmem_cache_create("isofs_inode_cache",
>  					     sizeof(struct iso_inode_info),
>  					     0, SLAB_HWCACHE_ALIGN,
> -					     init_once, NULL);
> +					     age_icache_memory, init_once, NULL);
>  	if (isofs_inode_cachep == NULL)
>  		return -ENOMEM;
>  	return 0;
> --- 2.5.33/fs/jbd/journal.c~slablru	Sun Sep  1 21:23:12 2002
> +++ 2.5.33-akpm/fs/jbd/journal.c	Sun Sep  1 21:23:12 2002
> @@ -1569,6 +1569,7 @@ static int journal_init_journal_head_cac
>  				sizeof(struct journal_head),
>  				0,		/* offset */
>  				0,		/* flags */
> +				NULL,		/* pruner */
>  				NULL,		/* ctor */
>  				NULL);		/* dtor */
>  	retval = 0;
> --- 2.5.33/fs/jbd/revoke.c~slablru	Sun Sep  1 21:23:12 2002
> +++ 2.5.33-akpm/fs/jbd/revoke.c	Sun Sep  1 21:23:12 2002
> @@ -163,13 +163,13 @@ int __init journal_init_revoke_caches(vo
>  {
>  	revoke_record_cache = kmem_cache_create("revoke_record",
>  					   sizeof(struct jbd_revoke_record_s),
> -					   0, SLAB_HWCACHE_ALIGN, NULL, NULL);
> +					   0, SLAB_HWCACHE_ALIGN, NULL, NULL, NULL);
>  	if (revoke_record_cache == 0)
>  		return -ENOMEM;
>
>  	revoke_table_cache = kmem_cache_create("revoke_table",
>  					   sizeof(struct jbd_revoke_table_s),
> -					   0, 0, NULL, NULL);
> +					   0, 0, NULL, NULL, NULL);
>  	if (revoke_table_cache == 0) {
>  		kmem_cache_destroy(revoke_record_cache);
>  		revoke_record_cache = NULL;
> --- 2.5.33/fs/jffs2/malloc.c~slablru	Sun Sep  1 21:23:12 2002
> +++ 2.5.33-akpm/fs/jffs2/malloc.c	Sun Sep  1 21:23:12 2002
> @@ -37,43 +37,43 @@ int __init jffs2_create_slab_caches(void
>  {
>  	full_dnode_slab = kmem_cache_create("jffs2_full_dnode",
>  					    sizeof(struct jffs2_full_dnode),
> -					    0, JFFS2_SLAB_POISON, NULL, NULL);
> +					    0, JFFS2_SLAB_POISON, NULL, NULL, NULL);
>  	if (!full_dnode_slab)
>  		goto err;
>
>  	raw_dirent_slab = kmem_cache_create("jffs2_raw_dirent",
>  					    sizeof(struct jffs2_raw_dirent),
> -					    0, JFFS2_SLAB_POISON, NULL, NULL);
> +					    0, JFFS2_SLAB_POISON, NULL, NULL, NULL);
>  	if (!raw_dirent_slab)
>  		goto err;
>
>  	raw_inode_slab = kmem_cache_create("jffs2_raw_inode",
>  					   sizeof(struct jffs2_raw_inode),
> -					   0, JFFS2_SLAB_POISON, NULL, NULL);
> +					   0, JFFS2_SLAB_POISON, NULL, NULL, NULL);
>  	if (!raw_inode_slab)
>  		goto err;
>
>  	tmp_dnode_info_slab = kmem_cache_create("jffs2_tmp_dnode",
>  						sizeof(struct jffs2_tmp_dnode_info),
> -						0, JFFS2_SLAB_POISON, NULL, NULL);
> +						0, JFFS2_SLAB_POISON, NULL, NULL, NULL);
>  	if (!tmp_dnode_info_slab)
>  		goto err;
>
>  	raw_node_ref_slab = kmem_cache_create("jffs2_raw_node_ref",
>  					      sizeof(struct jffs2_raw_node_ref),
> -					      0, JFFS2_SLAB_POISON, NULL, NULL);
> +					      0, JFFS2_SLAB_POISON, NULL, NULL, NULL);
>  	if (!raw_node_ref_slab)
>  		goto err;
>
>  	node_frag_slab = kmem_cache_create("jffs2_node_frag",
>  					   sizeof(struct jffs2_node_frag),
> -					   0, JFFS2_SLAB_POISON, NULL, NULL);
> +					   0, JFFS2_SLAB_POISON, NULL, NULL, NULL);
>  	if (!node_frag_slab)
>  		goto err;
>
>  	inode_cache_slab = kmem_cache_create("jffs2_inode_cache",
>  					     sizeof(struct jffs2_inode_cache),
> -					     0, JFFS2_SLAB_POISON, NULL, NULL);
> +					     0, JFFS2_SLAB_POISON, NULL, NULL, NULL);
>  	if (inode_cache_slab)
>  		return 0;
>   err:
> --- 2.5.33/fs/jffs2/super.c~slablru	Sun Sep  1 21:23:12 2002
> +++ 2.5.33-akpm/fs/jffs2/super.c	Sun Sep  1 21:23:12 2002
> @@ -299,7 +299,7 @@ static int __init init_jffs2_fs(void)
>  	jffs2_inode_cachep = kmem_cache_create("jffs2_i",
>  					     sizeof(struct jffs2_inode_info),
>  					     0, SLAB_HWCACHE_ALIGN,
> -					     jffs2_i_init_once, NULL);
> +					     age_icache_memory, jffs2_i_init_once, NULL);
>  	if (!jffs2_inode_cachep) {
>  		printk(KERN_ERR "JFFS2 error: Failed to initialise inode cache\n");
>  		return -ENOMEM;
> --- 2.5.33/fs/jffs/inode-v23.c~slablru	Sun Sep  1 21:23:12 2002
> +++ 2.5.33-akpm/fs/jffs/inode-v23.c	Sun Sep  1 21:23:12 2002
> @@ -1799,9 +1799,9 @@ init_jffs_fs(void)
>  	jffs_proc_root = proc_mkdir("jffs", proc_root_fs);
>  #endif
>  	fm_cache = kmem_cache_create("jffs_fm", sizeof(struct jffs_fm),
> -				     0, SLAB_HWCACHE_ALIGN, NULL, NULL);
> +				     0, SLAB_HWCACHE_ALIGN, NULL, NULL, NULL);
>  	node_cache = kmem_cache_create("jffs_node",sizeof(struct jffs_node),
> -				       0, SLAB_HWCACHE_ALIGN, NULL, NULL);
> +				       0, SLAB_HWCACHE_ALIGN, NULL, NULL, NULL);
>  	return register_filesystem(&jffs_fs_type);
>  }
>
> --- 2.5.33/fs/jfs/super.c~slablru	Sun Sep  1 21:23:12 2002
> +++ 2.5.33-akpm/fs/jfs/super.c	Sun Sep  1 21:23:12 2002
> @@ -457,7 +457,7 @@ static int __init init_jfs_fs(void)
>
>  	jfs_inode_cachep =
>  	    kmem_cache_create("jfs_ip", sizeof(struct jfs_inode_info), 0, 0,
> -			      init_once, NULL);
> +			      age_icache_memory, init_once, NULL);
>  	if (jfs_inode_cachep == NULL)
>  		return -ENOMEM;
>
> --- 2.5.33/fs/locks.c~slablru	Sun Sep  1 21:23:12 2002
> +++ 2.5.33-akpm/fs/locks.c	Sun Sep  1 21:23:12 2002
> @@ -1892,7 +1892,7 @@ int lock_may_write(struct inode *inode,
>  static int __init filelock_init(void)
>  {
>  	filelock_cache = kmem_cache_create("file_lock_cache",
> -			sizeof(struct file_lock), 0, 0, init_once, NULL);
> +			sizeof(struct file_lock), 0, 0, NULL, init_once, NULL);
>  	if (!filelock_cache)
>  		panic("cannot create file lock slab cache");
>  	return 0;
> --- 2.5.33/fs/minix/inode.c~slablru	Sun Sep  1 21:23:12 2002
> +++ 2.5.33-akpm/fs/minix/inode.c	Sun Sep  1 21:23:12 2002
> @@ -79,7 +79,7 @@ static int init_inodecache(void)
>  	minix_inode_cachep = kmem_cache_create("minix_inode_cache",
>  					     sizeof(struct minix_inode_info),
>  					     0, SLAB_HWCACHE_ALIGN,
> -					     init_once, NULL);
> +					     age_icache_memory, init_once, NULL);
>  	if (minix_inode_cachep == NULL)
>  		return -ENOMEM;
>  	return 0;
> --- 2.5.33/fs/namespace.c~slablru	Sun Sep  1 21:23:12 2002
> +++ 2.5.33-akpm/fs/namespace.c	Sun Sep  1 21:23:12 2002
> @@ -1046,7 +1046,7 @@ void __init mnt_init(unsigned long mempa
>  	int i;
>
>  	mnt_cache = kmem_cache_create("mnt_cache", sizeof(struct vfsmount),
> -					0, SLAB_HWCACHE_ALIGN, NULL, NULL);
> +					0, SLAB_HWCACHE_ALIGN, NULL, NULL, NULL);
>  	if (!mnt_cache)
>  		panic("Cannot create vfsmount cache");
>
> --- 2.5.33/fs/ncpfs/inode.c~slablru	Sun Sep  1 21:23:12 2002
> +++ 2.5.33-akpm/fs/ncpfs/inode.c	Sun Sep  1 21:23:12 2002
> @@ -69,7 +69,7 @@ static int init_inodecache(void)
>  	ncp_inode_cachep = kmem_cache_create("ncp_inode_cache",
>  					     sizeof(struct ncp_inode_info),
>  					     0, SLAB_HWCACHE_ALIGN,
> -					     init_once, NULL);
> +					     age_icache_memory, init_once, NULL);
>  	if (ncp_inode_cachep == NULL)
>  		return -ENOMEM;
>  	return 0;
> --- 2.5.33/fs/nfs/inode.c~slablru	Sun Sep  1 21:23:12 2002
> +++ 2.5.33-akpm/fs/nfs/inode.c	Sun Sep  1 21:23:12 2002
> @@ -1317,7 +1317,7 @@ int nfs_init_inodecache(void)
>  	nfs_inode_cachep = kmem_cache_create("nfs_inode_cache",
>  					     sizeof(struct nfs_inode),
>  					     0, SLAB_HWCACHE_ALIGN,
> -					     init_once, NULL);
> +					     age_icache_memory, init_once, NULL);
>  	if (nfs_inode_cachep == NULL)
>  		return -ENOMEM;
>
> --- 2.5.33/fs/nfs/pagelist.c~slablru	Sun Sep  1 21:23:12 2002
> +++ 2.5.33-akpm/fs/nfs/pagelist.c	Sun Sep  1 21:23:12 2002
> @@ -492,7 +492,7 @@ int nfs_init_nfspagecache(void)
>  	nfs_page_cachep = kmem_cache_create("nfs_page",
>  					    sizeof(struct nfs_page),
>  					    0, SLAB_HWCACHE_ALIGN,
> -					    NULL, NULL);
> +					    NULL, NULL, NULL);
>  	if (nfs_page_cachep == NULL)
>  		return -ENOMEM;
>
> --- 2.5.33/fs/nfs/read.c~slablru	Sun Sep  1 21:23:12 2002
> +++ 2.5.33-akpm/fs/nfs/read.c	Sun Sep  1 21:23:12 2002
> @@ -497,7 +497,7 @@ int nfs_init_readpagecache(void)
>  	nfs_rdata_cachep = kmem_cache_create("nfs_read_data",
>  					     sizeof(struct nfs_read_data),
>  					     0, SLAB_HWCACHE_ALIGN,
> -					     NULL, NULL);
> +					     NULL, NULL, NULL);
>  	if (nfs_rdata_cachep == NULL)
>  		return -ENOMEM;
>
> --- 2.5.33/fs/nfs/write.c~slablru	Sun Sep  1 21:23:12 2002
> +++ 2.5.33-akpm/fs/nfs/write.c	Sun Sep  1 21:23:12 2002
> @@ -1317,7 +1317,7 @@ int nfs_init_writepagecache(void)
>  	nfs_wdata_cachep = kmem_cache_create("nfs_write_data",
>  					     sizeof(struct nfs_write_data),
>  					     0, SLAB_HWCACHE_ALIGN,
> -					     NULL, NULL);
> +					     NULL, NULL, NULL);
>  	if (nfs_wdata_cachep == NULL)
>  		return -ENOMEM;
>
> --- 2.5.33/fs/ntfs/super.c~slablru	Sun Sep  1 21:23:12 2002
> +++ 2.5.33-akpm/fs/ntfs/super.c	Sun Sep  1 21:23:12 2002
> @@ -1667,7 +1667,7 @@ static int __init init_ntfs_fs(void)
>
>  	ntfs_attr_ctx_cache = kmem_cache_create(ntfs_attr_ctx_cache_name,
>  			sizeof(attr_search_context), 0 /* offset */,
> -			SLAB_HWCACHE_ALIGN, NULL /* ctor */, NULL /* dtor */);
> +			SLAB_HWCACHE_ALIGN, NULL, NULL /* ctor */, NULL /* dtor */);
>  	if (!ntfs_attr_ctx_cache) {
>  		printk(KERN_CRIT "NTFS: Failed to create %s!\n",
>  				ntfs_attr_ctx_cache_name);
> @@ -1676,7 +1676,7 @@ static int __init init_ntfs_fs(void)
>
>  	ntfs_name_cache = kmem_cache_create(ntfs_name_cache_name,
>  			(NTFS_MAX_NAME_LEN+1) * sizeof(uchar_t), 0,
> -			SLAB_HWCACHE_ALIGN, NULL, NULL);
> +			SLAB_HWCACHE_ALIGN, NULL, NULL, NULL);
>  	if (!ntfs_name_cache) {
>  		printk(KERN_CRIT "NTFS: Failed to create %s!\n",
>  				ntfs_name_cache_name);
> @@ -1684,7 +1684,8 @@ static int __init init_ntfs_fs(void)
>  	}
>
>  	ntfs_inode_cache = kmem_cache_create(ntfs_inode_cache_name,
> -			sizeof(ntfs_inode), 0, SLAB_HWCACHE_ALIGN, NULL, NULL);
> +			sizeof(ntfs_inode), 0, SLAB_HWCACHE_ALIGN,
> +			age_icache_memory, NULL, NULL);
>  	if (!ntfs_inode_cache) {
>  		printk(KERN_CRIT "NTFS: Failed to create %s!\n",
>  				ntfs_inode_cache_name);
> @@ -1693,7 +1694,7 @@ static int __init init_ntfs_fs(void)
>
>  	ntfs_big_inode_cache = kmem_cache_create(ntfs_big_inode_cache_name,
>  			sizeof(big_ntfs_inode), 0, SLAB_HWCACHE_ALIGN,
> -			ntfs_big_inode_init_once, NULL);
> +			age_icache_memory, ntfs_big_inode_init_once, NULL);
>  	if (!ntfs_big_inode_cache) {
>  		printk(KERN_CRIT "NTFS: Failed to create %s!\n",
>  				ntfs_big_inode_cache_name);
> --- 2.5.33/fs/proc/inode.c~slablru	Sun Sep  1 21:23:12 2002
> +++ 2.5.33-akpm/fs/proc/inode.c	Sun Sep  1 21:23:12 2002
> @@ -123,7 +123,7 @@ int __init proc_init_inodecache(void)
>  	proc_inode_cachep = kmem_cache_create("proc_inode_cache",
>  					     sizeof(struct proc_inode),
>  					     0, SLAB_HWCACHE_ALIGN,
> -					     init_once, NULL);
> +					     age_icache_memory, init_once, NULL);
>  	if (proc_inode_cachep == NULL)
>  		return -ENOMEM;
>  	return 0;
> --- 2.5.33/fs/qnx4/inode.c~slablru	Sun Sep  1 21:23:12 2002
> +++ 2.5.33-akpm/fs/qnx4/inode.c	Sun Sep  1 21:23:12 2002
> @@ -544,7 +544,7 @@ static int init_inodecache(void)
>  	qnx4_inode_cachep = kmem_cache_create("qnx4_inode_cache",
>  					     sizeof(struct qnx4_inode_info),
>  					     0, SLAB_HWCACHE_ALIGN,
> -					     init_once, NULL);
> +					     age_icache_memory, init_once, NULL);
>  	if (qnx4_inode_cachep == NULL)
>  		return -ENOMEM;
>  	return 0;
> --- 2.5.33/fs/reiserfs/super.c~slablru	Sun Sep  1 21:23:12 2002
> +++ 2.5.33-akpm/fs/reiserfs/super.c	Sun Sep  1 21:23:12 2002
> @@ -434,7 +434,7 @@ static int init_inodecache(void)
>  	reiserfs_inode_cachep = kmem_cache_create("reiser_inode_cache",
>  					     sizeof(struct reiserfs_inode_info),
>  					     0, SLAB_HWCACHE_ALIGN,
> -					     init_once, NULL);
> +					     age_icache_memory, init_once, NULL);
>  	if (reiserfs_inode_cachep == NULL)
>  		return -ENOMEM;
>  	return 0;
> --- 2.5.33/fs/romfs/inode.c~slablru	Sun Sep  1 21:23:12 2002
> +++ 2.5.33-akpm/fs/romfs/inode.c	Sun Sep  1 21:23:12 2002
> @@ -577,7 +577,7 @@ static int init_inodecache(void)
>  	romfs_inode_cachep = kmem_cache_create("romfs_inode_cache",
>  					     sizeof(struct romfs_inode_info),
>  					     0, SLAB_HWCACHE_ALIGN,
> -					     init_once, NULL);
> +					     age_icache_memory, init_once, NULL);
>  	if (romfs_inode_cachep == NULL)
>  		return -ENOMEM;
>  	return 0;
> --- 2.5.33/fs/smbfs/inode.c~slablru	Sun Sep  1 21:23:12 2002
> +++ 2.5.33-akpm/fs/smbfs/inode.c	Sun Sep  1 21:23:12 2002
> @@ -78,7 +78,7 @@ static int init_inodecache(void)
>  	smb_inode_cachep = kmem_cache_create("smb_inode_cache",
>  					     sizeof(struct smb_inode_info),
>  					     0, SLAB_HWCACHE_ALIGN,
> -					     init_once, NULL);
> +					     age_icache_memory, init_once, NULL);
>  	if (smb_inode_cachep == NULL)
>  		return -ENOMEM;
>  	return 0;
> --- 2.5.33/fs/smbfs/request.c~slablru	Sun Sep  1 21:23:12 2002
> +++ 2.5.33-akpm/fs/smbfs/request.c	Sun Sep  1 21:23:12 2002
> @@ -37,7 +37,7 @@ int smb_init_request_cache(void)
>  	req_cachep = kmem_cache_create("smb_request",
>  				       sizeof(struct smb_request), 0,
>  				       SMB_SLAB_DEBUG | SLAB_HWCACHE_ALIGN,
> -				       NULL, NULL);
> +				       NULL, NULL, NULL);
>  	if (req_cachep == NULL)
>  		return -ENOMEM;
>
> --- 2.5.33/fs/sysv/inode.c~slablru	Sun Sep  1 21:23:12 2002
> +++ 2.5.33-akpm/fs/sysv/inode.c	Sun Sep  1 21:23:12 2002
> @@ -325,7 +325,7 @@ int __init sysv_init_icache(void)
>  {
>  	sysv_inode_cachep = kmem_cache_create("sysv_inode_cache",
>  			sizeof(struct sysv_inode_info), 0,
> -			SLAB_HWCACHE_ALIGN, init_once, NULL);
> +			SLAB_HWCACHE_ALIGN, age_icache_memory, init_once, NULL);
>  	if (!sysv_inode_cachep)
>  		return -ENOMEM;
>  	return 0;
> --- 2.5.33/fs/udf/super.c~slablru	Sun Sep  1 21:23:12 2002
> +++ 2.5.33-akpm/fs/udf/super.c	Sun Sep  1 21:23:12 2002
> @@ -141,7 +141,7 @@ static int init_inodecache(void)
>  	udf_inode_cachep = kmem_cache_create("udf_inode_cache",
>  					     sizeof(struct udf_inode_info),
>  					     0, SLAB_HWCACHE_ALIGN,
> -					     init_once, NULL);
> +					     age_icache_memory, init_once, NULL);
>  	if (udf_inode_cachep == NULL)
>  		return -ENOMEM;
>  	return 0;
> --- 2.5.33/fs/ufs/super.c~slablru	Sun Sep  1 21:23:12 2002
> +++ 2.5.33-akpm/fs/ufs/super.c	Sun Sep  1 21:23:12 2002
> @@ -1028,7 +1028,7 @@ static int init_inodecache(void)
>  	ufs_inode_cachep = kmem_cache_create("ufs_inode_cache",
>  					     sizeof(struct ufs_inode_info),
>  					     0, SLAB_HWCACHE_ALIGN,
> -					     init_once, NULL);
> +					     age_icache_memory, init_once, NULL);
>  	if (ufs_inode_cachep == NULL)
>  		return -ENOMEM;
>  	return 0;
> --- 2.5.33/include/linux/dcache.h~slablru	Sun Sep  1 21:23:12 2002
> +++ 2.5.33-akpm/include/linux/dcache.h	Sun Sep  1 21:23:12 2002
> @@ -182,16 +182,11 @@ extern void shrink_dcache_anon(struct li
>  extern int d_invalidate(struct dentry *);
>
>  /* dcache memory management */
> -extern int shrink_dcache_memory(int, unsigned int);
>  extern void prune_dcache(int);
>
>  /* icache memory management (defined in linux/fs/inode.c) */
> -extern int shrink_icache_memory(int, int);
>  extern void prune_icache(int);
>
> -/* quota cache memory management (defined in linux/fs/dquot.c) */
> -extern int shrink_dqcache_memory(int, unsigned int);
> -
>  /* only used at mount-time */
>  extern struct dentry * d_alloc_root(struct inode *);
>
> --- 2.5.33/include/linux/page-flags.h~slablru	Sun Sep  1 21:23:12 2002
> +++ 2.5.33-akpm/include/linux/page-flags.h	Sun Sep  1 21:23:35 2002
> @@ -78,6 +78,7 @@ extern struct page_state {
>  	unsigned long nr_pagecache;
>  	unsigned long nr_page_table_pages;
>  	unsigned long nr_reverse_maps;
> +	unsigned long nr_slab;
>  } ____cacheline_aligned_in_smp page_states[NR_CPUS];
>
>  extern void get_page_state(struct page_state *ret);
> --- 2.5.33/include/linux/slab.h~slablru	Sun Sep  1 21:23:12 2002
> +++ 2.5.33-akpm/include/linux/slab.h	Sun Sep  1 22:12:50 2002
> @@ -49,12 +49,32 @@ typedef struct kmem_cache_s kmem_cache_t
>  extern void kmem_cache_init(void);
>  extern void kmem_cache_sizes_init(void);
>
> +typedef int (*kmem_pruner_t)(kmem_cache_t *, int, int);
> +
>  extern kmem_cache_t *kmem_find_general_cachep(size_t, int gfpflags);
> -extern kmem_cache_t *kmem_cache_create(const char *, size_t, size_t,
> unsigned long, -				       void (*)(void *, kmem_cache_t *, unsigned long),
> -				       void (*)(void *, kmem_cache_t *, unsigned long));
> +extern kmem_cache_t *kmem_cache_create(const char *, size_t, size_t,
> +			unsigned long, kmem_pruner_t,
> +			void (*)(void *, kmem_cache_t *, unsigned long),
> +			void (*)(void *, kmem_cache_t *, unsigned long));
>  extern int kmem_cache_destroy(kmem_cache_t *);
>  extern int kmem_cache_shrink(kmem_cache_t *);
> +
> +extern int kmem_do_prunes(int);
> +extern int kmem_count_page(struct page *, int);
> +#define kmem_touch_page(addr)	SetPageReferenced(virt_to_page(addr));
> +
> +/* shrink a slab */
> +extern int kmem_shrink_slab(struct page *);
> +
> +/* dcache prune ( defined in linux/fs/dcache.c) */
> +extern int age_dcache_memory(kmem_cache_t *, int, int);
> +
> +/* icache prune (defined in linux/fs/inode.c) */
> +extern int age_icache_memory(kmem_cache_t *, int, int);
> +
> +/* quota cache prune (defined in linux/fs/dquot.c) */
> +extern int age_dqcache_memory(kmem_cache_t *, int, int);
> +
>  extern void *kmem_cache_alloc(kmem_cache_t *, int);
>  extern void kmem_cache_free(kmem_cache_t *, void *);
>  extern unsigned int kmem_cache_size(kmem_cache_t *);
> --- 2.5.33/kernel/fork.c~slablru	Sun Sep  1 21:23:12 2002
> +++ 2.5.33-akpm/kernel/fork.c	Sun Sep  1 21:23:12 2002
> @@ -112,7 +112,7 @@ void __init fork_init(unsigned long memp
>  	task_struct_cachep =
>  		kmem_cache_create("task_struct",
>  				  sizeof(struct task_struct),0,
> -				  SLAB_HWCACHE_ALIGN, NULL, NULL);
> +				  SLAB_HWCACHE_ALIGN, NULL, NULL, NULL);
>  	if (!task_struct_cachep)
>  		panic("fork_init(): cannot create task_struct SLAB cache");
>
> @@ -940,31 +940,31 @@ void __init proc_caches_init(void)
>  {
>  	sigact_cachep = kmem_cache_create("signal_act",
>  			sizeof(struct signal_struct), 0,
> -			SLAB_HWCACHE_ALIGN, NULL, NULL);
> +			SLAB_HWCACHE_ALIGN, NULL, NULL, NULL);
>  	if (!sigact_cachep)
>  		panic("Cannot create signal action SLAB cache");
>
>  	files_cachep = kmem_cache_create("files_cache",
>  			 sizeof(struct files_struct), 0,
> -			 SLAB_HWCACHE_ALIGN, NULL, NULL);
> +			 SLAB_HWCACHE_ALIGN, NULL, NULL, NULL);
>  	if (!files_cachep)
>  		panic("Cannot create files SLAB cache");
>
>  	fs_cachep = kmem_cache_create("fs_cache",
>  			 sizeof(struct fs_struct), 0,
> -			 SLAB_HWCACHE_ALIGN, NULL, NULL);
> +			 SLAB_HWCACHE_ALIGN, NULL, NULL, NULL);
>  	if (!fs_cachep)
>  		panic("Cannot create fs_struct SLAB cache");
>
>  	vm_area_cachep = kmem_cache_create("vm_area_struct",
>  			sizeof(struct vm_area_struct), 0,
> -			SLAB_HWCACHE_ALIGN, NULL, NULL);
> +			SLAB_HWCACHE_ALIGN, NULL, NULL, NULL);
>  	if(!vm_area_cachep)
>  		panic("vma_init: Cannot alloc vm_area_struct SLAB cache");
>
>  	mm_cachep = kmem_cache_create("mm_struct",
>  			sizeof(struct mm_struct), 0,
> -			SLAB_HWCACHE_ALIGN, NULL, NULL);
> +			SLAB_HWCACHE_ALIGN, NULL, NULL, NULL);
>  	if(!mm_cachep)
>  		panic("vma_init: Cannot alloc mm_struct SLAB cache");
>  }
> --- 2.5.33/kernel/signal.c~slablru	Sun Sep  1 21:23:12 2002
> +++ 2.5.33-akpm/kernel/signal.c	Sun Sep  1 21:23:12 2002
> @@ -43,7 +43,7 @@ void __init signals_init(void)
>  		kmem_cache_create("sigqueue",
>  				  sizeof(struct sigqueue),
>  				  __alignof__(struct sigqueue),
> -				  SIG_SLAB_DEBUG, NULL, NULL);
> +				  SIG_SLAB_DEBUG, NULL, NULL, NULL);
>  	if (!sigqueue_cachep)
>  		panic("signals_init(): cannot create sigqueue SLAB cache");
>  }
> --- 2.5.33/kernel/user.c~slablru	Sun Sep  1 21:23:12 2002
> +++ 2.5.33-akpm/kernel/user.c	Sun Sep  1 21:23:12 2002
> @@ -118,7 +118,7 @@ static int __init uid_cache_init(void)
>
>  	uid_cachep = kmem_cache_create("uid_cache", sizeof(struct user_struct),
>  				       0,
> -				       SLAB_HWCACHE_ALIGN, NULL, NULL);
> +				       SLAB_HWCACHE_ALIGN, NULL, NULL, NULL);
>  	if(!uid_cachep)
>  		panic("Cannot create uid taskcount SLAB cache\n");
>
> --- 2.5.33/lib/radix-tree.c~slablru	Sun Sep  1 21:23:12 2002
> +++ 2.5.33-akpm/lib/radix-tree.c	Sun Sep  1 21:23:12 2002
> @@ -293,7 +293,7 @@ void __init radix_tree_init(void)
>  {
>  	radix_tree_node_cachep = kmem_cache_create("radix_tree_node",
>  			sizeof(struct radix_tree_node), 0,
> -			SLAB_HWCACHE_ALIGN, radix_tree_node_ctor, NULL);
> +			SLAB_HWCACHE_ALIGN, NULL, radix_tree_node_ctor, NULL);
>  	if (!radix_tree_node_cachep)
>  		panic ("Failed to create radix_tree_node cache\n");
>  	radix_tree_node_pool = mempool_create(512, radix_tree_node_pool_alloc,
> --- 2.5.33/mm/page_alloc.c~slablru	Sun Sep  1 21:23:12 2002
> +++ 2.5.33-akpm/mm/page_alloc.c	Sun Sep  1 21:30:44 2002
> @@ -561,6 +561,7 @@ void get_page_state(struct page_state *r
>  		ret->nr_pagecache += ps->nr_pagecache;
>  		ret->nr_page_table_pages += ps->nr_page_table_pages;
>  		ret->nr_reverse_maps += ps->nr_reverse_maps;
> +		ret->nr_slab += ps->nr_slab;
>  	}
>  }
>
> --- 2.5.33/mm/rmap.c~slablru	Sun Sep  1 21:23:12 2002
> +++ 2.5.33-akpm/mm/rmap.c	Sun Sep  1 21:23:12 2002
> @@ -521,6 +521,7 @@ void __init pte_chain_init(void)
>  						sizeof(struct pte_chain),
>  						0,
>  						0,
> +						NULL,
>  						pte_chain_ctor,
>  						NULL);
>
> --- 2.5.33/mm/shmem.c~slablru	Sun Sep  1 21:23:12 2002
> +++ 2.5.33-akpm/mm/shmem.c	Sun Sep  1 21:23:12 2002
> @@ -1514,7 +1514,7 @@ static int init_inodecache(void)
>  	shmem_inode_cachep = kmem_cache_create("shmem_inode_cache",
>  					     sizeof(struct shmem_inode_info),
>  					     0, SLAB_HWCACHE_ALIGN,
> -					     init_once, NULL);
> +					     age_icache_memory, init_once, NULL);
>  	if (shmem_inode_cachep == NULL)
>  		return -ENOMEM;
>  	return 0;
> --- 2.5.33/mm/slab.c~slablru	Sun Sep  1 21:23:12 2002
> +++ 2.5.33-akpm/mm/slab.c	Sun Sep  1 22:11:59 2002
> @@ -77,6 +77,7 @@
>  #include	<linux/init.h>
>  #include	<linux/compiler.h>
>  #include	<linux/seq_file.h>
> +#include	<linux/pagemap.h>
>  #include	<asm/uaccess.h>
>
>  /*
> @@ -215,6 +216,8 @@ struct kmem_cache_s {
>  	kmem_cache_t		*slabp_cache;
>  	unsigned int		growing;
>  	unsigned int		dflags;		/* dynamic flags */
> +	kmem_pruner_t		pruner;		/* shrink callback */
> +	int 			count;		/* count used to trigger shrink */
>
>  	/* constructor func */
>  	void (*ctor)(void *, kmem_cache_t *, unsigned long);
> @@ -256,7 +259,7 @@ struct kmem_cache_s {
>
>  #define	OFF_SLAB(x)	((x)->flags & CFLGS_OFF_SLAB)
>  #define	OPTIMIZE(x)	((x)->flags & CFLGS_OPTIMIZE)
> -#define	GROWN(x)	((x)->dlags & DFLGS_GROWN)
> +#define	GROWN(x)	((x)->dflags & DFLGS_GROWN)
>
>  #if STATS
>  #define	STATS_INC_ACTIVE(x)	((x)->num_active++)
> @@ -412,6 +415,56 @@ static int g_cpucache_up;
>  static void enable_cpucache (kmem_cache_t *cachep);
>  static void enable_all_cpucaches (void);
>  #endif
> +
> +/*
> + * Used by shrink_cache to determine caches that need pruning.
> + */
> +int kmem_count_page(struct page *page, int ref)
> +{
> +	kmem_cache_t *cachep = GET_PAGE_CACHE(page);
> +	slab_t *slabp = GET_PAGE_SLAB(page);
> +	int ret = 0;
> +
> +	spin_lock_irq(&cachep->spinlock);
> +	if (cachep->pruner != NULL) {
> +		cachep->count += slabp->inuse;
> +		ret = !slabp->inuse;
> +	} else {
> +		ret = !ref && !slabp->inuse;
> +	}
> +	spin_unlock_irq(&cachep->spinlock);
> +	return ret;
> +}
> +
> +
> +/* Call the prune functions to age pruneable caches */
> +int kmem_do_prunes(int gfp_mask)
> +{
> +	struct list_head *p;
> +	int nr;
> +
> +        if (gfp_mask & __GFP_WAIT)
> +                down(&cache_chain_sem);
> +        else
> +                if (down_trylock(&cache_chain_sem))
> +                        return 0;
> +
> +        list_for_each(p,&cache_chain) {
> +                kmem_cache_t *cachep = list_entry(p, kmem_cache_t, next);
> +		if (cachep->pruner != NULL) {
> +			spin_lock_irq(&cachep->spinlock);
> +			nr = cachep->count;
> +			cachep->count = 0;
> +			spin_unlock_irq(&cachep->spinlock);
> +			if (nr > 0)
> +				(*cachep->pruner)(cachep, nr, gfp_mask);
> +
> +		}
> +	}
> +        up(&cache_chain_sem);
> +	return 1;
> +}
> +
>
>  /* Cal the num objs, wastage, and bytes left over for a given slab size.
> */ static void kmem_cache_estimate (unsigned long gfporder, size_t size, @@
> -451,8 +504,7 @@ void __init kmem_cache_init(void)
>
>  	kmem_cache_estimate(0, cache_cache.objsize, 0,
>  			&left_over, &cache_cache.num);
> -	if (!cache_cache.num)
> -		BUG();
> +	BUG_ON(!cache_cache.num);
>
>  	cache_cache.colour = left_over/cache_cache.colour_off;
>  	cache_cache.colour_next = 0;
> @@ -477,12 +529,10 @@ void __init kmem_cache_sizes_init(void)
>  		 * eliminates "false sharing".
>  		 * Note for systems short on memory removing the alignment will
>  		 * allow tighter packing of the smaller caches. */
> -		if (!(sizes->cs_cachep =
> +		BUG_ON(!(sizes->cs_cachep =
>  			kmem_cache_create(cache_names[sizes-cache_sizes].name,
> -					  sizes->cs_size,
> -					0, SLAB_HWCACHE_ALIGN, NULL, NULL))) {
> -			BUG();
> -		}
> +				sizes->cs_size,
> +				0, SLAB_HWCACHE_ALIGN, NULL, NULL, NULL)));
>
>  		/* Inc off-slab bufctl limit until the ceiling is hit. */
>  		if (!(OFF_SLAB(sizes->cs_cachep))) {
> @@ -490,11 +540,10 @@ void __init kmem_cache_sizes_init(void)
>  			offslab_limit /= 2;
>  		}
>  		sizes->cs_dmacachep = kmem_cache_create(
> -		    cache_names[sizes-cache_sizes].name_dma,
> +			cache_names[sizes-cache_sizes].name_dma,
>  			sizes->cs_size, 0,
> -			SLAB_CACHE_DMA|SLAB_HWCACHE_ALIGN, NULL, NULL);
> -		if (!sizes->cs_dmacachep)
> -			BUG();
> +			SLAB_CACHE_DMA|SLAB_HWCACHE_ALIGN, NULL, NULL, NULL);
> +		BUG_ON(!sizes->cs_dmacachep);
>  		sizes++;
>  	} while (sizes->cs_size);
>  }
> @@ -510,7 +559,8 @@ int __init kmem_cpucache_init(void)
>
>  __initcall(kmem_cpucache_init);
>
> -/* Interface to system's page allocator. No need to hold the cache-lock.
> +/*
> + * Interface to system's page allocator. No need to hold the cache-lock.
>   */
>  static inline void * kmem_getpages (kmem_cache_t *cachep, unsigned long
> flags) {
> @@ -532,7 +582,6 @@ static inline void * kmem_getpages (kmem
>  	return addr;
>  }
>
> -/* Interface to system's page release. */
>  static inline void kmem_freepages (kmem_cache_t *cachep, void *addr)
>  {
>  	unsigned long i = (1<<cachep->gfporder);
> @@ -545,9 +594,16 @@ static inline void kmem_freepages (kmem_
>  	 */
>  	while (i--) {
>  		ClearPageSlab(page);
> +		dec_page_state(nr_slab);
>  		page++;
>  	}
> -	free_pages((unsigned long)addr, cachep->gfporder);
> +
> +	/* free slab pages, page count is decremented by page_cache_release */
> +	page = virt_to_page(addr);
> +	if (cachep->gfporder)
> +		free_pages((unsigned long)addr, cachep->gfporder);
> +	else
> +		page_cache_release(page);
>  }
>
>  #if DEBUG
> @@ -577,6 +633,7 @@ static inline int kmem_check_poison_obj
>  }
>  #endif
>
> +
>  /* Destroy all the objs in a slab, and release the mem back to the system.
>   * Before calling the slab must have been unlinked from the cache.
>   * The cache-lock is not held/needed.
> @@ -593,11 +650,9 @@ static void kmem_slab_destroy (kmem_cach
>  			void* objp = slabp->s_mem+cachep->objsize*i;
>  #if DEBUG
>  			if (cachep->flags & SLAB_RED_ZONE) {
> -				if (*((unsigned long*)(objp)) != RED_MAGIC1)
> -					BUG();
> -				if (*((unsigned long*)(objp + cachep->objsize
> -						-BYTES_PER_WORD)) != RED_MAGIC1)
> -					BUG();
> +				BUG_ON(*((unsigned long*)(objp)) != RED_MAGIC1);
> +				BUG_ON(*((unsigned long*)(objp + cachep->objsize
> +					-BYTES_PER_WORD)) != RED_MAGIC1);
>  				objp += BYTES_PER_WORD;
>  			}
>  #endif
> @@ -607,9 +662,8 @@ static void kmem_slab_destroy (kmem_cach
>  			if (cachep->flags & SLAB_RED_ZONE) {
>  				objp -= BYTES_PER_WORD;
>  			}
> -			if ((cachep->flags & SLAB_POISON)  &&
> -				kmem_check_poison_obj(cachep, objp))
> -				BUG();
> +			BUG_ON((cachep->flags & SLAB_POISON)  &&
> +				kmem_check_poison_obj(cachep, objp));
>  #endif
>  		}
>  	}
> @@ -625,6 +679,7 @@ static void kmem_slab_destroy (kmem_cach
>   * @size: The size of objects to be created in this cache.
>   * @offset: The offset to use within the page.
>   * @flags: SLAB flags
> + * @thepruner: a callback to prune entries for ageable caches
>   * @ctor: A constructor for the objects.
>   * @dtor: A destructor for the objects.
>   *
> @@ -654,7 +709,8 @@ static void kmem_slab_destroy (kmem_cach
>   */
>  kmem_cache_t *
>  kmem_cache_create (const char *name, size_t size, size_t offset,
> -	unsigned long flags, void (*ctor)(void*, kmem_cache_t *, unsigned long),
> +	unsigned long flags, kmem_pruner_t thepruner,
> +	void (*ctor)(void*, kmem_cache_t *, unsigned long),
>  	void (*dtor)(void*, kmem_cache_t *, unsigned long))
>  {
>  	const char *func_nm = KERN_ERR "kmem_create: ";
> @@ -664,13 +720,12 @@ kmem_cache_create (const char *name, siz
>  	/*
>  	 * Sanity checks... these are all serious usage bugs.
>  	 */
> -	if ((!name) ||
> +	BUG_ON((!name) ||
>  		in_interrupt() ||
>  		(size < BYTES_PER_WORD) ||
>  		(size > (1<<MAX_OBJ_ORDER)*PAGE_SIZE) ||
>  		(dtor && !ctor) ||
> -		(offset < 0 || offset > size))
> -			BUG();
> +		(offset < 0 || offset > size));
>
>  #if DEBUG
>  	if ((flags & SLAB_DEBUG_INITIAL) && !ctor) {
> @@ -700,8 +755,7 @@ kmem_cache_create (const char *name, siz
>  	 * Always checks flags, a caller might be expecting debug
>  	 * support which isn't available.
>  	 */
> -	if (flags & ~CREATE_MASK)
> -		BUG();
> +	BUG_ON(flags & ~CREATE_MASK);
>
>  	/* Get cache's description obj. */
>  	cachep = (kmem_cache_t *) kmem_cache_alloc(&cache_cache, SLAB_KERNEL);
> @@ -816,6 +870,8 @@ next:
>  		flags |= CFLGS_OPTIMIZE;
>
>  	cachep->flags = flags;
> +	cachep->pruner = thepruner;
> +	cachep->count = 0;
>  	cachep->gfpflags = 0;
>  	if (flags & SLAB_CACHE_DMA)
>  		cachep->gfpflags |= GFP_DMA;
> @@ -958,15 +1014,14 @@ static void drain_cpu_caches(kmem_cache_
>  #define drain_cpu_caches(cachep)	do { } while (0)
>  #endif
>
> -static int __kmem_cache_shrink(kmem_cache_t *cachep)
> +
> +/*
> + * Worker function for freeing slab caches; returns number of pages freed.
> + */
> +static int __kmem_cache_shrink_locked(kmem_cache_t *cachep)
>  {
>  	slab_t *slabp;
> -	int ret;
> -
> -	drain_cpu_caches(cachep);
> -
> -	spin_lock_irq(&cachep->spinlock);
> -
> +	int ret = 0;
>  	/* If the cache is growing, stop shrinking. */
>  	while (!cachep->growing) {
>  		struct list_head *p;
> @@ -977,16 +1032,29 @@ static int __kmem_cache_shrink(kmem_cach
>
>  		slabp = list_entry(cachep->slabs_free.prev, slab_t, list);
>  #if DEBUG
> -		if (slabp->inuse)
> -			BUG();
> +		BUG_ON(slabp->inuse);
>  #endif
>  		list_del(&slabp->list);
>
> -		spin_unlock_irq(&cachep->spinlock);
> +		spin_unlock(&cachep->spinlock);
>  		kmem_slab_destroy(cachep, slabp);
> -		spin_lock_irq(&cachep->spinlock);
> +		ret++;
> +		spin_lock(&cachep->spinlock);
>  	}
> -	ret = !list_empty(&cachep->slabs_full) ||
> !list_empty(&cachep->slabs_partial); +	return ret;
> +}
> +
> +
> +static int __kmem_cache_shrink(kmem_cache_t *cachep)
> +{
> +	int ret;
> +
> +	drain_cpu_caches(cachep);
> +
> +	spin_lock_irq(&cachep->spinlock);
> +	__kmem_cache_shrink_locked(cachep);
> +	ret = !list_empty(&cachep->slabs_full) ||
> +		!list_empty(&cachep->slabs_partial);
>  	spin_unlock_irq(&cachep->spinlock);
>  	return ret;
>  }
> @@ -1000,12 +1068,47 @@ static int __kmem_cache_shrink(kmem_cach
>   */
>  int kmem_cache_shrink(kmem_cache_t *cachep)
>  {
> -	if (!cachep || in_interrupt() || !is_chained_kmem_cache(cachep))
> -		BUG();
> -
> +	BUG_ON(!cachep || in_interrupt() || !is_chained_kmem_cache(cachep));
>  	return __kmem_cache_shrink(cachep);
>  }
>
> +
> +/*
> + * Used by shrink_cache to try to shrink a cache.  The actual
> + * free is defered via a pagevec in shrink_list.
> + * - shrink works and we return the pages shrunk
> + * - shrink fails because the slab is in use, we return 0
> + * - the page_count gets decremented by __pagevec_release_nonlru
> + * called with page_lock bit set.
> + */
> +int kmem_shrink_slab(struct page *page)
> +{
> +	kmem_cache_t *cachep = GET_PAGE_CACHE(page);
> +	slab_t *slabp = GET_PAGE_SLAB(page);
> +	unsigned int ret = 0;
> +
> +	spin_lock_irq(&cachep->spinlock);
> +	if (!slabp->inuse) {
> +	 	if (!cachep->growing) {
> +			unsigned int i = (1<<cachep->gfporder);
> +
> +			list_del(&slabp->list);
> +			ret = i;
> +			while (i--) {
> +				ClearPageSlab(page);
> +				dec_page_state(nr_slab);
> +				page++;
> +			}
> +			goto out;
> +		}
> +		BUG_ON(PageActive(page));
> +	}
> +out:
> +	spin_unlock_irq(&cachep->spinlock);
> +	return ret;
> +}
> +
> +
>  /**
>   * kmem_cache_destroy - delete a cache
>   * @cachep: the cache to destroy
> @@ -1023,8 +1126,7 @@ int kmem_cache_shrink(kmem_cache_t *cach
>   */
>  int kmem_cache_destroy (kmem_cache_t * cachep)
>  {
> -	if (!cachep || in_interrupt() || cachep->growing)
> -		BUG();
> +	BUG_ON(!cachep || in_interrupt() || cachep->growing);
>
>  	/* Find the cache in the chain of caches. */
>  	down(&cache_chain_sem);
> @@ -1112,11 +1214,9 @@ static inline void kmem_cache_init_objs
>  			/* need to poison the objs */
>  			kmem_poison_obj(cachep, objp);
>  		if (cachep->flags & SLAB_RED_ZONE) {
> -			if (*((unsigned long*)(objp)) != RED_MAGIC1)
> -				BUG();
> -			if (*((unsigned long*)(objp + cachep->objsize -
> -					BYTES_PER_WORD)) != RED_MAGIC1)
> -				BUG();
> +			BUG_ON(*((unsigned long*)(objp)) != RED_MAGIC1);
> +			BUG_ON(*((unsigned long*)(objp + cachep->objsize -
> +				BYTES_PER_WORD)) != RED_MAGIC1);
>  		}
>  #endif
>  		slab_bufctl(slabp)[i] = i+1;
> @@ -1142,8 +1242,7 @@ static int kmem_cache_grow (kmem_cache_t
>  	/* Be lazy and only check for valid flags here,
>   	 * keeping it out of the critical path in kmem_cache_alloc().
>  	 */
> -	if (flags & ~(SLAB_DMA|SLAB_LEVEL_MASK|SLAB_NO_GROW))
> -		BUG();
> +	BUG_ON(flags & ~(SLAB_DMA|SLAB_LEVEL_MASK|SLAB_NO_GROW));
>  	if (flags & SLAB_NO_GROW)
>  		return 0;
>
> @@ -1153,8 +1252,7 @@ static int kmem_cache_grow (kmem_cache_t
>  	 * in kmem_cache_alloc(). If a caller is seriously mis-behaving they
>  	 * will eventually be caught here (where it matters).
>  	 */
> -	if (in_interrupt() && (flags & __GFP_WAIT))
> -		BUG();
> +	BUG_ON(in_interrupt() && (flags & __GFP_WAIT));
>
>  	ctor_flags = SLAB_CTOR_CONSTRUCTOR;
>  	local_flags = (flags & SLAB_LEVEL_MASK);
> @@ -1197,15 +1295,24 @@ static int kmem_cache_grow (kmem_cache_t
>  		goto opps1;
>
>  	/* Nasty!!!!!! I hope this is OK. */
> -	i = 1 << cachep->gfporder;
>  	page = virt_to_page(objp);
> +	i = 1 << cachep->gfporder;
>  	do {
>  		SET_PAGE_CACHE(page, cachep);
>  		SET_PAGE_SLAB(page, slabp);
>  		SetPageSlab(page);
> +		inc_page_state(nr_slab);
>  		page++;
>  	} while (--i);
>
> +	/*
> +	 * add to lru after setup of page - can happen in interrupt context.
> +	 */
> +	if (!cachep->gfporder) {
> +		page = virt_to_page(objp);
> +		lru_cache_add(page);
> +	}
> +
>  	kmem_cache_init_objs(cachep, slabp, ctor_flags);
>
>  	spin_lock_irqsave(&cachep->spinlock, save_flags);
> @@ -1219,7 +1326,8 @@ static int kmem_cache_grow (kmem_cache_t
>  	spin_unlock_irqrestore(&cachep->spinlock, save_flags);
>  	return 1;
>  opps1:
> -	kmem_freepages(cachep, objp);
> +	/* do not use kmem_freepages - we are not in the lru yet... */
> +	free_pages((unsigned long)objp, cachep->gfporder);
>  failed:
>  	spin_lock_irqsave(&cachep->spinlock, save_flags);
>  	cachep->growing--;
> @@ -1241,15 +1349,12 @@ static int kmem_extra_free_checks (kmem_
>  	int i;
>  	unsigned int objnr = (objp-slabp->s_mem)/cachep->objsize;
>
> -	if (objnr >= cachep->num)
> -		BUG();
> -	if (objp != slabp->s_mem + objnr*cachep->objsize)
> -		BUG();
> +	BUG_ON(objnr >= cachep->num);
> +	BUG_ON(objp != slabp->s_mem + objnr*cachep->objsize);
>
>  	/* Check slab's freelist to see if this obj is there. */
>  	for (i = slabp->free; i != BUFCTL_END; i = slab_bufctl(slabp)[i]) {
> -		if (i == objnr)
> -			BUG();
> +		BUG_ON(i == objnr);
>  	}
>  	return 0;
>  }
> @@ -1258,11 +1363,9 @@ static int kmem_extra_free_checks (kmem_
>  static inline void kmem_cache_alloc_head(kmem_cache_t *cachep, int flags)
>  {
>  	if (flags & SLAB_DMA) {
> -		if (!(cachep->gfpflags & GFP_DMA))
> -			BUG();
> +		BUG_ON(!(cachep->gfpflags & GFP_DMA));
>  	} else {
> -		if (cachep->gfpflags & GFP_DMA)
> -			BUG();
> +		BUG_ON(cachep->gfpflags & GFP_DMA);
>  	}
>  }
>
> @@ -1284,18 +1387,16 @@ static inline void * kmem_cache_alloc_on
>  		list_del(&slabp->list);
>  		list_add(&slabp->list, &cachep->slabs_full);
>  	}
> +	kmem_touch_page(objp);
>  #if DEBUG
>  	if (cachep->flags & SLAB_POISON)
> -		if (kmem_check_poison_obj(cachep, objp))
> -			BUG();
> +		BUG_ON(kmem_check_poison_obj(cachep, objp));
>  	if (cachep->flags & SLAB_RED_ZONE) {
>  		/* Set alloc red-zone, and check old one. */
> -		if (xchg((unsigned long *)objp, RED_MAGIC2) !=
> -							 RED_MAGIC1)
> -			BUG();
> -		if (xchg((unsigned long *)(objp+cachep->objsize -
> -			  BYTES_PER_WORD), RED_MAGIC2) != RED_MAGIC1)
> -			BUG();
> +		BUG_ON(xchg((unsigned long *)objp, RED_MAGIC2) !=
> +		       RED_MAGIC1);
> +		BUG_ON(xchg((unsigned long *)(objp+cachep->objsize -
> +					      BYTES_PER_WORD), RED_MAGIC2) != RED_MAGIC1);
>  		objp += BYTES_PER_WORD;
>  	}
>  #endif
> @@ -1473,13 +1574,11 @@ static inline void kmem_cache_free_one(k
>
>  	if (cachep->flags & SLAB_RED_ZONE) {
>  		objp -= BYTES_PER_WORD;
> -		if (xchg((unsigned long *)objp, RED_MAGIC1) != RED_MAGIC2)
> -			/* Either write before start, or a double free. */
> -			BUG();
> -		if (xchg((unsigned long *)(objp+cachep->objsize -
> -				BYTES_PER_WORD), RED_MAGIC1) != RED_MAGIC2)
> -			/* Either write past end, or a double free. */
> -			BUG();
> +		BUG_ON(xchg((unsigned long *)objp, RED_MAGIC1) != RED_MAGIC2);
> +		/* Either write before start, or a double free. */
> +		BUG_ON(xchg((unsigned long *)(objp+cachep->objsize -
> +			BYTES_PER_WORD), RED_MAGIC1) != RED_MAGIC2);
> +		/* Either write past end, or a double free. */
>  	}
>  	if (cachep->flags & SLAB_POISON)
>  		kmem_poison_obj(cachep, objp);
> @@ -1617,8 +1716,7 @@ void kmem_cache_free (kmem_cache_t *cach
>  	unsigned long flags;
>  #if DEBUG
>  	CHECK_PAGE(objp);
> -	if (cachep != GET_PAGE_CACHE(virt_to_page(objp)))
> -		BUG();
> +	BUG_ON(cachep != GET_PAGE_CACHE(virt_to_page(objp)));
>  #endif
>
>  	local_irq_save(flags);
> @@ -1823,23 +1921,18 @@ int kmem_cache_reap (int gfp_mask)
>  		while (p != &searchp->slabs_free) {
>  			slabp = list_entry(p, slab_t, list);
>  #if DEBUG
> -			if (slabp->inuse)
> -				BUG();
> +			BUG_ON(slabp->inuse);
>  #endif
>  			full_free++;
>  			p = p->next;
>  		}
>
>  		/*
> -		 * Try to avoid slabs with constructors and/or
> -		 * more than one page per slab (as it can be difficult
> -		 * to get high orders from gfp()).
> +		 * Try to avoid slabs with constuctors
>  		 */
>  		pages = full_free * (1<<searchp->gfporder);
>  		if (searchp->ctor)
>  			pages = (pages*4+1)/5;
> -		if (searchp->gfporder)
> -			pages = (pages*4+1)/5;
>  		if (pages > best_pages) {
>  			best_cachep = searchp;
>  			best_len = full_free;
> @@ -1876,8 +1969,7 @@ perfect:
>  			break;
>  		slabp = list_entry(p,slab_t,list);
>  #if DEBUG
> -		if (slabp->inuse)
> -			BUG();
> +		BUG_ON(slabp->inuse);
>  #endif
>  		list_del(&slabp->list);
>  		STATS_INC_REAPED(best_cachep);
> @@ -1962,22 +2054,19 @@ static int s_show(struct seq_file *m, vo
>  	num_slabs = 0;
>  	list_for_each(q,&cachep->slabs_full) {
>  		slabp = list_entry(q, slab_t, list);
> -		if (slabp->inuse != cachep->num)
> -			BUG();
> +		BUG_ON(slabp->inuse != cachep->num);
>  		active_objs += cachep->num;
>  		active_slabs++;
>  	}
>  	list_for_each(q,&cachep->slabs_partial) {
>  		slabp = list_entry(q, slab_t, list);
> -		if (slabp->inuse == cachep->num || !slabp->inuse)
> -			BUG();
> +		BUG_ON(slabp->inuse == cachep->num || !slabp->inuse);
>  		active_objs += slabp->inuse;
>  		active_slabs++;
>  	}
>  	list_for_each(q,&cachep->slabs_free) {
>  		slabp = list_entry(q, slab_t, list);
> -		if (slabp->inuse)
> -			BUG();
> +		BUG_ON(slabp->inuse);
>  		num_slabs++;
>  	}
>  	num_slabs+=active_slabs;
> --- 2.5.33/mm/swap.c~slablru	Sun Sep  1 21:23:12 2002
> +++ 2.5.33-akpm/mm/swap.c	Sun Sep  1 21:23:12 2002
> @@ -46,25 +46,34 @@ void activate_page(struct page *page)
>  /**
>   * lru_cache_add: add a page to the page lists
>   * @page: the page to add
> + *
> + * Can be called from interrupt context by slab, so protect against that.
>   */
>  static struct pagevec lru_add_pvecs[NR_CPUS];
>
>  void lru_cache_add(struct page *page)
>  {
> -	struct pagevec *pvec = &lru_add_pvecs[get_cpu()];
> +	unsigned long flags;
> +	struct pagevec *pvec;
>
>  	page_cache_get(page);
> +	pvec = &lru_add_pvecs[get_cpu()];
> +	local_irq_save(flags);
>  	if (!pagevec_add(pvec, page))
>  		__pagevec_lru_add(pvec);
> +	local_irq_restore(flags);
>  	put_cpu();
>  }
>
>  void lru_add_drain(void)
>  {
> +	unsigned long flags;
>  	struct pagevec *pvec = &lru_add_pvecs[get_cpu()];
>
> +	local_irq_save(flags);
>  	if (pagevec_count(pvec))
>  		__pagevec_lru_add(pvec);
> +	local_irq_restore(flags);
>  	put_cpu();
>  }
>
> @@ -202,6 +211,7 @@ void pagevec_deactivate_inactive(struct
>  void __pagevec_lru_add(struct pagevec *pvec)
>  {
>  	int i;
> +	unsigned long flags = 0;	/* avoid uninitialised var warning */
>  	struct zone *zone = NULL;
>
>  	for (i = 0; i < pagevec_count(pvec); i++) {
> @@ -210,16 +220,16 @@ void __pagevec_lru_add(struct pagevec *p
>
>  		if (pagezone != zone) {
>  			if (zone)
> -				spin_unlock_irq(&zone->lru_lock);
> +				spin_unlock_irqrestore(&zone->lru_lock, flags);
>  			zone = pagezone;
> -			spin_lock_irq(&zone->lru_lock);
> +			spin_lock_irqsave(&zone->lru_lock, flags);
>  		}
>  		if (TestSetPageLRU(page))
>  			BUG();
>  		add_page_to_inactive_list(zone, page);
>  	}
>  	if (zone)
> -		spin_unlock_irq(&zone->lru_lock);
> +		spin_unlock_irqrestore(&zone->lru_lock, flags);
>  	pagevec_release(pvec);
>  }
>
> --- 2.5.33/mm/vmscan.c~slablru	Sun Sep  1 21:23:12 2002
> +++ 2.5.33-akpm/mm/vmscan.c	Sun Sep  1 21:46:20 2002
> @@ -114,10 +114,26 @@ shrink_list(struct list_head *page_list,
>
>  		if (TestSetPageLocked(page))
>  			goto keep;
> -
>  		BUG_ON(PageActive(page));
> +
> +		/*
> +		 * For slab pages, use kmem_count_page to increment the aging
> +		 * counter for the cache and to tell us if we should try to
> +		 * free the slab.  Use kmem_shrink_slab to free the slab and
> +		 * stop if we are done.
> +		 */
> +		if (PageSlab(page)) {
> +			int ref = TestClearPageReferenced(page);
> +			if (kmem_count_page(page, ref)) {
> +				if (kmem_shrink_slab(page))
> +					goto free_ref;
> +			}
> +			goto keep_locked;
> +		}
> +
>  		may_enter_fs = (gfp_mask & __GFP_FS) ||
>  				(PageSwapCache(page) && (gfp_mask & __GFP_IO));
> +
>  		if (PageWriteback(page)) {
>  			if (may_enter_fs)
>  				wait_on_page_writeback(page);  /* throttling */
> @@ -238,6 +254,7 @@ shrink_list(struct list_head *page_list,
>  			__remove_from_page_cache(page);
>  			write_unlock(&mapping->page_lock);
>  		}
> +free_ref:
>  		__put_page(page);	/* The pagecache ref */
>  free_it:
>  		unlock_page(page);
> @@ -473,10 +490,6 @@ shrink_zone(struct zone *zone, int prior
>  	unsigned long ratio;
>  	int max_scan;
>
> -	/* This is bogus for ZONE_HIGHMEM? */
> -	if (kmem_cache_reap(gfp_mask) >= nr_pages)
> -  		return 0;
> -
>  	/*
>  	 * Try to keep the active list 2/3 of the size of the cache.  And
>  	 * make sure that refill_inactive is given a decent number of pages.
> @@ -498,20 +511,12 @@ shrink_zone(struct zone *zone, int prior
>  	max_scan = zone->nr_inactive / priority;
>  	nr_pages = shrink_cache(nr_pages, zone,
>  				gfp_mask, priority, max_scan);
> +	kmem_do_prunes(gfp_mask);
>
>  	if (nr_pages <= 0)
>  		return 0;
>
>  	wakeup_bdflush();
> -
> -	shrink_dcache_memory(priority, gfp_mask);
> -
> -	/* After shrinking the dcache, get rid of unused inodes too .. */
> -	shrink_icache_memory(1, gfp_mask);
> -#ifdef CONFIG_QUOTA
> -	shrink_dqcache_memory(DEF_PRIORITY, gfp_mask);
> -#endif
> -
>  	return nr_pages;
>  }
>
> @@ -552,6 +557,14 @@ try_to_free_pages(struct zone *classzone
>  		if (nr_pages <= 0)
>  			return 1;
>  	} while (--priority);
> +
> +	/*
> +	 * perform full reap before concluding we are oom
> +	 */
> +	nr_pages -= kmem_cache_reap(gfp_mask);
> +	if (nr_pages <= 0)
> +		   return 1;
> +
>  	out_of_memory();
>  	return 0;
>  }
> --- 2.5.33/net/atm/clip.c~slablru	Sun Sep  1 21:23:12 2002
> +++ 2.5.33-akpm/net/atm/clip.c	Sun Sep  1 21:23:12 2002
> @@ -751,5 +751,5 @@ void atm_clip_init(void)
>  {
>  	clip_tbl.lock = RW_LOCK_UNLOCKED;
>  	clip_tbl.kmem_cachep = kmem_cache_create(clip_tbl.id,
> -	    clip_tbl.entry_size, 0, SLAB_HWCACHE_ALIGN, NULL, NULL);
> +	    clip_tbl.entry_size, 0, SLAB_HWCACHE_ALIGN, NULL, NULL, NULL);
>  }
> --- 2.5.33/net/bluetooth/af_bluetooth.c~slablru	Sun Sep  1 21:23:12 2002
> +++ 2.5.33-akpm/net/bluetooth/af_bluetooth.c	Sun Sep  1 21:23:12 2002
> @@ -328,7 +328,7 @@ static int __init bluez_init(void)
>  	/* Init socket cache */
>  	bluez_sock_cache = kmem_cache_create("bluez_sock",
>  			sizeof(struct bluez_sock), 0,
> -			SLAB_HWCACHE_ALIGN, 0, 0);
> +			SLAB_HWCACHE_ALIGN, NULL, NULL, NULL);
>
>  	if (!bluez_sock_cache) {
>  		BT_ERR("BlueZ socket cache creation failed");
> --- 2.5.33/net/core/neighbour.c~slablru	Sun Sep  1 21:23:12 2002
> +++ 2.5.33-akpm/net/core/neighbour.c	Sun Sep  1 21:23:12 2002
> @@ -1146,7 +1146,7 @@ void neigh_table_init(struct neigh_table
>  						     (tbl->entry_size +
>  						      15) & ~15,
>  						     0, SLAB_HWCACHE_ALIGN,
> -						     NULL, NULL);
> +						     NULL, NULL, NULL);
>  #ifdef CONFIG_SMP
>  	tasklet_init(&tbl->gc_task, SMP_TIMER_NAME(neigh_periodic_timer),
>  		     (unsigned long)tbl);
> --- 2.5.33/net/core/skbuff.c~slablru	Sun Sep  1 21:23:12 2002
> +++ 2.5.33-akpm/net/core/skbuff.c	Sun Sep  1 21:23:12 2002
> @@ -1204,7 +1204,7 @@ void __init skb_init(void)
>  					      sizeof(struct sk_buff),
>  					      0,
>  					      SLAB_HWCACHE_ALIGN,
> -					      skb_headerinit, NULL);
> +					      NULL, skb_headerinit, NULL);
>  	if (!skbuff_head_cache)
>  		panic("cannot create skbuff cache");
>
> --- 2.5.33/net/core/sock.c~slablru	Sun Sep  1 21:23:12 2002
> +++ 2.5.33-akpm/net/core/sock.c	Sun Sep  1 21:23:12 2002
> @@ -633,7 +633,7 @@ void sk_free(struct sock *sk)
>  void __init sk_init(void)
>  {
>  	sk_cachep = kmem_cache_create("sock", sizeof(struct sock), 0,
> -				      SLAB_HWCACHE_ALIGN, 0, 0);
> +				      SLAB_HWCACHE_ALIGN, NULL, NULL, NULL);
>  	if (!sk_cachep)
>  		printk(KERN_CRIT "sk_init: Cannot create sock SLAB cache!");
>
> --- 2.5.33/net/decnet/dn_route.c~slablru	Sun Sep  1 21:23:12 2002
> +++ 2.5.33-akpm/net/decnet/dn_route.c	Sun Sep  1 21:23:12 2002
> @@ -1244,7 +1244,7 @@ void __init dn_route_init(void)
>  	dn_dst_ops.kmem_cachep = kmem_cache_create("dn_dst_cache",
>  						   sizeof(struct dn_route),
>  						   0, SLAB_HWCACHE_ALIGN,
> -						   NULL, NULL);
> +						   NULL, NULL, NULL);
>
>  	if (!dn_dst_ops.kmem_cachep)
>  		panic("DECnet: Failed to allocate dn_dst_cache\n");
> --- 2.5.33/net/decnet/dn_table.c~slablru	Sun Sep  1 21:23:12 2002
> +++ 2.5.33-akpm/net/decnet/dn_table.c	Sun Sep  1 21:23:12 2002
> @@ -888,7 +888,7 @@ void __init dn_fib_table_init(void)
>  	dn_hash_kmem = kmem_cache_create("dn_fib_info_cache",
>  					sizeof(struct dn_fib_info),
>  					0, SLAB_HWCACHE_ALIGN,
> -					NULL, NULL);
> +					NULL, NULL, NULL);
>  }
>
>  void __exit dn_fib_table_cleanup(void)
> --- 2.5.33/net/ipv4/af_inet.c~slablru	Sun Sep  1 21:23:12 2002
> +++ 2.5.33-akpm/net/ipv4/af_inet.c	Sun Sep  1 21:23:12 2002
> @@ -1142,13 +1142,13 @@ static int __init inet_init(void)
>
>  	tcp_sk_cachep = kmem_cache_create("tcp_sock",
>  					  sizeof(struct tcp_sock), 0,
> -					  SLAB_HWCACHE_ALIGN, 0, 0);
> +					  SLAB_HWCACHE_ALIGN, NULL, NULL, NULL);
>  	udp_sk_cachep = kmem_cache_create("udp_sock",
>  					  sizeof(struct udp_sock), 0,
> -					  SLAB_HWCACHE_ALIGN, 0, 0);
> +					  SLAB_HWCACHE_ALIGN, NULL, NULL, NULL);
>  	raw4_sk_cachep = kmem_cache_create("raw4_sock",
>  					   sizeof(struct raw_sock), 0,
> -					   SLAB_HWCACHE_ALIGN, 0, 0);
> +					   SLAB_HWCACHE_ALIGN, NULL, NULL, NULL);
>  	if (!tcp_sk_cachep || !udp_sk_cachep || !raw4_sk_cachep)
>  		printk(KERN_CRIT
>  		       "inet_init: Can't create protocol sock SLAB caches!\n");
> --- 2.5.33/net/ipv4/fib_hash.c~slablru	Sun Sep  1 21:23:12 2002
> +++ 2.5.33-akpm/net/ipv4/fib_hash.c	Sun Sep  1 21:23:12 2002
> @@ -899,7 +899,7 @@ struct fib_table * __init fib_hash_init(
>  		fn_hash_kmem = kmem_cache_create("ip_fib_hash",
>  						 sizeof(struct fib_node),
>  						 0, SLAB_HWCACHE_ALIGN,
> -						 NULL, NULL);
> +						 NULL, NULL, NULL);
>
>  	tb = kmalloc(sizeof(struct fib_table) + sizeof(struct fn_hash),
> GFP_KERNEL); if (tb == NULL)
> --- 2.5.33/net/ipv4/inetpeer.c~slablru	Sun Sep  1 21:23:12 2002
> +++ 2.5.33-akpm/net/ipv4/inetpeer.c	Sun Sep  1 21:23:12 2002
> @@ -125,7 +125,7 @@ void __init inet_initpeers(void)
>  	peer_cachep = kmem_cache_create("inet_peer_cache",
>  			sizeof(struct inet_peer),
>  			0, SLAB_HWCACHE_ALIGN,
> -			NULL, NULL);
> +			NULL, NULL, NULL);
>
>  	/* All the timers, started at system startup tend
>  	   to synchronize. Perturb it a bit.
> --- 2.5.33/net/ipv4/ipmr.c~slablru	Sun Sep  1 21:23:12 2002
> +++ 2.5.33-akpm/net/ipv4/ipmr.c	Sun Sep  1 21:23:12 2002
> @@ -1750,7 +1750,7 @@ void __init ip_mr_init(void)
>  	mrt_cachep = kmem_cache_create("ip_mrt_cache",
>  				       sizeof(struct mfc_cache),
>  				       0, SLAB_HWCACHE_ALIGN,
> -				       NULL, NULL);
> +				       NULL, NULL, NULL);
>  	init_timer(&ipmr_expire_timer);
>  	ipmr_expire_timer.function=ipmr_expire_process;
>  	register_netdevice_notifier(&ip_mr_notifier);
> --- 2.5.33/net/ipv4/netfilter/ip_conntrack_core.c~slablru	Sun Sep  1
> 21:23:12 2002 +++ 2.5.33-akpm/net/ipv4/netfilter/ip_conntrack_core.c	Sun
> Sep  1 21:23:12 2002 @@ -1444,7 +1444,7 @@ int __init
> ip_conntrack_init(void)
>
>  	ip_conntrack_cachep = kmem_cache_create("ip_conntrack",
>  	                                        sizeof(struct ip_conntrack), 0,
> -	                                        SLAB_HWCACHE_ALIGN, NULL, NULL);
> +	                                        SLAB_HWCACHE_ALIGN, NULL, NULL,
> NULL); if (!ip_conntrack_cachep) {
>  		printk(KERN_ERR "Unable to create ip_conntrack slab cache\n");
>  		goto err_free_hash;
> --- 2.5.33/net/ipv4/route.c~slablru	Sun Sep  1 21:23:12 2002
> +++ 2.5.33-akpm/net/ipv4/route.c	Sun Sep  1 21:23:12 2002
> @@ -2472,7 +2472,7 @@ void __init ip_rt_init(void)
>  	ipv4_dst_ops.kmem_cachep = kmem_cache_create("ip_dst_cache",
>  						     sizeof(struct rtable),
>  						     0, SLAB_HWCACHE_ALIGN,
> -						     NULL, NULL);
> +						     NULL, NULL, NULL);
>
>  	if (!ipv4_dst_ops.kmem_cachep)
>  		panic("IP: failed to allocate ip_dst_cache\n");
> --- 2.5.33/net/ipv4/tcp.c~slablru	Sun Sep  1 21:23:12 2002
> +++ 2.5.33-akpm/net/ipv4/tcp.c	Sun Sep  1 21:23:12 2002
> @@ -2569,21 +2569,21 @@ void __init tcp_init(void)
>  	tcp_openreq_cachep = kmem_cache_create("tcp_open_request",
>  						   sizeof(struct open_request),
>  					       0, SLAB_HWCACHE_ALIGN,
> -					       NULL, NULL);
> +					       NULL, NULL, NULL);
>  	if (!tcp_openreq_cachep)
>  		panic("tcp_init: Cannot alloc open_request cache.");
>
>  	tcp_bucket_cachep = kmem_cache_create("tcp_bind_bucket",
>  					      sizeof(struct tcp_bind_bucket),
>  					      0, SLAB_HWCACHE_ALIGN,
> -					      NULL, NULL);
> +					      NULL, NULL, NULL);
>  	if (!tcp_bucket_cachep)
>  		panic("tcp_init: Cannot alloc tcp_bind_bucket cache.");
>
>  	tcp_timewait_cachep = kmem_cache_create("tcp_tw_bucket",
>  						sizeof(struct tcp_tw_bucket),
>  						0, SLAB_HWCACHE_ALIGN,
> -						NULL, NULL);
> +						NULL, NULL, NULL);
>  	if (!tcp_timewait_cachep)
>  		panic("tcp_init: Cannot alloc tcp_tw_bucket cache.");
>
> --- 2.5.33/net/ipv6/af_inet6.c~slablru	Sun Sep  1 21:23:12 2002
> +++ 2.5.33-akpm/net/ipv6/af_inet6.c	Sun Sep  1 21:23:12 2002
> @@ -655,13 +655,13 @@ static int __init inet6_init(void)
>  	/* allocate our sock slab caches */
>          tcp6_sk_cachep = kmem_cache_create("tcp6_sock",
>  					   sizeof(struct tcp6_sock), 0,
> -                                           SLAB_HWCACHE_ALIGN, 0, 0);
> +                                           SLAB_HWCACHE_ALIGN, NULL, NULL,
> NULL); udp6_sk_cachep = kmem_cache_create("udp6_sock",
>  					   sizeof(struct udp6_sock), 0,
> -                                           SLAB_HWCACHE_ALIGN, 0, 0);
> +                                           SLAB_HWCACHE_ALIGN, NULL, NULL,
> NULL); raw6_sk_cachep = kmem_cache_create("raw6_sock",
>  					   sizeof(struct raw6_sock), 0,
> -                                           SLAB_HWCACHE_ALIGN, 0, 0);
> +                                           SLAB_HWCACHE_ALIGN, NULL, NULL,
> NULL); if (!tcp6_sk_cachep || !udp6_sk_cachep || !raw6_sk_cachep)
> printk(KERN_CRIT __FUNCTION__
>                          ": Can't create protocol sock SLAB caches!\n");
> --- 2.5.33/net/ipv6/ip6_fib.c~slablru	Sun Sep  1 21:23:12 2002
> +++ 2.5.33-akpm/net/ipv6/ip6_fib.c	Sun Sep  1 21:23:12 2002
> @@ -1218,7 +1218,7 @@ void __init fib6_init(void)
>  		fib6_node_kmem = kmem_cache_create("fib6_nodes",
>  						   sizeof(struct fib6_node),
>  						   0, SLAB_HWCACHE_ALIGN,
> -						   NULL, NULL);
> +						   NULL, NULL, NULL);
>  }
>
>  #ifdef MODULE
> --- 2.5.33/net/ipv6/route.c~slablru	Sun Sep  1 21:23:12 2002
> +++ 2.5.33-akpm/net/ipv6/route.c	Sun Sep  1 21:23:12 2002
> @@ -1919,7 +1919,7 @@ void __init ip6_route_init(void)
>  	ip6_dst_ops.kmem_cachep = kmem_cache_create("ip6_dst_cache",
>  						     sizeof(struct rt6_info),
>  						     0, SLAB_HWCACHE_ALIGN,
> -						     NULL, NULL);
> +						     NULL, NULL, NULL);
>  	fib6_init();
>  #ifdef 	CONFIG_PROC_FS
>  	proc_net_create("ipv6_route", 0, rt6_proc_info);
> --- 2.5.33/net/socket.c~slablru	Sun Sep  1 21:23:12 2002
> +++ 2.5.33-akpm/net/socket.c	Sun Sep  1 21:23:12 2002
> @@ -305,7 +305,7 @@ static int init_inodecache(void)
>  	sock_inode_cachep = kmem_cache_create("sock_inode_cache",
>  					     sizeof(struct socket_alloc),
>  					     0, SLAB_HWCACHE_ALIGN,
> -					     init_once, NULL);
> +					     NULL, init_once, NULL);
>  	if (sock_inode_cachep == NULL)
>  		return -ENOMEM;
>  	return 0;
> --- 2.5.33/net/unix/af_unix.c~slablru	Sun Sep  1 21:23:12 2002
> +++ 2.5.33-akpm/net/unix/af_unix.c	Sun Sep  1 21:23:12 2002
> @@ -1893,7 +1893,7 @@ static int __init af_unix_init(void)
>          /* allocate our sock slab cache */
>          unix_sk_cachep = kmem_cache_create("unix_sock",
>  					   sizeof(struct unix_sock), 0,
> -					   SLAB_HWCACHE_ALIGN, 0, 0);
> +					   SLAB_HWCACHE_ALIGN, NULL, NULL, NULL);
>          if (!unix_sk_cachep)
>                  printk(KERN_CRIT
>                          "af_unix_init: Cannot create unix_sock SLAB
> cache!\n"); --- 2.5.33/fs/proc/proc_misc.c~slablru	Sun Sep  1 21:23:12 2002
> +++ 2.5.33-akpm/fs/proc/proc_misc.c	Sun Sep  1 21:30:44 2002
> @@ -177,6 +177,7 @@ static int meminfo_read_proc(char *page,
>  		"SwapFree:     %8lu kB\n"
>  		"Dirty:        %8lu kB\n"
>  		"Writeback:    %8lu kB\n"
> +		"Slab:         %8lu kB\n"
>  		"Committed_AS: %8u kB\n"
>  		"PageTables:   %8lu kB\n"
>  		"ReverseMaps:  %8lu\n"
> @@ -197,6 +198,7 @@ static int meminfo_read_proc(char *page,
>  		K(i.freeswap),
>  		K(ps.nr_dirty),
>  		K(ps.nr_writeback),
> +		K(ps.nr_slab),
>  		K(committed),
>  		K(ps.nr_page_table_pages),
>  		ps.nr_reverse_maps,
> --- 2.5.33/fs/jfs/jfs_metapage.c~slablru	Sun Sep  1 21:23:12 2002
> +++ 2.5.33-akpm/fs/jfs/jfs_metapage.c	Sun Sep  1 21:23:12 2002
> @@ -143,7 +143,7 @@ int __init metapage_init(void)
>  	 * Allocate the metapage structures
>  	 */
>  	metapage_cache = kmem_cache_create("jfs_mp", sizeof(metapage_t), 0, 0,
> -					   init_once, NULL);
> +					   NULL, init_once, NULL);
>  	if (metapage_cache == NULL)
>  		return -ENOMEM;
>
>
> .

-------------------------------------------------------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
