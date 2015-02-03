Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id D8DF76B006C
	for <linux-mm@kvack.org>; Tue,  3 Feb 2015 08:29:32 -0500 (EST)
Received: by mail-wi0-f176.google.com with SMTP id bs8so24375752wib.3
        for <linux-mm@kvack.org>; Tue, 03 Feb 2015 05:29:32 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id jd3si2244893wic.15.2015.02.03.05.29.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 03 Feb 2015 05:29:30 -0800 (PST)
Date: Tue, 3 Feb 2015 14:29:28 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm: fix arithmetic overflow in __vm_enough_memory()
Message-ID: <20150203132928.GB8914@dhcp22.suse.cz>
References: <1422536763-31325-1-git-send-email-klamm@yandex-team.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1422536763-31325-1-git-send-email-klamm@yandex-team.ru>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <klamm@yandex-team.ru>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Andrew Shewmaker <agshew@gmail.com>, Rik van Riel <riel@redhat.com>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, stable@vger.kernel.org

On Thu 29-01-15 16:06:03, Roman Gushchin wrote:
> I noticed, that "allowed" can easily overflow by falling below 0,
> because (total_vm / 32) can be larger than "allowed". The problem
> occurs in OVERCOMMIT_NONE mode.

s@OVERCOMMIT_NONE@OVERCOMMIT_NEVER@
 
> In this case, a huge allocation can success and overcommit the system
> (despite OVERCOMMIT_NONE mode). All subsequent allocations will fall
> (system-wide), so system become unusable.
> 
> The problem was masked out by commit c9b1d0981fcc
> ("mm: limit growth of 3% hardcoded other user reserve"),
> but it's easy to reproduce it on older kernels:
> 1) set overcommit_memory sysctl to 2
> 2) mmap() large file multiple times (with VM_SHARED flag)
> 3) try to malloc() large amount of memory
> 
> It also can be reproduced on newer kernels, but miss-configured
> sysctl_user_reserve_kbytes is required.
> 
> Fix this issue by switching to signed arithmetic here.
> 
> Signed-off-by: Roman Gushchin <klamm@yandex-team.ru>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Andrew Shewmaker <agshew@gmail.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> Cc: stable@vger.kernel.org

With Andrew min -> min_t fixup
Reviewed-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/mmap.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 7f684d5..5aa8dfe 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -152,7 +152,7 @@ EXPORT_SYMBOL_GPL(vm_memory_committed);
>   */
>  int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin)
>  {
> -	unsigned long free, allowed, reserve;
> +	long free, allowed, reserve;
>  
>  	VM_WARN_ONCE(percpu_counter_read(&vm_committed_as) <
>  			-(s64)vm_committed_as_batch * num_online_cpus(),
> @@ -220,7 +220,7 @@ int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin)
>  	 */
>  	if (mm) {
>  		reserve = sysctl_user_reserve_kbytes >> (PAGE_SHIFT - 10);
> -		allowed -= min(mm->total_vm / 32, reserve);
> +		allowed -= min((long)mm->total_vm / 32, reserve);
>  	}
>  
>  	if (percpu_counter_read_positive(&vm_committed_as) < allowed)
> -- 
> 2.1.0
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
