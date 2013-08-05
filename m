Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id F3B626B0033
	for <linux-mm@kvack.org>; Sun,  4 Aug 2013 22:58:50 -0400 (EDT)
Message-ID: <51FF14C5.4040003@huawei.com>
Date: Mon, 5 Aug 2013 10:58:13 +0800
From: Li Zefan <lizefan@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/5] cgroup: export __cgroup_from_dentry() and __cgroup_dput()
References: <1375632446-2581-1-git-send-email-tj@kernel.org> <1375632446-2581-3-git-send-email-tj@kernel.org>
In-Reply-To: <1375632446-2581-3-git-send-email-tj@kernel.org>
Content-Type: text/plain; charset="GB2312"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: hannes@cmpxchg.org, mhocko@suse.cz, bsingharora@gmail.com, kamezawa.hiroyu@jp.fujitsu.com, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

> +struct cgroup *__cgroup_from_dentry(struct dentry *dentry, struct cftype **cftp)
>  {
> -	if (file_inode(file)->i_fop != &cgroup_file_operations)
> -		return ERR_PTR(-EINVAL);
> -	return __d_cft(file->f_dentry);
> +	if (!dentry->d_inode ||
> +	    dentry->d_inode->i_op != &cgroup_file_inode_operations)
> +		return NULL;
> +
> +	if (cftp)
> +		*cftp = __d_cft(dentry);
> +	return __d_cgrp(dentry->d_parent);
>  }
> +EXPORT_SYMBOL_GPL(__cgroup_from_dentry);

As we don't expect new users, why export this symbol? memcg can't be
built as a module.

>  
>  static int cgroup_create_file(struct dentry *dentry, umode_t mode,
>  				struct super_block *sb)
> @@ -3953,7 +3956,7 @@ static int cgroup_write_notify_on_release(struct cgroup_subsys_state *css,
>   *
>   * That's why we hold a reference before dput() and drop it right after.
>   */
> -static void cgroup_dput(struct cgroup *cgrp)
> +void __cgroup_dput(struct cgroup *cgrp)
>  {
>  	struct super_block *sb = cgrp->root->sb;
>  
> @@ -3961,6 +3964,7 @@ static void cgroup_dput(struct cgroup *cgrp)
>  	dput(cgrp->dentry);
>  	deactivate_super(sb);
>  }
> +EXPORT_SYMBOL_GPL(__cgroup_dput);

ditto

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
