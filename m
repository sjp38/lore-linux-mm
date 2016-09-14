Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8FB526B0038
	for <linux-mm@kvack.org>; Wed, 14 Sep 2016 12:34:04 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id s64so19694674lfs.1
        for <linux-mm@kvack.org>; Wed, 14 Sep 2016 09:34:04 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id x17si22569251wma.104.2016.09.14.09.34.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Sep 2016 09:34:03 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u8EGWc0f027146
	for <linux-mm@kvack.org>; Wed, 14 Sep 2016 12:34:01 -0400
Received: from e36.co.us.ibm.com (e36.co.us.ibm.com [32.97.110.154])
	by mx0b-001b2d01.pphosted.com with ESMTP id 25eyhb2nps-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 14 Sep 2016 12:34:01 -0400
Received: from localhost
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rui.teng@linux.vnet.ibm.com>;
	Wed, 14 Sep 2016 10:34:00 -0600
Subject: Re: [PATCH] memory-hotplug: Fix bad area access on
 dissolve_free_huge_pages()
References: <1473755948-13215-1-git-send-email-rui.teng@linux.vnet.ibm.com>
 <57D83821.4090804@linux.intel.com>
From: Rui Teng <rui.teng@linux.vnet.ibm.com>
Date: Thu, 15 Sep 2016 00:33:48 +0800
MIME-Version: 1.0
In-Reply-To: <57D83821.4090804@linux.intel.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Message-Id: <a789f3ef-bd49-8811-e1df-e949f0758ad1@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Michal Hocko <mhocko@suse.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Mike Kravetz <mike.kravetz@oracle.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Paul Gortmaker <paul.gortmaker@windriver.com>, Santhosh G <santhog4@in.ibm.com>

On 9/14/16 1:32 AM, Dave Hansen wrote:
> On 09/13/2016 01:39 AM, Rui Teng wrote:
>> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
>> index 87e11d8..64b5f81 100644
>> --- a/mm/hugetlb.c
>> +++ b/mm/hugetlb.c
>> @@ -1442,7 +1442,7 @@ static int free_pool_huge_page(struct hstate *h, nodemask_t *nodes_allowed,
>>  static void dissolve_free_huge_page(struct page *page)
>>  {
>>  	spin_lock(&hugetlb_lock);
>> -	if (PageHuge(page) && !page_count(page)) {
>> +	if (PageHuge(page) && !page_count(page) && PageHead(page)) {
>>  		struct hstate *h = page_hstate(page);
>>  		int nid = page_to_nid(page);
>>  		list_del(&page->lru);
>
> This is goofy.  What is calling dissolve_free_huge_page() on a tail page?
>
> Hmm:
>
>>         for (pfn = start_pfn; pfn < end_pfn; pfn += 1 << minimum_order)
>>                 dissolve_free_huge_page(pfn_to_page(pfn));
>
> So, skip through the area being offlined at the smallest huge page size,
> and try to dissolve a huge page in each place one might appear.  But,
> after we dissolve a 16GB huge page, we continue looking through the
> remaining 15.98GB tail area for huge pages in the area we just
> dissolved.  The tail pages are still PageHuge() (how??), and we call
> page_hstate() on the tail page whose head was just dissolved.
>
> Note, even with the fix, this taking a (global) spinlock 1023 more times
> that it doesn't have to.
>
> This seems inefficient, and fails to fully explain what is going on, and
> how tail pages still _look_ like PageHuge(), which seems pretty wrong.
>
> I guess the patch _works_.  But, sheesh, it leaves a lot of room for
> improvement.
>
Thanks for your suggestion!
How about return the size of page freed from dissolve_free_huge_page(), 
and jump such step on pfn?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
