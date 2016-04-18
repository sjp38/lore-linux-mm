Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f198.google.com (mail-ob0-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1E85F6B007E
	for <linux-mm@kvack.org>; Mon, 18 Apr 2016 04:42:32 -0400 (EDT)
Received: by mail-ob0-f198.google.com with SMTP id th5so163149613obc.1
        for <linux-mm@kvack.org>; Mon, 18 Apr 2016 01:42:32 -0700 (PDT)
Received: from e28smtp06.in.ibm.com (e28smtp06.in.ibm.com. [125.16.236.6])
        by mx.google.com with ESMTPS id g130si20154179ioa.170.2016.04.18.01.42.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 18 Apr 2016 01:42:31 -0700 (PDT)
Received: from localhost
	by e28smtp06.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Mon, 18 Apr 2016 14:12:28 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay03.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u3I8gKMV8257948
	for <linux-mm@kvack.org>; Mon, 18 Apr 2016 14:12:21 +0530
Received: from d28av01.in.ibm.com (localhost [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u3IEAMUw030859
	for <linux-mm@kvack.org>; Mon, 18 Apr 2016 19:40:24 +0530
Message-ID: <57149DE9.9060600@linux.vnet.ibm.com>
Date: Mon, 18 Apr 2016 14:12:17 +0530
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 03/10] mm/hugetlb: Protect follow_huge_(pud|pgd) functions
 from race
References: <201604071708.osnfXWQP%fengguang.wu@intel.com> <570B3E51.2090308@linux.vnet.ibm.com>
In-Reply-To: <570B3E51.2090308@linux.vnet.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, hughd@google.com, linux-kernel@vger.kernel.org, dave.hansen@intel.com, kbuild-all@01.org, kirill@shutemov.name, n-horiguchi@ah.jp.nec.com, mgorman@techsingularity.net, akpm@linux-foundation.org, aneesh.kumar@linux.vnet.ibm.com

On 04/11/2016 11:34 AM, Anshuman Khandual wrote:
> On 04/07/2016 03:04 PM, kbuild test robot wrote:
>> > All errors (new ones prefixed by >>):
>> > 
>> >    mm/hugetlb.c: In function 'follow_huge_pud':
>>>>>> >>> >> mm/hugetlb.c:4360:3: error: implicit declaration of function 'pud_page' [-Werror=implicit-function-declaration]
>> >       page = pud_page(*pud) + ((address & ~PUD_MASK) >> PAGE_SHIFT);
>> >       ^
>> >    mm/hugetlb.c:4360:8: warning: assignment makes pointer from integer without a cast
>> >       page = pud_page(*pud) + ((address & ~PUD_MASK) >> PAGE_SHIFT);
>> >            ^
>> >    mm/hugetlb.c: In function 'follow_huge_pgd':
>> >    mm/hugetlb.c:4395:3: error: implicit declaration of function 'pgd_page' [-Werror=implicit-function-declaration]
>> >       page = pgd_page(*pgd) + ((address & ~PGDIR_MASK) >> PAGE_SHIFT);
> Both the build errors here are because of the fact that pgd_page() is
> not available for some platforms and config options. It got missed as
> I ran only powerpc config options for build test purpose. My bad, will
> fix it.

The following change seems to fix the build problem on S390 but will
require some inputs from S390 maintainers regarding the functional
correctness of the patch.

diff --git a/arch/s390/include/asm/pgtable.h b/arch/s390/include/asm/pgtable.h
index 2f66645..834a8a6 100644
--- a/arch/s390/include/asm/pgtable.h
+++ b/arch/s390/include/asm/pgtable.h
@@ -963,6 +963,8 @@ static inline pmd_t *pmd_offset(pud_t *pud, unsigned long address)
 #define pte_page(x) pfn_to_page(pte_pfn(x))
 
 #define pmd_page(pmd) pfn_to_page(pmd_pfn(pmd))
+#define pud_page(pud) pud_val(pud)
+#define pgd_page(pgd) pgd_val(pgd)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
