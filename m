Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f181.google.com (mail-ob0-f181.google.com [209.85.214.181])
	by kanga.kvack.org (Postfix) with ESMTP id D82D46B0038
	for <linux-mm@kvack.org>; Fri, 24 Jul 2015 14:54:56 -0400 (EDT)
Received: by obre1 with SMTP id e1so21580930obr.1
        for <linux-mm@kvack.org>; Fri, 24 Jul 2015 11:54:56 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id o6si7455848oig.109.2015.07.24.11.54.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Jul 2015 11:54:56 -0700 (PDT)
Date: Fri, 24 Jul 2015 14:54:51 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCHv2 05/10] xen/balloon: rationalize memory hotplug stats
Message-ID: <20150724185451.GC12824@l.oracle.com>
References: <1437738468-24110-1-git-send-email-david.vrabel@citrix.com>
 <1437738468-24110-6-git-send-email-david.vrabel@citrix.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1437738468-24110-6-git-send-email-david.vrabel@citrix.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Vrabel <david.vrabel@citrix.com>
Cc: xen-devel@lists.xenproject.org, Boris Ostrovsky <boris.ostrovsky@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Daniel Kiper <daniel.kiper@oracle.com>

On Fri, Jul 24, 2015 at 12:47:43PM +0100, David Vrabel wrote:
> The stats used for memory hotplug make no sense and are fiddled with
> in odd ways.  Remove them and introduce total_pages to track the total
> number of pages (both populated and unpopulated) including those within
> hotplugged regions (note that this includes not yet onlined pages).
> 
> This will be used in the following commit when deciding whether

s/the following commit/"xen/balloon: only hotplug additional memory if required"
patch
> additional memory needs to be hotplugged.
> 
> Signed-off-by: David Vrabel <david.vrabel@citrix.com>
> ---
>  drivers/xen/balloon.c | 75 +++++++++------------------------------------------
>  include/xen/balloon.h |  5 +---
>  2 files changed, 13 insertions(+), 67 deletions(-)
> 
> diff --git a/drivers/xen/balloon.c b/drivers/xen/balloon.c
> index 29aeb8f..b5037b1 100644
> --- a/drivers/xen/balloon.c
> +++ b/drivers/xen/balloon.c
> @@ -194,21 +194,6 @@ static enum bp_state update_schedule(enum bp_state state)
>  }
>  
>  #ifdef CONFIG_XEN_BALLOON_MEMORY_HOTPLUG
> -static long current_credit(void)
> -{
> -	return balloon_stats.target_pages - balloon_stats.current_pages -
> -		balloon_stats.hotplug_pages;
> -}
> -
> -static bool balloon_is_inflated(void)
> -{
> -	if (balloon_stats.balloon_low || balloon_stats.balloon_high ||
> -			balloon_stats.balloon_hotplug)
> -		return true;
> -	else
> -		return false;
> -}
> -
>  static struct resource *additional_memory_resource(phys_addr_t size)
>  {
>  	struct resource *res;
> @@ -300,10 +285,7 @@ static enum bp_state reserve_additional_memory(long credit)
>  		goto err;
>  	}
>  
> -	balloon_hotplug -= credit;
> -
> -	balloon_stats.hotplug_pages += credit;
> -	balloon_stats.balloon_hotplug = balloon_hotplug;
> +	balloon_stats.total_pages += balloon_hotplug;
>  
>  	return BP_DONE;
>    err:
> @@ -319,11 +301,6 @@ static void xen_online_page(struct page *page)
>  
>  	__balloon_append(page);
>  
> -	if (balloon_stats.hotplug_pages)
> -		--balloon_stats.hotplug_pages;
> -	else
> -		--balloon_stats.balloon_hotplug;
> -
>  	mutex_unlock(&balloon_mutex);
>  }
>  
> @@ -340,32 +317,22 @@ static struct notifier_block xen_memory_nb = {
>  	.priority = 0
>  };
>  #else
> -static long current_credit(void)
> +static enum bp_state reserve_additional_memory(long credit)
>  {
> -	unsigned long target = balloon_stats.target_pages;
> -
> -	target = min(target,
> -		     balloon_stats.current_pages +
> -		     balloon_stats.balloon_low +
> -		     balloon_stats.balloon_high);
> -
> -	return target - balloon_stats.current_pages;
> +	balloon_stats.target_pages = balloon_stats.current_pages;
> +	return BP_DONE;
>  }
> +#endif /* CONFIG_XEN_BALLOON_MEMORY_HOTPLUG */
>  
> -static bool balloon_is_inflated(void)
> +static long current_credit(void)
>  {
> -	if (balloon_stats.balloon_low || balloon_stats.balloon_high)
> -		return true;
> -	else
> -		return false;
> +	return balloon_stats.target_pages - balloon_stats.current_pages;
>  }
>  
> -static enum bp_state reserve_additional_memory(long credit)
> +static bool balloon_is_inflated(void)
>  {
> -	balloon_stats.target_pages = balloon_stats.current_pages;
> -	return BP_DONE;
> +	return balloon_stats.balloon_low || balloon_stats.balloon_high;
>  }
> -#endif /* CONFIG_XEN_BALLOON_MEMORY_HOTPLUG */
>  
>  static enum bp_state increase_reservation(unsigned long nr_pages)
>  {
> @@ -378,15 +345,6 @@ static enum bp_state increase_reservation(unsigned long nr_pages)
>  		.domid        = DOMID_SELF
>  	};
>  
> -#ifdef CONFIG_XEN_BALLOON_MEMORY_HOTPLUG
> -	if (!balloon_stats.balloon_low && !balloon_stats.balloon_high) {
> -		nr_pages = min(nr_pages, balloon_stats.balloon_hotplug);
> -		balloon_stats.hotplug_pages += nr_pages;
> -		balloon_stats.balloon_hotplug -= nr_pages;
> -		return BP_DONE;
> -	}
> -#endif
> -
>  	if (nr_pages > ARRAY_SIZE(frame_list))
>  		nr_pages = ARRAY_SIZE(frame_list);
>  
> @@ -449,15 +407,6 @@ static enum bp_state decrease_reservation(unsigned long nr_pages, gfp_t gfp)
>  		.domid        = DOMID_SELF
>  	};
>  
> -#ifdef CONFIG_XEN_BALLOON_MEMORY_HOTPLUG
> -	if (balloon_stats.hotplug_pages) {
> -		nr_pages = min(nr_pages, balloon_stats.hotplug_pages);
> -		balloon_stats.hotplug_pages -= nr_pages;
> -		balloon_stats.balloon_hotplug += nr_pages;
> -		return BP_DONE;
> -	}
> -#endif
> -
>  	if (nr_pages > ARRAY_SIZE(frame_list))
>  		nr_pages = ARRAY_SIZE(frame_list);
>  
> @@ -647,6 +596,8 @@ static void __init balloon_add_region(unsigned long start_pfn,
>  		   don't subtract from it. */
>  		__balloon_append(page);
>  	}
> +
> +	balloon_stats.total_pages += extra_pfn_end - start_pfn;
>  }
>  
>  static int __init balloon_init(void)
> @@ -664,6 +615,7 @@ static int __init balloon_init(void)
>  	balloon_stats.target_pages  = balloon_stats.current_pages;
>  	balloon_stats.balloon_low   = 0;
>  	balloon_stats.balloon_high  = 0;
> +	balloon_stats.total_pages   = balloon_stats.current_pages;
>  
>  	balloon_stats.schedule_delay = 1;
>  	balloon_stats.max_schedule_delay = 32;
> @@ -671,9 +623,6 @@ static int __init balloon_init(void)
>  	balloon_stats.max_retry_count = RETRY_UNLIMITED;
>  
>  #ifdef CONFIG_XEN_BALLOON_MEMORY_HOTPLUG
> -	balloon_stats.hotplug_pages = 0;
> -	balloon_stats.balloon_hotplug = 0;
> -
>  	set_online_page_callback(&xen_online_page);
>  	register_memory_notifier(&xen_memory_nb);
>  #endif
> diff --git a/include/xen/balloon.h b/include/xen/balloon.h
> index cc2e1a7..c8aee7a 100644
> --- a/include/xen/balloon.h
> +++ b/include/xen/balloon.h
> @@ -11,14 +11,11 @@ struct balloon_stats {
>  	/* Number of pages in high- and low-memory balloons. */
>  	unsigned long balloon_low;
>  	unsigned long balloon_high;
> +	unsigned long total_pages;
>  	unsigned long schedule_delay;
>  	unsigned long max_schedule_delay;
>  	unsigned long retry_count;
>  	unsigned long max_retry_count;
> -#ifdef CONFIG_XEN_BALLOON_MEMORY_HOTPLUG
> -	unsigned long hotplug_pages;
> -	unsigned long balloon_hotplug;
> -#endif
>  };
>  
>  extern struct balloon_stats balloon_stats;
> -- 
> 2.1.4
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
