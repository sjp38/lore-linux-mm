Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 19BEF6B0031
	for <linux-mm@kvack.org>; Wed, 24 Jul 2013 10:07:06 -0400 (EDT)
Date: Wed, 24 Jul 2013 16:07:02 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2 1/8] cgroup: convert cgroup_ida to cgroup_idr
Message-ID: <20130724140702.GD2540@dhcp22.suse.cz>
References: <51EFA554.6080801@huawei.com>
 <51EFA570.5020907@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51EFA570.5020907@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Glauber Costa <glommer@parallels.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org

On Wed 24-07-13 17:59:12, Li Zefan wrote:
> This enables us to lookup a cgroup by its id.
> 
> Signed-off-by: Li Zefan <lizefan@huawei.com>

Reviewed-by: Michal Hocko <mhocko@suse.cz>

One nit/question bellow
[...]
> @@ -4268,15 +4271,19 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
>  	if (!cgrp)
>  		return -ENOMEM;
>  
> +	/*
> +	 * Temporarily set the pointer to NULL, so idr_find() won't return
> +	 * a half-baked cgroup.
> +	 */
> +	cgrp->id = idr_alloc(&root->cgroup_idr, NULL, 1, 0, GFP_KERNEL);
> +	if (cgrp->id < 0)
> +		goto err_free_cgrp;
> +
>  	name = cgroup_alloc_name(dentry);
>  	if (!name)
> -		goto err_free_cgrp;
> +		goto err_free_id;
>  	rcu_assign_pointer(cgrp->name, name);
>  
> -	cgrp->id = ida_simple_get(&root->cgroup_ida, 1, 0, GFP_KERNEL);
> -	if (cgrp->id < 0)
> -		goto err_free_name;
> -

Is the move necessary? You would safe few lines in the patch if you kept
the ordering.

>  	/*
>  	 * Only live parents can have children.  Note that the liveliness
>  	 * check isn't strictly necessary because cgroup_mkdir() and
> @@ -4286,7 +4293,7 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
>  	 */
>  	if (!cgroup_lock_live_group(parent)) {
>  		err = -ENODEV;
> -		goto err_free_id;
> +		goto err_free_name;
>  	}
>  
>  	/* Grab a reference on the superblock so the hierarchy doesn't
> @@ -4371,6 +4378,8 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
>  		}
>  	}
>  
> +	idr_replace(&root->cgroup_idr, cgrp, cgrp->id);
> +
>  	err = cgroup_addrm_files(cgrp, NULL, cgroup_base_files, true);
>  	if (err)
>  		goto err_destroy;
> @@ -4396,10 +4405,10 @@ err_free_all:
>  	mutex_unlock(&cgroup_mutex);
>  	/* Release the reference count that we took on the superblock */
>  	deactivate_super(sb);
> -err_free_id:
> -	ida_simple_remove(&root->cgroup_ida, cgrp->id);
>  err_free_name:
>  	kfree(rcu_dereference_raw(cgrp->name));
> +err_free_id:
> +	idr_remove(&root->cgroup_idr, cgrp->id);
>  err_free_cgrp:
>  	kfree(cgrp);
>  	return err;
[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
