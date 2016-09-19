Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id A54D26B0069
	for <linux-mm@kvack.org>; Mon, 19 Sep 2016 02:56:24 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id y6so30944879lff.0
        for <linux-mm@kvack.org>; Sun, 18 Sep 2016 23:56:24 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r134si18157713wmd.40.2016.09.18.23.56.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 18 Sep 2016 23:56:23 -0700 (PDT)
Date: Mon, 19 Sep 2016 08:56:22 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: More OOM problems
Message-ID: <20160919065622.GB10785@dhcp22.suse.cz>
References: <CA+55aFwu30Yz52yW+MRHt_JgpqZkq4DHdWR-pX4+gO_OK7agCQ@mail.gmail.com>
 <6aa81fe3-7f04-78d7-d477-609a7acd351a@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6aa81fe3-7f04-78d7-d477-609a7acd351a@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, Markus Trippelsdorf <markus@trippelsdorf.de>, Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>, Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>, Jiri Slaby <jslaby@suse.com>, Olaf Hering <olaf@aepfle.de>, Joonsoo Kim <js1304@gmail.com>, linux-mm <linux-mm@kvack.org>

On Mon 19-09-16 00:00:24, Vlastimil Babka wrote:
[...]
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index a2214c64ed3c..9b3b3a79c58a 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3347,17 +3347,24 @@ should_reclaim_retry(gfp_t gfp_mask, unsigned order,
>  					ac->nodemask) {
>  		unsigned long available;
>  		unsigned long reclaimable;
> +		int check_order = order;
> +		unsigned long watermark = min_wmark_pages(zone);
>  
>  		available = reclaimable = zone_reclaimable_pages(zone);
>  		available -= DIV_ROUND_UP(no_progress_loops * available,
>  					  MAX_RECLAIM_RETRIES);
>  		available += zone_page_state_snapshot(zone, NR_FREE_PAGES);
>  
> +		if (order > 0 && order <= PAGE_ALLOC_COSTLY_ORDER) {
> +			check_order = 0;
> +			watermark += 1UL << order;
> +		}
> +
>  		/*
>  		 * Would the allocation succeed if we reclaimed the whole
>  		 * available?
>  		 */
> -		if (__zone_watermark_ok(zone, order, min_wmark_pages(zone),
> +		if (__zone_watermark_ok(zone, check_order, watermark,
>  				ac_classzone_idx(ac), alloc_flags, available)) {
>  			/*
>  			 * If we didn't make any progress and have a lot of

Joonsoo was suggesting something like this before and I really hated
that. We can very well just not invoke the OOM killer for those requests
at all and rely on a smaller order request to trigger it for us. But
who knows maybe we will have no other option and bite the bullet and
declare the defeat and do something special for !costly orders.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
