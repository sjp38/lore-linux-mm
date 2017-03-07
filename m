Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 82D846B038B
	for <linux-mm@kvack.org>; Tue,  7 Mar 2017 06:40:19 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id u9so546048wme.6
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 03:40:19 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g14si30429040wrg.275.2017.03.07.03.40.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 07 Mar 2017 03:40:18 -0800 (PST)
Date: Tue, 7 Mar 2017 12:40:16 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] mm: do not call mem_cgroup_free() from within
 mem_cgroup_alloc()
Message-ID: <20170307114016.GH28642@dhcp22.suse.cz>
References: <20170306135947.GF27953@dhcp22.suse.cz>
 <20170306192122.24262-1-tahsin@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170306192122.24262-1-tahsin@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tahsin Erdogan <tahsin@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

[CC Andrew]

On Mon 06-03-17 11:21:22, Tahsin Erdogan wrote:
> mem_cgroup_free() indirectly calls wb_domain_exit() which is not
> prepared to deal with a struct wb_domain object that hasn't executed
> wb_domain_init(). For instance, the following warning message is
> printed by lockdep if alloc_percpu() fails in mem_cgroup_alloc():
> 
>   INFO: trying to register non-static key.
>   the code is fine but needs lockdep annotation.
>   turning off the locking correctness validator.
>   CPU: 1 PID: 1950 Comm: mkdir Not tainted 4.10.0+ #151
>   Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
>   Call Trace:
>    dump_stack+0x67/0x99
>    register_lock_class+0x36d/0x540
>    __lock_acquire+0x7f/0x1a30
>    ? irq_work_queue+0x73/0x90
>    ? wake_up_klogd+0x36/0x40
>    ? console_unlock+0x45d/0x540
>    ? vprintk_emit+0x211/0x2e0
>    lock_acquire+0xcc/0x200
>    ? try_to_del_timer_sync+0x60/0x60
>    del_timer_sync+0x3c/0xc0
>    ? try_to_del_timer_sync+0x60/0x60
>    wb_domain_exit+0x14/0x20
>    mem_cgroup_free+0x14/0x40
>    mem_cgroup_css_alloc+0x3f9/0x620
>    cgroup_apply_control_enable+0x190/0x390
>    cgroup_mkdir+0x290/0x3d0
>    kernfs_iop_mkdir+0x58/0x80
>    vfs_mkdir+0x10e/0x1a0
>    SyS_mkdirat+0xa8/0xd0
>    SyS_mkdir+0x14/0x20
>    entry_SYSCALL_64_fastpath+0x18/0xad
> 
> Add __mem_cgroup_free() which skips wb_domain_exit(). This is
> used by both mem_cgroup_free() and mem_cgroup_alloc() clean up.
> 
> Fixes: 0b8f73e104285 ("mm: memcontrol: clean up alloc, online, offline, free functions")
> Signed-off-by: Tahsin Erdogan <tahsin@google.com>
> ---
> v2:
>   Added __mem_cgroup_free()
> 
>  mm/memcontrol.c | 11 ++++++++---
>  1 file changed, 8 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index c52ec893e241..e7d900c5f2d0 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -4135,17 +4135,22 @@ static void free_mem_cgroup_per_node_info(struct mem_cgroup *memcg, int node)
>  	kfree(memcg->nodeinfo[node]);
>  }
>  
> -static void mem_cgroup_free(struct mem_cgroup *memcg)
> +static void __mem_cgroup_free(struct mem_cgroup *memcg)
>  {
>  	int node;
>  
> -	memcg_wb_domain_exit(memcg);
>  	for_each_node(node)
>  		free_mem_cgroup_per_node_info(memcg, node);
>  	free_percpu(memcg->stat);
>  	kfree(memcg);
>  }
>  
> +static void mem_cgroup_free(struct mem_cgroup *memcg)
> +{
> +	memcg_wb_domain_exit(memcg);
> +	__mem_cgroup_free(memcg);
> +}
> +
>  static struct mem_cgroup *mem_cgroup_alloc(void)
>  {
>  	struct mem_cgroup *memcg;
> @@ -4196,7 +4201,7 @@ static struct mem_cgroup *mem_cgroup_alloc(void)
>  fail:
>  	if (memcg->id.id > 0)
>  		idr_remove(&mem_cgroup_idr, memcg->id.id);
> -	mem_cgroup_free(memcg);
> +	__mem_cgroup_free(memcg);
>  	return NULL;
>  }
>  
> -- 
> 2.12.0.rc1.440.g5b76565f74-goog

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
