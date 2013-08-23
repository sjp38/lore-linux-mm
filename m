Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 149146B003B
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 20:03:34 -0400 (EDT)
Received: from /spool/local
	by e28smtp03.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Fri, 23 Aug 2013 05:25:47 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 3982B1258054
	for <linux-mm@kvack.org>; Fri, 23 Aug 2013 05:33:16 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7N054UV40042504
	for <linux-mm@kvack.org>; Fri, 23 Aug 2013 05:35:04 +0530
Received: from d28av02.in.ibm.com (localhost [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r7N03SHs005908
	for <linux-mm@kvack.org>; Fri, 23 Aug 2013 05:33:28 +0530
Date: Fri, 23 Aug 2013 08:03:27 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH 6/6] mm/hwpoison: centralize set PG_hwpoison flag and
 increase num_poisoned_pages
Message-ID: <20130823000327.GC17669@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1377164907-24801-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1377164907-24801-6-git-send-email-liwanp@linux.vnet.ibm.com>
 <1377202401-mrb1wzdx-mutt-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1377202401-mrb1wzdx-mutt-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Fengguang Wu <fengguang.wu@intel.com>, Tony Luck <tony.luck@intel.com>, gong.chen@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Naoya,
On Thu, Aug 22, 2013 at 04:13:21PM -0400, Naoya Horiguchi wrote:
>On Thu, Aug 22, 2013 at 05:48:27PM +0800, Wanpeng Li wrote:
>> soft_offline_page will invoke __soft_offline_page for in-use normal pages 
>> and soft_offline_huge_page for in-use hugetlbfs pages. Both of them will 
>> done the same effort as for soft offline free pages set PG_hwpoison, increase 
>> num_poisoned_pages etc, this patch centralize do them in soft_offline_page.
>> 
>> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
>> ---
>>  mm/memory-failure.c | 16 ++++------------
>>  1 file changed, 4 insertions(+), 12 deletions(-)
>> 
>> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
>> index 0a52571..3226de1 100644
>> --- a/mm/memory-failure.c
>> +++ b/mm/memory-failure.c
>> @@ -1486,15 +1486,9 @@ static int soft_offline_huge_page(struct page *page, int flags)
>>  	ret = migrate_huge_page(hpage, new_page, MPOL_MF_MOVE_ALL,
>>  				MIGRATE_SYNC);
>>  	put_page(hpage);
>> -	if (ret) {
>> +	if (ret)
>>  		pr_info("soft offline: %#lx: migration failed %d, type %lx\n",
>>  			pfn, ret, page->flags);
>> -	} else {
>> -		set_page_hwpoison_huge_page(hpage);
>> -		dequeue_hwpoisoned_huge_page(hpage);
>> -		atomic_long_add(1 << compound_order(hpage),
>> -				&num_poisoned_pages);
>> -	}
>>  	return ret;
>>  }
>>  
>> @@ -1530,8 +1524,6 @@ static int __soft_offline_page(struct page *page, int flags)
>>  	if (ret == 1) {
>>  		put_page(page);
>>  		pr_info("soft_offline: %#lx: invalidated\n", pfn);
>> -		SetPageHWPoison(page);
>> -		atomic_long_inc(&num_poisoned_pages);
>>  		return 0;
>>  	}
>>  
>> @@ -1572,11 +1564,9 @@ static int __soft_offline_page(struct page *page, int flags)
>>  				lru_add_drain_all();
>>  			if (!is_free_buddy_page(page))
>>  				drain_all_pages();
>> -			SetPageHWPoison(page);
>>  			if (!is_free_buddy_page(page))
>>  				pr_info("soft offline: %#lx: page leaked\n",
>>  					pfn);
>> -			atomic_long_inc(&num_poisoned_pages);
>>  		}
>>  	} else {
>>  		pr_info("soft offline: %#lx: isolation failed: %d, page count %d, type %lx\n",
>
>This change does not simply clean up code, but affects the behavior.
>This memory leak check should come after SetPageHWPoison().
>

Thanks for pointing out. ;-)

Regards,
Wanpeng Li 

>Thanks,
>Naoya Horiguchi
>
>> @@ -1633,7 +1623,9 @@ int soft_offline_page(struct page *page, int flags)
>>  			ret = soft_offline_huge_page(page, flags);
>>  		else
>>  			ret = __soft_offline_page(page, flags);
>> -	} else { /* for free pages */
>> +	}
>> +
>> +	if (!ret) {
>>  		if (PageHuge(page)) {
>>  			set_page_hwpoison_huge_page(hpage);
>>  			dequeue_hwpoisoned_huge_page(hpage);
>> -- 
>> 1.8.1.2
>> 
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>>
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
