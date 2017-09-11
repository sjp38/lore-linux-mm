Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5602C6B02EC
	for <linux-mm@kvack.org>; Mon, 11 Sep 2017 16:15:10 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id v109so9785752wrc.5
        for <linux-mm@kvack.org>; Mon, 11 Sep 2017 13:15:10 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f128si2998332wmg.252.2017.09.11.13.15.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 11 Sep 2017 13:15:09 -0700 (PDT)
Date: Mon, 11 Sep 2017 22:15:06 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] mm/backing-dev.c: fix an error handling path in
 'cgwb_create()'
Message-ID: <20170911201506.GA15044@quack2.suse.cz>
References: <20170911194323.17833-1-christophe.jaillet@wanadoo.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170911194323.17833-1-christophe.jaillet@wanadoo.fr>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Cc: axboe@fb.com, jack@suse.cz, tj@kernel.org, geliangtang@gmail.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org

On Mon 11-09-17 21:43:23, Christophe JAILLET wrote:
> If the 'kmalloc' fails, we must go through the existing error handling
> path.
> 
> Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>

Looks good to me. You can add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  mm/backing-dev.c | 6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/backing-dev.c b/mm/backing-dev.c
> index f028a9a472fd..e19606bb41a0 100644
> --- a/mm/backing-dev.c
> +++ b/mm/backing-dev.c
> @@ -569,8 +569,10 @@ static int cgwb_create(struct backing_dev_info *bdi,
>  
>  	/* need to create a new one */
>  	wb = kmalloc(sizeof(*wb), gfp);
> -	if (!wb)
> -		return -ENOMEM;
> +	if (!wb) {
> +		ret = -ENOMEM;
> +		goto out_put;
> +	}
>  
>  	ret = wb_init(wb, bdi, blkcg_css->id, gfp);
>  	if (ret)
> -- 
> 2.11.0
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
