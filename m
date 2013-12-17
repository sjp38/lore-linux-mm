Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f180.google.com (mail-ea0-f180.google.com [209.85.215.180])
	by kanga.kvack.org (Postfix) with ESMTP id CF0526B0035
	for <linux-mm@kvack.org>; Tue, 17 Dec 2013 08:06:00 -0500 (EST)
Received: by mail-ea0-f180.google.com with SMTP id f15so2886818eak.11
        for <linux-mm@kvack.org>; Tue, 17 Dec 2013 05:06:00 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t6si4921560eeh.108.2013.12.17.05.05.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 17 Dec 2013 05:05:59 -0800 (PST)
Date: Tue, 17 Dec 2013 14:05:55 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: 3.13-rc breaks MEMCG_SWAP
Message-ID: <20131217130555.GC28991@dhcp22.suse.cz>
References: <alpine.LNX.2.00.1312160025200.2785@eggly.anvils>
 <52AEC989.4080509@huawei.com>
 <20131216095345.GB23582@dhcp22.suse.cz>
 <20131216104042.GC23582@dhcp22.suse.cz>
 <20131216163530.GH32509@htj.dyndns.org>
 <20131216171937.GG26797@dhcp22.suse.cz>
 <20131216172143.GJ32509@htj.dyndns.org>
 <alpine.LNX.2.00.1312161718001.2037@eggly.anvils>
 <52AFC163.5010507@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52AFC163.5010507@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue 17-12-13 11:13:39, Li Zefan wrote:
[...]
> From: Li Zefan <lizefan@huawei.com>
> Date: Tue, 17 Dec 2013 10:45:09 +0800
> Subject: [PATCH] cgroup: don't recycle cgroup id until all csses' have been destroyed
> 
> Hugh reported this bug:
> 
> > CONFIG_MEMCG_SWAP is broken in 3.13-rc.  Try something like this:
> >
> > mkdir -p /tmp/tmpfs /tmp/memcg
> > mount -t tmpfs -o size=1G tmpfs /tmp/tmpfs
> > mount -t cgroup -o memory memcg /tmp/memcg
> > mkdir /tmp/memcg/old
> > echo 512M >/tmp/memcg/old/memory.limit_in_bytes
> > echo $$ >/tmp/memcg/old/tasks
> > cp /dev/zero /tmp/tmpfs/zero 2>/dev/null
> > echo $$ >/tmp/memcg/tasks
> > rmdir /tmp/memcg/old
> > sleep 1	# let rmdir work complete
> > mkdir /tmp/memcg/new
> > umount /tmp/tmpfs
> > dmesg | grep WARNING
> > rmdir /tmp/memcg/new
> > umount /tmp/memcg
> >
> > Shows lots of WARNING: CPU: 1 PID: 1006 at kernel/res_counter.c:91
> >                            res_counter_uncharge_locked+0x1f/0x2f()
> >
> > Breakage comes from 34c00c319ce7 ("memcg: convert to use cgroup id").
> >
> > The lifetime of a cgroup id is different from the lifetime of the
> > css id it replaced: memsw's css_get()s do nothing to hold on to the
> > old cgroup id, it soon gets recycled to a new cgroup, which then
> > mysteriously inherits the old's swap, without any charge for it.
> 
> Instead of removing cgroup id right after all the csses have been
> offlined, we should do that after csses have been destroyed.
> 
> To make sure an invalid css pointer won't be returned after the css
> is destroyed, make sure css_from_id() returns NULL in this case.

OK, so this will postpone idr_remove to css_free and until then
mem_cgroup_lookup finds a correct memcg. This will work as well.
It is basically the same thing we had with css_id AFAIR.

Originally I thought this wouldn't be possible because of the comment
above idr_remove for some reason.

> Reported-by: Hugh Dickins <hughd@google.com>
> Signed-off-by: Li Zefan <lizefan@huawei.com>

Reviewed-by: Michal Hocko <mhocko@suse.cz>

> ---
>  kernel/cgroup.c | 18 ++++++++++--------
>  1 file changed, 10 insertions(+), 8 deletions(-)
> 
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index c36d906..769b5bb 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -868,6 +868,15 @@ static void cgroup_diput(struct dentry *dentry, struct inode *inode)
>  		struct cgroup *cgrp = dentry->d_fsdata;
>  
>  		BUG_ON(!(cgroup_is_dead(cgrp)));
> +
> +		/*
> +		 * We should remove the cgroup object from idr before its
> +		 * grace period starts, so we won't be looking up a cgroup
> +		 * while the cgroup is being freed.
> +		 */
> +		idr_remove(&cgrp->root->cgroup_idr, cgrp->id);
> +		cgrp->id = -1;
> +
>  		call_rcu(&cgrp->rcu_head, cgroup_free_rcu);
>  	} else {
>  		struct cfent *cfe = __d_cfe(dentry);
> @@ -4104,6 +4113,7 @@ static void css_release(struct percpu_ref *ref)
>  	struct cgroup_subsys_state *css =
>  		container_of(ref, struct cgroup_subsys_state, refcnt);
>  
> +	rcu_assign_pointer(css->cgroup->subsys[css->ss->subsys_id], NULL);
>  	call_rcu(&css->rcu_head, css_free_rcu_fn);
>  }
>  
> @@ -4545,14 +4555,6 @@ static void cgroup_destroy_css_killed(struct cgroup *cgrp)
>  	/* delete this cgroup from parent->children */
>  	list_del_rcu(&cgrp->sibling);
>  
> -	/*
> -	 * We should remove the cgroup object from idr before its grace
> -	 * period starts, so we won't be looking up a cgroup while the
> -	 * cgroup is being freed.
> -	 */
> -	idr_remove(&cgrp->root->cgroup_idr, cgrp->id);
> -	cgrp->id = -1;
> -
>  	dput(d);
>  
>  	set_bit(CGRP_RELEASABLE, &parent->flags);
> -- 
> 1.8.0.2
> 
> 
> 
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
