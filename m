Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 86C7F6B004D
	for <linux-mm@kvack.org>; Thu, 24 Sep 2009 02:35:18 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n8O6ZHgd008385
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 24 Sep 2009 15:35:17 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 821AB45DE4D
	for <linux-mm@kvack.org>; Thu, 24 Sep 2009 15:35:17 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 645B145DE50
	for <linux-mm@kvack.org>; Thu, 24 Sep 2009 15:35:17 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 46C99E38003
	for <linux-mm@kvack.org>; Thu, 24 Sep 2009 15:35:17 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id EF51FE08002
	for <linux-mm@kvack.org>; Thu, 24 Sep 2009 15:35:16 +0900 (JST)
Date: Thu, 24 Sep 2009 15:33:09 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 1/8] cgroup: introduce cancel_attach()
Message-Id: <20090924153309.ed78007f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090924144327.a3d09d36.nishimura@mxp.nes.nec.co.jp>
References: <20090917112304.6cd4e6f6.nishimura@mxp.nes.nec.co.jp>
	<20090917160103.1bcdddee.nishimura@mxp.nes.nec.co.jp>
	<20090924144214.508469d1.nishimura@mxp.nes.nec.co.jp>
	<20090924144327.a3d09d36.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, 24 Sep 2009 14:43:27 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> This patch adds cancel_attach() operation to struct cgroup_subsys.
> cancel_attach() can be used when can_attach() operation prepares something
> for the subsys, but we should discard what can_attach() operation has prepared
> if attach task/proc fails afterwards.
> 
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> ---
>  Documentation/cgroups/cgroups.txt |   12 ++++++++++++
>  include/linux/cgroup.h            |    2 ++
>  kernel/cgroup.c                   |   36 ++++++++++++++++++++++++++++--------
>  3 files changed, 42 insertions(+), 8 deletions(-)
> 
> diff --git a/Documentation/cgroups/cgroups.txt b/Documentation/cgroups/cgroups.txt
> index 3df4b9a..07bb678 100644
> --- a/Documentation/cgroups/cgroups.txt
> +++ b/Documentation/cgroups/cgroups.txt
> @@ -544,6 +544,18 @@ remain valid while the caller holds cgroup_mutex. If threadgroup is
>  true, then a successful result indicates that all threads in the given
>  thread's threadgroup can be moved together.
>  
> +void cancel_attach(struct cgroup_subsys *ss, struct cgroup *cgrp,
> +	       struct task_struct *task, bool threadgroup)
> +(cgroup_mutex held by caller)
> +
> +Called when a task attach operation has failed after can_attach() has succeeded.
> +For example, this will be called if some subsystems are mounted on the same
> +hierarchy, can_attach() operations have succeeded about part of the subsystems,
> +but has failed about next subsystem. This will be called only about subsystems
> +whose can_attach() operation has succeeded. This may be useful for subsystems
> +which prepare something in can_attach() operation but should discard what has
> +been prepared on failure.
> +

Hmm..I'd like to add a text like this ..
==
  +A subsystem whose can_attach() has some side-effects should provide this function.
  +Then, the subsytem can implement a rollback. If not, not necessary.
==

>  void attach(struct cgroup_subsys *ss, struct cgroup *cgrp,
>  	    struct cgroup *old_cgrp, struct task_struct *task,
>  	    bool threadgroup)
> diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
> index 642a47f..a08edbc 100644
> --- a/include/linux/cgroup.h
> +++ b/include/linux/cgroup.h
> @@ -429,6 +429,8 @@ struct cgroup_subsys {
>  	void (*destroy)(struct cgroup_subsys *ss, struct cgroup *cgrp);
>  	int (*can_attach)(struct cgroup_subsys *ss, struct cgroup *cgrp,
>  			  struct task_struct *tsk, bool threadgroup);
> +	void (*cancel_attach)(struct cgroup_subsys *ss, struct cgroup *cgrp,
> +			  struct task_struct *tsk, bool threadgroup);
>  	void (*attach)(struct cgroup_subsys *ss, struct cgroup *cgrp,
>  			struct cgroup *old_cgrp, struct task_struct *tsk,
>  			bool threadgroup);
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index 7da6004..2d9a808 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -1700,7 +1700,7 @@ void threadgroup_fork_unlock(struct sighand_struct *sighand)
>  int cgroup_attach_task(struct cgroup *cgrp, struct task_struct *tsk)
>  {
>  	int retval;
> -	struct cgroup_subsys *ss;
> +	struct cgroup_subsys *ss, *fail = NULL;
>  	struct cgroup *oldcgrp;
>  	struct cgroupfs_root *root = cgrp->root;
>  
> @@ -1712,14 +1712,16 @@ int cgroup_attach_task(struct cgroup *cgrp, struct task_struct *tsk)
>  	for_each_subsys(root, ss) {
>  		if (ss->can_attach) {
>  			retval = ss->can_attach(ss, cgrp, tsk, false);
> -			if (retval)
> -				return retval;
> +			if (retval) {
> +				fail = ss;
> +				goto out;
> +			}
>  		}
>  	}
>  
>  	retval = cgroup_task_migrate(cgrp, oldcgrp, tsk, 0);
>  	if (retval)
> -		return retval;
> +		goto out;
>  

Hmm...maybe we don't have this code in the latest tree.
Ah...ok, this is from
cgroups-add-ability-to-move-all-threads-in-a-process-to-a-new-cgroup-atomically
.patch
which is now hidden.



>  	for_each_subsys(root, ss) {
>  		if (ss->attach)
> @@ -1733,7 +1735,15 @@ int cgroup_attach_task(struct cgroup *cgrp, struct task_struct *tsk)
>  	 * is no longer empty.
>  	 */
>  	cgroup_wakeup_rmdir_waiter(cgrp);
> -	return 0;
> +out:
> +	if (retval)
> +		for_each_subsys(root, ss) {
> +			if (ss == fail)
> +				break;
> +			if (ss->cancel_attach)
> +				ss->cancel_attach(ss, cgrp, tsk, false);
> +		}
> +	return retval;
>  }
>  
>  /*
> @@ -1813,7 +1823,7 @@ static int css_set_prefetch(struct cgroup *cgrp, struct css_set *cg,
>  int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
>  {
>  	int retval;
> -	struct cgroup_subsys *ss;
> +	struct cgroup_subsys *ss, *fail = NULL;
>  	struct cgroup *oldcgrp;
>  	struct css_set *oldcg;
>  	struct cgroupfs_root *root = cgrp->root;
> @@ -1839,8 +1849,10 @@ int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
>  	for_each_subsys(root, ss) {
>  		if (ss->can_attach) {
>  			retval = ss->can_attach(ss, cgrp, leader, true);
> -			if (retval)
> -				return retval;
> +			if (retval) {
> +				fail = ss;
> +				goto out;
> +			}
>  		}
>  	}
>  
> @@ -1978,6 +1990,14 @@ list_teardown:
>  		put_css_set(cg_entry->cg);
>  		kfree(cg_entry);
>  	}
> +out:
> +	if (retval)
> +		for_each_subsys(root, ss) {
> +			if (ss == fail)
> +				break;
> +			if (ss->cancel_attach)
> +				ss->cancel_attach(ss, cgrp, tsk, true);
> +		}
>  	/* done! */
>  	return retval;
>  }

No objections from me. just wait for comments from Paul or Li.

I wonder if we add cancel_attach(), can_attach() should be renamed to
prepare_attach() or some. ;)


Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
