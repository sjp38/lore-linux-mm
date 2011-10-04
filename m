Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 5FAE19000DF
	for <linux-mm@kvack.org>; Mon,  3 Oct 2011 20:58:09 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 2540E3EE0C2
	for <linux-mm@kvack.org>; Tue,  4 Oct 2011 09:58:04 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id EB9CC45DE58
	for <linux-mm@kvack.org>; Tue,  4 Oct 2011 09:58:03 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id CBE7245DE55
	for <linux-mm@kvack.org>; Tue,  4 Oct 2011 09:58:03 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id BFE121DB8044
	for <linux-mm@kvack.org>; Tue,  4 Oct 2011 09:58:03 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 79F3C1DB8047
	for <linux-mm@kvack.org>; Tue,  4 Oct 2011 09:58:03 +0900 (JST)
Date: Tue, 4 Oct 2011 09:57:15 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v4 3/8] foundations of per-cgroup memory pressure
 controlling.
Message-Id: <20111004095715.479da44d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1317637123-18306-4-git-send-email-glommer@parallels.com>
References: <1317637123-18306-1-git-send-email-glommer@parallels.com>
	<1317637123-18306-4-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, paul@paulmenage.org, lizf@cn.fujitsu.com, ebiederm@xmission.com, davem@davemloft.net, gthelen@google.com, netdev@vger.kernel.org, linux-mm@kvack.org, kirill@shutemov.name, avagin@parallels.com

On Mon,  3 Oct 2011 14:18:38 +0400
Glauber Costa <glommer@parallels.com> wrote:

> This patch converts struct sock fields memory_pressure,
> memory_allocated, sockets_allocated, and sysctl_mem (now prot_mem)
> to function pointers, receiving a struct mem_cgroup parameter.
> 
> enter_memory_pressure is kept the same, since all its callers
> have socket a context, and the kmem_cgroup can be derived from
> the socket itself.
> 
> To keep things working, the patch convert all users of those fields
> to use acessor functions.
> 
> In my benchmarks I didn't see a significant performance difference
> with this patch applied compared to a baseline (around 1 % diff, thus
> inside error margin).
> 
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> CC: David S. Miller <davem@davemloft.net>
> CC: Hiroyouki Kamezawa <kamezawa.hiroyu@jp.fujitsu.com>
> CC: Eric W. Biederman <ebiederm@xmission.com>

A nitpick.

 
>  #ifdef CONFIG_INET
>  struct sock;
> +struct proto;
>  #ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
>  void sock_update_memcg(struct sock *sk);
>  void sock_release_memcg(struct sock *sk);
> -
> +void memcg_sock_mem_alloc(struct mem_cgroup *mem, struct proto *prot,
> +			  int amt, int *parent_failure);
> +void memcg_sock_mem_free(struct mem_cgroup *mem, struct proto *prot, int amt);
> +void memcg_sockets_allocated_dec(struct mem_cgroup *mem, struct proto *prot);
> +void memcg_sockets_allocated_inc(struct mem_cgroup *mem, struct proto *prot);
>  #else
> +/* memcontrol includes sockets.h, that includes memcontrol.h ... */
> +static inline void memcg_sock_mem_alloc(struct mem_cgroup *mem,
> +					struct proto *prot, int amt,
> +					int *parent_failure)
> +{
> +}

In these days, at naming memory cgroup pointers, we use "memcg" instead of
"mem". So, could you use "memcg" for represeinting memory cgroup ?


> +
> +void memcg_sock_mem_alloc(struct mem_cgroup *mem, struct proto *prot,
> +			  int amt, int *parent_failure)
> +{
> +	mem = parent_mem_cgroup(mem);
> +	for (; mem != NULL; mem = parent_mem_cgroup(mem)) {
> +		long alloc;
> +		long *prot_mem = prot->prot_mem(mem);
> +		/*
> +		 * Large nestings are not the common case, and stopping in the
> +		 * middle would be complicated enough, that we bill it all the
> +		 * way through the root, and if needed, unbill everything later
> +		 */
> +		alloc = atomic_long_add_return(amt,
> +					       prot->memory_allocated(mem));
> +		*parent_failure |= (alloc > prot_mem[2]);
> +	}
> +}
> +EXPORT_SYMBOL(memcg_sock_mem_alloc);

Hmm. why not using res_counter ? for reusing 'unbill' code ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
