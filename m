Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id DC2D36B0033
	for <linux-mm@kvack.org>; Thu, 26 Oct 2017 09:54:10 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id 15so2849325pgc.21
        for <linux-mm@kvack.org>; Thu, 26 Oct 2017 06:54:10 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j17si3010064pll.365.2017.10.26.06.54.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 26 Oct 2017 06:54:09 -0700 (PDT)
Date: Thu, 26 Oct 2017 15:54:05 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] bdi: add check before create debugfs dir or files
Message-ID: <20171026135405.GC31161@quack2.suse.cz>
References: <20171025152312.GA23944@source.didichuxing.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171025152312.GA23944@source.didichuxing.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: weiping zhang <zhangweiping@didichuxing.com>
Cc: axboe@kernel.dk, jack@suse.cz, linux-mm@kvack.org

On Wed 25-10-17 23:23:18, weiping zhang wrote:
> we should make sure parents directory exist, and then create dir or
> files under that.
> 
> Signed-off-by: weiping zhang <zhangweiping@didichuxing.com>

OK, this looks reasonable to me but instead of instead of just leaving
debugfs in half-initialized state, we should rather properly tear it down,
return error from bdi_debug_register() and handle it in
bdi_register_va()...

								hONZA

> ---
>  mm/backing-dev.c | 8 +++++---
>  1 file changed, 5 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/backing-dev.c b/mm/backing-dev.c
> index 74b52dfd5852..81f4a86ebbed 100644
> --- a/mm/backing-dev.c
> +++ b/mm/backing-dev.c
> @@ -115,9 +115,11 @@ static const struct file_operations bdi_debug_stats_fops = {
>  
>  static void bdi_debug_register(struct backing_dev_info *bdi, const char *name)
>  {
> -	bdi->debug_dir = debugfs_create_dir(name, bdi_debug_root);
> -	bdi->debug_stats = debugfs_create_file("stats", 0444, bdi->debug_dir,
> -					       bdi, &bdi_debug_stats_fops);
> +	if (bdi_debug_root)
> +		bdi->debug_dir = debugfs_create_dir(name, bdi_debug_root);
> +	if (bdi->debug_dir)
> +		bdi->debug_stats = debugfs_create_file("stats", 0444,
> +				bdi->debug_dir, bdi, &bdi_debug_stats_fops);
>  }
>  
>  static void bdi_debug_unregister(struct backing_dev_info *bdi)
> -- 
> 2.14.2
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
