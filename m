Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f180.google.com (mail-we0-f180.google.com [74.125.82.180])
	by kanga.kvack.org (Postfix) with ESMTP id B3BB86B0031
	for <linux-mm@kvack.org>; Tue, 17 Jun 2014 09:47:48 -0400 (EDT)
Received: by mail-we0-f180.google.com with SMTP id x48so7286422wes.11
        for <linux-mm@kvack.org>; Tue, 17 Jun 2014 06:47:48 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id es20si12684061wic.55.2014.06.17.06.47.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 17 Jun 2014 06:47:47 -0700 (PDT)
Date: Tue, 17 Jun 2014 15:47:45 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 03/12] mm: huge_memory: use GFP_TRANSHUGE when charging
 huge pages
Message-ID: <20140617134745.GB19886@dhcp22.suse.cz>
References: <1402948472-8175-1-git-send-email-hannes@cmpxchg.org>
 <1402948472-8175-4-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1402948472-8175-4-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 16-06-14 15:54:23, Johannes Weiner wrote:
> Transparent huge page charges prefer falling back to regular pages
> rather than spending a lot of time in direct reclaim.
> 
> Desired reclaim behavior is usually declared in the gfp mask, but THP
> charges use GFP_KERNEL and then rely on the fact that OOM is disabled
> for THP charges, and that OOM-disabled charges currently skip reclaim.

OOM-disabled charges do one round of reclaim currently.

> Needless to say, this is anything but obvious and quite error prone.
> 
> Convert THP charges to use GFP_TRANSHUGE instead, which implies
> __GFP_NORETRY, to indicate the low-latency requirement.

OK, this makes sense. It would be ideal if we could use the same gfp as
for allocation but that would be too much churn I guess because some
allocator use a allocation helper which deduces proper gfp flags without
giving them back to the caller.

Nevertheless, I would still prefer if 05/12 was moved before
this patch because this is strictly speaking a behavior change.
 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Anyway
Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/huge_memory.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index e60837dc785c..10cd7f2bf776 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -827,7 +827,7 @@ int do_huge_pmd_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  		count_vm_event(THP_FAULT_FALLBACK);
>  		return VM_FAULT_FALLBACK;
>  	}
> -	if (unlikely(mem_cgroup_charge_anon(page, mm, GFP_KERNEL))) {
> +	if (unlikely(mem_cgroup_charge_anon(page, mm, GFP_TRANSHUGE))) {
>  		put_page(page);
>  		count_vm_event(THP_FAULT_FALLBACK);
>  		return VM_FAULT_FALLBACK;
> @@ -1101,7 +1101,7 @@ alloc:
>  		goto out;
>  	}
>  
> -	if (unlikely(mem_cgroup_charge_anon(new_page, mm, GFP_KERNEL))) {
> +	if (unlikely(mem_cgroup_charge_anon(new_page, mm, GFP_TRANSHUGE))) {
>  		put_page(new_page);
>  		if (page) {
>  			split_huge_page(page);
> @@ -2368,7 +2368,7 @@ static void collapse_huge_page(struct mm_struct *mm,
>  	if (!new_page)
>  		return;
>  
> -	if (unlikely(mem_cgroup_charge_anon(new_page, mm, GFP_KERNEL)))
> +	if (unlikely(mem_cgroup_charge_anon(new_page, mm, GFP_TRANSHUGE)))
>  		return;
>  
>  	/*
> -- 
> 2.0.0
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
