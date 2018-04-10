Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id E97CC6B0003
	for <linux-mm@kvack.org>; Mon,  9 Apr 2018 21:28:58 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id 91-v6so8167524pla.18
        for <linux-mm@kvack.org>; Mon, 09 Apr 2018 18:28:58 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id q1si1011647pgr.455.2018.04.09.18.28.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Apr 2018 18:28:57 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -mm] mm, pagemap: Fix swap offset value for PMD migration entry
References: <20180408033737.10897-1-ying.huang@intel.com>
Date: Tue, 10 Apr 2018 09:28:54 +0800
In-Reply-To: <20180408033737.10897-1-ying.huang@intel.com> (Ying Huang's
	message of "Sun, 8 Apr 2018 11:37:37 +0800")
Message-ID: <87fu43lui1.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrei Vagin <avagin@openvz.org>, Dan Williams <dan.j.williams@intel.com>, Jerome Glisse <jglisse@redhat.com>, Daniel Colascione <dancol@google.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Hi, Andrew,

"Huang, Ying" <ying.huang@intel.com> writes:

> From: Huang Ying <ying.huang@intel.com>
>
> The swap offset reported by /proc/<pid>/pagemap may be not correct for
> PMD migration entry.  If addr passed into pagemap_range() isn't
> aligned with PMD start address, the swap offset reported doesn't
> reflect this.  And in the loop to report information of each sub-page,
> the swap offset isn't increased accordingly as that for PFN.
>
> BTW: migration swap entries have PFN information, do we need to
> restrict whether to show them?
>
> Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Cc: Andrei Vagin <avagin@openvz.org>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: "Jerome Glisse" <jglisse@redhat.com>
> Cc: Daniel Colascione <dancol@google.com>
> Cc: Zi Yan <zi.yan@cs.rutgers.edu>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> ---
>  fs/proc/task_mmu.c | 6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)
>
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index 65ae54659833..757e748da613 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -1310,9 +1310,11 @@ static int pagemap_pmd_range(pmd_t *pmdp, unsigned long addr, unsigned long end,
>  #ifdef CONFIG_ARCH_ENABLE_THP_MIGRATION
>  		else if (is_swap_pmd(pmd)) {
>  			swp_entry_t entry = pmd_to_swp_entry(pmd);
> +			unsigned long offset = swp_offset(entry);
>  
> +			offset += (addr & ~PMD_MASK) >> PAGE_SHIFT;
>  			frame = swp_type(entry) |
> -				(swp_offset(entry) << MAX_SWAPFILES_SHIFT);
> +				(offset << MAX_SWAPFILES_SHIFT);
>  			flags |= PM_SWAP;
>  			if (pmd_swp_soft_dirty(pmd))
>  				flags |= PM_SOFT_DIRTY;
> @@ -1332,6 +1334,8 @@ static int pagemap_pmd_range(pmd_t *pmdp, unsigned long addr, unsigned long end,
>  				break;
>  			if (pm->show_pfn && (flags & PM_PRESENT))
>  				frame++;
> +			else if (flags | PM_SWAP)

Oops, I just found a typo here, it should be,

+			else if (flags & PM_SWAP)

Sorry about that.  Do I need to refresh the patch or you will fix it
inline?

Best Regards,
Huang, Ying

> +				frame += (1 << MAX_SWAPFILES_SHIFT);
>  		}
>  		spin_unlock(ptl);
>  		return err;
