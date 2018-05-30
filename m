Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id 472E16B0003
	for <linux-mm@kvack.org>; Wed, 30 May 2018 12:05:31 -0400 (EDT)
Received: by mail-yw0-f197.google.com with SMTP id f186-v6so8637154ywb.5
        for <linux-mm@kvack.org>; Wed, 30 May 2018 09:05:31 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g203-v6sor9966426ybg.114.2018.05.30.09.05.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 30 May 2018 09:05:30 -0700 (PDT)
Date: Wed, 30 May 2018 09:05:27 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 05/13] swap,blkcg: issue swap io with the appropriate
 context
Message-ID: <20180530160527.GM1351649@devbig577.frc2.facebook.com>
References: <20180529211724.4531-1-josef@toxicpanda.com>
 <20180529211724.4531-6-josef@toxicpanda.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180529211724.4531-6-josef@toxicpanda.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josef Bacik <josef@toxicpanda.com>
Cc: axboe@kernel.dk, kernel-team@fb.com, linux-block@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org

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

So, this ignores the cases where bdev_write_page() is the one which
does the writes.  If my reading is correct, only brd, zram, btt and
pmem implement bdev_ops->rw_page() and take bdev_write_page() path, so
it shouldn't be a problem in majority of cases.

I don't think we need to address ->rw_page() case right now but it
might be a good idea to add a comment explaining the ommission.

Thanks.

-- 
tejun
