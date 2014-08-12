Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 9E9A16B0035
	for <linux-mm@kvack.org>; Tue, 12 Aug 2014 11:43:59 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id et14so13182039pad.35
        for <linux-mm@kvack.org>; Tue, 12 Aug 2014 08:43:59 -0700 (PDT)
Received: from e28smtp02.in.ibm.com (e28smtp02.in.ibm.com. [122.248.162.2])
        by mx.google.com with ESMTPS id pj8si12753029pdb.54.2014.08.12.08.43.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 12 Aug 2014 08:43:58 -0700 (PDT)
Received: from /spool/local
	by e28smtp02.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 12 Aug 2014 21:13:55 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 4BAEEE0019
	for <linux-mm@kvack.org>; Tue, 12 Aug 2014 21:15:49 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s7CFiCYK65339396
	for <linux-mm@kvack.org>; Tue, 12 Aug 2014 21:14:13 +0530
Received: from d28av01.in.ibm.com (localhost [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s7CFhnim025526
	for <linux-mm@kvack.org>; Tue, 12 Aug 2014 21:13:49 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH] hugetlb_cgroup: use lockdep_assert_held rather than spin_is_locked
In-Reply-To: <1407849830-22500-1-git-send-email-mhocko@suse.cz>
References: <1407849830-22500-1-git-send-email-mhocko@suse.cz>
Date: Tue, 12 Aug 2014 21:13:39 +0530
Message-ID: <87r40l67dg.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko <mhocko@suse.cz> writes:

> spin_lock may be an empty struct for !SMP configurations and so
> arch_spin_is_locked may return unconditional 0 and trigger the VM_BUG_ON
> even when the lock is held.
>
> Replace spin_is_locked by lockdep_assert_held. We will not BUG anymore
> but it is questionable whether crashing makes a lot of sense in the
> uncharge path. Uncharge happens after the last page reference was
> released so nobody should touch the page and the function doesn't update
> any shared state except for res counter which uses synchronization of
> its own.

We do update the hugepage's hugetlb cgroup details. But as you mentioned,
this should not be an issue because we are in hugepage free.

Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

>
> Signed-off-by: Michal Hocko <mhocko@suse.cz>
> ---
>  mm/hugetlb_cgroup.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/mm/hugetlb_cgroup.c b/mm/hugetlb_cgroup.c
> index 9aae6f47433f..9edf189a5ef3 100644
> --- a/mm/hugetlb_cgroup.c
> +++ b/mm/hugetlb_cgroup.c
> @@ -217,7 +217,7 @@ void hugetlb_cgroup_uncharge_page(int idx, unsigned long nr_pages,
>
>  	if (hugetlb_cgroup_disabled())
>  		return;
> -	VM_BUG_ON(!spin_is_locked(&hugetlb_lock));
> +	lockdep_assert_held(&hugetlb_lock);
>  	h_cg = hugetlb_cgroup_from_page(page);
>  	if (unlikely(!h_cg))
>  		return;
> -- 
> 2.1.0.rc1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
