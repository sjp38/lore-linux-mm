Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id B2B726B03AE
	for <linux-mm@kvack.org>; Thu, 20 Apr 2017 01:06:42 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id o22so52464465iod.6
        for <linux-mm@kvack.org>; Wed, 19 Apr 2017 22:06:42 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id s3si5160301plb.315.2017.04.19.22.06.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Apr 2017 22:06:41 -0700 (PDT)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3K53hPt083645
	for <linux-mm@kvack.org>; Thu, 20 Apr 2017 01:06:41 -0400
Received: from e23smtp05.au.ibm.com (e23smtp05.au.ibm.com [202.81.31.147])
	by mx0a-001b2d01.pphosted.com with ESMTP id 29x6x1ypax-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 20 Apr 2017 01:06:41 -0400
Received: from localhost
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Thu, 20 Apr 2017 15:06:13 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v3K562Ga56164532
	for <linux-mm@kvack.org>; Thu, 20 Apr 2017 15:06:10 +1000
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v3K55b8U019249
	for <linux-mm@kvack.org>; Thu, 20 Apr 2017 15:05:37 +1000
Subject: Re: [RFC] mm/madvise: Enable (soft|hard) offline of HugeTLB pages at
 PGD level
References: <20170419032759.29700-1-khandual@linux.vnet.ibm.com>
 <877f2ghqaf.fsf@skywalker.in.ibm.com>
 <d3189584-4ddd-53b8-f412-57e378dbf7ca@linux.vnet.ibm.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Thu, 20 Apr 2017 10:35:14 +0530
MIME-Version: 1.0
In-Reply-To: <d3189584-4ddd-53b8-f412-57e378dbf7ca@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <893ecbd7-e9fa-7a54-fc62-43f8a5b8107f@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: n-horiguchi@ah.jp.nec.com, akpm@linux-foundation.org

On 04/19/2017 12:12 PM, Anshuman Khandual wrote:
> On 04/19/2017 11:50 AM, Aneesh Kumar K.V wrote:
>> Anshuman Khandual <khandual@linux.vnet.ibm.com> writes:
>>
>>> Though migrating gigantic HugeTLB pages does not sound much like real
>>> world use case, they can be affected by memory errors. Hence migration
>>> at the PGD level HugeTLB pages should be supported just to enable soft
>>> and hard offline use cases.
>> In that case do we want to isolated the entire 16GB range ? Should we
>> just dequeue the page from hugepage pool convert them to regular 64K
>> pages and then isolate the 64K that had memory error ?
> Though its a better thing to do, assuming that we can actually dequeue
> the huge page and push it to the buddy allocator as normal 64K pages
> (need to check on this as the original allocation happened from the
> memblock instead of the buddy allocator, guess it should be possible
> given that we do similar stuff during memory hot plug). In that case
> we will also have to consider the same for the PMD based HugeTLB pages
> as well or it should be only for these gigantic huge pages ?

If we look at the code inside the function soft_offline_huge_page(),
if the source huge page has been freed to the active_freelist then
we mark the *entire* hugepage as poisoned but if the huge page has
been released back to the buddy allocator then only the page in
question is marked poisoned not the entire huge page. This was
part was added with the commit a49ecbcd7 ("mm/memory-failure.c:
recheck PageHuge() after hugetlb page migrate successfully"). But
when I look at the migrate_pages() handling of huge pages, it always
calls putback_active_hugepage() after successful migration to release
the huge page back the active list not to the buddy allocator. I am 
not sure if the second half of 'if' block is ever getting executed
at all.

I am starting to wonder whats the point of releasing the huge page
to the active list in migrate_pages() when we will go and mark the
entire huge page as *poisoned*, put it in a dangling state (page->lru
pointing to itself) which can not be allocated anyway.

After migrate_pages() is successful and the source huge page is
release to the active list. We just mark the single normal page
has poisoned, get the source page from the active list and free
it to the buddy allocator. This should just take care both PMD
and PGD based huge pages.

----------------------------------------------------------------------
ret = migrate_pages(&pagelist, new_page, NULL, MPOL_MF_MOVE_ALL,
				MIGRATE_SYNC, MR_MEMORY_FAILURE);
if (ret) {
	pr_info("soft offline: %#lx: migration failed %d, type %lx\n",
		pfn, ret, page->flags);
	/*
	 * We know that soft_offline_huge_page() tries to migrate
	 * only one hugepage pointed to by hpage, so we need not
	 * run through the pagelist here.
	 */
	putback_active_hugepage(hpage);
	if (ret > 0)
		ret = -EIO;
} else {
	/* overcommit hugetlb page will be freed to buddy */
	if (PageHuge(page)) {
		set_page_hwpoison_huge_page(hpage);
		dequeue_hwpoisoned_huge_page(hpage);
		num_poisoned_pages_add(1 << compound_order(hpage));
	} else {
		SetPageHWPoison(page);
		num_poisoned_pages_inc();
	}
}
----------------------------------------------------------------------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
