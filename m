Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id 894968E0018
	for <linux-mm@kvack.org>; Mon, 10 Dec 2018 10:22:27 -0500 (EST)
Received: by mail-lj1-f197.google.com with SMTP id 18-v6so2848694ljn.8
        for <linux-mm@kvack.org>; Mon, 10 Dec 2018 07:22:27 -0800 (PST)
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id l132si9199559lfb.54.2018.12.10.07.22.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Dec 2018 07:22:25 -0800 (PST)
Subject: Re: [PATCH v3] ksm: Assist buddy allocator to assemble 1-order pages
From: Kirill Tkhai <ktkhai@virtuozzo.com>
References: <153995241537.4096.15189862239521235797.stgit@localhost.localdomain>
 <20181109130857.54a1f383629e771b4f3888c4@linux-foundation.org>
 <0ac6ace8-1e0a-7013-7b1f-2dbe0f35f34f@virtuozzo.com>
Message-ID: <add11fe3-c524-ec00-be25-4892e905cfcd@virtuozzo.com>
Date: Mon, 10 Dec 2018 18:22:12 +0300
MIME-Version: 1.0
In-Reply-To: <0ac6ace8-1e0a-7013-7b1f-2dbe0f35f34f@virtuozzo.com>
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: hughd@google.com, aarcange@redhat.com, kirill.shutemov@linux.intel.com, andriy.shevchenko@linux.intel.com, mhocko@suse.com, rppt@linux.vnet.ibm.com, imbrenda@linux.vnet.ibm.com, corbet@lwn.net, ndesaulniers@google.com, dave.jiang@intel.com, jglisse@redhat.com, jia.he@hxt-semitech.com, paulmck@linux.vnet.ibm.com, colin.king@canonical.com, jiang.biao2@zte.com.cn, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Andrew, please, drop this patch.

It misses, that the caller (i.e. cmp_and_merge_page()) is not symmetrical
for page and tree_page (there is put_page(tree_page) in the caller).
We could change try_to_merge_two_pages() arguments and to pass &rmap_item,
&page, &tree_rmap_item and &tree_page from the caller, but I need time
to investigate the reason tests did not warn about this, before resending
or new iteration of patch.

Thanks,
Kirill

On 15.11.2018 17:12, Kirill Tkhai wrote:
> On 10.11.2018 0:08, Andrew Morton wrote:
>> On Fri, 19 Oct 2018 15:33:39 +0300 Kirill Tkhai <ktkhai@virtuozzo.com> wrote:
>>
>>> v3: Comment improvements.
>>> v2: Style improvements.
>>>
>>> try_to_merge_two_pages() merges two pages, one of them
>>> is a page of currently scanned mm, the second is a page
>>> with identical hash from unstable tree. Currently, we
>>> merge the page from unstable tree into the first one,
>>> and then free it.
>>>
>>> The idea of this patch is to prefer freeing that page
>>> of them, which has a free neighbour (i.e., neighbour
>>> with zero page_count()). This allows buddy allocator
>>> to assemble at least 1-order set from the freed page
>>> and its neighbour; this is a kind of cheep passive
>>> compaction.
>>>
>>> AFAIK, 1-order pages set consists of pages with PFNs
>>> [2n, 2n+1] (odd, even), so the neighbour's pfn is
>>> calculated via XOR with 1. We check the result pfn
>>> is valid and its page_count(), and prefer merging
>>> into @tree_page if neighbour's usage count is zero.
>>>
>>> There a is small difference with current behavior
>>> in case of error path. In case of the second
>>> try_to_merge_with_ksm_page() is failed, we return
>>> from try_to_merge_two_pages() with @tree_page
>>> removed from unstable tree. It does not seem to matter,
>>> but if we do not want a change at all, it's not
>>> a problem to move remove_rmap_item_from_tree() from
>>> try_to_merge_with_ksm_page() to its callers.
>>>
>>
>> Seems sensible.
>>
>>>
>>> ...
>>>
>>> --- a/mm/ksm.c
>>> +++ b/mm/ksm.c
>>> @@ -1321,6 +1321,23 @@ static struct page *try_to_merge_two_pages(struct rmap_item *rmap_item,
>>>  {
>>>  	int err;
>>>  
>>> +	if (IS_ENABLED(CONFIG_COMPACTION)) {
>>> +		unsigned long pfn;
>>> +
>>> +		/*
>>> +		 * Find neighbour of @page containing 1-order pair in buddy
>>> +		 * allocator and check whether its count is 0. If so, we
>>> +		 * consider the neighbour as a free page (this is more
>>> +		 * probable than it's freezed via page_ref_freeze()), and
>>> +		 * we try to use @tree_page as ksm page and to free @page.
>>> +		 */
>>> +		pfn = page_to_pfn(page) ^ 1;
>>> +		if (pfn_valid(pfn) && page_count(pfn_to_page(pfn)) == 0) {
>>> +			swap(rmap_item, tree_rmap_item);
>>> +			swap(page, tree_page);
>>> +		}
>>> +	}
>>> +
>>
>> A few thoughts
>>
>> - if tree_page's neighbor is unused, there was no point in doing this
>>   swapping?
> 
> You are sure, and this is the thing I analyzed from several ways before
> the submitting. There is no point for doing this swapping, but there is
> no point for not doing it too. Both of this approach are almost equal
> each other, while the "doing swapping" approach just adds less code.
> This is the only reason I prefered it.
> 
>> - if both *page and *tree_page have unused neighbors we could go
>>   further and look for an opportunity to create an order-2 page. 
>>   etcetera.  This may b excessive ;)
> 
> We may do that, there are just less probability to meet a page with
> 3 free neighbors, than with 1 free neighbor. But we can.
> 
>> - are we really sure that this optimization causes desirable results?
>>   If we always merge from one tree into the other, we maximise the
>>   opportunities for page coalescing in the long term.  But if we
>>   sometimes merge one way and sometimes merge the other way, we might
>>   end up with less higher-order page coalescing?  Or am I confusing
>>   myself?
> 
> Just the previous version was RFC, so I'm not 100% sure :) I asked for
> compaction tests in reply to v2, but it looks like we don't have them.
> I tested this by adding a counter of swapped pages on top of this patch.
> The counter grows (though, not so fast as I expected this before).
> 
> It's difficult to rate the long term coalescing, since there are many
> players, which may introduce external influence, or make page disappear
> from process (shrinker, parallel compaction, COW on ksm-ed page, thp).
> This all is not completely deterministic, there are too many input
> parameters. There is a question whether short term compaction or long
> term compaction is more important. I have no answer on this...
> 
> Kirill
> 
