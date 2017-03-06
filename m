Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2589728089F
	for <linux-mm@kvack.org>; Mon,  6 Mar 2017 08:59:53 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id u48so65534499wrc.0
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 05:59:53 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g16si5793840wmg.45.2017.03.06.05.59.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 06 Mar 2017 05:59:51 -0800 (PST)
Date: Mon, 6 Mar 2017 14:59:48 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: do not call mem_cgroup_free() from within
 mem_cgroup_alloc()
Message-ID: <20170306135947.GF27953@dhcp22.suse.cz>
References: <20170304025356.12265-1-tahsin@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170304025356.12265-1-tahsin@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tahsin Erdogan <tahsin@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 03-03-17 18:53:56, Tahsin Erdogan wrote:
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
> Fix mem_cgroup_alloc() by doing more granular clean up in case of
> failures.
> 
> Fixes: 0b8f73e104285 ("mm: memcontrol: clean up alloc, online, offline, free functions")
> Signed-off-by: Tahsin Erdogan <tahsin@google.com>

Please do not duplicate mem_cgroup_free code and rather add
__mem_cgroup_free which does everything except for wb_domain_exit.
An alternative would be to teach memcg_wb_domain_exit to not call
wb_domain_exit if it hasn't been initialized yet. The first option seems
easier.

Thanks!

> ---
>  mm/memcontrol.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index c52ec893e241..9a9d5630df91 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -4194,9 +4194,12 @@ static struct mem_cgroup *mem_cgroup_alloc(void)
>  	idr_replace(&mem_cgroup_idr, memcg, memcg->id.id);
>  	return memcg;
>  fail:
> +	for_each_node(node)
> +		free_mem_cgroup_per_node_info(memcg, node);
> +	free_percpu(memcg->stat);
>  	if (memcg->id.id > 0)
>  		idr_remove(&mem_cgroup_idr, memcg->id.id);
> -	mem_cgroup_free(memcg);
> +	kfree(memcg);
>  	return NULL;
>  }
>  
> -- 
> 2.12.0.rc1.440.g5b76565f74-goog
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
