Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id D89E86B0267
	for <linux-mm@kvack.org>; Thu, 10 Nov 2016 03:29:15 -0500 (EST)
Received: by mail-pa0-f71.google.com with SMTP id ro13so88614642pac.7
        for <linux-mm@kvack.org>; Thu, 10 Nov 2016 00:29:15 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id l5si3543510pgk.200.2016.11.10.00.29.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Nov 2016 00:29:15 -0800 (PST)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uAA8NkkC072253
	for <linux-mm@kvack.org>; Thu, 10 Nov 2016 03:29:14 -0500
Received: from e23smtp04.au.ibm.com (e23smtp04.au.ibm.com [202.81.31.146])
	by mx0b-001b2d01.pphosted.com with ESMTP id 26mkqvcuvp-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 10 Nov 2016 03:29:13 -0500
Received: from localhost
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Thu, 10 Nov 2016 18:29:10 +1000
Received: from d23relay08.au.ibm.com (d23relay08.au.ibm.com [9.185.71.33])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 32A8E357805A
	for <linux-mm@kvack.org>; Thu, 10 Nov 2016 19:29:08 +1100 (EST)
Received: from d23av05.au.ibm.com (d23av05.au.ibm.com [9.190.234.119])
	by d23relay08.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id uAA8T8lq35717156
	for <linux-mm@kvack.org>; Thu, 10 Nov 2016 19:29:08 +1100
Received: from d23av05.au.ibm.com (localhost [127.0.0.1])
	by d23av05.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id uAA8T6MY023258
	for <linux-mm@kvack.org>; Thu, 10 Nov 2016 19:29:08 +1100
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 05/12] mm: thp: add core routines for thp/pmd migration
References: <1478561517-4317-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1478561517-4317-6-git-send-email-n-horiguchi@ah.jp.nec.com>
Date: Thu, 10 Nov 2016 13:59:03 +0530
MIME-Version: 1.0
In-Reply-To: <1478561517-4317-6-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <58242FCF.50602@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Pavel Emelyanov <xemul@parallels.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Balbir Singh <bsingharora@gmail.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On 11/08/2016 05:01 AM, Naoya Horiguchi wrote:
> This patch prepares thp migration's core code. These code will be open when
> unmap_and_move() stops unconditionally splitting thp and get_new_page() starts
> to allocate destination thps.
> 

Snip

> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> ---
> ChangeLog v1 -> v2:
> - support pte-mapped thp, doubly-mapped thp
> ---
>  arch/x86/include/asm/pgtable_64.h |   2 +
>  include/linux/swapops.h           |  61 +++++++++++++++
>  mm/huge_memory.c                  | 154 ++++++++++++++++++++++++++++++++++++++
>  mm/migrate.c                      |  44 ++++++++++-
>  mm/pgtable-generic.c              |   3 +-
>  5 files changed, 262 insertions(+), 2 deletions(-)


> diff --git v4.9-rc2-mmotm-2016-10-27-18-27/mm/pgtable-generic.c v4.9-rc2-mmotm-2016-10-27-18-27_patched/mm/pgtable-generic.c
> index 71c5f91..6012343 100644
> --- v4.9-rc2-mmotm-2016-10-27-18-27/mm/pgtable-generic.c
> +++ v4.9-rc2-mmotm-2016-10-27-18-27_patched/mm/pgtable-generic.c
> @@ -118,7 +118,8 @@ pmd_t pmdp_huge_clear_flush(struct vm_area_struct *vma, unsigned long address,
>  {
>  	pmd_t pmd;
>  	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
> -	VM_BUG_ON(!pmd_trans_huge(*pmdp) && !pmd_devmap(*pmdp));
> +	VM_BUG_ON(pmd_present(*pmdp) && !pmd_trans_huge(*pmdp) &&
> +		  !pmd_devmap(*pmdp))

Its a valid VM_BUG_ON check but is it related to THP migration or
just a regular fix up ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
