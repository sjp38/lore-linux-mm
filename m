Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id 7A4D66B0036
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 19:52:47 -0400 (EDT)
Received: from /spool/local
	by e28smtp05.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Fri, 23 Aug 2013 05:16:15 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id E98881258053
	for <linux-mm@kvack.org>; Fri, 23 Aug 2013 05:22:29 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7MNsH1H40829000
	for <linux-mm@kvack.org>; Fri, 23 Aug 2013 05:24:18 +0530
Received: from d28av01.in.ibm.com (localhost [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r7MNqfA9030341
	for <linux-mm@kvack.org>; Fri, 23 Aug 2013 05:22:41 +0530
Date: Fri, 23 Aug 2013 07:52:40 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH 3/6] mm/hwpoison: fix num_poisoned_pages error statistics
 for thp
Message-ID: <20130822235239.GA17669@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1377164907-24801-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1377164907-24801-3-git-send-email-liwanp@linux.vnet.ibm.com>
 <1377189788-xv5ewgmb-mutt-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1377189788-xv5ewgmb-mutt-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Fengguang Wu <fengguang.wu@intel.com>, Tony Luck <tony.luck@intel.com>, gong.chen@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Naoya,
On Thu, Aug 22, 2013 at 12:43:08PM -0400, Naoya Horiguchi wrote:
>On Thu, Aug 22, 2013 at 05:48:24PM +0800, Wanpeng Li wrote:
>> There is a race between hwpoison page and unpoison page, memory_failure 
>> set the page hwpoison and increase num_poisoned_pages without hold page 
>> lock, and one page count will be accounted against thp for num_poisoned_pages.
>> However, unpoison can occur before memory_failure hold page lock and 
>> split transparent hugepage, unpoison will decrease num_poisoned_pages 
>> by 1 << compound_order since memory_failure has not yet split transparent 
>> hugepage with page lock held. That means we account one page for hwpoison
>> and 1 << compound_order for unpoison. This patch fix it by decrease one 
>> account for num_poisoned_pages against no hugetlbfs pages case.
>> 
>> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
>
>I think that a thp never becomes hwpoisoned without splitting, so "trying
>to unpoison thp" never happens (I think that this implicit fact should be

There is a race window here for hwpoison thp: 

				A	  			 									B
		memory_failue 
		TestSetPageHWPoison(p);
		if (PageHuge(p))
			nr_pages = 1 << compound_order(hpage);
		else 
			nr_pages = 1;
		atomic_long_add(nr_pages, &num_poisoned_pages);	
																unpoison_memory
																nr_pages = 1<< compound_trans_order(page;)
																if(TestClearPageHWPoison(p))
																	atomic_long_sub(nr_pages, &num_poisoned_pages);
		lock page 
		if (!PageHWPoison(p))
			unlock page and return 
		hwpoison_user_mappings
		if (PageTransHuge(hpage))
			split_huge_page(hpage);


We increase one page count, however, decrease 1 << compound_trans_order.
The compound_trans_order you mentioned is used here for thp, that's why 
I don't drop it in patch 2/6.

>commented somewhere or asserted with VM_BUG_ON().)

I will add the VM_BUG_ON() in unpoison_memory after lock page in next
version.

>And nr_pages in unpoison_memory() can be greater than 1 for hugetlbfs page.
>So does this patch break counting when unpoisoning free hugetlbfs pages?
>
>Thanks,
>Naoya Horiguchi
>
>> ---
>>  mm/memory-failure.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>> 
>> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
>> index 5092e06..6bfd51e 100644
>> --- a/mm/memory-failure.c
>> +++ b/mm/memory-failure.c
>> @@ -1350,7 +1350,7 @@ int unpoison_memory(unsigned long pfn)
>>  			return 0;
>>  		}
>>  		if (TestClearPageHWPoison(p))
>> -			atomic_long_sub(nr_pages, &num_poisoned_pages);
>> +			atomic_long_dec(&num_poisoned_pages);
>>  		pr_info("MCE: Software-unpoisoned free page %#lx\n", pfn);
>>  		return 0;
>>  	}
>> -- 
>> 1.8.1.2
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
