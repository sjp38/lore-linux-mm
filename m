Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id C896C6B0007
	for <linux-mm@kvack.org>; Wed, 31 Jan 2018 02:15:32 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id h5so10043832pgv.21
        for <linux-mm@kvack.org>; Tue, 30 Jan 2018 23:15:32 -0800 (PST)
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-bn3nam01on0071.outbound.protection.outlook.com. [104.47.33.71])
        by mx.google.com with ESMTPS id q16si1114779pfg.163.2018.01.30.23.15.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 30 Jan 2018 23:15:31 -0800 (PST)
Subject: Re: [PATCH] mm/swap: add function get_total_swap_pages to expose
 total_swap_pages
References: <1517214582-30880-1-git-send-email-Hongbo.He@amd.com>
From: Chunming Zhou <zhoucm1@amd.com>
Message-ID: <9ecba5f4-3d4c-0179-bf03-f89c436cff6b@amd.com>
Date: Wed, 31 Jan 2018 15:15:19 +0800
MIME-Version: 1.0
In-Reply-To: <1517214582-30880-1-git-send-email-Hongbo.He@amd.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roger He <Hongbo.He@amd.com>, dri-devel@lists.freedesktop.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christian.Koenig@amd.com

Hi Roger,

I think this patch isn't need at all. You can directly read 
total_swap_pages variable in TTM. See the comment:

/* protected with swap_lock. reading in vm_swap_full() doesn't need lock */
long total_swap_pages;

there are many places using it directly, you just couldn't change its 
value. Reading it doesn't need lock.


Regards,

David Zhou


On 2018a1'01ae??29ae?JPY 16:29, Roger He wrote:
> ttm module needs it to determine its internal parameter setting.
>
> Signed-off-by: Roger He <Hongbo.He@amd.com>
> ---
>   include/linux/swap.h |  6 ++++++
>   mm/swapfile.c        | 15 +++++++++++++++
>   2 files changed, 21 insertions(+)
>
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index c2b8128..708d66f 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -484,6 +484,7 @@ extern int try_to_free_swap(struct page *);
>   struct backing_dev_info;
>   extern int init_swap_address_space(unsigned int type, unsigned long nr_pages);
>   extern void exit_swap_address_space(unsigned int type);
> +extern long get_total_swap_pages(void);
>   
>   #else /* CONFIG_SWAP */
>   
> @@ -516,6 +517,11 @@ static inline void show_swap_cache_info(void)
>   {
>   }
>   
> +long get_total_swap_pages(void)
> +{
> +	return 0;
> +}
> +
>   #define free_swap_and_cache(e) ({(is_migration_entry(e) || is_device_private_entry(e));})
>   #define swapcache_prepare(e) ({(is_migration_entry(e) || is_device_private_entry(e));})
>   
> diff --git a/mm/swapfile.c b/mm/swapfile.c
> index 3074b02..a0062eb 100644
> --- a/mm/swapfile.c
> +++ b/mm/swapfile.c
> @@ -98,6 +98,21 @@ static atomic_t proc_poll_event = ATOMIC_INIT(0);
>   
>   atomic_t nr_rotate_swap = ATOMIC_INIT(0);
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
>   static inline unsigned char swap_count(unsigned char ent)
>   {
>   	return ent & ~SWAP_HAS_CACHE;	/* may include SWAP_HAS_CONT flag */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
