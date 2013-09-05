Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id E2B376B0031
	for <linux-mm@kvack.org>; Thu,  5 Sep 2013 08:43:56 -0400 (EDT)
Date: Thu, 5 Sep 2013 14:43:52 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 0/7] improve memcg oom killer robustness v2
Message-ID: <20130905124352.GB13666@dhcp22.suse.cz>
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
> On Wed, Sep 04, 2013 at 10:18:52AM +0200, azurIt wrote:
> > Ok, i see this message several times in my syslog logs, one of them
> > is also for this unremovable cgroup (but maybe all of them cannot
> > be removed, should i try?). Example of the log is here (don't know
> > where exactly it starts and ends so here is the full kernel log):
> > http://watchdog.sk/lkml/oom_syslog.gz
> 
> There is an unfinished OOM invocation here:
> 
>   Aug 22 13:15:21 server01 kernel: [1251422.715112] Fixing unhandled memcg OOM context set up from:
>   Aug 22 13:15:21 server01 kernel: [1251422.715191]  [<ffffffff811105c2>] T.1154+0x622/0x8f0
>   Aug 22 13:15:21 server01 kernel: [1251422.715274]  [<ffffffff8111153e>] mem_cgroup_cache_charge+0xbe/0xe0
>   Aug 22 13:15:21 server01 kernel: [1251422.715357]  [<ffffffff810cf31c>] add_to_page_cache_locked+0x4c/0x140
>   Aug 22 13:15:21 server01 kernel: [1251422.715443]  [<ffffffff810cf432>] add_to_page_cache_lru+0x22/0x50
>   Aug 22 13:15:21 server01 kernel: [1251422.715526]  [<ffffffff810cfdd3>] find_or_create_page+0x73/0xb0
>   Aug 22 13:15:21 server01 kernel: [1251422.715608]  [<ffffffff811493ba>] __getblk+0xea/0x2c0
>   Aug 22 13:15:21 server01 kernel: [1251422.715692]  [<ffffffff8114ca73>] __bread+0x13/0xc0
>   Aug 22 13:15:21 server01 kernel: [1251422.715774]  [<ffffffff81196968>] ext3_get_branch+0x98/0x140
>   Aug 22 13:15:21 server01 kernel: [1251422.715859]  [<ffffffff81197557>] ext3_get_blocks_handle+0xd7/0xdc0
>   Aug 22 13:15:21 server01 kernel: [1251422.715942]  [<ffffffff81198304>] ext3_get_block+0xc4/0x120
>   Aug 22 13:15:21 server01 kernel: [1251422.716023]  [<ffffffff81155c3a>] do_mpage_readpage+0x38a/0x690
>   Aug 22 13:15:21 server01 kernel: [1251422.716107]  [<ffffffff81155f8f>] mpage_readpage+0x4f/0x70
>   Aug 22 13:15:21 server01 kernel: [1251422.716188]  [<ffffffff811973a8>] ext3_readpage+0x28/0x60
>   Aug 22 13:15:21 server01 kernel: [1251422.716268]  [<ffffffff810cfa48>] filemap_fault+0x308/0x560
>   Aug 22 13:15:21 server01 kernel: [1251422.716350]  [<ffffffff810ef898>] __do_fault+0x78/0x5a0
>   Aug 22 13:15:21 server01 kernel: [1251422.716433]  [<ffffffff810f2ab4>] handle_pte_fault+0x84/0x940
> 
> __getblk() has this weird loop where it tries to instantiate the page,
> frees memory on failure, then retries.  If the memcg goes OOM, the OOM
> path might be entered multiple times and each time leak the memcg
> reference of the respective previous OOM invocation.

Very well spotted, Johannes!

> There are a few more find_or_create() sites that do not propagate an
> error and it's incredibly hard to find out whether they are even taken
> during a page fault.  It's not practical to annotate them all with
> memcg OOM toggles, so let's just catch all OOM contexts at the end of
> handle_mm_fault() and clear them if !VM_FAULT_OOM instead of treating
> this like an error.
> 
> azur, here is a patch on top of your modified 3.2.  Note that Michal
> might be onto something and we are looking at multiple issues here,
> but the log excert above suggests this fix is required either way.
> 
> ---
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

This is getting way more trickier than I've expected and hoped for. The
above should work although I cannot say I love it. I am afraid we do not
have many choices left without polluting the every single place which
can charge, though :/

> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

I guess this should be correct but I have to think about it some more.

Two minor comments bellow.

> ---
>  include/linux/memcontrol.h | 40 ++++++----------------------------------
>  include/linux/sched.h      |  3 ---
>  mm/filemap.c               | 11 +----------
>  mm/memcontrol.c            | 15 ++++++++-------
>  mm/memory.c                |  8 ++------
>  mm/oom_kill.c              |  2 +-
>  6 files changed, 18 insertions(+), 61 deletions(-)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index b113c0f..7c43903 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -120,39 +120,16 @@ mem_cgroup_get_reclaim_stat_from_page(struct page *page);
>  extern void mem_cgroup_print_oom_info(struct mem_cgroup *memcg,
>  					struct task_struct *p);
>  
> -/**
> - * mem_cgroup_toggle_oom - toggle the memcg OOM killer for the current task
> - * @new: true to enable, false to disable
> - *
> - * Toggle whether a failed memcg charge should invoke the OOM killer
> - * or just return -ENOMEM.  Returns the previous toggle state.
> - *
> - * NOTE: Any path that enables the OOM killer before charging must
> - *       call mem_cgroup_oom_synchronize() afterward to finalize the
> - *       OOM handling and clean up.
> - */
> -static inline bool mem_cgroup_toggle_oom(bool new)
> -{
> -	bool old;
> -
> -	old = current->memcg_oom.may_oom;
> -	current->memcg_oom.may_oom = new;
> -
> -	return old;
> -}

I will not miss this guy.

[...]
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

This deserves a fat comment /me thinks

[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
