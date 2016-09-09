Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 85AAA6B0069
	for <linux-mm@kvack.org>; Fri,  9 Sep 2016 09:36:53 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id k12so45338369lfb.2
        for <linux-mm@kvack.org>; Fri, 09 Sep 2016 06:36:53 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id yq7si2993958wjc.257.2016.09.09.06.36.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Sep 2016 06:36:50 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id w12so2816228wmf.1
        for <linux-mm@kvack.org>; Fri, 09 Sep 2016 06:36:50 -0700 (PDT)
Date: Fri, 9 Sep 2016 15:36:48 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH V4] mm: Add sysfs interface to dump each node's zonelist
 information
Message-ID: <20160909133648.GL4844@dhcp22.suse.cz>
References: <1473150666-3875-1-git-send-email-khandual@linux.vnet.ibm.com>
 <1473302818-23974-1-git-send-email-khandual@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1473302818-23974-1-git-send-email-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Dave Hansen <dave.hansen@intel.com>

On Thu 08-09-16 08:16:58, Anshuman Khandual wrote:
> Each individual node in the system has a ZONELIST_FALLBACK zonelist
> and a ZONELIST_NOFALLBACK zonelist. These zonelists decide fallback
> order of zones during memory allocations. Sometimes it helps to dump
> these zonelists to see the priority order of various zones in them.
> 
> Particularly platforms which support memory hotplug into previously
> non existing zones (at boot), this interface helps in visualizing
> which all zonelists of the system at what priority level, the new
> hot added memory ends up in. POWER is such a platform where all the
> memory detected during boot time remains with ZONE_DMA for good but
> then hot plug process can actually get new memory into ZONE_MOVABLE.
> So having a way to get the snapshot of the zonelists on the system
> after memory or node hot[un]plug is desirable. This change adds one
> new sysfs interface (/sys/devices/system/memory/system_zone_details)
> which will fetch and dump this information.

I am still not sure I understand why this is helpful and who is the
consumer for this interface and how it will benefit from the
information. Dave (who doesn't seem to be on the CC list re-added) had
another objection that this breaks one-value-per-file rule for sysfs
files.

This all smells like a debugging feature to me and so it should go into
debugfs.

> Example zonelist information from a KVM guest.
> 
> [NODE (0)]
>         ZONELIST_FALLBACK
>                 (0) (node 0) (DMA     0xc0000000ffff6300)
>                 (1) (node 1) (DMA     0xc0000001ffff6300)
>                 (2) (node 2) (DMA     0xc0000002ffff6300)
>                 (3) (node 3) (DMA     0xc0000003ffdba300)
>         ZONELIST_NOFALLBACK
>                 (0) (node 0) (DMA     0xc0000000ffff6300)
> [NODE (1)]
>         ZONELIST_FALLBACK
>                 (0) (node 1) (DMA     0xc0000001ffff6300)
>                 (1) (node 2) (DMA     0xc0000002ffff6300)
>                 (2) (node 3) (DMA     0xc0000003ffdba300)
>                 (3) (node 0) (DMA     0xc0000000ffff6300)
>         ZONELIST_NOFALLBACK
>                 (0) (node 1) (DMA     0xc0000001ffff6300)
> [NODE (2)]
>         ZONELIST_FALLBACK
>                 (0) (node 2) (DMA     0xc0000002ffff6300)
>                 (1) (node 3) (DMA     0xc0000003ffdba300)
>                 (2) (node 0) (DMA     0xc0000000ffff6300)
>                 (3) (node 1) (DMA     0xc0000001ffff6300)
>         ZONELIST_NOFALLBACK
>                 (0) (node 2) (DMA     0xc0000002ffff6300)
> [NODE (3)]
>         ZONELIST_FALLBACK
>                 (0) (node 3) (DMA     0xc0000003ffdba300)
>                 (1) (node 0) (DMA     0xc0000000ffff6300)
>                 (2) (node 1) (DMA     0xc0000001ffff6300)
>                 (3) (node 2) (DMA     0xc0000002ffff6300)
>         ZONELIST_NOFALLBACK
>                 (0) (node 3) (DMA     0xc0000003ffdba300)
> 
> Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
> ---
> Changes in V4:
> - Explicitly included mmzone.h header inside page_alloc.c
> - Changed the kernel address printing from %lx to %pK
> 
> Changes in V3:
> - Moved all these new sysfs code inside CONFIG_NUMA
> 
> Changes in V2:
> - Added more details into the commit message
> - Added sysfs interface file details into the commit message
> - Added ../ABI/testing/sysfs-system-zone-details file
> 
>  .../ABI/testing/sysfs-system-zone-details          |  9 ++++
>  drivers/base/memory.c                              | 52 ++++++++++++++++++++++
>  mm/page_alloc.c                                    |  1 +
>  3 files changed, 62 insertions(+)
>  create mode 100644 Documentation/ABI/testing/sysfs-system-zone-details
> 
> diff --git a/Documentation/ABI/testing/sysfs-system-zone-details b/Documentation/ABI/testing/sysfs-system-zone-details
> new file mode 100644
> index 0000000..9c13b2e
> --- /dev/null
> +++ b/Documentation/ABI/testing/sysfs-system-zone-details
> @@ -0,0 +1,9 @@
> +What:		/sys/devices/system/memory/system_zone_details
> +Date:		Sep 2016
> +KernelVersion:	4.8
> +Contact:	khandual@linux.vnet.ibm.com
> +Description:
> +		This read only file dumps the zonelist and it's constituent
> +		zones information for both ZONELIST_FALLBACK and ZONELIST_
> +		NOFALLBACK zonelists for each online node of the system at
> +		any given point of time.
> diff --git a/drivers/base/memory.c b/drivers/base/memory.c
> index dc75de9..c7ab991 100644
> --- a/drivers/base/memory.c
> +++ b/drivers/base/memory.c
> @@ -442,7 +442,56 @@ print_block_size(struct device *dev, struct device_attribute *attr,
>  	return sprintf(buf, "%lx\n", get_memory_block_size());
>  }
>  
> +#ifdef CONFIG_NUMA
> +static ssize_t dump_zonelist(char *buf, struct zonelist *zonelist)
> +{
> +	unsigned int i;
> +	ssize_t count = 0;
> +
> +	for (i = 0; zonelist->_zonerefs[i].zone; i++) {
> +		count += sprintf(buf + count,
> +			"\t\t(%d) (node %d) (%-7s 0x%pK)\n", i,
> +			zonelist->_zonerefs[i].zone->zone_pgdat->node_id,
> +			zone_names[zonelist->_zonerefs[i].zone_idx],
> +			(void *) zonelist->_zonerefs[i].zone);
> +	}
> +	return count;
> +}
> +
> +static ssize_t dump_zonelists(char *buf)
> +{
> +	struct zonelist *zonelist;
> +	unsigned int node;
> +	ssize_t count = 0;
> +
> +	for_each_online_node(node) {
> +		zonelist = &(NODE_DATA(node)->
> +				node_zonelists[ZONELIST_FALLBACK]);
> +		count += sprintf(buf + count, "[NODE (%d)]\n", node);
> +		count += sprintf(buf + count, "\tZONELIST_FALLBACK\n");
> +		count += dump_zonelist(buf + count, zonelist);
> +
> +		zonelist = &(NODE_DATA(node)->
> +				node_zonelists[ZONELIST_NOFALLBACK]);
> +		count += sprintf(buf + count, "\tZONELIST_NOFALLBACK\n");
> +		count += dump_zonelist(buf + count, zonelist);
> +	}
> +	return count;
> +}
> +
> +static ssize_t
> +print_system_zone_details(struct device *dev, struct device_attribute *attr,
> +		 char *buf)
> +{
> +	return dump_zonelists(buf);
> +}
> +#endif
> +
> +
>  static DEVICE_ATTR(block_size_bytes, 0444, print_block_size, NULL);
> +#ifdef CONFIG_NUMA
> +static DEVICE_ATTR(system_zone_details, 0444, print_system_zone_details, NULL);
> +#endif
>  
>  /*
>   * Memory auto online policy.
> @@ -783,6 +832,9 @@ static struct attribute *memory_root_attrs[] = {
>  #endif
>  
>  	&dev_attr_block_size_bytes.attr,
> +#ifdef CONFIG_NUMA
> +	&dev_attr_system_zone_details.attr,
> +#endif
>  	&dev_attr_auto_online_blocks.attr,
>  	NULL
>  };
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index a2214c6..d3da022 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -64,6 +64,7 @@
>  #include <linux/page_owner.h>
>  #include <linux/kthread.h>
>  #include <linux/memcontrol.h>
> +#include <linux/mmzone.h>
>  
>  #include <asm/sections.h>
>  #include <asm/tlbflush.h>
> -- 
> 2.1.0
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
