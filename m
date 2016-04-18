Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 160C16B007E
	for <linux-mm@kvack.org>; Mon, 18 Apr 2016 04:44:43 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id t124so317676828pfb.1
        for <linux-mm@kvack.org>; Mon, 18 Apr 2016 01:44:43 -0700 (PDT)
Received: from e28smtp02.in.ibm.com (e28smtp02.in.ibm.com. [125.16.236.2])
        by mx.google.com with ESMTPS id vc15si2883277pab.8.2016.04.18.01.44.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 18 Apr 2016 01:44:42 -0700 (PDT)
Received: from localhost
	by e28smtp02.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Mon, 18 Apr 2016 14:14:39 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay02.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u3I8iYiH14221776
	for <linux-mm@kvack.org>; Mon, 18 Apr 2016 14:14:35 +0530
Received: from d28av05.in.ibm.com (localhost [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u3I8iXDm028870
	for <linux-mm@kvack.org>; Mon, 18 Apr 2016 14:14:36 +0530
Message-ID: <57149E68.5020207@linux.vnet.ibm.com>
Date: Mon, 18 Apr 2016 14:14:24 +0530
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 03/10] mm/hugetlb: Protect follow_huge_(pud|pgd) functions
 from race
References: <201604071717.fjhqVZh6%fengguang.wu@intel.com>
In-Reply-To: <201604071717.fjhqVZh6%fengguang.wu@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: dave.hansen@intel.com, mgorman@techsingularity.net, hughd@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kbuild-all@01.org, kirill@shutemov.name, n-horiguchi@ah.jp.nec.com, linuxppc-dev@lists.ozlabs.org, akpm@linux-foundation.org, aneesh.kumar@linux.vnet.ibm.com

On 04/07/2016 02:46 PM, kbuild test robot wrote:
> Hi Anshuman,
> 
> [auto build test ERROR on powerpc/next]
> [also build test ERROR on v4.6-rc2 next-20160407]
> [if your patch is applied to the wrong git tree, please drop us a note to help improving the system]
> 
> url:    https://github.com/0day-ci/linux/commits/Anshuman-Khandual/Enable-HugeTLB-page-migration-on-POWER/20160407-165841
> base:   https://git.kernel.org/pub/scm/linux/kernel/git/powerpc/linux.git next
> config: sparc64-allyesconfig (attached as .config)
> reproduce:
>         wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         # save the attached .config to linux build tree
>         make.cross ARCH=sparc64 
> 
> All error/warnings (new ones prefixed by >>):
> 
>    mm/hugetlb.c: In function 'follow_huge_pgd':
>>> >> mm/hugetlb.c:4395:3: error: implicit declaration of function 'pgd_page' [-Werror=implicit-function-declaration]
>       page = pgd_page(*pgd) + ((address & ~PGDIR_MASK) >> PAGE_SHIFT);
>       ^


The following change seems to fix the build problem on SPARC but will
require some inputs from SPARC maintainers regarding the functional
correctness of the patch.

diff --git a/arch/sparc/include/asm/pgtable_64.h
b/arch/sparc/include/asm/pgtable_64.h
index f089cfa..7b7e6a0 100644
--- a/arch/sparc/include/asm/pgtable_64.h
+++ b/arch/sparc/include/asm/pgtable_64.h
@@ -804,6 +804,7 @@ static inline unsigned long __pmd_page(pmd_t pmd)
 #define pmd_clear(pmdp)                        (pmd_val(*(pmdp)) = 0UL)
 #define pud_present(pud)               (pud_val(pud) != 0U)
 #define pud_clear(pudp)                        (pud_val(*(pudp)) = 0UL)
+#define pgd_page(pgd)                  (pgd_val(pgd))
 #define pgd_page_vaddr(pgd)            \
        ((unsigned long) __va(pgd_val(pgd)))
 #define pgd_present(pgd)               (pgd_val(pgd) != 0U)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
