Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 557C66B0038
	for <linux-mm@kvack.org>; Tue, 17 Oct 2017 05:47:51 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id p54so1357643qtc.5
        for <linux-mm@kvack.org>; Tue, 17 Oct 2017 02:47:51 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id q196si2196198qke.194.2017.10.17.02.47.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Oct 2017 02:47:50 -0700 (PDT)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9H9lh8L071338
	for <linux-mm@kvack.org>; Tue, 17 Oct 2017 05:47:49 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2dna1sdngd-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 17 Oct 2017 05:47:49 -0400
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Tue, 17 Oct 2017 10:47:47 +0100
Received: from d23av05.au.ibm.com (d23av05.au.ibm.com [9.190.234.119])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v9H9lh4p18546816
	for <linux-mm@kvack.org>; Tue, 17 Oct 2017 09:47:44 GMT
Received: from d23av05.au.ibm.com (localhost [127.0.0.1])
	by d23av05.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v9H9lg2n032568
	for <linux-mm@kvack.org>; Tue, 17 Oct 2017 20:47:42 +1100
Subject: Re: [PATCH -mm] mm, pagemap: Fix soft dirty marking for PMD migration
 entry
References: <20171017081818.31795-1-ying.huang@intel.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Tue, 17 Oct 2017 15:17:38 +0530
MIME-Version: 1.0
In-Reply-To: <20171017081818.31795-1-ying.huang@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Message-Id: <8fd6b1d8-6dc3-29a8-0377-e4323b74d6af@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, David Rientjes <rientjes@google.com>, Arnd Bergmann <arnd@arndb.de>, Hugh Dickins <hughd@google.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Daniel Colascione <dancol@google.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

On 10/17/2017 01:48 PM, Huang, Ying wrote:
> From: Huang Ying <ying.huang@intel.com>
> 
> Now, when the page table is walked in the implementation of
> /proc/<pid>/pagemap, pmd_soft_dirty() is used for both the PMD huge
> page map and the PMD migration entries.  That is wrong,
> pmd_swp_soft_dirty() should be used for the PMD migration entries
> instead because the different page table entry flag is used.

Yeah, different flags can be used on various archs to represent
mapped a PMD and a migration PMD entry. Sounds good.

> 
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Arnd Bergmann <arnd@arndb.de>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: "JA(C)rA'me Glisse" <jglisse@redhat.com>
> Cc: Daniel Colascione <dancol@google.com>
> Cc: Zi Yan <zi.yan@cs.rutgers.edu>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
> ---
>  fs/proc/task_mmu.c | 6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index 2593a0c609d7..01aad772f8db 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -1311,13 +1311,15 @@ static int pagemap_pmd_range(pmd_t *pmdp, unsigned long addr, unsigned long end,
>  		pmd_t pmd = *pmdp;
>  		struct page *page = NULL;
>  
> -		if ((vma->vm_flags & VM_SOFTDIRTY) || pmd_soft_dirty(pmd))
> +		if (vma->vm_flags & VM_SOFTDIRTY)
>  			flags |= PM_SOFT_DIRTY;
>  
>  		if (pmd_present(pmd)) {
>  			page = pmd_page(pmd);
>  
>  			flags |= PM_PRESENT;
> +			if (pmd_soft_dirty(pmd))
> +				flags |= PM_SOFT_DIRTY;
>  			if (pm->show_pfn)
>  				frame = pmd_pfn(pmd) +
>  					((addr & ~PMD_MASK) >> PAGE_SHIFT);
> @@ -1329,6 +1331,8 @@ static int pagemap_pmd_range(pmd_t *pmdp, unsigned long addr, unsigned long end,
>  			frame = swp_type(entry) |
>  				(swp_offset(entry) << MAX_SWAPFILES_SHIFT);
>  			flags |= PM_SWAP;
> +			if (pmd_swp_soft_dirty(pmd))
> +				flags |= PM_SOFT_DIRTY;

Though I was initially skeptical about whether this will compile
on POWER because of lack of a pmd_swp_soft_dirty() definition
but it turns out we have a generic one to fallback on as we dont
define ARCH_ENABLE_THP_MIGRATION yet.

#ifdef CONFIG_HAVE_ARCH_SOFT_DIRTY
#ifndef CONFIG_ARCH_ENABLE_THP_MIGRATION
static inline pmd_t pmd_swp_mksoft_dirty(pmd_t pmd)
{
	return pmd;
}

static inline int pmd_swp_soft_dirty(pmd_t pmd)
{
	return 0;
}

static inline pmd_t pmd_swp_clear_soft_dirty(pmd_t pmd)
{
	return pmd;
}
#endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
