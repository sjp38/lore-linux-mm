Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id DAF3F6B0038
	for <linux-mm@kvack.org>; Tue,  8 Nov 2016 03:14:42 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id n85so63753817pfi.4
        for <linux-mm@kvack.org>; Tue, 08 Nov 2016 00:14:42 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id m87si30919918pfi.148.2016.11.08.00.14.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Nov 2016 00:14:42 -0800 (PST)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uA88DjNq043703
	for <linux-mm@kvack.org>; Tue, 8 Nov 2016 03:14:41 -0500
Received: from e28smtp09.in.ibm.com (e28smtp09.in.ibm.com [125.16.236.9])
	by mx0b-001b2d01.pphosted.com with ESMTP id 26k9vvb9de-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 08 Nov 2016 03:14:40 -0500
Received: from localhost
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Tue, 8 Nov 2016 13:44:37 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id BA0E6E0066
	for <linux-mm@kvack.org>; Tue,  8 Nov 2016 13:44:38 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay04.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id uA88E06u45744330
	for <linux-mm@kvack.org>; Tue, 8 Nov 2016 13:44:00 +0530
Received: from d28av05.in.ibm.com (localhost [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id uA88Dtl3019428
	for <linux-mm@kvack.org>; Tue, 8 Nov 2016 13:43:59 +0530
Subject: Re: [PATCH v2 05/12] mm: thp: add core routines for thp/pmd migration
References: <1478561517-4317-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1478561517-4317-6-git-send-email-n-horiguchi@ah.jp.nec.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Tue, 8 Nov 2016 13:43:54 +0530
MIME-Version: 1.0
In-Reply-To: <1478561517-4317-6-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <58218942.8010608@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Pavel Emelyanov <xemul@parallels.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Balbir Singh <bsingharora@gmail.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On 11/08/2016 05:01 AM, Naoya Horiguchi wrote:
> This patch prepares thp migration's core code. These code will be open when
> unmap_and_move() stops unconditionally splitting thp and get_new_page() starts
> to allocate destination thps.
> 
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
> 
> diff --git v4.9-rc2-mmotm-2016-10-27-18-27/arch/x86/include/asm/pgtable_64.h v4.9-rc2-mmotm-2016-10-27-18-27_patched/arch/x86/include/asm/pgtable_64.h
> index 1cc82ec..3a1b48e 100644
> --- v4.9-rc2-mmotm-2016-10-27-18-27/arch/x86/include/asm/pgtable_64.h
> +++ v4.9-rc2-mmotm-2016-10-27-18-27_patched/arch/x86/include/asm/pgtable_64.h
> @@ -167,7 +167,9 @@ static inline int pgd_large(pgd_t pgd) { return 0; }
>  					 ((type) << (SWP_TYPE_FIRST_BIT)) \
>  					 | ((offset) << SWP_OFFSET_FIRST_BIT) })
>  #define __pte_to_swp_entry(pte)		((swp_entry_t) { pte_val((pte)) })
> +#define __pmd_to_swp_entry(pte)		((swp_entry_t) { pmd_val((pmd)) })

The above macro takes *pte* but evaluates on *pmd*, guess its should
be fixed either way.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
