Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f46.google.com (mail-pb0-f46.google.com [209.85.160.46])
	by kanga.kvack.org (Postfix) with ESMTP id E030F6B0031
	for <linux-mm@kvack.org>; Wed, 18 Jun 2014 18:27:54 -0400 (EDT)
Received: by mail-pb0-f46.google.com with SMTP id md12so1196520pbc.33
        for <linux-mm@kvack.org>; Wed, 18 Jun 2014 15:27:54 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id ps5si3568000pbb.80.2014.06.18.15.27.53
        for <linux-mm@kvack.org>;
        Wed, 18 Jun 2014 15:27:54 -0700 (PDT)
Date: Wed, 18 Jun 2014 15:27:51 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/vmscan.c: fix an implementation flaw in proportional
 scanning
Message-Id: <20140618152751.283deda95257cc32ccea8f20@linux-foundation.org>
In-Reply-To: <1402980902-6345-1-git-send-email-slaoub@gmail.com>
References: <1402980902-6345-1-git-send-email-slaoub@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Yucong <slaoub@gmail.com>
Cc: minchan@kernel.org, mgorman@suse.de, hannes@cmpxchg.org, mhocko@suse.cz, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 17 Jun 2014 12:55:02 +0800 Chen Yucong <slaoub@gmail.com> wrote:

> Via https://lkml.org/lkml/2013/4/10/897, we can know that the relative design
> idea is to keep
> 
>     scan_target[anon] : scan_target[file]
>         == really_scanned_num[anon] : really_scanned_num[file]
> 
> But we can find the following snippet in shrink_lruvec():
> 
>     if (nr_file > nr_anon) {
>         ...
>     } else {
>         ...
>     }
> 
> However, the above code fragment broke the design idea. We can assume:
> 
>       nr[LRU_ACTIVE_FILE] = 30
>       nr[LRU_INACTIVE_FILE] = 30
>       nr[LRU_ACTIVE_ANON] = 0
>       nr[LRU_INACTIVE_ANON] = 40
> 
> When the value of (nr_reclaimed < nr_to_reclaim) become false, there are
> the following results:
> 
>       nr[LRU_ACTIVE_FILE] = 15
>       nr[LRU_INACTIVE_FILE] = 15
>       nr[LRU_ACTIVE_ANON] = 0
>       nr[LRU_INACTIVE_ANON] = 25
>       nr_file = 30
>       nr_anon = 25
>       file_percent = 30 / 60 = 0.5
>       anon_percent = 25 / 40 = 0.65
> 
> According to the above design idea, we should scan some pages from ANON,
> but in fact we execute the an error code path due to "if (nr_file > nr_anon)".
> In this way, nr[lru] is likely to be a negative number. Luckily,
> "nr[lru] -= min(nr[lru], nr_scanned)" can help us to filter this situation,
> but it has rebelled against our design idea.

Mel, could you please pencil in some time to look at this one?

Perhaps before doing that you could suggest what sort of testing might
help us understand any runtime effects from this fix.

> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index a8ffe4e..2c35e34 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2087,8 +2086,8 @@ static void shrink_lruvec(struct lruvec *lruvec, struct scan_control *sc)
>  	blk_start_plug(&plug);
>  	while (nr[LRU_INACTIVE_ANON] || nr[LRU_ACTIVE_FILE] ||
>  					nr[LRU_INACTIVE_FILE]) {
> -		unsigned long nr_anon, nr_file, percentage;
> -		unsigned long nr_scanned;
> +		unsigned long nr_anon, nr_file, file_percent, anon_percent;
> +		unsigned long nr_to_scan, nr_scanned, percentage;
>  
>  		for_each_evictable_lru(lru) {
>  			if (nr[lru]) {

The increased stack use is a slight concern - we can be very deep here.
I suspect the "percent" locals are more for convenience/clarity, and
they could be eliminated (in a separate patch) at some cost of clarity?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
