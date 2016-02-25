Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1FDE06B0005
	for <linux-mm@kvack.org>; Wed, 24 Feb 2016 20:07:32 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id yy13so22108875pab.3
        for <linux-mm@kvack.org>; Wed, 24 Feb 2016 17:07:32 -0800 (PST)
Received: from mail-pf0-x234.google.com (mail-pf0-x234.google.com. [2607:f8b0:400e:c00::234])
        by mx.google.com with ESMTPS id lf12si8411683pab.207.2016.02.24.17.07.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Feb 2016 17:07:31 -0800 (PST)
Received: by mail-pf0-x234.google.com with SMTP id e127so22638955pfe.3
        for <linux-mm@kvack.org>; Wed, 24 Feb 2016 17:07:31 -0800 (PST)
Message-ID: <1456362446.22049.20.camel@gmail.com>
Subject: Re: [PATCH] mm, memory hotplug: print more failure information for
 online_pages
From: Chen Yucong <slaoub@gmail.com>
Date: Thu, 25 Feb 2016 09:07:26 +0800
In-Reply-To: <alpine.DEB.2.10.1602241331570.5955@chino.kir.corp.google.com>
References: <1456300925-20415-1-git-send-email-slaoub@gmail.com>
	 <alpine.DEB.2.10.1602241331570.5955@chino.kir.corp.google.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: akpm@linux-foundation.org, vbabka@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 2016-02-24 at 13:33 -0800, David Rientjes wrote:
> On Wed, 24 Feb 2016, Chen Yucong wrote:
> 
> > diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> > index c832ef3..e4b6dec3 100644
> > --- a/mm/memory_hotplug.c
> > +++ b/mm/memory_hotplug.c
> > @@ -1059,10 +1059,9 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
> >  
> >  	ret = memory_notify(MEM_GOING_ONLINE, &arg);
> >  	ret = notifier_to_errno(ret);
> > -	if (ret) {
> > -		memory_notify(MEM_CANCEL_ONLINE, &arg);
> > -		return ret;
> > -	}
> > +	if (ret)
> > +		goto failed_addition;
> > +
> >  	/*
> >  	 * If this zone is not populated, then it is not in zonelist.
> >  	 * This means the page allocator ignores this zone.
> > @@ -1080,12 +1079,7 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
> >  		if (need_zonelists_rebuild)
> >  			zone_pcp_reset(zone);
> >  		mutex_unlock(&zonelists_mutex);
> > -		printk(KERN_DEBUG "online_pages [mem %#010llx-%#010llx] failed\n",
> > -		       (unsigned long long) pfn << PAGE_SHIFT,
> > -		       (((unsigned long long) pfn + nr_pages)
> > -			    << PAGE_SHIFT) - 1);
> > -		memory_notify(MEM_CANCEL_ONLINE, &arg);
> > -		return ret;
> > +		goto failed_addition;
> >  	}
> >  
> >  	zone->present_pages += onlined_pages;
> > @@ -1118,6 +1112,13 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
> >  	if (onlined_pages)
> >  		memory_notify(MEM_ONLINE, &arg);
> >  	return 0;
> > +
> > +failed_addition:
> > +	pr_info("online_pages [mem %#010llx-%#010llx] failed\n",
> > +		(unsigned long long) pfn << PAGE_SHIFT,
> > +		(((unsigned long long) pfn + nr_pages) << PAGE_SHIFT) - 1);
> > +	memory_notify(MEM_CANCEL_ONLINE, &arg);
> > +	return ret;
> >  }
> >  #endif /* CONFIG_MEMORY_HOTPLUG_SPARSE */
> >  
> 
> Please explain how the conversion from KERN_DEBUG to KERN_INFO level is 
> better?

Like __offline_pages(), printk() in online_pages() is used for reporting
an failed addition rather than debug information.
Another reason is that pr_debug() is not an exact equivalent of 
printk(KERN_DEBUG ...)

/* If you are writing a driver, please use dev_dbg instead */
#if defined(CONFIG_DYNAMIC_DEBUG)
/* dynamic_pr_debug() uses pr_fmt() internally so we don't need it here
*/
#define pr_debug(fmt, ...) \
        dynamic_pr_debug(fmt, ##__VA_ARGS__)
#elif defined(DEBUG)
#define pr_debug(fmt, ...) \
        printk(KERN_DEBUG pr_fmt(fmt), ##__VA_ARGS__)
#else
#define pr_debug(fmt, ...) \
        no_printk(KERN_DEBUG pr_fmt(fmt), ##__VA_ARGS__)
#endif
 

> If the onlining returns an error value, which it will, why do we need to 
> leave an artifact behind in the kernel log that it failed?

In __offline_pages(), we can find the following snippet:

...
        ret = memory_notify(MEM_GOING_OFFLINE, &arg);
        ret = notifier_to_errno(ret);
        if (ret)
                goto failed_removal;
...
        offlined_pages = check_pages_isolated(start_pfn, end_pfn);
        if (offlined_pages < 0) {
                ret = -EBUSY;
                goto failed_removal;
        }
...
failed_removal:
        printk(KERN_INFO "memory offlining [mem %#010llx-%#010llx] 
...

Similarly, there's no single cause for failed online_pages operation.
So if memory_notify(MEM_GOING_ONLINE, &arg) returns an error
value, the result of online_pages is also ""online_pages [mem %#010llx-%
#010llx] failed\n".

thx!
    cyc



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
