Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0F01D6B0292
	for <linux-mm@kvack.org>; Thu, 31 Aug 2017 07:10:11 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id q53so1207929qtq.3
        for <linux-mm@kvack.org>; Thu, 31 Aug 2017 04:10:11 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u38si7707441qta.225.2017.08.31.04.10.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Aug 2017 04:10:09 -0700 (PDT)
Date: Thu, 31 Aug 2017 13:10:06 +0200
From: Artem Savkov <asavkov@redhat.com>
Subject: Re: possible circular locking dependency
 mmap_sem/cpu_hotplug_lock.rw_sem
Message-ID: <20170831111006.i7srs56xki4bjx34@shodan.usersys.redhat.com>
References: <20170807140947.nhfz2gel6wytl6ia@shodan.usersys.redhat.com>
 <alpine.DEB.2.20.1708161605050.1987@nanos>
 <20170830141543.qhipikpog6mkqe5b@dhcp22.suse.cz>
 <20170830154315.sa57wasw64rvnuhe@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20170830154315.sa57wasw64rvnuhe@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org

Hi Michal,

On Wed, Aug 30, 2017 at 05:43:15PM +0200, Michal Hocko wrote:
> The previous patch is insufficient. drain_all_stock can still race with
> the memory offline callback and the underlying memcg disappear. So we
> need to be more careful and pin the css on the memcg. This patch
> instead...

Tried this on top of rc7 and it does fix the splat for me.

> ---
> From 70a5acf9bbe76d183e81a1a6b57dd5b9edc677c6 Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.com>
> Date: Wed, 30 Aug 2017 16:09:01 +0200
> Subject: [PATCH] mm, memcg: remove hotplug locking from try_charge
> 
> The following lockde splat has been noticed during LTP testing
> 
> [21002.630252] ======================================================
> [21002.637148] WARNING: possible circular locking dependency detected
> [21002.644045] 4.13.0-rc3-next-20170807 #12 Not tainted
> [21002.649583] ------------------------------------------------------
> [21002.656492] a.out/4771 is trying to acquire lock:
> [21002.661742]  (cpu_hotplug_lock.rw_sem){++++++}, at: [<ffffffff812b4668>] drain_all_stock.part.35+0x18/0x140
> [21002.672629]
> [21002.672629] but task is already holding lock:
> [21002.679137]  (&mm->mmap_sem){++++++}, at: [<ffffffff8106eb35>] __do_page_fault+0x175/0x530
> [21002.688371]
> [21002.688371] which lock already depends on the new lock.
> [21002.688371]
> [21002.697505]
> [21002.697505] the existing dependency chain (in reverse order) is:
> [21002.705856]
> [21002.705856] -> #3 (&mm->mmap_sem){++++++}:
> [21002.712080]        lock_acquire+0xc9/0x230
> [21002.716661]        __might_fault+0x70/0xa0
> [21002.721241]        _copy_to_user+0x23/0x70
> [21002.725814]        filldir+0xa7/0x110
> [21002.729988]        xfs_dir2_sf_getdents.isra.10+0x20c/0x2c0 [xfs]
> [21002.736840]        xfs_readdir+0x1fa/0x2c0 [xfs]
> [21002.742042]        xfs_file_readdir+0x30/0x40 [xfs]
> [21002.747485]        iterate_dir+0x17a/0x1a0
> [21002.752057]        SyS_getdents+0xb0/0x160
> [21002.756638]        entry_SYSCALL_64_fastpath+0x1f/0xbe
> [21002.762371]
> [21002.762371] -> #2 (&type->i_mutex_dir_key#3){++++++}:
> [21002.769661]        lock_acquire+0xc9/0x230
> [21002.774239]        down_read+0x51/0xb0
> [21002.778429]        lookup_slow+0xde/0x210
> [21002.782903]        walk_component+0x160/0x250
> [21002.787765]        link_path_walk+0x1a6/0x610
> [21002.792625]        path_openat+0xe4/0xd50
> [21002.797100]        do_filp_open+0x91/0x100
> [21002.801673]        file_open_name+0xf5/0x130
> [21002.806429]        filp_open+0x33/0x50
> [21002.810620]        kernel_read_file_from_path+0x39/0x80
> [21002.816459]        _request_firmware+0x39f/0x880
> [21002.821610]        request_firmware_direct+0x37/0x50
> [21002.827151]        request_microcode_fw+0x64/0xe0
> [21002.832401]        reload_store+0xf7/0x180
> [21002.836974]        dev_attr_store+0x18/0x30
> [21002.841641]        sysfs_kf_write+0x44/0x60
> [21002.846318]        kernfs_fop_write+0x113/0x1a0
> [21002.851374]        __vfs_write+0x37/0x170
> [21002.855849]        vfs_write+0xc7/0x1c0
> [21002.860128]        SyS_write+0x58/0xc0
> [21002.864313]        do_syscall_64+0x6c/0x1f0
> [21002.868973]        return_from_SYSCALL_64+0x0/0x7a
> [21002.874317]
> [21002.874317] -> #1 (microcode_mutex){+.+.+.}:
> [21002.880748]        lock_acquire+0xc9/0x230
> [21002.885322]        __mutex_lock+0x88/0x960
> [21002.889894]        mutex_lock_nested+0x1b/0x20
> [21002.894854]        microcode_init+0xbb/0x208
> [21002.899617]        do_one_initcall+0x51/0x1a9
> [21002.904481]        kernel_init_freeable+0x208/0x2a7
> [21002.909922]        kernel_init+0xe/0x104
> [21002.914298]        ret_from_fork+0x2a/0x40
> [21002.918867]
> [21002.918867] -> #0 (cpu_hotplug_lock.rw_sem){++++++}:
> [21002.926058]        __lock_acquire+0x153c/0x1550
> [21002.931112]        lock_acquire+0xc9/0x230
> [21002.935688]        cpus_read_lock+0x4b/0x90
> [21002.940353]        drain_all_stock.part.35+0x18/0x140
> [21002.945987]        try_charge+0x3ab/0x6e0
> [21002.950460]        mem_cgroup_try_charge+0x7f/0x2c0
> [21002.955902]        shmem_getpage_gfp+0x25f/0x1050
> [21002.961149]        shmem_fault+0x96/0x200
> [21002.965621]        __do_fault+0x1e/0xa0
> [21002.969905]        __handle_mm_fault+0x9c3/0xe00
> [21002.975056]        handle_mm_fault+0x16e/0x380
> [21002.980013]        __do_page_fault+0x24a/0x530
> [21002.984968]        do_page_fault+0x30/0x80
> [21002.989537]        page_fault+0x28/0x30
> [21002.993812]
> [21002.993812] other info that might help us debug this:
> [21002.993812]
> [21003.002744] Chain exists of:
> [21003.002744]   cpu_hotplug_lock.rw_sem --> &type->i_mutex_dir_key#3 --> &mm->mmap_sem
> [21003.002744]
> [21003.016238]  Possible unsafe locking scenario:
> [21003.016238]
> [21003.022843]        CPU0                    CPU1
> [21003.027896]        ----                    ----
> [21003.032948]   lock(&mm->mmap_sem);
> [21003.036741]                                lock(&type->i_mutex_dir_key#3);
> [21003.044419]                                lock(&mm->mmap_sem);
> [21003.051025]   lock(cpu_hotplug_lock.rw_sem);
> [21003.055788]
> [21003.055788]  *** DEADLOCK ***
> [21003.055788]
> [21003.062393] 2 locks held by a.out/4771:
> [21003.066675]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff8106eb35>] __do_page_fault+0x175/0x530
> [21003.076391]  #1:  (percpu_charge_mutex){+.+...}, at: [<ffffffff812b4c97>] try_charge+0x397/0x6e0
> 
> The problem is very similar to the one fixed by a459eeb7b852 ("mm,
> page_alloc: do not depend on cpu hotplug locks inside the allocator").
> We are taking hotplug locks while we can be sitting on top of basically
> arbitrary locks. This just calls for problems.
> 
> We can get rid of {get,put}_online_cpus, fortunately. We do not have to
> be worried about races with memory hotplug because drain_local_stock,
> which is called from both the WQ draining and the memory hotplug
> contexts, is always operating on the local cpu stock with IRQs disabled.
> 
> The only thing to be careful about is that the target memcg doesn't
> vanish while we are still in drain_all_stock so take a reference on
> it.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  mm/memcontrol.c | 13 +++++++++----
>  1 file changed, 9 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index b9cf3cf4a3d0..5c70f47abb3d 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1765,6 +1765,10 @@ static void drain_local_stock(struct work_struct *dummy)
>  	struct memcg_stock_pcp *stock;
>  	unsigned long flags;
>  
> +	/*
> +	 * The only protection from memory hotplug vs. drain_stock races is
> +	 * that we always operate on local CPU stock here with IRQ disabled
> +	 */
>  	local_irq_save(flags);
>  
>  	stock = this_cpu_ptr(&memcg_stock);
> @@ -1807,26 +1811,27 @@ static void drain_all_stock(struct mem_cgroup *root_memcg)
>  	if (!mutex_trylock(&percpu_charge_mutex))
>  		return;
>  	/* Notify other cpus that system-wide "drain" is running */
> -	get_online_cpus();
>  	curcpu = get_cpu();
>  	for_each_online_cpu(cpu) {
>  		struct memcg_stock_pcp *stock = &per_cpu(memcg_stock, cpu);
>  		struct mem_cgroup *memcg;
>  
>  		memcg = stock->cached;
> -		if (!memcg || !stock->nr_pages)
> +		if (!memcg || !stock->nr_pages || !css_tryget(&memcg->css))
>  			continue;
> -		if (!mem_cgroup_is_descendant(memcg, root_memcg))
> +		if (!mem_cgroup_is_descendant(memcg, root_memcg)) {
> +			css_put(&memcg->css);
>  			continue;
> +		}
>  		if (!test_and_set_bit(FLUSHING_CACHED_CHARGE, &stock->flags)) {
>  			if (cpu == curcpu)
>  				drain_local_stock(&stock->work);
>  			else
>  				schedule_work_on(cpu, &stock->work);
>  		}
> +		css_put(&memcg->css);
>  	}
>  	put_cpu();
> -	put_online_cpus();
>  	mutex_unlock(&percpu_charge_mutex);
>  }
>  
> -- 
> 2.13.2
> 
> -- 
> Michal Hocko
> SUSE Labs

-- 
Regards,
  Artem

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
