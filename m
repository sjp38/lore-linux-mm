Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id CF5926B0287
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 07:43:20 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id f2so7381402plj.15
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 04:43:20 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i8si11214020pfk.151.2017.12.19.04.43.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 19 Dec 2017 04:43:19 -0800 (PST)
Date: Tue, 19 Dec 2017 13:43:17 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 4/5] mm: use node_page_state_snapshot to avoid
 deviation
Message-ID: <20171219124317.GP2787@dhcp22.suse.cz>
References: <1513665566-4465-1-git-send-email-kemi.wang@intel.com>
 <1513665566-4465-5-git-send-email-kemi.wang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1513665566-4465-5-git-send-email-kemi.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kemi Wang <kemi.wang@intel.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Christopher Lameter <cl@linux.com>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Nikolay Borisov <nborisov@suse.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, David Rientjes <rientjes@google.com>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Dave <dave.hansen@linux.intel.com>, Andi Kleen <andi.kleen@intel.com>, Tim Chen <tim.c.chen@intel.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>, Aubrey Li <aubrey.li@intel.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>

On Tue 19-12-17 14:39:25, Kemi Wang wrote:
> To avoid deviation, this patch uses node_page_state_snapshot instead of
> node_page_state for node page stats query.
> e.g. cat /proc/zoneinfo
>      cat /sys/devices/system/node/node*/vmstat
>      cat /sys/devices/system/node/node*/numastat
> 
> As it is a slow path and would not be read frequently, I would worry about
> it.

The changelog doesn't explain why these counters needs any special
treatment. _snapshot variants where used only for internal handling
where the precision really mattered. We do not have any in-tree user and
Jack has removed this by http://lkml.kernel.org/r/20171122094416.26019-1-jack@suse.cz
which is already sitting in the mmotm tree. We can re-add it but that
would really require a _very good_ reason.

> Signed-off-by: Kemi Wang <kemi.wang@intel.com>
> ---
>  drivers/base/node.c | 17 ++++++++++-------
>  mm/vmstat.c         |  2 +-
>  2 files changed, 11 insertions(+), 8 deletions(-)
> 
> diff --git a/drivers/base/node.c b/drivers/base/node.c
> index a045ea1..cf303f8 100644
> --- a/drivers/base/node.c
> +++ b/drivers/base/node.c
> @@ -169,12 +169,15 @@ static ssize_t node_read_numastat(struct device *dev,
>  		       "interleave_hit %lu\n"
>  		       "local_node %lu\n"
>  		       "other_node %lu\n",
> -		       node_page_state(NODE_DATA(dev->id), NUMA_HIT),
> -		       node_page_state(NODE_DATA(dev->id), NUMA_MISS),
> -		       node_page_state(NODE_DATA(dev->id), NUMA_FOREIGN),
> -		       node_page_state(NODE_DATA(dev->id), NUMA_INTERLEAVE_HIT),
> -		       node_page_state(NODE_DATA(dev->id), NUMA_LOCAL),
> -		       node_page_state(NODE_DATA(dev->id), NUMA_OTHER));
> +		       node_page_state_snapshot(NODE_DATA(dev->id), NUMA_HIT),
> +		       node_page_state_snapshot(NODE_DATA(dev->id), NUMA_MISS),
> +		       node_page_state_snapshot(NODE_DATA(dev->id),
> +			       NUMA_FOREIGN),
> +		       node_page_state_snapshot(NODE_DATA(dev->id),
> +			       NUMA_INTERLEAVE_HIT),
> +		       node_page_state_snapshot(NODE_DATA(dev->id), NUMA_LOCAL),
> +		       node_page_state_snapshot(NODE_DATA(dev->id),
> +			       NUMA_OTHER));
>  }
>  
>  static DEVICE_ATTR(numastat, S_IRUGO, node_read_numastat, NULL);
> @@ -194,7 +197,7 @@ static ssize_t node_read_vmstat(struct device *dev,
>  	for (i = 0; i < NR_VM_NODE_STAT_ITEMS; i++)
>  		n += sprintf(buf+n, "%s %lu\n",
>  			     vmstat_text[i + NR_VM_ZONE_STAT_ITEMS],
> -			     node_page_state(pgdat, i));
> +			     node_page_state_snapshot(pgdat, i));
>  
>  	return n;
>  }
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index 64e08ae..d65f28d 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -1466,7 +1466,7 @@ static void zoneinfo_show_print(struct seq_file *m, pg_data_t *pgdat,
>  		for (i = 0; i < NR_VM_NODE_STAT_ITEMS; i++) {
>  			seq_printf(m, "\n      %-12s %lu",
>  				vmstat_text[i + NR_VM_ZONE_STAT_ITEMS],
> -				node_page_state(pgdat, i));
> +				node_page_state_snapshot(pgdat, i));
>  		}
>  	}
>  	seq_printf(m,
> -- 
> 2.7.4
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
