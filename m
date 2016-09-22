Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0F7A76B027C
	for <linux-mm@kvack.org>; Thu, 22 Sep 2016 15:13:32 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id n185so52671862qke.2
        for <linux-mm@kvack.org>; Thu, 22 Sep 2016 12:13:32 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id i50si2249097qta.44.2016.09.22.12.13.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Sep 2016 12:13:31 -0700 (PDT)
Subject: Re: [PATCH v3] mm/hugetlb: fix memory offline with hugepage size >
 memory block size
References: <20160920155354.54403-1-gerald.schaefer@de.ibm.com>
 <20160920155354.54403-2-gerald.schaefer@de.ibm.com>
 <05d701d213d1$7fb70880$7f251980$@alibaba-inc.com>
 <20160921143534.0dd95fe7@thinkpad> <20160922095137.GC11875@dhcp22.suse.cz>
 <20160922154549.483ee313@thinkpad> <20160922182937.38af9d0e@thinkpad>
 <57E41EF6.1010903@linux.intel.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <aee7cebd-83de-f83e-9d18-eca540217ee4@oracle.com>
Date: Thu, 22 Sep 2016 12:13:14 -0700
MIME-Version: 1.0
In-Reply-To: <57E41EF6.1010903@linux.intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Rui Teng <rui.teng@linux.vnet.ibm.com>

On 09/22/2016 11:12 AM, Dave Hansen wrote:
> On 09/22/2016 09:29 AM, Gerald Schaefer wrote:
>>  static void dissolve_free_huge_page(struct page *page)
>>  {
>> +	struct page *head = compound_head(page);
>> +	struct hstate *h = page_hstate(head);
>> +	int nid = page_to_nid(head);
>> +
>>  	spin_lock(&hugetlb_lock);
>> -	if (PageHuge(page) && !page_count(page)) {
>> -		struct hstate *h = page_hstate(page);
>> -		int nid = page_to_nid(page);
>> -		list_del(&page->lru);
>> -		h->free_huge_pages--;
>> -		h->free_huge_pages_node[nid]--;
>> -		h->max_huge_pages--;
>> -		update_and_free_page(h, page);
>> -	}
>> +	list_del(&head->lru);
>> +	h->free_huge_pages--;
>> +	h->free_huge_pages_node[nid]--;
>> +	h->max_huge_pages--;
>> +	update_and_free_page(h, head);
>>  	spin_unlock(&hugetlb_lock);
>>  }
> 
> Do you need to revalidate anything once you acquire the lock?  Can this,
> for instance, race with another thread doing vm.nr_hugepages=0?  Or a
> thread faulting in and allocating the large page that's being dissolved?

I originally suggested the locking change, but this is not quite right.
The page count for huge pages is adjusted while holding hugetlb_lock.
So, that check or a revalidation needs to be done while holding the lock.

That question made me think about huge page reservations.  I don't think
the offline code takes this into account.  But, you would not want your
huge page count to drop below the reserved huge page count
(resv_huge_pages).
So, shouldn't this be another condition to check before allowing the huge
page to be dissolved?

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
