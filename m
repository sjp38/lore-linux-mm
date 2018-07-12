Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 756716B000A
	for <linux-mm@kvack.org>; Thu, 12 Jul 2018 03:28:53 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id l1-v6so2918252edi.11
        for <linux-mm@kvack.org>; Thu, 12 Jul 2018 00:28:53 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id q35-v6si6848385eda.392.2018.07.12.00.28.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Jul 2018 00:28:52 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w6C7NYfo142852
	for <linux-mm@kvack.org>; Thu, 12 Jul 2018 03:28:50 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2k6119w5aj-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 12 Jul 2018 03:28:50 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Thu, 12 Jul 2018 08:28:48 +0100
Date: Thu, 12 Jul 2018 10:28:42 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH v2] alpha: switch to NO_BOOTMEM
References: <1530371610-22174-1-git-send-email-rppt@linux.vnet.ibm.com>
 <20180704124446.GF4352@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180704124446.GF4352@rapoport-lnx>
Message-Id: <20180712072842.GC4422@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matt Turner <mattst88@gmail.com>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>
Cc: Michal Hocko <mhocko@kernel.org>, linux-alpha <linux-alpha@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>

(added Matt Turner, sorry, should have done it from the beginning)

Any comments on this?
 
> On Sat, Jun 30, 2018 at 06:13:30PM +0300, Mike Rapoport wrote:
> Replace bootmem allocator with memblock and enable use of NO_BOOTMEM like
> on most other architectures.
> 
> Alpha gets the description of the physical memory from the firmware as an
> array of memory clusters. Each cluster that is not reserved by the firmware
> is added to memblock.memory.
> 
> Once the memblock.memory is set up, we reserve the kernel and initrd pages
> with memblock reserve.
> 
> Since we don't need the bootmem bitmap anymore, the code that finds an
> appropriate place is removed.
> 
> The conversion does not take care of NUMA support which is marked broken
> for more than 10 years now.
> 
> Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
> ---
> v2: describe the conversion as per Michal's request
> 
> Tested with qemu-system-alpha. I've added some tweaks to sys_dp264 to force
> memory split for testing with CONFIG_DISCONTIGMEM=y
> 
> The allyesconfig build requires update to DEFERRED_STRUCT_PAGE_INIT
> dependencies [1] which is already in -mm tree.
> 
> [1] https://lkml.org/lkml/2018/6/29/353
> 
>  arch/alpha/Kconfig                |   2 +
>  arch/alpha/kernel/core_irongate.c |   4 +-
>  arch/alpha/kernel/setup.c         |  98 ++++-----------------------------
>  arch/alpha/mm/numa.c              | 113 +++++---------------------------------
>  4 files changed, 29 insertions(+), 188 deletions(-)
> 
> diff --git a/arch/alpha/Kconfig b/arch/alpha/Kconfig
> index 04a4a138ed13..040692a8d433 100644
> --- a/arch/alpha/Kconfig
> +++ b/arch/alpha/Kconfig
> @@ -30,6 +30,8 @@ config ALPHA
>  	select ODD_RT_SIGACTION
>  	select OLD_SIGSUSPEND
>  	select CPU_NO_EFFICIENT_FFS if !ALPHA_EV67
> +	select HAVE_MEMBLOCK
> +	select NO_BOOTMEM
>  	help
>  	  The Alpha is a 64-bit general-purpose processor designed and
>  	  marketed by the Digital Equipment Corporation of blessed memory,
> diff --git a/arch/alpha/kernel/core_irongate.c b/arch/alpha/kernel/core_irongate.c
> index aec757250e07..f70986683fc6 100644
> --- a/arch/alpha/kernel/core_irongate.c
> +++ b/arch/alpha/kernel/core_irongate.c
> @@ -21,6 +21,7 @@
>  #include <linux/init.h>
>  #include <linux/initrd.h>
>  #include <linux/bootmem.h>
> +#include <linux/memblock.h>
> 
>  #include <asm/ptrace.h>
>  #include <asm/cacheflush.h>
> @@ -241,8 +242,7 @@ albacore_init_arch(void)
>  				       size / 1024);
>  		}
>  #endif
> -		reserve_bootmem_node(NODE_DATA(0), pci_mem, memtop -
> -				pci_mem, BOOTMEM_DEFAULT);
> +		memblock_reserve(pci_mem, memtop - pci_mem);
>  		printk("irongate_init_arch: temporarily reserving "
>  			"region %08lx-%08lx for PCI\n", pci_mem, memtop - 1);
>  	}
> diff --git a/arch/alpha/kernel/setup.c b/arch/alpha/kernel/setup.c
> index 5576f7646fb6..4f0d94471bc9 100644
> --- a/arch/alpha/kernel/setup.c
> +++ b/arch/alpha/kernel/setup.c
> @@ -30,6 +30,7 @@
>  #include <linux/ioport.h>
>  #include <linux/platform_device.h>
>  #include <linux/bootmem.h>
> +#include <linux/memblock.h>
>  #include <linux/pci.h>
>  #include <linux/seq_file.h>
>  #include <linux/root_dev.h>
> @@ -312,9 +313,7 @@ setup_memory(void *kernel_end)
>  {
>  	struct memclust_struct * cluster;
>  	struct memdesc_struct * memdesc;
> -	unsigned long start_kernel_pfn, end_kernel_pfn;
> -	unsigned long bootmap_size, bootmap_pages, bootmap_start;
> -	unsigned long start, end;
> +	unsigned long kernel_size;
>  	unsigned long i;
> 
>  	/* Find free clusters, and init and free the bootmem accordingly.  */
> @@ -322,6 +321,8 @@ setup_memory(void *kernel_end)
>  	  (hwrpb->mddt_offset + (unsigned long) hwrpb);
> 
>  	for_each_mem_cluster(memdesc, cluster, i) {
> +		unsigned long end;
> +
>  		printk("memcluster %lu, usage %01lx, start %8lu, end %8lu\n",
>  		       i, cluster->usage, cluster->start_pfn,
>  		       cluster->start_pfn + cluster->numpages);
> @@ -335,6 +336,9 @@ setup_memory(void *kernel_end)
>  		end = cluster->start_pfn + cluster->numpages;
>  		if (end > max_low_pfn)
>  			max_low_pfn = end;
> +
> +		memblock_add(PFN_PHYS(cluster->start_pfn),
> +			     cluster->numpages << PAGE_SHIFT);
>  	}
> 
>  	/*
> @@ -363,87 +367,9 @@ setup_memory(void *kernel_end)
>  		max_low_pfn = mem_size_limit;
>  	}
> 
> -	/* Find the bounds of kernel memory.  */
> -	start_kernel_pfn = PFN_DOWN(KERNEL_START_PHYS);
> -	end_kernel_pfn = PFN_UP(virt_to_phys(kernel_end));
> -	bootmap_start = -1;
> -
> - try_again:
> -	if (max_low_pfn <= end_kernel_pfn)
> -		panic("not enough memory to boot");
> -
> -	/* We need to know how many physically contiguous pages
> -	   we'll need for the bootmap.  */
> -	bootmap_pages = bootmem_bootmap_pages(max_low_pfn);
> -
> -	/* Now find a good region where to allocate the bootmap.  */
> -	for_each_mem_cluster(memdesc, cluster, i) {
> -		if (cluster->usage & 3)
> -			continue;
> -
> -		start = cluster->start_pfn;
> -		end = start + cluster->numpages;
> -		if (start >= max_low_pfn)
> -			continue;
> -		if (end > max_low_pfn)
> -			end = max_low_pfn;
> -		if (start < start_kernel_pfn) {
> -			if (end > end_kernel_pfn
> -			    && end - end_kernel_pfn >= bootmap_pages) {
> -				bootmap_start = end_kernel_pfn;
> -				break;
> -			} else if (end > start_kernel_pfn)
> -				end = start_kernel_pfn;
> -		} else if (start < end_kernel_pfn)
> -			start = end_kernel_pfn;
> -		if (end - start >= bootmap_pages) {
> -			bootmap_start = start;
> -			break;
> -		}
> -	}
> -
> -	if (bootmap_start == ~0UL) {
> -		max_low_pfn >>= 1;
> -		goto try_again;
> -	}
> -
> -	/* Allocate the bootmap and mark the whole MM as reserved.  */
> -	bootmap_size = init_bootmem(bootmap_start, max_low_pfn);
> -
> -	/* Mark the free regions.  */
> -	for_each_mem_cluster(memdesc, cluster, i) {
> -		if (cluster->usage & 3)
> -			continue;
> -
> -		start = cluster->start_pfn;
> -		end = cluster->start_pfn + cluster->numpages;
> -		if (start >= max_low_pfn)
> -			continue;
> -		if (end > max_low_pfn)
> -			end = max_low_pfn;
> -		if (start < start_kernel_pfn) {
> -			if (end > end_kernel_pfn) {
> -				free_bootmem(PFN_PHYS(start),
> -					     (PFN_PHYS(start_kernel_pfn)
> -					      - PFN_PHYS(start)));
> -				printk("freeing pages %ld:%ld\n",
> -				       start, start_kernel_pfn);
> -				start = end_kernel_pfn;
> -			} else if (end > start_kernel_pfn)
> -				end = start_kernel_pfn;
> -		} else if (start < end_kernel_pfn)
> -			start = end_kernel_pfn;
> -		if (start >= end)
> -			continue;
> -
> -		free_bootmem(PFN_PHYS(start), PFN_PHYS(end) - PFN_PHYS(start));
> -		printk("freeing pages %ld:%ld\n", start, end);
> -	}
> -
> -	/* Reserve the bootmap memory.  */
> -	reserve_bootmem(PFN_PHYS(bootmap_start), bootmap_size,
> -			BOOTMEM_DEFAULT);
> -	printk("reserving pages %ld:%ld\n", bootmap_start, bootmap_start+PFN_UP(bootmap_size));
> +	/* Reserve the kernel memory. */
> +	kernel_size = virt_to_phys(kernel_end) - KERNEL_START_PHYS;
> +	memblock_reserve(KERNEL_START_PHYS, kernel_size);
> 
>  #ifdef CONFIG_BLK_DEV_INITRD
>  	initrd_start = INITRD_START;
> @@ -459,8 +385,8 @@ setup_memory(void *kernel_end)
>  				       initrd_end,
>  				       phys_to_virt(PFN_PHYS(max_low_pfn)));
>  		} else {
> -			reserve_bootmem(virt_to_phys((void *)initrd_start),
> -					INITRD_SIZE, BOOTMEM_DEFAULT);
> +			memblock_reserve(virt_to_phys((void *)initrd_start),
> +					INITRD_SIZE);
>  		}
>  	}
>  #endif /* CONFIG_BLK_DEV_INITRD */
> diff --git a/arch/alpha/mm/numa.c b/arch/alpha/mm/numa.c
> index a9e86475f169..26cd925d19b1 100644
> --- a/arch/alpha/mm/numa.c
> +++ b/arch/alpha/mm/numa.c
> @@ -11,6 +11,7 @@
>  #include <linux/kernel.h>
>  #include <linux/mm.h>
>  #include <linux/bootmem.h>
> +#include <linux/memblock.h>
>  #include <linux/swap.h>
>  #include <linux/initrd.h>
>  #include <linux/pfn.h>
> @@ -59,12 +60,10 @@ setup_memory_node(int nid, void *kernel_end)
>  	struct memclust_struct * cluster;
>  	struct memdesc_struct * memdesc;
>  	unsigned long start_kernel_pfn, end_kernel_pfn;
> -	unsigned long bootmap_size, bootmap_pages, bootmap_start;
>  	unsigned long start, end;
>  	unsigned long node_pfn_start, node_pfn_end;
>  	unsigned long node_min_pfn, node_max_pfn;
>  	int i;
> -	unsigned long node_datasz = PFN_UP(sizeof(pg_data_t));
>  	int show_init = 0;
> 
>  	/* Find the bounds of current node */
> @@ -134,24 +133,14 @@ setup_memory_node(int nid, void *kernel_end)
>  	/* Cute trick to make sure our local node data is on local memory */
>  	node_data[nid] = (pg_data_t *)(__va(node_min_pfn << PAGE_SHIFT));
>  #endif
> -	/* Quasi-mark the pg_data_t as in-use */
> -	node_min_pfn += node_datasz;
> -	if (node_min_pfn >= node_max_pfn) {
> -		printk(" not enough mem to reserve NODE_DATA");
> -		return;
> -	}
> -	NODE_DATA(nid)->bdata = &bootmem_node_data[nid];
> -
>  	printk(" Detected node memory:   start %8lu, end %8lu\n",
>  	       node_min_pfn, node_max_pfn);
> 
>  	DBGDCONT(" DISCONTIG: node_data[%d]   is at 0x%p\n", nid, NODE_DATA(nid));
> -	DBGDCONT(" DISCONTIG: NODE_DATA(%d)->bdata is at 0x%p\n", nid, NODE_DATA(nid)->bdata);
> 
>  	/* Find the bounds of kernel memory.  */
>  	start_kernel_pfn = PFN_DOWN(KERNEL_START_PHYS);
>  	end_kernel_pfn = PFN_UP(virt_to_phys(kernel_end));
> -	bootmap_start = -1;
> 
>  	if (!nid && (node_max_pfn < end_kernel_pfn || node_min_pfn > start_kernel_pfn))
>  		panic("kernel loaded out of ram");
> @@ -161,89 +150,11 @@ setup_memory_node(int nid, void *kernel_end)
>  	   has much larger alignment than 8Mb, so it's safe. */
>  	node_min_pfn &= ~((1UL << (MAX_ORDER-1))-1);
> 
> -	/* We need to know how many physically contiguous pages
> -	   we'll need for the bootmap.  */
> -	bootmap_pages = bootmem_bootmap_pages(node_max_pfn-node_min_pfn);
> -
> -	/* Now find a good region where to allocate the bootmap.  */
> -	for_each_mem_cluster(memdesc, cluster, i) {
> -		if (cluster->usage & 3)
> -			continue;
> -
> -		start = cluster->start_pfn;
> -		end = start + cluster->numpages;
> -
> -		if (start >= node_max_pfn || end <= node_min_pfn)
> -			continue;
> -
> -		if (end > node_max_pfn)
> -			end = node_max_pfn;
> -		if (start < node_min_pfn)
> -			start = node_min_pfn;
> -
> -		if (start < start_kernel_pfn) {
> -			if (end > end_kernel_pfn
> -			    && end - end_kernel_pfn >= bootmap_pages) {
> -				bootmap_start = end_kernel_pfn;
> -				break;
> -			} else if (end > start_kernel_pfn)
> -				end = start_kernel_pfn;
> -		} else if (start < end_kernel_pfn)
> -			start = end_kernel_pfn;
> -		if (end - start >= bootmap_pages) {
> -			bootmap_start = start;
> -			break;
> -		}
> -	}
> -
> -	if (bootmap_start == -1)
> -		panic("couldn't find a contiguous place for the bootmap");
> -
> -	/* Allocate the bootmap and mark the whole MM as reserved.  */
> -	bootmap_size = init_bootmem_node(NODE_DATA(nid), bootmap_start,
> -					 node_min_pfn, node_max_pfn);
> -	DBGDCONT(" bootmap_start %lu, bootmap_size %lu, bootmap_pages %lu\n",
> -		 bootmap_start, bootmap_size, bootmap_pages);
> +	memblock_add(PFN_PHYS(node_min_pfn),
> +		     (node_max_pfn - node_min_pfn) << PAGE_SHIFT);
> 
> -	/* Mark the free regions.  */
> -	for_each_mem_cluster(memdesc, cluster, i) {
> -		if (cluster->usage & 3)
> -			continue;
> -
> -		start = cluster->start_pfn;
> -		end = cluster->start_pfn + cluster->numpages;
> -
> -		if (start >= node_max_pfn || end <= node_min_pfn)
> -			continue;
> -
> -		if (end > node_max_pfn)
> -			end = node_max_pfn;
> -		if (start < node_min_pfn)
> -			start = node_min_pfn;
> -
> -		if (start < start_kernel_pfn) {
> -			if (end > end_kernel_pfn) {
> -				free_bootmem_node(NODE_DATA(nid), PFN_PHYS(start),
> -					     (PFN_PHYS(start_kernel_pfn)
> -					      - PFN_PHYS(start)));
> -				printk(" freeing pages %ld:%ld\n",
> -				       start, start_kernel_pfn);
> -				start = end_kernel_pfn;
> -			} else if (end > start_kernel_pfn)
> -				end = start_kernel_pfn;
> -		} else if (start < end_kernel_pfn)
> -			start = end_kernel_pfn;
> -		if (start >= end)
> -			continue;
> -
> -		free_bootmem_node(NODE_DATA(nid), PFN_PHYS(start), PFN_PHYS(end) - PFN_PHYS(start));
> -		printk(" freeing pages %ld:%ld\n", start, end);
> -	}
> -
> -	/* Reserve the bootmap memory.  */
> -	reserve_bootmem_node(NODE_DATA(nid), PFN_PHYS(bootmap_start),
> -			bootmap_size, BOOTMEM_DEFAULT);
> -	printk(" reserving pages %ld:%ld\n", bootmap_start, bootmap_start+PFN_UP(bootmap_size));
> +	NODE_DATA(nid)->node_start_pfn = node_min_pfn;
> +	NODE_DATA(nid)->node_present_pages = node_max_pfn - node_min_pfn;
> 
>  	node_set_online(nid);
>  }
> @@ -251,6 +162,7 @@ setup_memory_node(int nid, void *kernel_end)
>  void __init
>  setup_memory(void *kernel_end)
>  {
> +	unsigned long kernel_size;
>  	int nid;
> 
>  	show_mem_layout();
> @@ -262,6 +174,9 @@ setup_memory(void *kernel_end)
>  	for (nid = 0; nid < MAX_NUMNODES; nid++)
>  		setup_memory_node(nid, kernel_end);
> 
> +	kernel_size = virt_to_phys(kernel_end) - KERNEL_START_PHYS;
> +	memblock_reserve(KERNEL_START_PHYS, kernel_size);
> +
>  #ifdef CONFIG_BLK_DEV_INITRD
>  	initrd_start = INITRD_START;
>  	if (initrd_start) {
> @@ -279,9 +194,8 @@ setup_memory(void *kernel_end)
>  				       phys_to_virt(PFN_PHYS(max_low_pfn)));
>  		} else {
>  			nid = kvaddr_to_nid(initrd_start);
> -			reserve_bootmem_node(NODE_DATA(nid),
> -					     virt_to_phys((void *)initrd_start),
> -					     INITRD_SIZE, BOOTMEM_DEFAULT);
> +			memblock_reserve(virt_to_phys((void *)initrd_start),
> +					 INITRD_SIZE);
>  		}
>  	}
>  #endif /* CONFIG_BLK_DEV_INITRD */
> @@ -303,9 +217,8 @@ void __init paging_init(void)
>  	dma_local_pfn = virt_to_phys((char *)MAX_DMA_ADDRESS) >> PAGE_SHIFT;
> 
>  	for_each_online_node(nid) {
> -		bootmem_data_t *bdata = &bootmem_node_data[nid];
> -		unsigned long start_pfn = bdata->node_min_pfn;
> -		unsigned long end_pfn = bdata->node_low_pfn;
> +		unsigned long start_pfn = NODE_DATA(nid)->node_start_pfn;
> +		unsigned long end_pfn = start_pfn + NODE_DATA(nid)->node_present_pages;
> 
>  		if (dma_local_pfn >= end_pfn - start_pfn)
>  			zones_size[ZONE_DMA] = end_pfn - start_pfn;
> -- 
> 2.7.4

-- 
Sincerely yours,
Mike.
