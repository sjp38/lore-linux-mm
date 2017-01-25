Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 55EAE6B0033
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 07:01:20 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id t18so37081934wmt.7
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 04:01:20 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y22si22136449wmh.29.2017.01.25.04.01.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 25 Jan 2017 04:01:19 -0800 (PST)
Date: Wed, 25 Jan 2017 13:01:15 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/migration: make isolate_movable_page always defined
Message-ID: <20170125120115.GL32377@dhcp22.suse.cz>
References: <1485340563-60785-1-git-send-email-xieyisheng1@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1485340563-60785-1-git-send-email-xieyisheng1@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yisheng Xie <xieyisheng1@huawei.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, n-horiguchi@ah.jp.nec.com, akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, guohanjun@huawei.com, qiuxishi@huawei.com

On Wed 25-01-17 18:36:03, Yisheng Xie wrote:
> Define isolate_movable_page as a static inline function when
> CONFIG_MIGRATION is not enable. It should return false
> here which means failed to isolate movable pages.
> 
> This patch do not have any functional change but to resolve compile
> error caused by former commit "HWPOISON: soft offlining for non-lru
> movable page" with CONFIG_MIGRATION disabled.
> 
> Signed-off-by: Yisheng Xie <xieyisheng1@huawei.com>
> ---
>  include/linux/migrate.h | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/include/linux/migrate.h b/include/linux/migrate.h
> index ae8d475..631a8c8 100644
> --- a/include/linux/migrate.h
> +++ b/include/linux/migrate.h
> @@ -56,6 +56,8 @@ static inline int migrate_pages(struct list_head *l, new_page_t new,
>  		free_page_t free, unsigned long private, enum migrate_mode mode,
>  		int reason)
>  	{ return -ENOSYS; }
> +static inline bool isolate_movable_page(struct page *page, isolate_mode_t mode)
> +	{ return false; }

OK, so we return false here which will make __soft_offline_page return
true all the way up. Is this really what we want? Don't we want to
return EBUSY in that case? The error code propagation here is just
one big mess.

>  
>  static inline int migrate_prep(void) { return -ENOSYS; }
>  static inline int migrate_prep_local(void) { return -ENOSYS; }
> -- 
> 1.7.12.4
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
