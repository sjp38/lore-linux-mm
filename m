Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 25E186B0038
	for <linux-mm@kvack.org>; Sun, 14 May 2017 00:12:47 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id x53so34839340qtx.14
        for <linux-mm@kvack.org>; Sat, 13 May 2017 21:12:47 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id q74si7750014qkh.113.2017.05.13.21.12.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 13 May 2017 21:12:46 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4E48UI5053546
	for <linux-mm@kvack.org>; Sun, 14 May 2017 00:12:45 -0400
Received: from e23smtp06.au.ibm.com (e23smtp06.au.ibm.com [202.81.31.148])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2aedxkkdke-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 14 May 2017 00:12:45 -0400
Received: from localhost
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Sun, 14 May 2017 14:12:42 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v4E4CWU86750554
	for <linux-mm@kvack.org>; Sun, 14 May 2017 14:12:40 +1000
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v4E4C2mX011716
	for <linux-mm@kvack.org>; Sun, 14 May 2017 14:12:02 +1000
Subject: Re: [PATCH V2] mm/madvise: Enable (soft|hard) offline of HugeTLB
 pages at PGD level
References: <20170426035731.6924-1-khandual@linux.vnet.ibm.com>
 <20170512143503.81e0de2ae3d88a53168c601a@linux-foundation.org>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Sun, 14 May 2017 09:41:49 +0530
MIME-Version: 1.0
In-Reply-To: <20170512143503.81e0de2ae3d88a53168c601a@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <ab2e2a1d-9932-106d-83d1-3527dd7702bc@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, n-horiguchi@ah.jp.nec.com, aneesh.kumar@linux.vnet.ibm.com

On 05/13/2017 03:05 AM, Andrew Morton wrote:
> On Wed, 26 Apr 2017 09:27:31 +0530 Anshuman Khandual <khandual@linux.vnet.ibm.com> wrote:
> 
>> Though migrating gigantic HugeTLB pages does not sound much like real
>> world use case, they can be affected by memory errors. Hence migration
>> at the PGD level HugeTLB pages should be supported just to enable soft
>> and hard offline use cases.
>>
>> While allocating the new gigantic HugeTLB page, it should not matter
>> whether new page comes from the same node or not. There would be very
>> few gigantic pages on the system afterall, we should not be bothered
>> about node locality when trying to save a big page from crashing.
>>
>> This introduces a new HugeTLB allocator called alloc_huge_page_nonid()
>> which will scan over all online nodes on the system and allocate a
>> single HugeTLB page.
>>
>> ...
>>
>> --- a/mm/hugetlb.c
>> +++ b/mm/hugetlb.c
>> @@ -1669,6 +1669,23 @@ struct page *__alloc_buddy_huge_page_with_mpol(struct hstate *h,
>>  	return __alloc_buddy_huge_page(h, vma, addr, NUMA_NO_NODE);
>>  }
>>  
>> +struct page *alloc_huge_page_nonid(struct hstate *h)
>> +{
>> +	struct page *page = NULL;
>> +	int nid = 0;
>> +
>> +	spin_lock(&hugetlb_lock);
>> +	if (h->free_huge_pages - h->resv_huge_pages > 0) {
>> +		for_each_online_node(nid) {
>> +			page = dequeue_huge_page_node(h, nid);
>> +			if (page)
>> +				break;
>> +		}
>> +	}
>> +	spin_unlock(&hugetlb_lock);
>> +	return page;
>> +}
>> +
>>  /*
>>   * This allocation function is useful in the context where vma is irrelevant.
>>   * E.g. soft-offlining uses this function because it only cares physical
>> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
>> index fe64d7729a8e..d4f5710cf3f7 100644
>> --- a/mm/memory-failure.c
>> +++ b/mm/memory-failure.c
>> @@ -1481,11 +1481,15 @@ EXPORT_SYMBOL(unpoison_memory);
>>  static struct page *new_page(struct page *p, unsigned long private, int **x)
>>  {
>>  	int nid = page_to_nid(p);
>> -	if (PageHuge(p))
>> +	if (PageHuge(p)) {
>> +		if (hstate_is_gigantic(page_hstate(compound_head(p))))
>> +			return alloc_huge_page_nonid(page_hstate(compound_head(p)));
>> +
>>  		return alloc_huge_page_node(page_hstate(compound_head(p)),
>>  						   nid);
>> -	else
>> +	} else {
>>  		return __alloc_pages_node(nid, GFP_HIGHUSER_MOVABLE, 0);
>> +	}
>>  }
> 
> Rather than adding alloc_huge_page_nonid(), would it be neater to teach
> alloc_huge_page_node() (actually dequeue_huge_page_node()) to understand
> nid==NUMA_NO_NODE?

Sure, will change dequeue_huge_page_node() to accommodate NUMA_NO_NODE and
let soft offline call with NUMA_NO_NODE in case of gigantic huge pages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
