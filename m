Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9B7406B0005
	for <linux-mm@kvack.org>; Tue,  9 Aug 2016 06:37:33 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 63so17523491pfx.0
        for <linux-mm@kvack.org>; Tue, 09 Aug 2016 03:37:33 -0700 (PDT)
Received: from szxga03-in.huawei.com ([119.145.14.66])
        by mx.google.com with ESMTPS id ue10si42087109pab.203.2016.08.09.03.37.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 09 Aug 2016 03:37:32 -0700 (PDT)
Message-ID: <57A9B147.1090003@huawei.com>
Date: Tue, 9 Aug 2016 18:32:39 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: fix the incorrect hugepages count
References: <1470624546-902-1-git-send-email-zhongjiang@huawei.com> <d00a2c1d-5f02-056c-4eef-dd7514293418@oracle.com>
In-Reply-To: <d00a2c1d-5f02-056c-4eef-dd7514293418@oracle.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 2016/8/9 1:14, Mike Kravetz wrote:
> On 08/07/2016 07:49 PM, zhongjiang wrote:
>> From: zhong jiang <zhongjiang@huawei.com>
>>
>> when memory hotplug enable, free hugepages will be freed if movable node offline.
>> therefore, /proc/sys/vm/nr_hugepages will be incorrect.
>>
>> The patch fix it by reduce the max_huge_pages when the node offline.
>>
>> Signed-off-by: zhong jiang <zhongjiang@huawei.com>
>> ---
>>  mm/hugetlb.c | 1 +
>>  1 file changed, 1 insertion(+)
>>
>> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
>> index f904246..3356e3a 100644
>> --- a/mm/hugetlb.c
>> +++ b/mm/hugetlb.c
>> @@ -1448,6 +1448,7 @@ static void dissolve_free_huge_page(struct page *page)
>>  		list_del(&page->lru);
>>  		h->free_huge_pages--;
>>  		h->free_huge_pages_node[nid]--;
>> +		h->max_huge_pages--;
>>  		update_and_free_page(h, page);
>>  	}
>>  	spin_unlock(&hugetlb_lock);
>>
> Adding Naoya as he was the original author of this code.
>
> >From quick look it appears that the huge page will be migrated (allocated
> on another node).  If my understanding is correct, then max_huge_pages
> should not be adjusted here.
>
  we need to take free hugetlb pages into account.  of course, the allocated huge pages is no
  need to reduce.  The patch just reduce the free hugetlb pages count.

  Thanks
 zhongjiang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
