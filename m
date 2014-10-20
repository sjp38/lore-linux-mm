Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 9A5A36B0069
	for <linux-mm@kvack.org>; Mon, 20 Oct 2014 15:45:09 -0400 (EDT)
Received: by mail-wg0-f44.google.com with SMTP id y10so6180216wgg.3
        for <linux-mm@kvack.org>; Mon, 20 Oct 2014 12:45:09 -0700 (PDT)
Received: from mail-wg0-x22c.google.com (mail-wg0-x22c.google.com. [2a00:1450:400c:c00::22c])
        by mx.google.com with ESMTPS id ba6si2206078wib.32.2014.10.20.12.45.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 20 Oct 2014 12:45:08 -0700 (PDT)
Received: by mail-wg0-f44.google.com with SMTP id y10so6243355wgg.27
        for <linux-mm@kvack.org>; Mon, 20 Oct 2014 12:45:07 -0700 (PDT)
Date: Mon, 20 Oct 2014 21:45:05 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch] mm: memcontrol: clarify migration where old page is
 uncharged
Message-ID: <20141020194505.GE505@dhcp22.suse.cz>
References: <1413732647-16043-1-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1413732647-16043-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Sun 19-10-14 11:30:47, Johannes Weiner wrote:
> Better explain re-entrant migration when compaction races with
> reclaim, and also mention swapcache readahead pages as possible
> uncharged migration sources.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/memcontrol.c | 7 ++++++-
>  1 file changed, 6 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index fc1d7ca96b9d..76892eb89d26 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -6166,7 +6166,12 @@ void mem_cgroup_migrate(struct page *oldpage, struct page *newpage,
>  	if (PageCgroupUsed(pc))
>  		return;
>  
> -	/* Re-entrant migration: old page already uncharged? */
> +	/*
> +	 * Swapcache readahead pages can get migrated before being
> +	 * charged, and migration from compaction can happen to an
> +	 * uncharged page when the PFN walker finds a page that
> +	 * reclaim just put back on the LRU but has not released yet.
> +	 */
>  	pc = lookup_page_cgroup(oldpage);
>  	if (!PageCgroupUsed(pc))
>  		return;
> -- 
> 2.1.2
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
