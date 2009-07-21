Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 681F26B0055
	for <linux-mm@kvack.org>; Tue, 21 Jul 2009 13:55:14 -0400 (EDT)
Message-ID: <4A660101.3000307@redhat.com>
Date: Tue, 21 Jul 2009 13:55:13 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 06/10] ksm: identify PageKsm pages
References: <1247851850-4298-1-git-send-email-ieidus@redhat.com> <1247851850-4298-2-git-send-email-ieidus@redhat.com> <1247851850-4298-3-git-send-email-ieidus@redhat.com> <1247851850-4298-4-git-send-email-ieidus@redhat.com> <1247851850-4298-5-git-send-email-ieidus@redhat.com> <1247851850-4298-6-git-send-email-ieidus@redhat.com> <1247851850-4298-7-git-send-email-ieidus@redhat.com> <20090721175139.GE2239@random.random>
In-Reply-To: <20090721175139.GE2239@random.random>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Izik Eidus <ieidus@redhat.com>, akpm@linux-foundation.org, hugh.dickins@tiscali.co.uk, chrisw@redhat.com, avi@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, nickpiggin@yahoo.com.au, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

Andrea Arcangeli wrote:

>> +static inline void page_add_ksm_rmap(struct page *page)
>> +{
>> +	if (atomic_inc_and_test(&page->_mapcount)) {
>> +		page->mapping = (void *) PAGE_MAPPING_ANON;
>> +		__inc_zone_page_state(page, NR_ANON_PAGES);
>> +	}
>> +}
> 
> Is it correct to account them as anon pages?

Yes, but ...

>> -	if (PageAnon(old_page)) {
>> +	if (PageAnon(old_page) && !PageKsm(old_page)) {
>>  		if (!trylock_page(old_page)) {
>>  			page_cache_get(old_page);
>>  			pte_unmap_unlock(page_table, ptl);
> 
> What exactly does it buy to have PageAnon return 1 on ksm pages,
> besides requiring the above additional check (that if we stick to the
> above code, I would find safer to move inside reuse_swap_page).

I guess that if they are to remain unswappable, they
should go onto the unevictable list.

Then again, I'm guessing this is all about to change
in not too much time :)

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
