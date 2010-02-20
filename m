Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 73E0C6B0047
	for <linux-mm@kvack.org>; Fri, 19 Feb 2010 23:04:29 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o1K44Rnh007109
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Sat, 20 Feb 2010 13:04:27 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id C1B9B45DE59
	for <linux-mm@kvack.org>; Sat, 20 Feb 2010 13:04:26 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 958B545DE55
	for <linux-mm@kvack.org>; Sat, 20 Feb 2010 13:04:26 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 76B751DB8042
	for <linux-mm@kvack.org>; Sat, 20 Feb 2010 13:04:26 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2B26B1DB8044
	for <linux-mm@kvack.org>; Sat, 20 Feb 2010 13:04:26 +0900 (JST)
Date: Sat, 20 Feb 2010 13:00:55 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH -mmotm 1/4] cgroups: Fix race between userspace and
 kernelspace
Message-Id: <20100220130055.02bb143a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <05f582d6cdc85fbb96bfadc344572924c0776730.1266618391.git.kirill@shutemov.name>
References: <05f582d6cdc85fbb96bfadc344572924c0776730.1266618391.git.kirill@shutemov.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: containers@lists.linux-foundation.org, linux-mm@kvack.org, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, Dan Malek <dan@embeddedalley.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Sat, 20 Feb 2010 00:28:16 +0200
"Kirill A. Shutemov" <kirill@shutemov.name> wrote:

> Notify userspace about cgroup removing only after rmdir of cgroup
> directory to avoid race between userspace and kernelspace.
> 
> Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Hmm, but could you elaborate what is the race in patch description.
I can imagine by reading your patch but please write it in clear way.



> ---
>  kernel/cgroup.c |   32 +++++++++++++++++---------------
>  1 files changed, 17 insertions(+), 15 deletions(-)
> 
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index ce9008f..46903cb 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -780,28 +780,15 @@ static struct inode *cgroup_new_inode(mode_t mode, struct super_block *sb)
>  static int cgroup_call_pre_destroy(struct cgroup *cgrp)
>  {
>  	struct cgroup_subsys *ss;
> -	struct cgroup_event *event, *tmp;
>  	int ret = 0;
>  
>  	for_each_subsys(cgrp->root, ss)
>  		if (ss->pre_destroy) {
>  			ret = ss->pre_destroy(ss, cgrp);
>  			if (ret)
> -				goto out;
> +				break;
>  		}
>  
> -	/*
> -	 * Unregister events and notify userspace.
> -	 */
> -	spin_lock(&cgrp->event_list_lock);
> -	list_for_each_entry_safe(event, tmp, &cgrp->event_list, list) {
> -		list_del(&event->list);
> -		eventfd_signal(event->eventfd, 1);
> -		schedule_work(&event->remove);
> -	}
> -	spin_unlock(&cgrp->event_list_lock);
> -
> -out:
>  	return ret;
>  }
>  
> @@ -2991,7 +2978,6 @@ static void cgroup_event_remove(struct work_struct *work)
>  	event->cft->unregister_event(cgrp, event->cft, event->eventfd);
>  
>  	eventfd_ctx_put(event->eventfd);
> -	remove_wait_queue(event->wqh, &event->wait);
>  	kfree(event);
>  }
>  
> @@ -3009,6 +2995,7 @@ static int cgroup_event_wake(wait_queue_t *wait, unsigned mode,
>  	unsigned long flags = (unsigned long)key;
>  
>  	if (flags & POLLHUP) {
> +		remove_wait_queue_locked(event->wqh, &event->wait);
>  		spin_lock(&cgrp->event_list_lock);
>  		list_del(&event->list);
>  		spin_unlock(&cgrp->event_list_lock);
> @@ -3457,6 +3444,7 @@ static int cgroup_rmdir(struct inode *unused_dir, struct dentry *dentry)
>  	struct dentry *d;
>  	struct cgroup *parent;
>  	DEFINE_WAIT(wait);
> +	struct cgroup_event *event, *tmp;
>  	int ret;
>  
>  	/* the vfs holds both inode->i_mutex already */
> @@ -3540,6 +3528,20 @@ again:
>  	set_bit(CGRP_RELEASABLE, &parent->flags);
>  	check_for_release(parent);
>  
> +	/*
> +	 * Unregister events and notify userspace.
> +	 * Notify userspace about cgroup removing only after rmdir of cgroup
> +	 * directory to avoid race between userspace and kernelspace
> +	 */
> +	spin_lock(&cgrp->event_list_lock);
> +	list_for_each_entry_safe(event, tmp, &cgrp->event_list, list) {
> +		list_del(&event->list);
> +		remove_wait_queue(event->wqh, &event->wait);
> +		eventfd_signal(event->eventfd, 1);
> +		schedule_work(&event->remove);
> +	}
> +	spin_unlock(&cgrp->event_list_lock);
> +
>  	mutex_unlock(&cgroup_mutex);
>  	return 0;
>  }
> -- 
> 1.6.6.2
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
