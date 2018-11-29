Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id C0C0B6B52A4
	for <linux-mm@kvack.org>; Thu, 29 Nov 2018 07:52:32 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id h11so1372787pfj.13
        for <linux-mm@kvack.org>; Thu, 29 Nov 2018 04:52:32 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id b91si2309972plb.11.2018.11.29.04.52.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Nov 2018 04:52:31 -0800 (PST)
Date: Thu, 29 Nov 2018 13:52:28 +0100
From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH] mm: hide incomplete nr_indirectly_reclaimable in
 /proc/zoneinfo
Message-ID: <20181129125228.GN3149@kroah.com>
References: <20181030174649.16778-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181030174649.16778-1-guro@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: "stable@vger.kernel.org" <stable@vger.kernel.org>, Yongqin Liu <yongqin.liu@linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Kernel Team <Kernel-team@fb.com>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>

On Tue, Oct 30, 2018 at 05:48:25PM +0000, Roman Gushchin wrote:
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
> 
> BTW, in 4.19+ the counter has been renamed and exported by
> the commit b29940c1abd7 ("mm: rename and change semantics of
> nr_indirectly_reclaimable_bytes"), so there is no such a problem
> anymore.
> 
> Cc: <stable@vger.kernel.org> # 4.14.x-4.18.x
> Fixes: 7aaf77272358 ("mm: don't show nr_indirectly_reclaimable in /proc/vmstat")
> Reported-by: Yongqin Liu <yongqin.liu@linaro.org>
> Signed-off-by: Roman Gushchin <guro@fb.com>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: Andrew Morton <akpm@linux-foundation.org>
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
> -- 
> 2.17.2
> 

I do not see this patch in Linus's tree, do you?

If not, what am I supposed to do with this?

confused,

greg k-h
