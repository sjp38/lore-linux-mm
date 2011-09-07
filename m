Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 6F4A16B016D
	for <linux-mm@kvack.org>; Wed,  7 Sep 2011 18:17:12 -0400 (EDT)
Date: Thu, 8 Sep 2011 01:17:10 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v2 3/9] socket: initial cgroup code.
Message-ID: <20110907221710.GA7845@shutemov.name>
References: <1315369399-3073-1-git-send-email-glommer@parallels.com>
 <1315369399-3073-4-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1315369399-3073-4-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, xemul@parallels.com, netdev@vger.kernel.org, linux-mm@kvack.org, "Eric W. Biederman" <ebiederm@xmission.com>, containers@lists.osdl.org, "David S. Miller" <davem@davemloft.net>

On Wed, Sep 07, 2011 at 01:23:13AM -0300, Glauber Costa wrote:
> We aim to control the amount of kernel memory pinned at any
> time by tcp sockets. To lay the foundations for this work,
> this patch adds a pointer to the kmem_cgroup to the socket
> structure.
> 
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> CC: David S. Miller <davem@davemloft.net>
> CC: Hiroyouki Kamezawa <kamezawa.hiroyu@jp.fujitsu.com>
> CC: Eric W. Biederman <ebiederm@xmission.com>
> ---
>  include/linux/kmem_cgroup.h |   29 +++++++++++++++++++++++++++++
>  include/net/sock.h          |    2 ++
>  net/core/sock.c             |    5 ++---
>  3 files changed, 33 insertions(+), 3 deletions(-)
> 
> diff --git a/include/linux/kmem_cgroup.h b/include/linux/kmem_cgroup.h
> index 0e4a74b..77076d8 100644
> --- a/include/linux/kmem_cgroup.h
> +++ b/include/linux/kmem_cgroup.h
> @@ -49,5 +49,34 @@ static inline struct kmem_cgroup *kcg_from_task(struct task_struct *tsk)
>  	return NULL;
>  }
>  #endif /* CONFIG_CGROUP_KMEM */
> +
> +#ifdef CONFIG_INET

Will it break something if you define the helpers even if CONFIG_INET
is not defined?
It will be much cleaner. You can reuse ifdef CONFIG_CGROUP_KMEM in this
case.

> +#include <net/sock.h>
> +static inline void sock_update_kmem_cgrp(struct sock *sk)
> +{
> +#ifdef CONFIG_CGROUP_KMEM
> +	sk->sk_cgrp = kcg_from_task(current);
> +
> +	/*
> +	 * We don't need to protect against anything task-related, because
> +	 * we are basically stuck with the sock pointer that won't change,
> +	 * even if the task that originated the socket changes cgroups.
> +	 *
> +	 * What we do have to guarantee, is that the chain leading us to
> +	 * the top level won't change under our noses. Incrementing the
> +	 * reference count via cgroup_exclude_rmdir guarantees that.
> +	 */
> +	cgroup_exclude_rmdir(&sk->sk_cgrp->css);
> +#endif
> +}
> +
> +static inline void sock_release_kmem_cgrp(struct sock *sk)
> +{
> +#ifdef CONFIG_CGROUP_KMEM
> +	cgroup_release_and_wakeup_rmdir(&sk->sk_cgrp->css);
> +#endif
> +}
> +
> +#endif /* CONFIG_INET */
>  #endif /* _LINUX_KMEM_CGROUP_H */

> @@ -2252,9 +2254,6 @@ void sk_common_release(struct sock *sk)
>  }
>  EXPORT_SYMBOL(sk_common_release);
>  
> -static DEFINE_RWLOCK(proto_list_lock);
> -static LIST_HEAD(proto_list);
> -

Wrong patch?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
