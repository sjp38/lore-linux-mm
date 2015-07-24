Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f175.google.com (mail-ob0-f175.google.com [209.85.214.175])
	by kanga.kvack.org (Postfix) with ESMTP id B69E16B0038
	for <linux-mm@kvack.org>; Fri, 24 Jul 2015 14:55:49 -0400 (EDT)
Received: by obbop1 with SMTP id op1so21501600obb.2
        for <linux-mm@kvack.org>; Fri, 24 Jul 2015 11:55:49 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id u4si6848186obn.66.2015.07.24.11.55.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Jul 2015 11:55:49 -0700 (PDT)
Date: Fri, 24 Jul 2015 14:55:45 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCHv2 08/10] xen/balloon: use hotplugged pages for foreign
 mappings etc.
Message-ID: <20150724185545.GD12824@l.oracle.com>
References: <1437738468-24110-1-git-send-email-david.vrabel@citrix.com>
 <1437738468-24110-9-git-send-email-david.vrabel@citrix.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1437738468-24110-9-git-send-email-david.vrabel@citrix.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Vrabel <david.vrabel@citrix.com>
Cc: xen-devel@lists.xenproject.org, Boris Ostrovsky <boris.ostrovsky@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Daniel Kiper <daniel.kiper@oracle.com>

On Fri, Jul 24, 2015 at 12:47:46PM +0100, David Vrabel wrote:
> alloc_xenballooned_pages() is used to get ballooned pages to back
> foreign mappings etc.  Instead of having to balloon out real pages,
> use (if supported) hotplugged memory.
> 
> This makes more memory available to the guest and reduces
> fragmentation in the p2m.
> 
> If userspace is lacking a udev rule (or similar) to online hotplugged

Is that udev rule already in distros?

> regions automatically, alloc_xenballooned_pages() will timeout and
> fall back to the old behaviour of ballooning out pages.
> 
> Signed-off-by: David Vrabel <david.vrabel@citrix.com>
> Reviewed-by: Daniel Kiper <daniel.kiper@oracle.com>
> ---
>  drivers/xen/balloon.c | 32 ++++++++++++++++++++++++++------
>  include/xen/balloon.h |  1 +
>  2 files changed, 27 insertions(+), 6 deletions(-)
> 
> diff --git a/drivers/xen/balloon.c b/drivers/xen/balloon.c
> index cc68a4d..fd6970f3 100644
> --- a/drivers/xen/balloon.c
> +++ b/drivers/xen/balloon.c
> @@ -99,6 +99,7 @@ static xen_pfn_t frame_list[PAGE_SIZE / sizeof(unsigned long)];
>  
>  /* List of ballooned pages, threaded through the mem_map array. */
>  static LIST_HEAD(ballooned_pages);
> +static DECLARE_WAIT_QUEUE_HEAD(balloon_wq);
>  
>  /* Main work function, always executed in process context. */
>  static void balloon_process(struct work_struct *work);
> @@ -127,6 +128,7 @@ static void __balloon_append(struct page *page)
>  		list_add(&page->lru, &ballooned_pages);
>  		balloon_stats.balloon_low++;
>  	}
> +	wake_up(&balloon_wq);
>  }
>  
>  static void balloon_append(struct page *page)
> @@ -253,7 +255,8 @@ static enum bp_state reserve_additional_memory(void)
>  	int nid, rc;
>  	unsigned long balloon_hotplug;
>  
> -	credit = balloon_stats.target_pages - balloon_stats.total_pages;
> +	credit = balloon_stats.target_pages + balloon_stats.target_unpopulated
> +		- balloon_stats.total_pages;
>  
>  	/*
>  	 * Already hotplugged enough pages?  Wait for them to be
> @@ -334,7 +337,7 @@ static struct notifier_block xen_memory_nb = {
>  static enum bp_state reserve_additional_memory(void)
>  {
>  	balloon_stats.target_pages = balloon_stats.current_pages;
> -	return BP_DONE;
> +	return BP_ECANCELED;
>  }
>  #endif /* CONFIG_XEN_BALLOON_MEMORY_HOTPLUG */
>  
> @@ -538,13 +541,31 @@ int alloc_xenballooned_pages(int nr_pages, struct page **pages)
>  {
>  	int pgno = 0;
>  	struct page *page;
> +
>  	mutex_lock(&balloon_mutex);
> +
> +	balloon_stats.target_unpopulated += nr_pages;
> +
>  	while (pgno < nr_pages) {
>  		page = balloon_retrieve(true);
>  		if (page) {
>  			pages[pgno++] = page;
>  		} else {
>  			enum bp_state st;
> +
> +			st = reserve_additional_memory();
> +			if (st != BP_ECANCELED) {
> +				int ret;
> +
> +				mutex_unlock(&balloon_mutex);
> +				ret = wait_event_timeout(balloon_wq,
> +					!list_empty(&ballooned_pages),
> +					msecs_to_jiffies(100));
> +				mutex_lock(&balloon_mutex);
> +				if (ret > 0)
> +					continue;
> +			}
> +
>  			st = decrease_reservation(nr_pages - pgno, GFP_USER);
>  			if (st != BP_DONE)
>  				goto out_undo;
> @@ -553,11 +574,8 @@ int alloc_xenballooned_pages(int nr_pages, struct page **pages)
>  	mutex_unlock(&balloon_mutex);
>  	return 0;
>   out_undo:
> -	while (pgno)
> -		balloon_append(pages[--pgno]);
> -	/* Free the memory back to the kernel soon */
> -	schedule_delayed_work(&balloon_worker, 0);
>  	mutex_unlock(&balloon_mutex);
> +	free_xenballooned_pages(pgno, pages);
>  	return -ENOMEM;
>  }
>  EXPORT_SYMBOL(alloc_xenballooned_pages);
> @@ -578,6 +596,8 @@ void free_xenballooned_pages(int nr_pages, struct page **pages)
>  			balloon_append(pages[i]);
>  	}
>  
> +	balloon_stats.target_unpopulated -= nr_pages;
> +
>  	/* The balloon may be too large now. Shrink it if needed. */
>  	if (current_credit())
>  		schedule_delayed_work(&balloon_worker, 0);
> diff --git a/include/xen/balloon.h b/include/xen/balloon.h
> index 83efdeb..d1767df 100644
> --- a/include/xen/balloon.h
> +++ b/include/xen/balloon.h
> @@ -8,6 +8,7 @@ struct balloon_stats {
>  	/* We aim for 'current allocation' == 'target allocation'. */
>  	unsigned long current_pages;
>  	unsigned long target_pages;
> +	unsigned long target_unpopulated;
>  	/* Number of pages in high- and low-memory balloons. */
>  	unsigned long balloon_low;
>  	unsigned long balloon_high;
> -- 
> 2.1.4
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
