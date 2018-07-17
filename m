Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7CF4F6B000E
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 16:10:53 -0400 (EDT)
Received: by mail-vk0-f69.google.com with SMTP id n135-v6so802278vke.17
        for <linux-mm@kvack.org>; Tue, 17 Jul 2018 13:10:53 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id d1-v6si526016vke.273.2018.07.17.13.10.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jul 2018 13:10:52 -0700 (PDT)
Subject: Re: [PATCH v2 1/2] mm: fix race on soft-offlining free huge pages
References: <1531805552-19547-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1531805552-19547-2-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20180717142743.GJ7193@dhcp22.suse.cz>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <773a2f4e-c420-e973-cadd-4144730d28e8@oracle.com>
Date: Tue, 17 Jul 2018 13:10:39 -0700
MIME-Version: 1.0
In-Reply-To: <20180717142743.GJ7193@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, xishi.qiuxishi@alibaba-inc.com, zy.zhengyi@alibaba-inc.com, linux-kernel@vger.kernel.org

On 07/17/2018 07:27 AM, Michal Hocko wrote:
> On Tue 17-07-18 14:32:31, Naoya Horiguchi wrote:
>> There's a race condition between soft offline and hugetlb_fault which
>> causes unexpected process killing and/or hugetlb allocation failure.
>>
>> The process killing is caused by the following flow:
>>
>>   CPU 0               CPU 1              CPU 2
>>
>>   soft offline
>>     get_any_page
>>     // find the hugetlb is free
>>                       mmap a hugetlb file
>>                       page fault
>>                         ...
>>                           hugetlb_fault
>>                             hugetlb_no_page
>>                               alloc_huge_page
>>                               // succeed
>>       soft_offline_free_page
>>       // set hwpoison flag
>>                                          mmap the hugetlb file
>>                                          page fault
>>                                            ...
>>                                              hugetlb_fault
>>                                                hugetlb_no_page
>>                                                  find_lock_page
>>                                                    return VM_FAULT_HWPOISON
>>                                            mm_fault_error
>>                                              do_sigbus
>>                                              // kill the process
>>
>>
>> The hugetlb allocation failure comes from the following flow:
>>
>>   CPU 0                          CPU 1
>>
>>                                  mmap a hugetlb file
>>                                  // reserve all free page but don't fault-in
>>   soft offline
>>     get_any_page
>>     // find the hugetlb is free
>>       soft_offline_free_page
>>       // set hwpoison flag
>>         dissolve_free_huge_page
>>         // fail because all free hugepages are reserved
>>                                  page fault
>>                                    ...
>>                                      hugetlb_fault
>>                                        hugetlb_no_page
>>                                          alloc_huge_page
>>                                            ...
>>                                              dequeue_huge_page_node_exact
>>                                              // ignore hwpoisoned hugepage
>>                                              // and finally fail due to no-mem
>>
>> The root cause of this is that current soft-offline code is written
>> based on an assumption that PageHWPoison flag should beset at first to
>> avoid accessing the corrupted data.  This makes sense for memory_failure()
>> or hard offline, but does not for soft offline because soft offline is
>> about corrected (not uncorrected) error and is safe from data lost.
>> This patch changes soft offline semantics where it sets PageHWPoison flag
>> only after containment of the error page completes successfully.
> 
> Could you please expand on the worklow here please? The code is really
> hard to grasp. I must be missing something because the thing shouldn't
> be really complicated. Either the page is in the free pool and you just
> remove it from the allocator (with hugetlb asking for a new hugeltb page
> to guaratee reserves) or it is used and you just migrate the content to
> a new page (again with the hugetlb reserves consideration). Why should
> PageHWPoison flag ordering make any relevance?

My understanding may not be corect, but just looking at the current code
for soft_offline_free_page helps me understand:

static void soft_offline_free_page(struct page *page)
{
	struct page *head = compound_head(page);

	if (!TestSetPageHWPoison(head)) {
		num_poisoned_pages_inc();
		if (PageHuge(head))
			dissolve_free_huge_page(page);
	}
}

The HWPoison flag is set before even checking to determine if the huge
page can be dissolved.  So, someone could could attempt to pull the page
off the free list (if free) or fault/map it (if already associated with
a file) which leads to the  failures described above.  The patches ensure
that we only set HWPoison after successfully dissolving the page. At least
that is how I understand it.

It seems that soft_offline_free_page can be called for in use pages.
Certainly, that is the case in the first workflow above.  With the
suggested changes, I think this is OK for huge pages.  However, it seems
that setting HWPoison on a in use non-huge page could cause issues?

While looking at the code, I noticed this comment in __get_any_page()
        /*
         * When the target page is a free hugepage, just remove it
         * from free hugepage list.
         */
Did that apply to some code that was removed?  It does not seem to make
any sense in that routine.
-- 
Mike Kravetz
