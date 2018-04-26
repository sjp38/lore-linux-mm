Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 64A586B0005
	for <linux-mm@kvack.org>; Thu, 26 Apr 2018 16:03:34 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id c56-v6so27659025wrc.5
        for <linux-mm@kvack.org>; Thu, 26 Apr 2018 13:03:34 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 89si6324103edh.72.2018.04.26.13.03.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 26 Apr 2018 13:03:33 -0700 (PDT)
Date: Thu, 26 Apr 2018 22:03:31 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: don't show nr_indirectly_reclaimable in /proc/vmstat
Message-ID: <20180426200331.GZ17484@dhcp22.suse.cz>
References: <20180425191422.9159-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180425191422.9159-1-guro@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, kernel-team@fb.com, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Johannes Weiner <hannes@cmpxchg.org>

On Wed 25-04-18 20:14:22, Roman Gushchin wrote:
> Don't show nr_indirectly_reclaimable in /proc/vmstat,
> because there is no need in exporting this vm counter
> to the userspace, and some changes are expected
> in reclaimable object accounting, which can alter
> this counter.
> 
> Signed-off-by: Roman Gushchin <guro@fb.com>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: Matthew Wilcox <willy@infradead.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Alexander Viro <viro@zeniv.linux.org.uk>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>

This is quite a hack. I would much rather revert the counter and fixed
it the way Vlastimil has proposed. But if there is a strong opposition
to the revert then this is probably the simples thing to do. Therefore

Unhappy-Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/vmstat.c | 6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index 536332e988b8..a2b9518980ce 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -1161,7 +1161,7 @@ const char * const vmstat_text[] = {
>  	"nr_vmscan_immediate_reclaim",
>  	"nr_dirtied",
>  	"nr_written",
> -	"nr_indirectly_reclaimable",
> +	"", /* nr_indirectly_reclaimable */
>  
>  	/* enum writeback_stat_item counters */
>  	"nr_dirty_threshold",
> @@ -1740,6 +1740,10 @@ static int vmstat_show(struct seq_file *m, void *arg)
>  	unsigned long *l = arg;
>  	unsigned long off = l - (unsigned long *)m->private;
>  
> +	/* Skip hidden vmstat items. */
> +	if (*vmstat_text[off] == '\0')
> +		return 0;
> +
>  	seq_puts(m, vmstat_text[off]);
>  	seq_put_decimal_ull(m, " ", *l);
>  	seq_putc(m, '\n');
> -- 
> 2.14.3

-- 
Michal Hocko
SUSE Labs
