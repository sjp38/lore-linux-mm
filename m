Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id EF3C082F64
	for <linux-mm@kvack.org>; Mon, 12 Oct 2015 08:58:38 -0400 (EDT)
Received: by wicgb1 with SMTP id gb1so148012585wic.1
        for <linux-mm@kvack.org>; Mon, 12 Oct 2015 05:58:38 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u4si15805335wij.17.2015.10.12.05.58.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 12 Oct 2015 05:58:37 -0700 (PDT)
Date: Mon, 12 Oct 2015 14:58:35 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] mm: cleanup balance_dirty_pages() that leave variables
 uninitialized
Message-ID: <20151012125835.GD17050@quack.suse.cz>
References: <1444652698-28292-1-git-send-email-liaotonglang@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1444652698-28292-1-git-send-email-liaotonglang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Liao Tonglang <liaotonglang@gmail.com>
Cc: tj@kernel.org, axboe@fb.com, akpm@linux-foundation.org, jack@suse.cz, hannes@cmpxchg.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 12-10-15 20:24:58, Liao Tonglang wrote:
> Variables m_thresh and m_dirty in function balance_dirty_pages() may use
> uninitialized. GCC throws a warning on it. Fixed by assigned to 0 as
> initial value.

The code is correct - m_dirty & m_thresh gets set & used only if mdtc is
set. So the warning is false positive (and e.g. my gcc doesn't warn). What
gcc version are you using?

								Honza

> 
> Signed-off-by: Liao Tonglang <liaotonglang@gmail.com>
> ---
>  mm/page-writeback.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index 0a931cd..288db45 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -1534,7 +1534,7 @@ static void balance_dirty_pages(struct address_space *mapping,
>  	for (;;) {
>  		unsigned long now = jiffies;
>  		unsigned long dirty, thresh, bg_thresh;
> -		unsigned long m_dirty, m_thresh, m_bg_thresh;
> +		unsigned long m_dirty = 0, m_thresh = 0, m_bg_thresh;
>  
>  		/*
>  		 * Unstable writes are a feature of certain networked
> -- 
> 1.8.3.1
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
