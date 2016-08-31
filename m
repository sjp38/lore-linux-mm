Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0EB546B0260
	for <linux-mm@kvack.org>; Wed, 31 Aug 2016 11:17:34 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id k135so39109656lfb.2
        for <linux-mm@kvack.org>; Wed, 31 Aug 2016 08:17:33 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id x206si4450887wmg.67.2016.08.31.08.17.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Aug 2016 08:17:32 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id i5so8097651wmg.2
        for <linux-mm@kvack.org>; Wed, 31 Aug 2016 08:17:32 -0700 (PDT)
Date: Wed, 31 Aug 2016 17:17:30 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: memcontrol: Make the walk_page_range() limit obvious
Message-ID: <20160831151730.GF21661@dhcp22.suse.cz>
References: <1472655897-22532-1-git-send-email-james.morse@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1472655897-22532-1-git-send-email-james.morse@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Morse <james.morse@arm.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

On Wed 31-08-16 16:04:57, James Morse wrote:
> Trying to walk all of virtual memory requires architecture specific
> knowledge. On x86_64, addresses must be sign extended from bit 48,
> whereas on arm64 the top VA_BITS of address space have their own set
> of page tables.
> 
> mem_cgroup_count_precharge() and mem_cgroup_move_charge() both call
> walk_page_range() on the range 0 to ~0UL, neither provide a pte_hole
> callback, which causes the current implementation to skip non-vma regions.
> 
> As this call only expects to walk user address space, make it walk
> 0 to  'highest_vm_end'.
> 
> Signed-off-by: James Morse <james.morse@arm.com>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> ---
> This is in preparation for a RFC series that allows walk_page_range() to
> walk kernel page tables too.

OK, so do I get it right that this is only needed with that change?
Because AFAICS walk_page_range will be bound to the last vma->vm_end
right now. If this is the case this should be mentioned in the changelog
because the above might confuse somebody to think this is a bug fix.

Other than that this seams reasonable to me.

> 
>  mm/memcontrol.c | 6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 2ff0289ad061..bfd54b43beb9 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -4712,7 +4712,8 @@ static unsigned long mem_cgroup_count_precharge(struct mm_struct *mm)
>  		.mm = mm,
>  	};
>  	down_read(&mm->mmap_sem);
> -	walk_page_range(0, ~0UL, &mem_cgroup_count_precharge_walk);
> +	walk_page_range(0, mm->highest_vm_end,
> +			&mem_cgroup_count_precharge_walk);
>  	up_read(&mm->mmap_sem);
>  
>  	precharge = mc.precharge;
> @@ -5000,7 +5001,8 @@ retry:
>  	 * When we have consumed all precharges and failed in doing
>  	 * additional charge, the page walk just aborts.
>  	 */
> -	walk_page_range(0, ~0UL, &mem_cgroup_move_charge_walk);
> +	walk_page_range(0, mc.mm->highest_vm_end, &mem_cgroup_move_charge_walk);
> +
>  	up_read(&mc.mm->mmap_sem);
>  	atomic_dec(&mc.from->moving_account);
>  }
> -- 
> 2.8.0.rc3
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
