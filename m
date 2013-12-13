Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f43.google.com (mail-pb0-f43.google.com [209.85.160.43])
	by kanga.kvack.org (Postfix) with ESMTP id 6B7646B0035
	for <linux-mm@kvack.org>; Thu, 12 Dec 2013 22:11:01 -0500 (EST)
Received: by mail-pb0-f43.google.com with SMTP id rq2so1706539pbb.2
        for <linux-mm@kvack.org>; Thu, 12 Dec 2013 19:11:01 -0800 (PST)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id wm3si392356pab.107.2013.12.12.19.10.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 12 Dec 2013 19:11:00 -0800 (PST)
Message-ID: <52AA7A40.2030106@huawei.com>
Date: Fri, 13 Dec 2013 11:08:48 +0800
From: Jianguo Wu <wujianguo@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] mm/memory-failure.c: recheck PageHuge() after hugetlb
 page migrate successfully
References: <52AA5E60.3090207@huawei.com> <1386901949-fkz2l9bl-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1386901949-fkz2l9bl-mutt-n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mgorman@suse.de>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Hanjun Guo <guohanjun@huawei.com>, qiuxishi <qiuxishi@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, gong.chen@linux.intel.com

Hi,

On 2013/12/13 10:32, Naoya Horiguchi wrote:

> On Fri, Dec 13, 2013 at 09:09:52AM +0800, Jianguo Wu wrote:
>> After a successful hugetlb page migration by soft offline, the source page
>> will either be freed into hugepage_freelists or buddy(over-commit page). If page is in
>> buddy, page_hstate(page) will be NULL. It will hit a NULL pointer
>> dereference in dequeue_hwpoisoned_huge_page().
>>
>> [  890.677918] BUG: unable to handle kernel NULL pointer dereference at
>>  0000000000000058
>> [  890.685741] IP: [<ffffffff81163761>]
>> dequeue_hwpoisoned_huge_page+0x131/0x1d0
>> [  890.692861] PGD c23762067 PUD c24be2067 PMD 0
>> [  890.697314] Oops: 0000 [#1] SMP
>>
>> So check PageHuge(page) after call migrate_pages() successfully.
>>
>> Tested-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>> Cc: stable@vger.kernel.org
>> Signed-off-by: Jianguo Wu <wujianguo@huawei.com>
>> ---
>>  mm/memory-failure.c | 19 ++++++++++++++-----
>>  1 file changed, 14 insertions(+), 5 deletions(-)
>>
>> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
>> index b7c1716..e5567f2 100644
>> --- a/mm/memory-failure.c
>> +++ b/mm/memory-failure.c
>> @@ -1471,7 +1471,8 @@ static int get_any_page(struct page *page, unsigned long pfn, int flags)
>>  
>>  static int soft_offline_huge_page(struct page *page, int flags)
>>  {
>> -	int ret;
>> +	int ret, i;
>> +	unsigned long nr_pages;
>>  	unsigned long pfn = page_to_pfn(page);
>>  	struct page *hpage = compound_head(page);
>>  	LIST_HEAD(pagelist);
>> @@ -1489,6 +1490,8 @@ static int soft_offline_huge_page(struct page *page, int flags)
>>  	}
>>  	unlock_page(hpage);
>>  
>> +	nr_pages = 1 << compound_order(hpage);
>> +
>>  	/* Keep page count to indicate a given hugepage is isolated. */
>>  	list_move(&hpage->lru, &pagelist);
>>  	ret = migrate_pages(&pagelist, new_page, MPOL_MF_MOVE_ALL,
>> @@ -1505,10 +1508,16 @@ static int soft_offline_huge_page(struct page *page, int flags)
>>  		if (ret > 0)
>>  			ret = -EIO;
>>  	} else {
>> -		set_page_hwpoison_huge_page(hpage);
>> -		dequeue_hwpoisoned_huge_page(hpage);
>> -		atomic_long_add(1 << compound_order(hpage),
>> -				&num_poisoned_pages);
>> +		/* overcommit hugetlb page will be freed to buddy */
>> +		if (PageHuge(page)) {
>> +			set_page_hwpoison_huge_page(hpage);
>> +			dequeue_hwpoisoned_huge_page(hpage);
>> +		} else {
>> +			for (i = 0; i < nr_pages; i++)
>> +				SetPageHWPoison(hpage + i);
> 
> Why don't you set PageHWPoison only on the error raw page instead
> of the whole error hugepage, or is there some problem of doing so?
> 

Oh, yes, we should only poison the error raw page. I will resend a new version.

Thanks,
Jianguo Wu

> Thanks,
> Naoya
> 
>> +		}
>> +
>> +		atomic_long_add(nr_pages, &num_poisoned_pages);
>>  	}
>>  	return ret;
>>  }
>> -- 
>> 1.8.2.2
>>
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>>
> 
> .
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
