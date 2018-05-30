Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 05DE36B0006
	for <linux-mm@kvack.org>; Wed, 30 May 2018 09:04:44 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id v2-v6so12964777wmc.0
        for <linux-mm@kvack.org>; Wed, 30 May 2018 06:04:43 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id g42-v6si1319234edg.360.2018.05.30.06.04.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 30 May 2018 06:04:42 -0700 (PDT)
Date: Wed, 30 May 2018 09:06:48 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 05/13] swap,blkcg: issue swap io with the appropriate
 context
Message-ID: <20180530130648.GA4035@cmpxchg.org>
References: <20180529211724.4531-1-josef@toxicpanda.com>
 <20180529211724.4531-6-josef@toxicpanda.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180529211724.4531-6-josef@toxicpanda.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josef Bacik <josef@toxicpanda.com>
Cc: axboe@kernel.dk, kernel-team@fb.com, linux-block@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, tj@kernel.org, linux-fsdevel@vger.kernel.org

On Tue, May 29, 2018 at 05:17:16PM -0400, Josef Bacik wrote:
> From: Tejun Heo <tj@kernel.org>
> 
> For backcharging we need to know who the page belongs to when swapping
> it out.
> 
> Signed-off-by: Tejun Heo <tj@kernel.org>
> Signed-off-by: Josef Bacik <jbacik@fb.com>
> ---
>  mm/page_io.c | 10 ++++++++++
>  1 file changed, 10 insertions(+)
> 
> diff --git a/mm/page_io.c b/mm/page_io.c
> index a552cb37e220..61e1268e5dbc 100644
> --- a/mm/page_io.c
> +++ b/mm/page_io.c
> @@ -339,6 +339,16 @@ int __swap_writepage(struct page *page, struct writeback_control *wbc,
>  		goto out;
>  	}
>  	bio->bi_opf = REQ_OP_WRITE | REQ_SWAP | wbc_to_write_flags(wbc);
> +#if defined(CONFIG_MEMCG) && defined(CONFIG_BLK_CGROUP)
> +	if (page->mem_cgroup) {
> +		struct cgroup_subsys_state *blkcg_css;
> +
> +		blkcg_css = cgroup_get_e_css(page->mem_cgroup->css.cgroup,
> +					     &io_cgrp_subsys);
> +		bio_associate_blkcg(bio, blkcg_css);
> +		css_put(blkcg_css);
> +	}
> +#endif

This looks reasonable, but it probably warrants a helper function.

bio_associate_blkcg_from_page() or something?
