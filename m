Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f178.google.com (mail-pf0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 2D50B6B0005
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 01:25:14 -0400 (EDT)
Received: by mail-pf0-f178.google.com with SMTP id n1so116836302pfn.2
        for <linux-mm@kvack.org>; Sun, 10 Apr 2016 22:25:14 -0700 (PDT)
Received: from e28smtp02.in.ibm.com (e28smtp02.in.ibm.com. [125.16.236.2])
        by mx.google.com with ESMTPS id dy1si1293754pab.117.2016.04.10.22.25.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Sun, 10 Apr 2016 22:25:13 -0700 (PDT)
Received: from localhost
	by e28smtp02.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Mon, 11 Apr 2016 10:55:11 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay04.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u3B5PRSs22413594
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 10:55:27 +0530
Received: from d28av01.in.ibm.com (localhost [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u3BArK8b015766
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 16:23:22 +0530
Message-ID: <570B3531.2000808@linux.vnet.ibm.com>
Date: Mon, 11 Apr 2016 10:55:05 +0530
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 02/10] mm/hugetlb: Add PGD based implementation awareness
References: <1460007464-26726-1-git-send-email-khandual@linux.vnet.ibm.com> <1460007464-26726-3-git-send-email-khandual@linux.vnet.ibm.com> <570622B4.5020407@gmail.com>
In-Reply-To: <570622B4.5020407@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
Cc: hughd@google.com, dave.hansen@intel.com, aneesh.kumar@linux.vnet.ibm.com, kirill@shutemov.name, n-horiguchi@ah.jp.nec.com, mgorman@techsingularity.net, akpm@linux-foundation.org

On 04/07/2016 02:34 PM, Balbir Singh wrote:
> 
> 
> On 07/04/16 15:37, Anshuman Khandual wrote:
>> Currently the config ARCH_WANT_GENERAL_HUGETLB enabled functions like
>> 'huge_pte_alloc' and 'huge_pte_offset' dont take into account HugeTLB
>> page implementation at the PGD level. This is also true for functions
>> like 'follow_page_mask' which is called from move_pages() system call.
>> This lack of PGD level huge page support prohibits some architectures
>> to use these generic HugeTLB functions.
>>
> 
> From what I know of move_pages(), it will always call follow_page_mask()
> with FOLL_GET (I could be wrong here) and the implementation below
> returns NULL for follow_huge_pgd().

You are right. This patch makes ARCH_WANT_GENERAL_HUGETLB functions aware
of PGD implementation so that we can do all transactions on 16GB pages
using these function instead of the present arch overrides. But that also
requires follow_page_mask() changes for every other access to the page
than the migrate_pages() usage.

But yes, we dont support migrate_pages() on PGD based pages yet, hence
it just returns NULL in that case. May be the commit message needs to
reflect this.

> 
>> This change adds the required PGD based implementation awareness and
>> with that, more architectures like POWER which implements 16GB pages
>> at the PGD level along with the 16MB pages at the PMD level can now
>> use ARCH_WANT_GENERAL_HUGETLB config option.
>>
>> Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
>> ---
>>  include/linux/hugetlb.h |  3 +++
>>  mm/gup.c                |  6 ++++++
>>  mm/hugetlb.c            | 20 ++++++++++++++++++++
>>  3 files changed, 29 insertions(+)
>>
>> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
>> index 7d953c2..71832e1 100644
>> --- a/include/linux/hugetlb.h
>> +++ b/include/linux/hugetlb.h
>> @@ -115,6 +115,8 @@ struct page *follow_huge_pmd(struct mm_struct *mm, unsigned long address,
>>  				pmd_t *pmd, int flags);
>>  struct page *follow_huge_pud(struct mm_struct *mm, unsigned long address,
>>  				pud_t *pud, int flags);
>> +struct page *follow_huge_pgd(struct mm_struct *mm, unsigned long address,
>> +				pgd_t *pgd, int flags);
>>  int pmd_huge(pmd_t pmd);
>>  int pud_huge(pud_t pmd);
>>  unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
>> @@ -143,6 +145,7 @@ static inline void hugetlb_show_meminfo(void)
>>  }
>>  #define follow_huge_pmd(mm, addr, pmd, flags)	NULL
>>  #define follow_huge_pud(mm, addr, pud, flags)	NULL
>> +#define follow_huge_pgd(mm, addr, pgd, flags)	NULL
>>  #define prepare_hugepage_range(file, addr, len)	(-EINVAL)
>>  #define pmd_huge(x)	0
>>  #define pud_huge(x)	0
>> diff --git a/mm/gup.c b/mm/gup.c
>> index fb87aea..9bac78c 100644
>> --- a/mm/gup.c
>> +++ b/mm/gup.c
>> @@ -234,6 +234,12 @@ struct page *follow_page_mask(struct vm_area_struct *vma,
>>  	pgd = pgd_offset(mm, address);
>>  	if (pgd_none(*pgd) || unlikely(pgd_bad(*pgd)))
>>  		return no_page_table(vma, flags);
>> +	if (pgd_huge(*pgd) && vma->vm_flags & VM_HUGETLB) {
>> +		page = follow_huge_pgd(mm, address, pgd, flags);
>> +		if (page)
>> +			return page;
>> +		return no_page_table(vma, flags);
> This will return NULL as well?

That right, no_page_table() returns NULL for FOLL_GET when we fall through
after failing on follow_huge_pgd().

>> +	}
>>  
>>  	pud = pud_offset(pgd, address);
>>  	if (pud_none(*pud))
>> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
>> index 19d0d08..5ea3158 100644
>> --- a/mm/hugetlb.c
>> +++ b/mm/hugetlb.c
>> @@ -4250,6 +4250,11 @@ pte_t *huge_pte_alloc(struct mm_struct *mm,
>>  	pte_t *pte = NULL;
>>  
>>  	pgd = pgd_offset(mm, addr);
>> +	if (sz == PGDIR_SIZE) {
>> +		pte = (pte_t *)pgd;
>> +		goto huge_pgd;
>> +	}
>> +
> 
> No allocation for a pgd slot - right?

No, its already allocated for the mm during creation.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
