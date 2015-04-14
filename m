Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 770C36B006E
	for <linux-mm@kvack.org>; Tue, 14 Apr 2015 16:00:08 -0400 (EDT)
Received: by wizk4 with SMTP id k4so127929977wiz.1
        for <linux-mm@kvack.org>; Tue, 14 Apr 2015 13:00:08 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id jj4si22071640wid.55.2015.04.14.13.00.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 14 Apr 2015 13:00:06 -0700 (PDT)
Message-ID: <552D71C6.1020503@suse.cz>
Date: Tue, 14 Apr 2015 22:00:06 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: mm/compaction.c:250:13: warning: 'suitable_migration_target'
 defined but not used
References: <201504141443.QeT7AHmI%fengguang.wu@intel.com> <20150414125449.f97ea3286a90a55531d25924@linux-foundation.org>
In-Reply-To: <20150414125449.f97ea3286a90a55531d25924@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, kbuild test robot <fengguang.wu@intel.com>
Cc: kbuild-all@01.org, Linux Memory Management List <linux-mm@kvack.org>, Fabian Frederick <fabf@skynet.be>

On 14.4.2015 21:54, Andrew Morton wrote:
> On Tue, 14 Apr 2015 14:53:45 +0800 kbuild test robot <fengguang.wu@intel.com> wrote:
> 
>> tree:   git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
>> head:   b79013b2449c23f1f505bdf39c5a6c330338b244
>> commit: f8224aa5a0a4627926019bba7511926393fbee3b mm, compaction: do not recheck suitable_migration_target under lock
>> date:   6 months ago
>> config: x86_64-randconfig-ib0-04141359 (attached as .config)
>> reproduce:
>>   git checkout f8224aa5a0a4627926019bba7511926393fbee3b
>>   # save the attached .config to linux build tree
>>   make ARCH=x86_64 
>>
>> All warnings:
>>
>>>> mm/compaction.c:250:13: warning: 'suitable_migration_target' defined but not used [-Wunused-function]
>>     static bool suitable_migration_target(struct page *page)
>>                 ^
> 
> Easy enough - it only has one callsite.

This sounded familiar, and sure enough I found patch from January
https://lkml.org/lkml/2015/1/13/589

That was v2 after I suggested a subjectively better placement of the function
when v1 placed it as your patch IIRC. But whatever.

> 
> --- a/mm/compaction.c~mm-compactionc-fix-suitable_migration_target-unused-warning
> +++ a/mm/compaction.c
> @@ -391,28 +391,6 @@ static inline bool compact_should_abort(
>  	return false;
>  }
>  
> -/* Returns true if the page is within a block suitable for migration to */
> -static bool suitable_migration_target(struct page *page)
> -{
> -	/* If the page is a large free page, then disallow migration */
> -	if (PageBuddy(page)) {
> -		/*
> -		 * We are checking page_order without zone->lock taken. But
> -		 * the only small danger is that we skip a potentially suitable
> -		 * pageblock, so it's not worth to check order for valid range.
> -		 */
> -		if (page_order_unsafe(page) >= pageblock_order)
> -			return false;
> -	}
> -
> -	/* If the block is MIGRATE_MOVABLE or MIGRATE_CMA, allow migration */
> -	if (migrate_async_suitable(get_pageblock_migratetype(page)))
> -		return true;
> -
> -	/* Otherwise skip the block */
> -	return false;
> -}
> -
>  /*
>   * Isolate free pages onto a private freelist. If @strict is true, will abort
>   * returning 0 on any invalid PFNs or non-free pages inside of the pageblock
> @@ -896,6 +874,29 @@ isolate_migratepages_range(struct compac
>  
>  #endif /* CONFIG_COMPACTION || CONFIG_CMA */
>  #ifdef CONFIG_COMPACTION
> +
> +/* Returns true if the page is within a block suitable for migration to */
> +static bool suitable_migration_target(struct page *page)
> +{
> +	/* If the page is a large free page, then disallow migration */
> +	if (PageBuddy(page)) {
> +		/*
> +		 * We are checking page_order without zone->lock taken. But
> +		 * the only small danger is that we skip a potentially suitable
> +		 * pageblock, so it's not worth to check order for valid range.
> +		 */
> +		if (page_order_unsafe(page) >= pageblock_order)
> +			return false;
> +	}
> +
> +	/* If the block is MIGRATE_MOVABLE or MIGRATE_CMA, allow migration */
> +	if (migrate_async_suitable(get_pageblock_migratetype(page)))
> +		return true;
> +
> +	/* Otherwise skip the block */
> +	return false;
> +}
> +
>  /*
>   * Based on information in the current compact_control, find blocks
>   * suitable for isolating free pages from and then isolate them.
> _
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
