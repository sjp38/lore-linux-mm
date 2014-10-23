Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 7B02E6B0073
	for <linux-mm@kvack.org>; Thu, 23 Oct 2014 04:09:33 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id fp1so599027pdb.25
        for <linux-mm@kvack.org>; Thu, 23 Oct 2014 01:09:33 -0700 (PDT)
Received: from e23smtp01.au.ibm.com (e23smtp01.au.ibm.com. [202.81.31.143])
        by mx.google.com with ESMTPS id oq9si884857pbb.234.2014.10.23.01.09.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 23 Oct 2014 01:09:32 -0700 (PDT)
Received: from /spool/local
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 23 Oct 2014 18:09:27 +1000
Received: from d23relay10.au.ibm.com (d23relay10.au.ibm.com [9.190.26.77])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id AEA0E2BB0047
	for <linux-mm@kvack.org>; Thu, 23 Oct 2014 19:09:23 +1100 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id s9N8BFlg17105018
	for <linux-mm@kvack.org>; Thu, 23 Oct 2014 19:11:23 +1100
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s9N88oDI008760
	for <linux-mm@kvack.org>; Thu, 23 Oct 2014 19:08:50 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH V2 1/2] mm: Update generic gup implementation to handle hugepage directory
In-Reply-To: <20141022160224.9c2268795e55d5a2eff5b94d@linux-foundation.org>
References: <1413520687-31729-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20141022160224.9c2268795e55d5a2eff5b94d@linux-foundation.org>
Date: Thu, 23 Oct 2014 13:38:30 +0530
Message-ID: <87r3xzgqdd.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Steve Capper <steve.capper@linaro.org>, Andrea Arcangeli <aarcange@redhat.com>, benh@kernel.crashing.org, mpe@ellerman.id.au, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-arch@vger.kernel.org

Andrew Morton <akpm@linux-foundation.org> writes:

> On Fri, 17 Oct 2014 10:08:06 +0530 "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:
>
>> Update generic gup implementation with powerpc specific details.
>> On powerpc at pmd level we can have hugepte, normal pmd pointer
>> or a pointer to the hugepage directory.
>> 
>> ...
>>
>> --- a/arch/arm/include/asm/pgtable.h
>> +++ b/arch/arm/include/asm/pgtable.h
>> @@ -181,6 +181,8 @@ extern pgd_t swapper_pg_dir[PTRS_PER_PGD];
>>  /* to find an entry in a kernel page-table-directory */
>>  #define pgd_offset_k(addr)	pgd_offset(&init_mm, addr)
>>  
>> +#define pgd_huge(pgd)		(0)
>> +
>>  #define pmd_none(pmd)		(!pmd_val(pmd))
>>  #define pmd_present(pmd)	(pmd_val(pmd))
>>  
>> diff --git a/arch/arm64/include/asm/pgtable.h b/arch/arm64/include/asm/pgtable.h
>> index cefd3e825612..ed8f42497ac4 100644
>> --- a/arch/arm64/include/asm/pgtable.h
>> +++ b/arch/arm64/include/asm/pgtable.h
>> @@ -464,6 +464,8 @@ static inline pmd_t pmd_modify(pmd_t pmd, pgprot_t newprot)
>>  extern pgd_t swapper_pg_dir[PTRS_PER_PGD];
>>  extern pgd_t idmap_pg_dir[PTRS_PER_PGD];
>>  
>> +#define pgd_huge(pgd)		(0)
>> +
>
> So only arm, arm64 and powerpc implement CONFIG_HAVE_GENERIC_RCU_GUP
> and only powerpc impements pgd_huge().
>
> Could we get a bit of documentation in place for pgd_huge() so that
> people who aren't familiar with powerpc can understand what's going
> on?


I ended up moving that to include/linux/hugetlb.h with the below
comments added. Let me know if the below is ok 

/*
 * hugepages at page global directory. If arch support
 * hugepages at pgd level, they need to define this.
 */
#ifndef pgd_huge
#define pgd_huge(x)	0
#endif

#ifndef is_hugepd
/*
 * Some architectures requires a hugepage directory format that is
 * required to support multiple hugepage sizes. For example
 * a4fe3ce7699bfe1bd88f816b55d42d8fe1dac655 introduced the same
 * on powerpc. This allows for a more flexible hugepage pagetable
 * layout.
 */
typedef struct { unsigned long pd; } hugepd_t;
#define is_hugepd(hugepd) (0)
#define __hugepd(x) ((hugepd_t) { (x) })
static inline int gup_huge_pd(hugepd_t hugepd, unsigned long addr,
			      unsigned pdshift, unsigned long end,
			      int write, struct page **pages, int *nr)
{
	return 0;
}
#else
extern int gup_huge_pd(hugepd_t hugepd, unsigned long addr,
		       unsigned pdshift, unsigned long end,
		       int write, struct page **pages, int *nr);
#endif


-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
