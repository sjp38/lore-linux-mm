Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 31B006B0047
	for <linux-mm@kvack.org>; Fri, 19 Feb 2010 23:25:50 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o1K4PlRC019771
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Sat, 20 Feb 2010 13:25:48 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id BABDC45DE51
	for <linux-mm@kvack.org>; Sat, 20 Feb 2010 13:25:47 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8FED645DE50
	for <linux-mm@kvack.org>; Sat, 20 Feb 2010 13:25:47 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 755501DB803E
	for <linux-mm@kvack.org>; Sat, 20 Feb 2010 13:25:47 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1C52B1DB8038
	for <linux-mm@kvack.org>; Sat, 20 Feb 2010 13:25:47 +0900 (JST)
Date: Sat, 20 Feb 2010 13:22:17 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH -mmotm 2/4] cgroups: remove events before destroying
 subsystem state objects
Message-Id: <20100220132217.17dc7dd3.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <a2717b1f5e0b49db7b6ecd1a5a41e65c1dc6b50a.1266618391.git.kirill@shutemov.name>
References: <05f582d6cdc85fbb96bfadc344572924c0776730.1266618391.git.kirill@shutemov.name>
	<a2717b1f5e0b49db7b6ecd1a5a41e65c1dc6b50a.1266618391.git.kirill@shutemov.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: containers@lists.linux-foundation.org, linux-mm@kvack.org, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, Dan Malek <dan@embeddedalley.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Sat, 20 Feb 2010 00:28:17 +0200
"Kirill A. Shutemov" <kirill@shutemov.name> wrote:

> Events should be removed after rmdir of cgroup directory, but before
> destroying subsystem state objects. Let's take reference to cgroup
> directory dentry to do that.
> 
> Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>

Okay, I welcome this.

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hioryu@jp.fujitsu.com>

Just a quesion...After this change, if cgroup has remaining event,
cgroup is removed by workqueue of event->remove() -> d_put(), finally. Right ?
Do you have a test set for checking this behavior ?

Thanks,
-Kame



> ---
>  include/linux/cgroup.h |    3 ---
>  kernel/cgroup.c        |    8 ++++++++
>  mm/memcontrol.c        |    9 ---------
>  3 files changed, 8 insertions(+), 12 deletions(-)
> 
> diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
> index 64cebfe..1719c75 100644
> --- a/include/linux/cgroup.h
> +++ b/include/linux/cgroup.h
> @@ -395,9 +395,6 @@ struct cftype {
>  	 * closes the eventfd or on cgroup removing.
>  	 * This callback must be implemented, if you want provide
>  	 * notification functionality.
> -	 *
> -	 * Be careful. It can be called after destroy(), so you have
> -	 * to keep all nesessary data, until all events are removed.
>  	 */
>  	int (*unregister_event)(struct cgroup *cgrp, struct cftype *cft,
>  			struct eventfd_ctx *eventfd);
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index 46903cb..d142524 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -2979,6 +2979,7 @@ static void cgroup_event_remove(struct work_struct *work)
>  
>  	eventfd_ctx_put(event->eventfd);
>  	kfree(event);
> +	dput(cgrp->dentry);
>  }
>  
>  /*
> @@ -3099,6 +3100,13 @@ static int cgroup_write_event_control(struct cgroup *cgrp, struct cftype *cft,
>  		goto fail;
>  	}
>  
> +	/*
> +	 * Events should be removed after rmdir of cgroup directory, but before
> +	 * destroying subsystem state objects. Let's take reference to cgroup
> +	 * directory dentry to do that.
> +	 */
> +	dget(cgrp->dentry);
> +
>  	spin_lock(&cgrp->event_list_lock);
>  	list_add(&event->list, &cgrp->event_list);
>  	spin_unlock(&cgrp->event_list_lock);
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index a443c30..8fe6e7f 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -3358,12 +3358,6 @@ static int mem_cgroup_register_event(struct cgroup *cgrp, struct cftype *cft,
>  		}
>  	}
>  
> -	/*
> -	 * We need to increment refcnt to be sure that all thresholds
> -	 * will be unregistered before calling __mem_cgroup_free()
> -	 */
> -	mem_cgroup_get(memcg);
> -
>  	if (type == _MEM)
>  		rcu_assign_pointer(memcg->thresholds, thresholds_new);
>  	else
> @@ -3457,9 +3451,6 @@ assign:
>  	/* To be sure that nobody uses thresholds before freeing it */
>  	synchronize_rcu();
>  
> -	for (i = 0; i < thresholds->size - size; i++)
> -		mem_cgroup_put(memcg);
> -
>  	kfree(thresholds);
>  unlock:
>  	mutex_unlock(&memcg->thresholds_lock);
> -- 
> 1.6.6.2
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
