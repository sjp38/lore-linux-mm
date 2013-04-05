Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id AC78D6B0005
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 01:59:01 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 1F4473EE0C8
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 14:59:00 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id F0E0745DE52
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 14:58:58 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id C409C45DE4E
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 14:58:58 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id B40B41DB803C
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 14:58:58 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 634C11DB8040
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 14:58:58 +0900 (JST)
Message-ID: <515E680D.5040805@jp.fujitsu.com>
Date: Fri, 05 Apr 2013 14:58:37 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 5/7] cgroup: make sure parent won't be destroyed
 before its children
References: <515BF233.6070308@huawei.com> <515BF2A4.1070703@huawei.com>
In-Reply-To: <515BF2A4.1070703@huawei.com>
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, Tejun Heo <tj@kernel.org>, Glauber Costa <glommer@parallels.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>

(2013/04/03 18:13), Li Zefan wrote:
> Suppose we rmdir a cgroup and there're still css refs, this cgroup won't
> be freed. Then we rmdir the parent cgroup, and the parent is freed due
> to css ref draining to 0. Now it would be a disaster if the child cgroup
> tries to access its parent.
> 
> Make sure this won't happen.
> 
> Signed-off-by: Li Zefan <lizefan@huawei.com>
> ---
>   kernel/cgroup.c | 10 ++++++++++
>   1 file changed, 10 insertions(+)
> 
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index fa54b92..78204bc 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -888,6 +888,13 @@ static void cgroup_free_fn(struct work_struct *work)
>   	mutex_unlock(&cgroup_mutex);
>   
>   	/*
> +	 * We get a ref to the parent's dentry, and put the ref when
> +	 * this cgroup is being freed, so it's guaranteed that the
> +	 * parent won't be destroyed before its children.
> +	 */
> +	dput(cgrp->parent->dentry);
> +
> +	/*
>   	 * Drop the active superblock reference that we took when we
>   	 * created the cgroup
>   	 */
> @@ -4171,6 +4178,9 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
>   	for_each_subsys(root, ss)
>   		dget(dentry);
>   
> +	/* hold a ref to the parent's dentry */
> +	dget(parent->dentry);
> +
>   	/* creation succeeded, notify subsystems */
>   	for_each_subsys(root, ss) {
>   		err = online_css(ss, cgrp);
> 

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
