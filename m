Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8117E6B0312
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 04:31:04 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id a72-v6so13126622pfj.14
        for <linux-mm@kvack.org>; Wed, 31 Oct 2018 01:31:04 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a61-v6si27398926pla.430.2018.10.31.01.31.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Oct 2018 01:31:03 -0700 (PDT)
Subject: Re: [PATCH] mm: hide incomplete nr_indirectly_reclaimable in
 /proc/zoneinfo
References: <20181030174649.16778-1-guro@fb.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <8596268b-7bd1-16c4-ad06-31c3114528bb@suse.cz>
Date: Wed, 31 Oct 2018 09:12:16 +0100
MIME-Version: 1.0
In-Reply-To: <20181030174649.16778-1-guro@fb.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>
Cc: Yongqin Liu <yongqin.liu@linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Kernel Team <Kernel-team@fb.com>, Andrew Morton <akpm@linux-foundation.org>

On 10/30/18 6:48 PM, Roman Gushchin wrote:
> Yongqin reported that /proc/zoneinfo format is broken in 4.14
> due to commit 7aaf77272358 ("mm: don't show nr_indirectly_reclaimable
> in /proc/vmstat")
> 
> Node 0, zone      DMA
>   per-node stats
>       nr_inactive_anon 403
>       nr_active_anon 89123
>       nr_inactive_file 128887
>       nr_active_file 47377
>       nr_unevictable 2053
>       nr_slab_reclaimable 7510
>       nr_slab_unreclaimable 10775
>       nr_isolated_anon 0
>       nr_isolated_file 0
>       <...>
>       nr_vmscan_write 0
>       nr_vmscan_immediate_reclaim 0
>       nr_dirtied   6022
>       nr_written   5985
>                    74240
>       ^^^^^^^^^^
>   pages free     131656
> 
> The problem is caused by the nr_indirectly_reclaimable counter,
> which is hidden from the /proc/vmstat, but not from the
> /proc/zoneinfo. Let's fix this inconsistency and hide the
> counter from /proc/zoneinfo exactly as from /proc/vmstat.

Ooops, good catch.

> BTW, in 4.19+ the counter has been renamed and exported by
> the commit b29940c1abd7 ("mm: rename and change semantics of
> nr_indirectly_reclaimable_bytes"), so there is no such a problem
> anymore.

Yeah and that commit depends on introducing a new set kmalloc
reclaimable caches, which is definitely not a stable material, so a
stable-only patch seems to be the only option.

> Cc: <stable@vger.kernel.org> # 4.14.x-4.18.x
> Fixes: 7aaf77272358 ("mm: don't show nr_indirectly_reclaimable in /proc/vmstat")
> Reported-by: Yongqin Liu <yongqin.liu@linaro.org>
> Signed-off-by: Roman Gushchin <guro@fb.com>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: Andrew Morton <akpm@linux-foundation.org>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>  mm/vmstat.c | 4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index 527ae727d547..6389e876c7a7 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -1500,6 +1500,10 @@ static void zoneinfo_show_print(struct seq_file *m, pg_data_t *pgdat,
>  	if (is_zone_first_populated(pgdat, zone)) {
>  		seq_printf(m, "\n  per-node stats");
>  		for (i = 0; i < NR_VM_NODE_STAT_ITEMS; i++) {
> +			/* Skip hidden vmstat items. */
> +			if (*vmstat_text[i + NR_VM_ZONE_STAT_ITEMS +
> +					 NR_VM_NUMA_STAT_ITEMS] == '\0')
> +				continue;
>  			seq_printf(m, "\n      %-12s %lu",
>  				vmstat_text[i + NR_VM_ZONE_STAT_ITEMS +
>  				NR_VM_NUMA_STAT_ITEMS],
> 
