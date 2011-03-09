Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 9955D8D0039
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 15:15:27 -0500 (EST)
Date: Wed, 9 Mar 2011 15:14:03 -0500
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [Xen-devel] [PATCH R4 7/7] xen/balloon: Memory hotplug support
 for Xen balloon driver
Message-ID: <20110309201403.GJ8049@dumpdata.com>
References: <20110308215049.GH27331@router-fw-old.local.net-space.pl>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110308215049.GH27331@router-fw-old.local.net-space.pl>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Kiper <dkiper@net-space.pl>
Cc: ian.campbell@citrix.com, akpm@linux-foundation.org, andi.kleen@intel.com, haicheng.li@linux.intel.com, fengguang.wu@intel.com, jeremy@goop.org, dan.magenheimer@oracle.com, v.tolstov@selfip.ru, pasik@iki.fi, dave@linux.vnet.ibm.com, wdauchy@gmail.com, rientjes@google.com, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

> -		credit = current_target() - balloon_stats.current_pages;
> +		credit = current_credit();
>  
> -		if (credit > 0)
> -			state = increase_reservation(credit);
> +		if (credit > 0) {
> +			if (balloon_is_inflated())
> +				state = increase_reservation(credit);
> +			else
> +				state = reserve_additional_memory(credit);
> +		}

This code manipulation of where the current_target becomes current_credit
(and that logic) should be split off in its own patch.

Otherwise all the patches that touch Xen code look good.
>  
>  		if (credit < 0)
>  			state = decrease_reservation(-credit);
> @@ -458,6 +594,14 @@ static int __init balloon_init(void)
>  	balloon_stats.retry_count = 1;
>  	balloon_stats.max_retry_count = 16;
>  
> +#ifdef CONFIG_XEN_BALLOON_MEMORY_HOTPLUG
> +	balloon_stats.hotplug_pages = 0;
> +	balloon_stats.balloon_hotplug = 0;
> +
> +	register_online_page_notifier(&xen_online_page_nb);
> +	register_memory_notifier(&xen_memory_nb);
> +#endif
> +
>  	register_balloon(&balloon_sysdev);
>  
>  	/*
> -- 
> 1.5.6.5
> 
> _______________________________________________
> Xen-devel mailing list
> Xen-devel@lists.xensource.com
> http://lists.xensource.com/xen-devel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
