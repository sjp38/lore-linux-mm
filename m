Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 307156B0037
	for <linux-mm@kvack.org>; Thu, 31 Oct 2013 04:50:24 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id y10so2066676pdj.24
        for <linux-mm@kvack.org>; Thu, 31 Oct 2013 01:50:23 -0700 (PDT)
Received: from psmtp.com ([74.125.245.194])
        by mx.google.com with SMTP id c9si1211667pbj.52.2013.10.31.01.50.21
        for <linux-mm@kvack.org>;
        Thu, 31 Oct 2013 01:50:22 -0700 (PDT)
Date: Thu, 31 Oct 2013 09:50:17 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: + mm-memcg-lockdep-annotation-for-memcg-oom-lock.patch added to
 -mm tree
Message-ID: <20131031085017.GB13144@dhcp22.suse.cz>
References: <52718460.4+rPcYBdFtC2v3uh%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52718460.4+rPcYBdFtC2v3uh%akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, hannes@cmpxchg.org, linux-mm@kvack.org

On Wed 30-10-13 15:12:48, Andrew Morton wrote:
> Subject: + mm-memcg-lockdep-annotation-for-memcg-oom-lock.patch added to -mm tree
> To: hannes@cmpxchg.org,mhocko@suse.cz
> From: akpm@linux-foundation.org
> Date: Wed, 30 Oct 2013 15:12:48 -0700
> 
> 
> The patch titled
>      Subject: mm: memcg: lockdep annotation for memcg OOM lock
> has been added to the -mm tree.  Its filename is
>      mm-memcg-lockdep-annotation-for-memcg-oom-lock.patch
> 
> This patch should soon appear at
>     http://ozlabs.org/~akpm/mmots/broken-out/mm-memcg-lockdep-annotation-for-memcg-oom-lock.patch
> and later at
>     http://ozlabs.org/~akpm/mmotm/broken-out/mm-memcg-lockdep-annotation-for-memcg-oom-lock.patch
> 
> Before you just go and hit "reply", please:
>    a) Consider who else should be cc'ed
>    b) Prefer to cc a suitable mailing list as well
>    c) Ideally: find the original patch on the mailing list and do a
>       reply-to-all to that, adding suitable additional cc's
> 
> *** Remember to use Documentation/SubmitChecklist when testing your code ***
> 
> The -mm tree is included into linux-next and is updated
> there every 3-4 working days
> 
> ------------------------------------------------------
> From: Johannes Weiner <hannes@cmpxchg.org>
> Subject: mm: memcg: lockdep annotation for memcg OOM lock
> 
> The memcg OOM lock is a mutex-type lock that is open-coded due to memcg's
> special needs.  Add annotations for lockdep coverage.

I am not sure what this gives us to be honest. AA and AB-BA deadlocks
are impossible due to nature of the lock (it is trylock so we never
block on it).

> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@suse.cz>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  mm/memcontrol.c |   11 ++++++++++-
>  1 file changed, 10 insertions(+), 1 deletion(-)
> 
> diff -puN mm/memcontrol.c~mm-memcg-lockdep-annotation-for-memcg-oom-lock mm/memcontrol.c
> --- a/mm/memcontrol.c~mm-memcg-lockdep-annotation-for-memcg-oom-lock
> +++ a/mm/memcontrol.c
> @@ -54,6 +54,7 @@
>  #include <linux/page_cgroup.h>
>  #include <linux/cpu.h>
>  #include <linux/oom.h>
> +#include <linux/lockdep.h>
>  #include "internal.h"
>  #include <net/sock.h>
>  #include <net/ip.h>
> @@ -2046,6 +2047,12 @@ static int mem_cgroup_soft_reclaim(struc
>  	return total;
>  }
>  
> +#ifdef CONFIG_LOCKDEP
> +static struct lockdep_map memcg_oom_lock_dep_map = {
> +	.name = "memcg_oom_lock",
> +};
> +#endif
> +
>  static DEFINE_SPINLOCK(memcg_oom_lock);
>  
>  /*
> @@ -2083,7 +2090,8 @@ static bool mem_cgroup_oom_trylock(struc
>  			}
>  			iter->oom_lock = false;
>  		}
> -	}
> +	} else
> +		mutex_acquire(&memcg_oom_lock_dep_map, 0, 1, _RET_IP_);
>  
>  	spin_unlock(&memcg_oom_lock);
>  
> @@ -2095,6 +2103,7 @@ static void mem_cgroup_oom_unlock(struct
>  	struct mem_cgroup *iter;
>  
>  	spin_lock(&memcg_oom_lock);
> +	mutex_release(&memcg_oom_lock_dep_map, 1, _RET_IP_);
>  	for_each_mem_cgroup_tree(iter, memcg)
>  		iter->oom_lock = false;
>  	spin_unlock(&memcg_oom_lock);
> _
> 
> Patches currently in -mm which might be from hannes@cmpxchg.org are
> 
> percpu-fix-this_cpu_sub-subtrahend-casting-for-unsigneds.patch
> memcg-use-__this_cpu_sub-to-dec-stats-to-avoid-incorrect-subtrahend-casting.patch
> mm-memcg-use-proper-memcg-in-limit-bypass.patch
> mm-memcg-lockdep-annotation-for-memcg-oom-lock.patch
> mm-memcg-fix-test-for-child-groups.patch
> mm-nobootmemc-have-__free_pages_memory-free-in-larger-chunks.patch
> memcg-refactor-mem_control_numa_stat_show.patch
> memcg-support-hierarchical-memorynuma_stats.patch
> memblock-factor-out-of-top-down-allocation.patch
> memblock-introduce-bottom-up-allocation-mode.patch
> x86-mm-factor-out-of-top-down-direct-mapping-setup.patch
> x86-mem-hotplug-support-initialize-page-tables-in-bottom-up.patch
> x86-acpi-crash-kdump-do-reserve_crashkernel-after-srat-is-parsed.patch
> mem-hotplug-introduce-movable_node-boot-option.patch
> swap-add-a-simple-detector-for-inappropriate-swapin-readahead-fix.patch
> percpu-add-test-module-for-various-percpu-operations.patch
> linux-next.patch
> mm-avoid-increase-sizeofstruct-page-due-to-split-page-table-lock.patch
> mm-rename-use_split_ptlocks-to-use_split_pte_ptlocks.patch
> mm-convert-mm-nr_ptes-to-atomic_long_t.patch
> mm-introduce-api-for-split-page-table-lock-for-pmd-level.patch
> mm-thp-change-pmd_trans_huge_lock-to-return-taken-lock.patch
> mm-thp-move-ptl-taking-inside-page_check_address_pmd.patch
> mm-thp-do-not-access-mm-pmd_huge_pte-directly.patch
> mm-hugetlb-convert-hugetlbfs-to-use-split-pmd-lock.patch
> mm-convert-the-rest-to-new-page-table-lock-api.patch
> mm-implement-split-page-table-lock-for-pmd-level.patch
> x86-mm-enable-split-page-table-lock-for-pmd-level.patch
> debugging-keep-track-of-page-owners-fix-2-fix-fix-fix.patch
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
