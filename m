Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 35E196B0003
	for <linux-mm@kvack.org>; Wed, 25 Apr 2018 15:38:40 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id x2so432474wmc.3
        for <linux-mm@kvack.org>; Wed, 25 Apr 2018 12:38:40 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i41si2494120ede.346.2018.04.25.12.38.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 25 Apr 2018 12:38:38 -0700 (PDT)
Subject: Re: [PATCH] mm: don't show nr_indirectly_reclaimable in /proc/vmstat
References: <20180425191422.9159-1-guro@fb.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <a2206b6a-1492-39dc-101f-118060083206@suse.cz>
Date: Wed, 25 Apr 2018 21:36:35 +0200
MIME-Version: 1.0
In-Reply-To: <20180425191422.9159-1-guro@fb.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, kernel-team@fb.com, Matthew Wilcox <willy@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>

On 04/25/2018 09:14 PM, Roman Gushchin wrote:
> Don't show nr_indirectly_reclaimable in /proc/vmstat,
> because there is no need in exporting this vm counter
> to the userspace, and some changes are expected
> in reclaimable object accounting, which can alter
> this counter.

Oh, you beat me to it, thanks.

> Signed-off-by: Roman Gushchin <guro@fb.com>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: Matthew Wilcox <willy@infradead.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Alexander Viro <viro@zeniv.linux.org.uk>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

Andrew, can you send this to Linus before the current rc period ends,
please?

Thanks,
Vlastimil

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
> 
