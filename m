Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7B0736B0398
	for <linux-mm@kvack.org>; Wed,  9 May 2018 04:16:19 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id u56-v6so22732178wrf.18
        for <linux-mm@kvack.org>; Wed, 09 May 2018 01:16:19 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z15-v6si1648634ede.189.2018.05.09.01.16.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 09 May 2018 01:16:18 -0700 (PDT)
Date: Wed, 9 May 2018 10:16:15 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH -mm] mm, pagemap: Hide swap entry for unprivileged users
Message-ID: <20180509081615.GF32366@dhcp22.suse.cz>
References: <20180508012745.7238-1-ying.huang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180508012745.7238-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Andrei Vagin <avagin@openvz.org>, Jerome Glisse <jglisse@redhat.com>, Daniel Colascione <dancol@google.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Tue 08-05-18 09:27:45, Huang, Ying wrote:
> From: Huang Ying <ying.huang@intel.com>
> 
> In ab676b7d6fbf ("pagemap: do not leak physical addresses to
> non-privileged userspace"), the /proc/PID/pagemap is restricted to be
> readable only by CAP_SYS_ADMIN to address some security issue.  In
> 1c90308e7a77 ("pagemap: hide physical addresses from non-privileged
> users"), the restriction is relieved to make /proc/PID/pagemap
> readable, but hide the physical addresses for non-privileged users.
> But the swap entries are readable for non-privileged users too.  This
> has some security issues.  For example, for page under migrating, the
> swap entry has physical address information.  So, in this patch, the
> swap entries are hided for non-privileged users too.

Migration entries are quite ephemeral so I am not sure how this could be
abused. But I do agree that hiding swap entries make some sense from
consistency POV

> Fixes: 1c90308e7a77 ("pagemap: hide physical addresses from non-privileged users")
> Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
> Suggested-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> Cc: Andrei Vagin <avagin@openvz.org>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Jerome Glisse <jglisse@redhat.com>
> Cc: Daniel Colascione <dancol@google.com>
> Cc: Zi Yan <zi.yan@cs.rutgers.edu>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  fs/proc/task_mmu.c | 26 ++++++++++++++++----------
>  1 file changed, 16 insertions(+), 10 deletions(-)
> 
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index a20c6e495bb2..ff947fdd7c71 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -1258,8 +1258,9 @@ static pagemap_entry_t pte_to_pagemap_entry(struct pagemapread *pm,
>  		if (pte_swp_soft_dirty(pte))
>  			flags |= PM_SOFT_DIRTY;
>  		entry = pte_to_swp_entry(pte);
> -		frame = swp_type(entry) |
> -			(swp_offset(entry) << MAX_SWAPFILES_SHIFT);
> +		if (pm->show_pfn)
> +			frame = swp_type(entry) |
> +				(swp_offset(entry) << MAX_SWAPFILES_SHIFT);
>  		flags |= PM_SWAP;
>  		if (is_migration_entry(entry))
>  			page = migration_entry_to_page(entry);
> @@ -1310,11 +1311,14 @@ static int pagemap_pmd_range(pmd_t *pmdp, unsigned long addr, unsigned long end,
>  #ifdef CONFIG_ARCH_ENABLE_THP_MIGRATION
>  		else if (is_swap_pmd(pmd)) {
>  			swp_entry_t entry = pmd_to_swp_entry(pmd);
> -			unsigned long offset = swp_offset(entry);
> +			unsigned long offset;
>  
> -			offset += (addr & ~PMD_MASK) >> PAGE_SHIFT;
> -			frame = swp_type(entry) |
> -				(offset << MAX_SWAPFILES_SHIFT);
> +			if (pm->show_pfn) {
> +				offset = swp_offset(entry) +
> +					((addr & ~PMD_MASK) >> PAGE_SHIFT);
> +				frame = swp_type(entry) |
> +					(offset << MAX_SWAPFILES_SHIFT);
> +			}
>  			flags |= PM_SWAP;
>  			if (pmd_swp_soft_dirty(pmd))
>  				flags |= PM_SOFT_DIRTY;
> @@ -1332,10 +1336,12 @@ static int pagemap_pmd_range(pmd_t *pmdp, unsigned long addr, unsigned long end,
>  			err = add_to_pagemap(addr, &pme, pm);
>  			if (err)
>  				break;
> -			if (pm->show_pfn && (flags & PM_PRESENT))
> -				frame++;
> -			else if (flags & PM_SWAP)
> -				frame += (1 << MAX_SWAPFILES_SHIFT);
> +			if (pm->show_pfn) {
> +				if (flags & PM_PRESENT)
> +					frame++;
> +				else if (flags & PM_SWAP)
> +					frame += (1 << MAX_SWAPFILES_SHIFT);
> +			}
>  		}
>  		spin_unlock(ptl);
>  		return err;
> -- 
> 2.17.0
> 

-- 
Michal Hocko
SUSE Labs
