Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9429F6B0005
	for <linux-mm@kvack.org>; Mon, 29 Jan 2018 11:31:19 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id y18so5933271wrh.12
        for <linux-mm@kvack.org>; Mon, 29 Jan 2018 08:31:19 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c13si10449115wrd.16.2018.01.29.08.31.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 29 Jan 2018 08:31:17 -0800 (PST)
Date: Mon, 29 Jan 2018 17:31:14 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/swap: add function get_total_swap_pages to expose
 total_swap_pages
Message-ID: <20180129163114.GH21609@dhcp22.suse.cz>
References: <1517214582-30880-1-git-send-email-Hongbo.He@amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1517214582-30880-1-git-send-email-Hongbo.He@amd.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roger He <Hongbo.He@amd.com>
Cc: dri-devel@lists.freedesktop.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christian.Koenig@amd.com

On Mon 29-01-18 16:29:42, Roger He wrote:
> ttm module needs it to determine its internal parameter setting.

Could you be more specific why?

> Signed-off-by: Roger He <Hongbo.He@amd.com>
> ---
>  include/linux/swap.h |  6 ++++++
>  mm/swapfile.c        | 15 +++++++++++++++
>  2 files changed, 21 insertions(+)
> 
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index c2b8128..708d66f 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -484,6 +484,7 @@ extern int try_to_free_swap(struct page *);
>  struct backing_dev_info;
>  extern int init_swap_address_space(unsigned int type, unsigned long nr_pages);
>  extern void exit_swap_address_space(unsigned int type);
> +extern long get_total_swap_pages(void);
>  
>  #else /* CONFIG_SWAP */
>  
> @@ -516,6 +517,11 @@ static inline void show_swap_cache_info(void)
>  {
>  }
>  
> +long get_total_swap_pages(void)
> +{
> +	return 0;
> +}
> +
>  #define free_swap_and_cache(e) ({(is_migration_entry(e) || is_device_private_entry(e));})
>  #define swapcache_prepare(e) ({(is_migration_entry(e) || is_device_private_entry(e));})
>  
> diff --git a/mm/swapfile.c b/mm/swapfile.c
> index 3074b02..a0062eb 100644
> --- a/mm/swapfile.c
> +++ b/mm/swapfile.c
> @@ -98,6 +98,21 @@ static atomic_t proc_poll_event = ATOMIC_INIT(0);
>  
>  atomic_t nr_rotate_swap = ATOMIC_INIT(0);
>  
> +/*
> + * expose this value for others use
> + */
> +long get_total_swap_pages(void)
> +{
> +	long ret;
> +
> +	spin_lock(&swap_lock);
> +	ret = total_swap_pages;
> +	spin_unlock(&swap_lock);
> +
> +	return ret;
> +}
> +EXPORT_SYMBOL_GPL(get_total_swap_pages);
> +
>  static inline unsigned char swap_count(unsigned char ent)
>  {
>  	return ent & ~SWAP_HAS_CACHE;	/* may include SWAP_HAS_CONT flag */
> -- 
> 2.7.4

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
