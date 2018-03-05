Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id BB9CC6B0003
	for <linux-mm@kvack.org>; Sun,  4 Mar 2018 20:07:23 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id f4-v6so6238558plr.11
        for <linux-mm@kvack.org>; Sun, 04 Mar 2018 17:07:23 -0800 (PST)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id e6si7617294pgp.492.2018.03.04.17.07.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 04 Mar 2018 17:07:22 -0800 (PST)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -mm] mm: Fix races between swapoff and flush dcache
References: <20180302080426.14588-1-ying.huang@intel.com>
	<20180302131829.7009e1e19f478d55159928de@linux-foundation.org>
Date: Mon, 05 Mar 2018 09:07:17 +0800
In-Reply-To: <20180302131829.7009e1e19f478d55159928de@linux-foundation.org>
	(Andrew Morton's message of "Fri, 2 Mar 2018 13:18:29 -0800")
Message-ID: <877eqr49fe.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, Dave Hansen <dave.hansen@intel.com>, Arnd Bergmann <arnd@arndb.de>, Chen Liqin <liqin.linux@gmail.com>, Russell King <linux@armlinux.org.uk>, Yoshinori Sato <ysato@users.sourceforge.jp>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Guan Xuetao <gxt@mprc.pku.edu.cn>, "David S. Miller" <davem@davemloft.net>, Chris Zankel <chris@zankel.net>, Vineet Gupta <vgupta@synopsys.com>, Ley Foon Tan <lftan@altera.com>, Ralf Baechle <ralf@linux-mips.org>, Andi Kleen <ak@linux.intel.com>

Andrew Morton <akpm@linux-foundation.org> writes:

> On Fri,  2 Mar 2018 16:04:26 +0800 "Huang, Ying" <ying.huang@intel.com> wrote:
>
>> From: Huang Ying <ying.huang@intel.com>
>> 
>> >From commit 4b3ef9daa4fc ("mm/swap: split swap cache into 64MB
>> trunks") on, after swapoff, the address_space associated with the swap
>> device will be freed.  So page_mapping() users which may touch the
>> address_space need some kind of mechanism to prevent the address_space
>> from being freed during accessing.
>> 
>> The dcache flushing functions (flush_dcache_page(), etc) in
>> architecture specific code may access the address_space of swap device
>> for anonymous pages in swap cache via page_mapping() function.  But in
>> some cases there are no mechanisms to prevent the swap device from
>> being swapoff, for example,
>> 
>> CPU1					CPU2
>> __get_user_pages()			swapoff()
>>   flush_dcache_page()
>>     mapping = page_mapping()
>>       ...				  exit_swap_address_space()
>>       ...				    kvfree(spaces)
>>       mapping_mapped(mapping)
>> 
>> The address space may be accessed after being freed.
>> 
>> But from cachetlb.txt and Russell King, flush_dcache_page() only care
>> about file cache pages, for anonymous pages, flush_anon_page() should
>> be used.  The implementation of flush_dcache_page() in all
>> architectures follows this too.  They will check whether
>> page_mapping() is NULL and whether mapping_mapped() is true to
>> determine whether to flush the dcache immediately.  And they will use
>> interval tree (mapping->i_mmap) to find all user space mappings.
>> While mapping_mapped() and mapping->i_mmap isn't used by anonymous
>> pages in swap cache at all.
>> 
>> So, to fix the race between swapoff and flush dcache, __page_mapping()
>> is add to return the address_space for file cache pages and NULL
>> otherwise.  All page_mapping() invoking in flush dcache functions are
>> replaced with __page_mapping().
>> 
>> The patch is only build tested, because I have no machine with
>> architecture other than x86.
>> 
>> ...
>>
>> +/*
>> + * For file cache pages, return the address_space, otherwise return NULL
>> + */
>> +struct address_space *__page_mapping(struct page *page)
>> +{
>> +	struct address_space *mapping;
>> +
>> +	page = compound_head(page);
>> +
>> +	/* This happens if someone calls flush_dcache_page on slab page */
>> +	if (unlikely(PageSlab(page)))
>> +		return NULL;
>> +
>> +	mapping = page->mapping;
>> +	if ((unsigned long)mapping & PAGE_MAPPING_ANON)
>> +		return NULL;
>> +
>> +	return (void *)((unsigned long)mapping & ~PAGE_MAPPING_FLAGS);
>> +}
>> +
>
> I think page_mapping_file() would be a better name.

Thanks!  I will use that name.

> And do we really need to duplicate page_mapping()?  Could it be
>
> struct address_space *page_mapping_file(struct page *page)
> {
> 	if (PageSwapCache(page))
> 		return NULL;
> 	return page_mapping(page);
> }

Yes.  This looks better.

> (We don't need to run compound_head() here, do we?)

Yes.  I think so.

Best Regards,
Huang, Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
