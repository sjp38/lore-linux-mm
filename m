Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1FE646B0387
	for <linux-mm@kvack.org>; Tue,  7 Mar 2017 03:56:53 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id g2so18984106pge.7
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 00:56:53 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id x26si15152094pge.30.2017.03.07.00.56.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Mar 2017 00:56:52 -0800 (PST)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v278nfN0146925
	for <linux-mm@kvack.org>; Tue, 7 Mar 2017 03:56:51 -0500
Received: from e23smtp08.au.ibm.com (e23smtp08.au.ibm.com [202.81.31.141])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2917pnbypv-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 07 Mar 2017 03:56:51 -0500
Received: from localhost
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Tue, 7 Mar 2017 18:56:48 +1000
Received: from d23relay06.au.ibm.com (d23relay06.au.ibm.com [9.185.63.219])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id CE14F2BB0054
	for <linux-mm@kvack.org>; Tue,  7 Mar 2017 19:56:45 +1100 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay06.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v278ubag48824456
	for <linux-mm@kvack.org>; Tue, 7 Mar 2017 19:56:45 +1100
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v278uCap013830
	for <linux-mm@kvack.org>; Tue, 7 Mar 2017 19:56:13 +1100
Subject: Re: [RFC 05/11] mm: make the try_to_munlock void function
References: <1488436765-32350-1-git-send-email-minchan@kernel.org>
 <1488436765-32350-6-git-send-email-minchan@kernel.org>
 <98488e1a-0202-b88b-ca9c-1dc0d6c27ae5@linux.vnet.ibm.com>
 <20170306020901.GC8779@bbox>
 <12618e8d-9eaf-322a-4334-e1416dc95b8b@linux.vnet.ibm.com>
 <20170307065048.GD29458@bbox>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Tue, 7 Mar 2017 14:25:48 +0530
MIME-Version: 1.0
In-Reply-To: <20170307065048.GD29458@bbox>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <6e412428-86c7-9032-a3b6-41980ad667f9@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, kernel-team@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

On 03/07/2017 12:20 PM, Minchan Kim wrote:
> Hi Anshuman,
> 
> On Mon, Mar 06, 2017 at 03:10:17PM +0530, Anshuman Khandual wrote:
>> On 03/06/2017 07:39 AM, Minchan Kim wrote:
>>> On Fri, Mar 03, 2017 at 05:13:54PM +0530, Anshuman Khandual wrote:
>>>> On 03/02/2017 12:09 PM, Minchan Kim wrote:
>>>>> try_to_munlock returns SWAP_MLOCK if the one of VMAs mapped
>>>>> the page has VM_LOCKED flag. In that time, VM set PG_mlocked to
>>>>> the page if the page is not pte-mapped THP which cannot be
>>>>> mlocked, either.
>>>> Right.
>>>>
>>>>> With that, __munlock_isolated_page can use PageMlocked to check
>>>>> whether try_to_munlock is successful or not without relying on
>>>>> try_to_munlock's retval. It helps to make ttu/ttuo simple with
>>>>> upcoming patches.
>>>> Right.
>>>>
>>>>> Cc: Vlastimil Babka <vbabka@suse.cz>
>>>>> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
>>>>> Signed-off-by: Minchan Kim <minchan@kernel.org>
>>>>> ---
>>>>>  include/linux/rmap.h |  2 +-
>>>>>  mm/mlock.c           |  6 ++----
>>>>>  mm/rmap.c            | 16 ++++------------
>>>>>  3 files changed, 7 insertions(+), 17 deletions(-)
>>>>>
>>>>> diff --git a/include/linux/rmap.h b/include/linux/rmap.h
>>>>> index b556eef..1b0cd4c 100644
>>>>> --- a/include/linux/rmap.h
>>>>> +++ b/include/linux/rmap.h
>>>>> @@ -235,7 +235,7 @@ int page_mkclean(struct page *);
>>>>>   * called in munlock()/munmap() path to check for other vmas holding
>>>>>   * the page mlocked.
>>>>>   */
>>>>> -int try_to_munlock(struct page *);
>>>>> +void try_to_munlock(struct page *);
>>>>>  
>>>>>  void remove_migration_ptes(struct page *old, struct page *new, bool locked);
>>>>>  
>>>>> diff --git a/mm/mlock.c b/mm/mlock.c
>>>>> index cdbed8a..d34a540 100644
>>>>> --- a/mm/mlock.c
>>>>> +++ b/mm/mlock.c
>>>>> @@ -122,17 +122,15 @@ static bool __munlock_isolate_lru_page(struct page *page, bool getpage)
>>>>>   */
>>>>>  static void __munlock_isolated_page(struct page *page)
>>>>>  {
>>>>> -	int ret = SWAP_AGAIN;
>>>>> -
>>>>>  	/*
>>>>>  	 * Optimization: if the page was mapped just once, that's our mapping
>>>>>  	 * and we don't need to check all the other vmas.
>>>>>  	 */
>>>>>  	if (page_mapcount(page) > 1)
>>>>> -		ret = try_to_munlock(page);
>>>>> +		try_to_munlock(page);
>>>>>  
>>>>>  	/* Did try_to_unlock() succeed or punt? */
>>>>> -	if (ret != SWAP_MLOCK)
>>>>> +	if (!PageMlocked(page))
>>>> Checks if the page is still mlocked or not.
>>>>
>>>>>  		count_vm_event(UNEVICTABLE_PGMUNLOCKED);
>>>>>  
>>>>>  	putback_lru_page(page);
>>>>> diff --git a/mm/rmap.c b/mm/rmap.c
>>>>> index 0a48958..61ae694 100644
>>>>> --- a/mm/rmap.c
>>>>> +++ b/mm/rmap.c
>>>>> @@ -1540,18 +1540,10 @@ static int page_not_mapped(struct page *page)
>>>>>   * Called from munlock code.  Checks all of the VMAs mapping the page
>>>>>   * to make sure nobody else has this page mlocked. The page will be
>>>>>   * returned with PG_mlocked cleared if no other vmas have it mlocked.
>>>>> - *
>>>>> - * Return values are:
>>>>> - *
>>>>> - * SWAP_AGAIN	- no vma is holding page mlocked, or,
>>>>> - * SWAP_AGAIN	- page mapped in mlocked vma -- couldn't acquire mmap sem
>>>>> - * SWAP_FAIL	- page cannot be located at present
>>>>> - * SWAP_MLOCK	- page is now mlocked.
>>>>>   */
>>>>> -int try_to_munlock(struct page *page)
>>>>> -{
>>>>> -	int ret;
>>>>>  
>>>>> +void try_to_munlock(struct page *page)
>>>>> +{
>>>>>  	struct rmap_walk_control rwc = {
>>>>>  		.rmap_one = try_to_unmap_one,
>>>>>  		.arg = (void *)TTU_MUNLOCK,
>>>>> @@ -1561,9 +1553,9 @@ int try_to_munlock(struct page *page)
>>>>>  	};
>>>>>  
>>>>>  	VM_BUG_ON_PAGE(!PageLocked(page) || PageLRU(page), page);
>>>>> +	VM_BUG_ON_PAGE(PageMlocked(page), page);
>>>> We are calling on the page to see if its mlocked from any of it's
>>>> mapping VMAs. Then it is a possibility that the page is mlocked
>>>> and the above condition is true and we print VM BUG report there.
>>>> The point is if its a valid possibility why we have added the
>>>> above check ?
>>> If I read code properly,  __munlock_isolated_page calls try_to_munlock
>>> always pass the TestClearPageMlocked page to try_to_munlock.
>> Right.
>>
>>> (e.g., munlock_vma_page and __munlock_pagevec) so I thought
>>> try_to_munlock should be called non-PG_mlocked page and try_to_unmap_one
>>> returns PG_mlocked page once it found a VM_LOCKED VMA for a page.
>>> IOW, non-PG_mlocked page is precondition for try_to_munlock.
>> Okay, I have missed that part. Nonetheless this is a separate issue,
>> should be part of a different patch ? Not inside these cleanups.
> If that precondition is not true, this patch changes the behavior
> slightly.
> 
>         UNEVICTABLE_PGMUNLOCKED count mistmatch compared to old.
> 
> I wanted to catch it up. If you still think it's separate issue,
> I will do. Please tell me. However, I still think it's no problem
> to merge it in this clean up patch.

Got it, its okay. Let this change be part of this patch itself.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
