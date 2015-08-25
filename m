Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 15E206B0253
	for <linux-mm@kvack.org>; Tue, 25 Aug 2015 04:32:56 -0400 (EDT)
Received: by wicja10 with SMTP id ja10so7542298wic.1
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 01:32:55 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id sc17si37531308wjb.23.2015.08.25.01.32.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 25 Aug 2015 01:32:54 -0700 (PDT)
Date: Tue, 25 Aug 2015 10:32:49 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] mm/backing-dev: Check return value of the
 debugfs_create_dir()
Message-ID: <20150825083249.GB8823@quack.suse.cz>
References: <1440489263-3547-1-git-send-email-kuleshovmail@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1440489263-3547-1-git-send-email-kuleshovmail@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Kuleshov <kuleshovmail@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 25-08-15 13:54:23, Alexander Kuleshov wrote:
> The debugfs_create_dir() function may fail and return error. If the
> root directory not created, we can't create anything inside it. This
> patch adds check for this case.
> 
> Signed-off-by: Alexander Kuleshov <kuleshovmail@gmail.com>

The patch looks good to me. You can add:

Reviewed-by: Jan Kara <jack@suse.com>

								Honza
> ---
>  mm/backing-dev.c | 16 +++++++++++-----
>  1 file changed, 11 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/backing-dev.c b/mm/backing-dev.c
> index dac5bf5..518d26a 100644
> --- a/mm/backing-dev.c
> +++ b/mm/backing-dev.c
> @@ -117,15 +117,21 @@ static const struct file_operations bdi_debug_stats_fops = {
>  
>  static void bdi_debug_register(struct backing_dev_info *bdi, const char *name)
>  {
> -	bdi->debug_dir = debugfs_create_dir(name, bdi_debug_root);
> -	bdi->debug_stats = debugfs_create_file("stats", 0444, bdi->debug_dir,
> -					       bdi, &bdi_debug_stats_fops);
> +	if (bdi_debug_root) {
> +		bdi->debug_dir = debugfs_create_dir(name, bdi_debug_root);
> +		if (bdi->debug_dir)
> +			bdi->debug_stats = debugfs_create_file("stats", 0444,
> +							bdi->debug_dir, bdi,
> +							&bdi_debug_stats_fops);
> +	}
>  }
>  
>  static void bdi_debug_unregister(struct backing_dev_info *bdi)
>  {
> -	debugfs_remove(bdi->debug_stats);
> -	debugfs_remove(bdi->debug_dir);
> +	if (bdi_debug_root) {
> +		debugfs_remove(bdi->debug_stats);
> +		debugfs_remove(bdi->debug_dir);
> +	}
>  }
>  #else
>  static inline void bdi_debug_init(void)
> -- 
> 2.5.0
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
