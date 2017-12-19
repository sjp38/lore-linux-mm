Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id BA07D6B0038
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 02:53:26 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id f8so12235619pgs.9
        for <linux-mm@kvack.org>; Mon, 18 Dec 2017 23:53:26 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v132si2732923pgb.599.2017.12.18.23.53.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 18 Dec 2017 23:53:25 -0800 (PST)
Date: Tue, 19 Dec 2017 08:52:18 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v3 05/10] writeback: add counters for metadata usage
Message-ID: <20171219075218.GB2277@quack2.suse.cz>
References: <1513029335-5112-1-git-send-email-josef@toxicpanda.com>
 <1513029335-5112-6-git-send-email-josef@toxicpanda.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1513029335-5112-6-git-send-email-josef@toxicpanda.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josef Bacik <josef@toxicpanda.com>
Cc: hannes@cmpxchg.org, linux-mm@kvack.org, akpm@linux-foundation.org, jack@suse.cz, linux-fsdevel@vger.kernel.org, kernel-team@fb.com, linux-btrfs@vger.kernel.org, Josef Bacik <jbacik@fb.com>

On Mon 11-12-17 16:55:30, Josef Bacik wrote:
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 356a814e7c8e..48de090f5a07 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -179,9 +179,19 @@ enum node_stat_item {
>  	NR_VMSCAN_IMMEDIATE,	/* Prioritise for reclaim when writeback ends */
>  	NR_DIRTIED,		/* page dirtyings since bootup */
>  	NR_WRITTEN,		/* page writings since bootup */
> +	NR_METADATA_DIRTY_BYTES,	/* Metadata dirty bytes */
> +	NR_METADATA_WRITEBACK_BYTES,	/* Metadata writeback bytes */
> +	NR_METADATA_BYTES,	/* total metadata bytes in use. */
>  	NR_VM_NODE_STAT_ITEMS
>  };

Please add here something like: "Warning: These counters will overflow on
32-bit machines if we ever have more than 2G of metadata on such machine!
But kernel won't be able to address that easily either so it should not be
a real issue."

> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index 4bb13e72ac97..0b32e6381590 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -273,6 +273,13 @@ void __mod_node_page_state(struct pglist_data *pgdat, enum node_stat_item item,
>  
>  	t = __this_cpu_read(pcp->stat_threshold);
>  
> +	/*
> +	 * If this item is counted in bytes and not pages adjust the threshold
> +	 * accordingly.
> +	 */
> +	if (is_bytes_node_stat(item))
> +		t <<= PAGE_SHIFT;
> +
>  	if (unlikely(x > t || x < -t)) {
>  		node_page_state_add(x, pgdat, item);
>  		x = 0;

This is wrong. The per-cpu counters are stored in s8 so you cannot just
bump the threshold. I would just ignore the PCP counters for metadata (I
don't think they are that critical for performance for metadata tracking)
and add to the comment I've suggested above: "Also note that updates to
these counters won't be batched using per-cpu counters since the updates
are generally larger than the counter threshold."

								Honza

-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
