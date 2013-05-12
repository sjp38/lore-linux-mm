Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 989EE6B0002
	for <linux-mm@kvack.org>; Sun, 12 May 2013 04:37:35 -0400 (EDT)
Received: from /spool/local
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Sun, 12 May 2013 14:03:50 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id AE1B2E002D
	for <linux-mm@kvack.org>; Sun, 12 May 2013 14:09:50 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4C8bNEb1966470
	for <linux-mm@kvack.org>; Sun, 12 May 2013 14:07:23 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4C8bRx7028394
	for <linux-mm@kvack.org>; Sun, 12 May 2013 18:37:27 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm/THP: Use the right function when updating access flags
In-Reply-To: <20130508130454.8b0d87cfb9273227c9a9dabf@linux-foundation.org>
References: <1367873388-12338-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20130508130454.8b0d87cfb9273227c9a9dabf@linux-foundation.org>
Date: Sun, 12 May 2013 14:07:26 +0530
Message-ID: <87d2swoapl.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: aarcange@redhat.com, linux-mm@kvack.org

Andrew Morton <akpm@linux-foundation.org> writes:

> On Tue,  7 May 2013 02:19:48 +0530 "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:
>
>> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>> 
>> We should use pmdp_set_access_flags to update access flags. Archs like powerpc
>> use extra checks(_PAGE_BUSY) when updating a hugepage PTE. A set_pmd_at doesn't
>> do those checks. We should use set_pmd_at only when updating a none hugepage PTE.
>> 
>> ...
>>
>> --- a/mm/huge_memory.c
>> +++ b/mm/huge_memory.c
>> @@ -1265,7 +1265,9 @@ struct page *follow_trans_huge_pmd(struct vm_area_struct *vma,
>>  		 * young bit, instead of the current set_pmd_at.
>>  		 */
>>  		_pmd = pmd_mkyoung(pmd_mkdirty(*pmd));
>> -		set_pmd_at(mm, addr & HPAGE_PMD_MASK, pmd, _pmd);
>> +		if (pmdp_set_access_flags(vma, addr & HPAGE_PMD_MASK,
>> +					  pmd, _pmd,  1))
>> +			update_mmu_cache_pmd(vma, addr, pmd);
>>  	}
>>  	if ((flags & FOLL_MLOCK) && (vma->vm_flags & VM_LOCKED)) {
>>  		if (page->mapping && trylock_page(page)) {
>
> <canned message>
> When writing a changelog, please describe the end-user-visible effects
> of the bug, so that others can more easily decide which kernel
> version(s) should be fixed, and so that downstream kernel maintainers
> can more easily work out whether this patch will fix a problem which
> they or their customers are observing.

I found that reading code while debugging some crashes with THP on
ppc64. So user visible effects would mostly be some random crashes. 
I will make sure to document the user visible effects next time.

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
