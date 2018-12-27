Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id BA1068E0001
	for <linux-mm@kvack.org>; Thu, 27 Dec 2018 11:44:56 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id 202so17950545pgb.6
        for <linux-mm@kvack.org>; Thu, 27 Dec 2018 08:44:56 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id h19si33219281pgb.231.2018.12.27.08.44.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 27 Dec 2018 08:44:55 -0800 (PST)
Subject: Re: [PATCH] mm: compaction.c: Propagate return value upstream
References: <20181226194257.11038-1-pakki001@umn.edu>
 <20181227035029.GE20878@bombadil.infradead.org>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <6af3b9ee-34c9-ba6d-f4c0-2c8e21b0550e@infradead.org>
Date: Thu, 27 Dec 2018 08:44:45 -0800
MIME-Version: 1.0
In-Reply-To: <20181227035029.GE20878@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Aditya Pakki <pakki001@umn.edu>
Cc: kjlu@umn.edu, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Yang Shi <yang.shi@linux.alibaba.com>, Johannes Weiner <hannes@cmpxchg.org>, Joe Perches <joe@perches.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@techsingularity.net>

On 12/26/18 7:50 PM, Matthew Wilcox wrote:
> On Wed, Dec 26, 2018 at 01:42:56PM -0600, Aditya Pakki wrote:
>> In sysctl_extfrag_handler(), proc_dointvec_minmax() can return an
>> error. The fix propagates the error upstream in case of failure.
> 
> Why not just ...

Yes, this change (below) makes sense to me.

> Mel, Randy?  You seem to have been the prime instigators on this.

I expect that all I did was move the location of the source code lines of
the sysctl, but that is just a guess, based on this commit message:
  [randy.dunlap@oracle.com: Fix build errors when proc fs is not configured]

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
