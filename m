Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id B8A6F6B0031
	for <linux-mm@kvack.org>; Thu,  5 Sep 2013 09:24:18 -0400 (EDT)
Date: Thu, 5 Sep 2013 15:24:15 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 0/7] improve memcg oom killer robustness v2
Message-ID: <20130905132415.GD13666@dhcp22.suse.cz>
References: <1375549200-19110-1-git-send-email-hannes@cmpxchg.org>
 <20130803170831.GB23319@cmpxchg.org>
 <20130830215852.3E5D3D66@pobox.sk>
 <20130902123802.5B8E8CB1@pobox.sk>
 <20130903204850.GA1412@cmpxchg.org>
 <20130904101852.58E70042@pobox.sk>
 <20130905115430.GB856@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130905115430.GB856@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: azurIt <azurit@pobox.sk>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu 05-09-13 07:54:30, Johannes Weiner wrote:
[...]
> From: Johannes Weiner <hannes@cmpxchg.org>
> Subject: [patch] mm: memcg: handle non-error OOM situations more gracefully
> 
> Many places that can trigger a memcg OOM situation return gracefully
> and don't propagate VM_FAULT_OOM up the fault stack.
> 
> It's not practical to annotate all of them to disable the memcg OOM
> killer.  Instead, just clean up any set OOM state without warning in
> case the fault is not returning VM_FAULT_OOM.
> 
> Also fail charges immediately when the current task already is in an
> OOM context.  Otherwise, the previous context gets overwritten and the
> memcg reference is leaked.

Could you paste find_or_create_page called from __get_blk as an example
here, please? So that we do not have to scratch our heads again later...

Also task_in_memcg_oom could be stuffed into mem_cgroup_disable_oom
branch to reduce an overhead for in-kernel faults. The overhead
shouldn't be noticeable so I am not sure this is that important.

> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

I do not see any easier way to fix this without returning back to the
old behavior which is much worse.

Acked-by: Michal Hocko <mhocko@suse.cz>

Thanks!

> diff --git a/mm/memory.c b/mm/memory.c
> index cdbe41b..cdad471 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -57,7 +57,6 @@
>  #include <linux/swapops.h>
>  #include <linux/elf.h>
>  #include <linux/gfp.h>
> -#include <linux/stacktrace.h>
>  
>  #include <asm/io.h>
>  #include <asm/pgalloc.h>
> @@ -3521,11 +3520,8 @@ int handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
>  	if (flags & FAULT_FLAG_USER)
>  		mem_cgroup_disable_oom();
>  
> -	if (WARN_ON(task_in_memcg_oom(current) && !(ret & VM_FAULT_OOM))) {
> -		printk("Fixing unhandled memcg OOM context set up from:\n");
> -		print_stack_trace(&current->memcg_oom.trace, 0);
> -		mem_cgroup_oom_synchronize();
> -	}
> +	if (task_in_memcg_oom(current) && !(ret & VM_FAULT_OOM))
> +		mem_cgroup_oom_synchronize(false);
>  
>  	return ret;
>  }
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index aa60863..3bf664c 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -785,7 +785,7 @@ out:
>   */
>  void pagefault_out_of_memory(void)
>  {
> -	if (mem_cgroup_oom_synchronize())
> +	if (mem_cgroup_oom_synchronize(true))
>  		return;
>  	if (try_set_system_oom()) {
>  		out_of_memory(NULL, 0, 0, NULL);
> -- 
> 1.8.4
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
