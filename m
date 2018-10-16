Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id 10B5C6B0006
	for <linux-mm@kvack.org>; Tue, 16 Oct 2018 05:34:26 -0400 (EDT)
Received: by mail-lj1-f200.google.com with SMTP id h7-v6so6265296ljc.15
        for <linux-mm@kvack.org>; Tue, 16 Oct 2018 02:34:25 -0700 (PDT)
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id c18-v6si11079475lja.167.2018.10.16.02.34.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Oct 2018 02:34:23 -0700 (PDT)
Subject: Re: [PATCH RFC] ksm: Assist buddy allocator to assemble 1-order pages
References: <153925511661.21256.9692370932417728663.stgit@localhost.localdomain>
 <20181015154112.6bj5p4zuxjtz43pd@kshutemo-mobl1>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <0b0a81c4-d0b3-99f4-6910-10b757732825@virtuozzo.com>
Date: Tue, 16 Oct 2018 12:34:11 +0300
MIME-Version: 1.0
In-Reply-To: <20181015154112.6bj5p4zuxjtz43pd@kshutemo-mobl1>
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, andriy.shevchenko@linux.intel.com, mhocko@suse.com, rppt@linux.vnet.ibm.com, imbrenda@linux.vnet.ibm.com, corbet@lwn.net, ndesaulniers@google.com, dave.jiang@intel.com, jglisse@redhat.com, jia.he@hxt-semitech.com, paulmck@linux.vnet.ibm.com, colin.king@canonical.com, jiang.biao2@zte.com.cn, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 15.10.2018 18:41, Kirill A. Shutemov wrote:
> On Thu, Oct 11, 2018 at 01:52:22PM +0300, Kirill Tkhai wrote:
>> try_to_merge_two_pages() merges two pages, one of them
>> is a page of currently scanned mm, the second is a page
>> with identical hash from unstable tree. Currently, we
>> merge the page from unstable tree into the first one,
>> and then free it.
>>
>> The idea of this patch is to prefer freeing that page
>> of them, which has a free neighbour (i.e., neighbour
>> with zero page_count()). This allows buddy allocator
>> to assemble at least 1-order set from the freed page
>> and its neighbour; this is a kind of cheep passive
>> compaction.
>>
>> AFAIK, 1-order pages set consists of pages with PFNs
>> [2n, 2n+1] (odd, even), so the neighbour's pfn is
>> calculated via XOR with 1. We check the result pfn
>> is valid and its page_count(), and prefer merging
>> into @tree_page if neighbour's usage count is zero.
>>
>> There a is small difference with current behavior
>> in case of error path. In case of the second
>> try_to_merge_with_ksm_page() is failed, we return
>> from try_to_merge_two_pages() with @tree_page
>> removed from unstable tree. It does not seem to matter,
>> but if we do not want a change at all, it's not
>> a problem to move remove_rmap_item_from_tree() from
>> try_to_merge_with_ksm_page() to its callers.
>>
>> Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
>> ---
>>  mm/ksm.c |   15 +++++++++++++++
>>  1 file changed, 15 insertions(+)
>>
>> diff --git a/mm/ksm.c b/mm/ksm.c
>> index 5b0894b45ee5..b83ca37e28f0 100644
>> --- a/mm/ksm.c
>> +++ b/mm/ksm.c
>> @@ -1321,6 +1321,21 @@ static struct page *try_to_merge_two_pages(struct rmap_item *rmap_item,
>>  {
>>  	int err;
>>  
>> +	if (IS_ENABLED(CONFIG_COMPACTION)) {
>> +		unsigned long pfn;
>> +		/*
>> +		 * Find neighbour of @page containing 1-order pair
>> +		 * in buddy-allocator and check whether it is free.
> 
> You cannot really check if the page is free. There are some paths that
> makes the refcount zero temporarely, but doesn't free the page.
> See page_ref_freeze() for instance.

Thanks. Does this look better?

  Find neighbour of @page containing 1-order pair in buddy-allocator
  and check whether its count is 0. If it is so, we consider it's as free
  (this is more probable than it's freezed via page_ref_freeze()),
  and we try to use @tree_page as ksm page and to free @page.
 
> It should be fine for the use case, but comment should state that we
> speculate about page usage, not having definetive answer.
> 
> [ I don't know enough about KSM to ack the patch in general, but it looks
> fine to me at the first glance.]
> 
>> +		 * If it is so, try to use @tree_page as ksm page
>> +		 * and to free @page.
>> +		 */
>> +		pfn = (page_to_pfn(page) ^ 1);
>> +		if (pfn_valid(pfn) && page_count(pfn_to_page(pfn)) == 0) {
>> +			swap(rmap_item, tree_rmap_item);
>> +			swap(page, tree_page);
>> +		}
>> +	}
>> +
>>  	err = try_to_merge_with_ksm_page(rmap_item, page, NULL);
>>  	if (!err) {
>>  		err = try_to_merge_with_ksm_page(tree_rmap_item,
>>
> 
