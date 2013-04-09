Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 3A21F6B0006
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 23:57:08 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 56AC63EE0BB
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 12:57:06 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3BEC545DE4F
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 12:57:06 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 218EB45DE53
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 12:57:06 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 07A491DB8043
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 12:57:06 +0900 (JST)
Received: from m1001.s.css.fujitsu.com (m1001.s.css.fujitsu.com [10.240.81.139])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id A06EF1DB803E
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 12:57:05 +0900 (JST)
Message-ID: <51639180.3060806@jp.fujitsu.com>
Date: Tue, 09 Apr 2013 12:56:48 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/8] cgroup: implement cgroup_from_id()
References: <51627DA9.7020507@huawei.com> <51627DEB.4090104@huawei.com>
In-Reply-To: <51627DEB.4090104@huawei.com>
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Glauber Costa <glommer@parallels.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org

(2013/04/08 17:20), Li Zefan wrote:
> This will be used as a replacement for css_lookup().
> 
> Signed-off-by: Li Zefan <lizefan@huawei.com>
> ---
>   include/linux/cgroup.h |  1 +
>   kernel/cgroup.c        | 31 +++++++++++++++++++++++++------
>   2 files changed, 26 insertions(+), 6 deletions(-)
> 
> diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
> index 96072e4..6ae8ae1 100644
> --- a/include/linux/cgroup.h
> +++ b/include/linux/cgroup.h
> @@ -732,6 +732,7 @@ unsigned short css_depth(struct cgroup_subsys_state *css);
>   struct cgroup_subsys_state *cgroup_css_from_dir(struct file *f, int id);
>   
>   bool cgroup_is_ancestor(struct cgroup *child, struct cgroup *root);
> +struct cgroup *cgroup_from_id(struct cgroup_subsys *ss, int id);
>   
>   #else /* !CONFIG_CGROUPS */
>   
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index e87872c..5ae1e87 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -139,7 +139,7 @@ struct cgroupfs_root {
>   	unsigned long flags;
>   
>   	/* IDs for cgroups in this hierarchy */
> -	struct ida cgroup_ida;
> +	struct idr cgroup_idr;
>   
>   	/* The path to use for release notifications. */
>   	char release_agent_path[PATH_MAX];
> @@ -908,7 +908,7 @@ static void cgroup_free_fn(struct work_struct *work)
>   
>   	simple_xattrs_free(&cgrp->xattrs);
>   
> -	ida_simple_remove(&cgrp->root->cgroup_ida, cgrp->id);
> +	idr_remove(&cgrp->root->cgroup_idr, cgrp->id);
>   	kfree(rcu_dereference_raw(cgrp->name));
>   	kfree(cgrp);
>   }
> @@ -1512,7 +1512,8 @@ static struct cgroupfs_root *cgroup_root_from_opts(struct cgroup_sb_opts *opts)
>   
>   	root->subsys_mask = opts->subsys_mask;
>   	root->flags = opts->flags;
> -	ida_init(&root->cgroup_ida);
> +	idr_init(&root->cgroup_idr);
> +
>   	if (opts->release_agent)
>   		strcpy(root->release_agent_path, opts->release_agent);
>   	if (opts->name)
> @@ -1531,7 +1532,7 @@ static void cgroup_drop_root(struct cgroupfs_root *root)
>   	spin_lock(&hierarchy_id_lock);
>   	ida_remove(&hierarchy_ida, root->hierarchy_id);
>   	spin_unlock(&hierarchy_id_lock);
> -	ida_destroy(&root->cgroup_ida);
> +	idr_destroy(&root->cgroup_idr);
>   	kfree(root);
>   }
>   
> @@ -1645,6 +1646,11 @@ static struct dentry *cgroup_mount(struct file_system_type *fs_type,
>   		mutex_lock(&cgroup_mutex);
>   		mutex_lock(&cgroup_root_mutex);
>   
> +		root_cgrp->id = idr_alloc(&root->cgroup_idr, root_cgrp,
> +					  0, 0, GFP_KERNEL);
> +		if (root_cgrp->id < 0)
> +			goto unlock_drop;
> +
>   		/* Check for name clashes with existing mounts */
>   		ret = -EBUSY;
>   		if (strlen(root->name))
> @@ -4104,7 +4110,7 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
>   		goto err_free_cgrp;
>   	rcu_assign_pointer(cgrp->name, name);
>   
> -	cgrp->id = ida_simple_get(&root->cgroup_ida, 1, 0, GFP_KERNEL);
> +	cgrp->id = idr_alloc(&root->cgroup_idr, cgrp, 1, 0, GFP_KERNEL);
>   	if (cgrp->id < 0)
>   		goto err_free_name;
>   
> @@ -4215,7 +4221,7 @@ err_free_all:
>   	/* Release the reference count that we took on the superblock */
>   	deactivate_super(sb);
>   err_free_id:
> -	ida_simple_remove(&root->cgroup_ida, cgrp->id);
> +	idr_remove(&root->cgroup_idr, cgrp->id);
>   err_free_name:
>   	kfree(rcu_dereference_raw(cgrp->name));
>   err_free_cgrp:
> @@ -5320,6 +5326,19 @@ bool cgroup_is_ancestor(struct cgroup *child, struct cgroup *root)
>   	return (child == root);
>   }
>   
> +/**
> + * cgroup_from_id - lookup cgroup by id
> + * @ss: cgroup subsys to be looked into.
> + * @id: the id
> + *
> + * Returns pointer to cgroup if there is valid one with id.
> + * NULL if not. Should be called under rcu_read_lock()
> + */
> +struct cgroup *cgroup_from_id(struct cgroup_subsys *ss, int id)
> +{
> +	return idr_find(&ss->root->cgroup_idr, id);
> +}
> +

How about checking cgroup_populated_dir() have been called once ?
If not, returning NULL.

Thanks,
-Kame






--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
