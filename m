Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f52.google.com (mail-yh0-f52.google.com [209.85.213.52])
	by kanga.kvack.org (Postfix) with ESMTP id 884EB6B0039
	for <linux-mm@kvack.org>; Tue, 17 Dec 2013 02:09:53 -0500 (EST)
Received: by mail-yh0-f52.google.com with SMTP id i7so4610747yha.39
        for <linux-mm@kvack.org>; Mon, 16 Dec 2013 23:09:53 -0800 (PST)
Received: from mail-pa0-x234.google.com (mail-pa0-x234.google.com [2607:f8b0:400e:c03::234])
        by mx.google.com with ESMTPS id u45si14922502yhc.253.2013.12.16.23.09.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 16 Dec 2013 23:09:52 -0800 (PST)
Received: by mail-pa0-f52.google.com with SMTP id ld10so4097159pab.11
        for <linux-mm@kvack.org>; Mon, 16 Dec 2013 23:09:51 -0800 (PST)
Date: Mon, 16 Dec 2013 23:09:23 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: 3.13-rc breaks MEMCG_SWAP
In-Reply-To: <52AFC163.5010507@huawei.com>
Message-ID: <alpine.LNX.2.00.1312162300410.16426@eggly.anvils>
References: <alpine.LNX.2.00.1312160025200.2785@eggly.anvils> <52AEC989.4080509@huawei.com> <20131216095345.GB23582@dhcp22.suse.cz> <20131216104042.GC23582@dhcp22.suse.cz> <20131216163530.GH32509@htj.dyndns.org> <20131216171937.GG26797@dhcp22.suse.cz>
 <20131216172143.GJ32509@htj.dyndns.org> <alpine.LNX.2.00.1312161718001.2037@eggly.anvils> <52AFC163.5010507@huawei.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, 17 Dec 2013, Li Zefan wrote:
> On 2013/12/17 9:41, Hugh Dickins wrote:
> > On Mon, 16 Dec 2013, Tejun Heo wrote:
> >> On Mon, Dec 16, 2013 at 06:19:37PM +0100, Michal Hocko wrote:
> >>> I have to think about it some more (the brain is not working anymore
> >>> today). But what we really need is that nobody gets the same id while
> >>> the css is alive.
> 
> That's what I meant to do in my last reply.
> 
> But I'm confused by
> 
> "How would this work? .. the swap will be there
> after the last reference to css as well."
> 
> >>> So css_from_id returning NULL doesn't seem to be
> >>> enough.
> >>
> >> Oh, I meant whether it's necessary to keep css_from_id() working
> >> (ie. doing successful lookups) between offline and release, because
> >> that's where lifetimes are coupled.  IOW, if it's enough for cgroup to
> >> not recycle the ID until all css's are released && fail css_from_id()
> >> lookup after the css is offlined, I can make a five liner quick fix.
> > 
> > Don't take my word on it, I'm too fuzzy on this: but although it would
> > be good to refrain from recycling the ID until all css's are released,
> > I believe that it would not be good enough to fail css_from_id() once
> > the css is offlined - mem_cgroup_uncharge_swap() needs to uncharge the
> > hierarchy of the dead memcg (for example, when tmpfs file is removed).
> > 
> > Uncharging the dead memcg itself is presumably irrelevant, but it does
> > need to locate the right parent to uncharge, and NULL css_from_id()
> > would make that impossible.  It would be easy if we said those charges
> > migrate to root rather than to parent, but that's inconsistent with
> > what we have happily converged upon doing elsewhere (in the preferred
> > use_hierarchy case), and it would be a change in behaviour.
> > 
> > I'm not nearly as enthusiastic for my patch as Michal is: I really
> > would prefer a five-liner from you or from Zefan. 
> 
> I've come up with a fix. Though it's more than five-line, it mostly moves
> a few lines from one place to another. I've tested it with your script.

It seems to be working very well for me.  I'm inclined to forgive you for
taking more than five lines, given that there are almost as many -s as +s ;)

In my opinion, your patch is greatly preferable to mine - if there are
good things in mine, memcg can incorporate them at leisure later on,
but right now this seems a much better 3.13 solution.  I'm guessing
Tejun and Hannes will feel the same way: how about you, Michal?

Thank you!
Hugh

> 
> ============================
> 
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
> 
> Reported-by: Hugh Dickins <hughd@google.com>
> Signed-off-by: Li Zefan <lizefan@huawei.com>
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
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
