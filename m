Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5758D6B0003
	for <linux-mm@kvack.org>; Wed, 25 Apr 2018 15:37:29 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id g15so14308306pfi.8
        for <linux-mm@kvack.org>; Wed, 25 Apr 2018 12:37:29 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g2sor4304847pgf.284.2018.04.25.12.37.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 25 Apr 2018 12:37:28 -0700 (PDT)
Date: Wed, 25 Apr 2018 12:37:26 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: don't show nr_indirectly_reclaimable in
 /proc/vmstat
In-Reply-To: <20180425191422.9159-1-guro@fb.com>
Message-ID: <alpine.DEB.2.21.1804251235330.151692@chino.kir.corp.google.com>
References: <20180425191422.9159-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, kernel-team@fb.com, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>

On Wed, 25 Apr 2018, Roman Gushchin wrote:

> Don't show nr_indirectly_reclaimable in /proc/vmstat,
> because there is no need in exporting this vm counter
> to the userspace, and some changes are expected
> in reclaimable object accounting, which can alter
> this counter.
> 

I don't think it should be a per-node vmstat, in this case.  It appears 
only to be used for the global context.  Shouldn't this be handled like 
totalram_pages, total_swap_pages, totalreserve_pages, etc?

> Signed-off-by: Roman Gushchin <guro@fb.com>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: Matthew Wilcox <willy@infradead.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Alexander Viro <viro@zeniv.linux.org.uk>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
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
