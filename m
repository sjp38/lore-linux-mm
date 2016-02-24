Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 43CD76B0005
	for <linux-mm@kvack.org>; Wed, 24 Feb 2016 16:33:44 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id yy13so19322063pab.3
        for <linux-mm@kvack.org>; Wed, 24 Feb 2016 13:33:44 -0800 (PST)
Received: from mail-pf0-x22d.google.com (mail-pf0-x22d.google.com. [2607:f8b0:400e:c00::22d])
        by mx.google.com with ESMTPS id yp9si7318231pab.121.2016.02.24.13.33.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Feb 2016 13:33:43 -0800 (PST)
Received: by mail-pf0-x22d.google.com with SMTP id x65so19820402pfb.1
        for <linux-mm@kvack.org>; Wed, 24 Feb 2016 13:33:43 -0800 (PST)
Date: Wed, 24 Feb 2016 13:33:41 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm, memory hotplug: print more failure information for
 online_pages
In-Reply-To: <1456300925-20415-1-git-send-email-slaoub@gmail.com>
Message-ID: <alpine.DEB.2.10.1602241331570.5955@chino.kir.corp.google.com>
References: <1456300925-20415-1-git-send-email-slaoub@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Yucong <slaoub@gmail.com>
Cc: akpm@linux-foundation.org, vbabka@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 24 Feb 2016, Chen Yucong wrote:

> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index c832ef3..e4b6dec3 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1059,10 +1059,9 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
>  
>  	ret = memory_notify(MEM_GOING_ONLINE, &arg);
>  	ret = notifier_to_errno(ret);
> -	if (ret) {
> -		memory_notify(MEM_CANCEL_ONLINE, &arg);
> -		return ret;
> -	}
> +	if (ret)
> +		goto failed_addition;
> +
>  	/*
>  	 * If this zone is not populated, then it is not in zonelist.
>  	 * This means the page allocator ignores this zone.
> @@ -1080,12 +1079,7 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
>  		if (need_zonelists_rebuild)
>  			zone_pcp_reset(zone);
>  		mutex_unlock(&zonelists_mutex);
> -		printk(KERN_DEBUG "online_pages [mem %#010llx-%#010llx] failed\n",
> -		       (unsigned long long) pfn << PAGE_SHIFT,
> -		       (((unsigned long long) pfn + nr_pages)
> -			    << PAGE_SHIFT) - 1);
> -		memory_notify(MEM_CANCEL_ONLINE, &arg);
> -		return ret;
> +		goto failed_addition;
>  	}
>  
>  	zone->present_pages += onlined_pages;
> @@ -1118,6 +1112,13 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
>  	if (onlined_pages)
>  		memory_notify(MEM_ONLINE, &arg);
>  	return 0;
> +
> +failed_addition:
> +	pr_info("online_pages [mem %#010llx-%#010llx] failed\n",
> +		(unsigned long long) pfn << PAGE_SHIFT,
> +		(((unsigned long long) pfn + nr_pages) << PAGE_SHIFT) - 1);
> +	memory_notify(MEM_CANCEL_ONLINE, &arg);
> +	return ret;
>  }
>  #endif /* CONFIG_MEMORY_HOTPLUG_SPARSE */
>  

Please explain how the conversion from KERN_DEBUG to KERN_INFO level is 
better?

If the onlining returns an error value, which it will, why do we need to 
leave an artifact behind in the kernel log that it failed?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
