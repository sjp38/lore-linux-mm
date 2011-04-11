Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 5AC3D8D003B
	for <linux-mm@kvack.org>; Mon, 11 Apr 2011 07:20:59 -0400 (EDT)
Date: Mon, 11 Apr 2011 19:20:55 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] mm: per-node vmstat show proper vmstats
Message-ID: <20110411112055.GA19123@localhost>
References: <20110411201015.F5BC.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110411201015.F5BC.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Michael Rubin <mrubin@google.com>

> With this patch, the vmstat show all vm stastics as /proc/vmstat.

Nice! It's good to see all the per-node vmstats, here are my numbers :)

wfg@fat ~% cat /sys/devices/system/node/node0/vmstat
nr_free_pages 67026
nr_inactive_anon 147
nr_active_anon 3697
nr_inactive_file 611711
nr_active_file 2291
nr_unevictable 0
nr_mlock 0
nr_anon_pages 3623
nr_mapped 2165
nr_file_pages 614269
nr_dirty 116123
nr_writeback 23596
nr_slab_reclaimable 25178
nr_slab_unreclaimable 6946
nr_page_table_pages 380
nr_kernel_stack 142
nr_unstable 0
nr_bounce 0
nr_vmscan_write 0
nr_writeback_temp 0
nr_isolated_anon 0
nr_isolated_file 0
nr_shmem 153
nr_dirtied 605215
nr_written 489092
numa_hit 1199939
numa_miss 0
numa_foreign 0
numa_interleave 7408
numa_local 1199939
numa_other 0
nr_anon_transparent_hugepages 0

Thanks,
Fengguang

On Mon, Apr 11, 2011 at 07:10:19PM +0800, KOSAKI Motohiro wrote:
> commit 2ac390370a (writeback: add /sys/devices/system/node/<node>/vmstat)
> added vmstat entry. But strangely it only show nr_written and nr_dirtied.
> 
>         # cat /sys/devices/system/node/node20/vmstat
>         nr_written 0
>         nr_dirtied 0
> 
> Of cource, It's no adequate. With this patch, the vmstat show
> all vm stastics as /proc/vmstat.
> 
>         # cat /sys/devices/system/node/node0/vmstat
> 	nr_free_pages 899224
> 	nr_inactive_anon 201
> 	nr_active_anon 17380
> 	nr_inactive_file 31572
> 	nr_active_file 28277
> 	nr_unevictable 0
> 	nr_mlock 0
> 	nr_anon_pages 17321
> 	nr_mapped 8640
> 	nr_file_pages 60107
> 	nr_dirty 33
> 	nr_writeback 0
> 	nr_slab_reclaimable 6850
> 	nr_slab_unreclaimable 7604
> 	nr_page_table_pages 3105
> 	nr_kernel_stack 175
> 	nr_unstable 0
> 	nr_bounce 0
> 	nr_vmscan_write 0
> 	nr_writeback_temp 0
> 	nr_isolated_anon 0
> 	nr_isolated_file 0
> 	nr_shmem 260
> 	nr_dirtied 1050
> 	nr_written 938
> 	numa_hit 962872
> 	numa_miss 0
> 	numa_foreign 0
> 	numa_interleave 8617
> 	numa_local 962872
> 	numa_other 0
> 	nr_anon_transparent_hugepages 0
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Michael Rubin <mrubin@google.com>
> Cc: Wu Fengguang <fengguang.wu@intel.com>
> ---
>  drivers/base/node.c |   15 ++++++++++-----
>  mm/vmstat.c         |    2 +-
>  2 files changed, 11 insertions(+), 6 deletions(-)
> 
> diff --git a/drivers/base/node.c b/drivers/base/node.c
> index b3b72d6..3fc5f28 100644
> --- a/drivers/base/node.c
> +++ b/drivers/base/node.c
> @@ -175,15 +175,20 @@ static ssize_t node_read_numastat(struct sys_device * dev,
>  }
>  static SYSDEV_ATTR(numastat, S_IRUGO, node_read_numastat, NULL);
>  
> +extern const char * const vmstat_text[];
> +
>  static ssize_t node_read_vmstat(struct sys_device *dev,
>  				struct sysdev_attribute *attr, char *buf)
>  {
>  	int nid = dev->id;
> -	return sprintf(buf,
> -		"nr_written %lu\n"
> -		"nr_dirtied %lu\n",
> -		node_page_state(nid, NR_WRITTEN),
> -		node_page_state(nid, NR_DIRTIED));
> +	int i;
> +	int n = 0;
> +
> +	for (i = 0; i < NR_VM_ZONE_STAT_ITEMS; i++)
> +		n += sprintf(buf+n, "%s %lu\n", vmstat_text[i],
> +			     node_page_state(nid, i));
> +
> +	return n;
>  }
>  static SYSDEV_ATTR(vmstat, S_IRUGO, node_read_vmstat, NULL);
>  
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index 897ea9e..0000aad 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -852,7 +852,7 @@ static const struct file_operations pagetypeinfo_file_ops = {
>  #define TEXTS_FOR_ZONES(xx) TEXT_FOR_DMA(xx) TEXT_FOR_DMA32(xx) xx "_normal", \
>  					TEXT_FOR_HIGHMEM(xx) xx "_movable",
>  
> -static const char * const vmstat_text[] = {
> +const char * const vmstat_text[] = {
>  	/* Zoned VM counters */
>  	"nr_free_pages",
>  	"nr_inactive_anon",
> -- 
> 1.7.3.1
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
