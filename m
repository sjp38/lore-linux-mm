Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2E3F48E00AE
	for <linux-mm@kvack.org>; Thu,  3 Jan 2019 22:29:56 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id f18so16522292wrt.1
        for <linux-mm@kvack.org>; Thu, 03 Jan 2019 19:29:56 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id r127si18612wmf.152.2019.01.03.19.29.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 03 Jan 2019 19:29:54 -0800 (PST)
Subject: Re: [PATCH] mm: Remove sysctl_extfrag_handler
References: <20190104032557.3056-1-willy@infradead.org>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <8b4fa422-8a98-0705-cdb2-0521f2a1923e@infradead.org>
Date: Thu, 3 Jan 2019 19:29:42 -0800
MIME-Version: 1.0
In-Reply-To: <20190104032557.3056-1-willy@infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Aditya Pakki <pakki001@umn.edu>, Mel Gorman <mgorman@techsingularity.net>

On 1/3/19 7:25 PM, Matthew Wilcox wrote:
> The sysctl_extfrag_handler function neglects to propagate the return
> value from proc_dointvec_minmax() to its caller.  It's a wrapper that
> doesn't need to exist, so just use proc_dointvec_minmax directly.
> 
> Reported-by: Aditya Pakki <pakki001@umn.edu>
> Signed-off-by: Matthew Wilcox <willy@infradead.org>
> Acked-by: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Randy Dunlap <rdunlap@infradead.org>

Thanks.

> ---
>  include/linux/compaction.h | 2 --
>  kernel/sysctl.c            | 2 +-
>  mm/compaction.c            | 8 --------
>  3 files changed, 1 insertion(+), 11 deletions(-)
> 
> diff --git a/include/linux/compaction.h b/include/linux/compaction.h
> index 68250a57aace..70d0256edd31 100644
> --- a/include/linux/compaction.h
> +++ b/include/linux/compaction.h
> @@ -88,8 +88,6 @@ extern int sysctl_compact_memory;
>  extern int sysctl_compaction_handler(struct ctl_table *table, int write,
>  			void __user *buffer, size_t *length, loff_t *ppos);
>  extern int sysctl_extfrag_threshold;
> -extern int sysctl_extfrag_handler(struct ctl_table *table, int write,
> -			void __user *buffer, size_t *length, loff_t *ppos);
>  extern int sysctl_compact_unevictable_allowed;
>  
>  extern int fragmentation_index(struct zone *zone, unsigned int order);
> diff --git a/kernel/sysctl.c b/kernel/sysctl.c
> index 5fc724e4e454..e9c69247fc29 100644
> --- a/kernel/sysctl.c
> +++ b/kernel/sysctl.c
> @@ -1439,7 +1439,7 @@ static struct ctl_table vm_table[] = {
>  		.data		= &sysctl_extfrag_threshold,
>  		.maxlen		= sizeof(int),
>  		.mode		= 0644,
> -		.proc_handler	= sysctl_extfrag_handler,
> +		.proc_handler	= proc_dointvec_minmax,
>  		.extra1		= &min_extfrag_threshold,
>  		.extra2		= &max_extfrag_threshold,
>  	},
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 7c607479de4a..80b941d9b6e7 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -1876,14 +1876,6 @@ int sysctl_compaction_handler(struct ctl_table *table, int write,
>  	return 0;
>  }
>  
> -int sysctl_extfrag_handler(struct ctl_table *table, int write,
> -			void __user *buffer, size_t *length, loff_t *ppos)
> -{
> -	proc_dointvec_minmax(table, write, buffer, length, ppos);
> -
> -	return 0;
> -}
> -
>  #if defined(CONFIG_SYSFS) && defined(CONFIG_NUMA)
>  static ssize_t sysfs_compact_node(struct device *dev,
>  			struct device_attribute *attr,
> 


-- 
~Randy
