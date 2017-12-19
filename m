Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1E5E66B0285
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 07:40:47 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id l33so11362069wrl.5
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 04:40:47 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l38si2379982wre.522.2017.12.19.04.40.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 19 Dec 2017 04:40:46 -0800 (PST)
Date: Tue, 19 Dec 2017 13:40:45 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 3/5] mm: enlarge NUMA counters threshold size
Message-ID: <20171219124045.GO2787@dhcp22.suse.cz>
References: <1513665566-4465-1-git-send-email-kemi.wang@intel.com>
 <1513665566-4465-4-git-send-email-kemi.wang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1513665566-4465-4-git-send-email-kemi.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kemi Wang <kemi.wang@intel.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Christopher Lameter <cl@linux.com>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Nikolay Borisov <nborisov@suse.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, David Rientjes <rientjes@google.com>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Dave <dave.hansen@linux.intel.com>, Andi Kleen <andi.kleen@intel.com>, Tim Chen <tim.c.chen@intel.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>, Aubrey Li <aubrey.li@intel.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>

On Tue 19-12-17 14:39:24, Kemi Wang wrote:
> We have seen significant overhead in cache bouncing caused by NUMA counters
> update in multi-threaded page allocation. See 'commit 1d90ca897cb0 ("mm:
> update NUMA counter threshold size")' for more details.
> 
> This patch updates NUMA counters to a fixed size of (MAX_S16 - 2) and deals
> with global counter update using different threshold size for node page
> stats.

Again, no numbers. To be honest I do not really like the special casing
here. Why are numa counters any different from PGALLOC which is
incremented for _every_ single page allocation?

> ---
>  mm/vmstat.c | 13 +++++++++++--
>  1 file changed, 11 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index 9c681cc..64e08ae 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -30,6 +30,8 @@
>  
>  #include "internal.h"
>  
> +#define VM_NUMA_STAT_THRESHOLD (S16_MAX - 2)
> +
>  #ifdef CONFIG_NUMA
>  int sysctl_vm_numa_stat = ENABLE_NUMA_STAT;
>  
> @@ -394,7 +396,11 @@ void __inc_node_state(struct pglist_data *pgdat, enum node_stat_item item)
>  	s16 v, t;
>  
>  	v = __this_cpu_inc_return(*p);
> -	t = __this_cpu_read(pcp->stat_threshold);
> +	if (item >= NR_VM_NUMA_STAT_ITEMS)
> +		t = __this_cpu_read(pcp->stat_threshold);
> +	else
> +		t = VM_NUMA_STAT_THRESHOLD;
> +
>  	if (unlikely(v > t)) {
>  		s16 overstep = t >> 1;
>  
> @@ -549,7 +555,10 @@ static inline void mod_node_state(struct pglist_data *pgdat,
>  		 * Most of the time the thresholds are the same anyways
>  		 * for all cpus in a node.
>  		 */
> -		t = this_cpu_read(pcp->stat_threshold);
> +		if (item >= NR_VM_NUMA_STAT_ITEMS)
> +			t = this_cpu_read(pcp->stat_threshold);
> +		else
> +			t = VM_NUMA_STAT_THRESHOLD;
>  
>  		o = this_cpu_read(*p);
>  		n = delta + o;
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
