Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 0A1CE6B004F
	for <linux-mm@kvack.org>; Tue, 29 Nov 2011 20:08:55 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 71BC63EE0BD
	for <linux-mm@kvack.org>; Wed, 30 Nov 2011 10:08:52 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 51B8B45DEE8
	for <linux-mm@kvack.org>; Wed, 30 Nov 2011 10:08:52 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 21CF445DEEE
	for <linux-mm@kvack.org>; Wed, 30 Nov 2011 10:08:52 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 12D371DB803B
	for <linux-mm@kvack.org>; Wed, 30 Nov 2011 10:08:52 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id A4E381DB803F
	for <linux-mm@kvack.org>; Wed, 30 Nov 2011 10:08:51 +0900 (JST)
Date: Wed, 30 Nov 2011 10:07:38 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v7 03/10] socket: initial cgroup code.
Message-Id: <20111130100738.553020ba.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1322611021-1730-4-git-send-email-glommer@parallels.com>
References: <1322611021-1730-1-git-send-email-glommer@parallels.com>
	<1322611021-1730-4-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, paul@paulmenage.org, lizf@cn.fujitsu.com, ebiederm@xmission.com, davem@davemloft.net, gthelen@google.com, netdev@vger.kernel.org, linux-mm@kvack.org, kirill@shutemov.name, avagin@parallels.com, devel@openvz.org, eric.dumazet@gmail.com, cgroups@vger.kernel.org

On Tue, 29 Nov 2011 21:56:54 -0200
Glauber Costa <glommer@parallels.com> wrote:

> The goal of this work is to move the memory pressure tcp
> controls to a cgroup, instead of just relying on global
> conditions.
> 
> To avoid excessive overhead in the network fast paths,
> the code that accounts allocated memory to a cgroup is
> hidden inside a static_branch(). This branch is patched out
> until the first non-root cgroup is created. So when nobody
> is using cgroups, even if it is mounted, no significant performance
> penalty should be seen.
> 
> This patch handles the generic part of the code, and has nothing
> tcp-specific.
> 
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> Acked-by: Kirill A. Shutemov<kirill@shutemov.name>
> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujtsu.com>
> CC: David S. Miller <davem@davemloft.net>
> CC: Eric W. Biederman <ebiederm@xmission.com>
> CC: Eric Dumazet <eric.dumazet@gmail.com>

<snip>

> +extern struct jump_label_key memcg_socket_limit_enabled;
>  static inline bool sk_has_memory_pressure(const struct sock *sk)
>  {
>  	return sk->sk_prot->memory_pressure != NULL;
> @@ -873,6 +900,17 @@ static inline bool sk_under_memory_pressure(const struct sock *sk)
>  {
>  	if (!sk->sk_prot->memory_pressure)
>  		return false;
> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
> +	if (static_branch(&memcg_socket_limit_enabled)) {
> +		struct cg_proto *cg_proto = sk->sk_cgrp;
> +
> +		if (!cg_proto)
> +			goto nocgroup;
> +		return !!*cg_proto->memory_pressure;
> +	} else

What is dangling 'else' for ?


> +nocgroup:
> +#endif
> +
>  	return !!*sk->sk_prot->memory_pressure;
>  }
>  
> @@ -880,52 +918,176 @@ static inline void sk_leave_memory_pressure(struct sock *sk)
>  {
>  	int *memory_pressure = sk->sk_prot->memory_pressure;
>  
> -	if (memory_pressure && *memory_pressure)
> +	if (!memory_pressure)
> +		return;
> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
> +	if (static_branch(&memcg_socket_limit_enabled)) {
> +		struct cg_proto *cg_proto = sk->sk_cgrp;
> +
> +		if (!cg_proto)
> +			goto nocgroup;
> +
> +		for (; cg_proto; cg_proto = cg_proto->parent)
> +			if (*cg_proto->memory_pressure)
> +				*cg_proto->memory_pressure = 0;
> +	}
> +nocgroup:
> +#endif

Hmm..can't we have a good way for avoiding this #ifdef ?

I guess... as NUMA_BUILD macro in page_alloc.c, you can define

if (HAS_KMEM_LIMIT && static_branch(&.....)).

For example,
==
#include <stdio.h>

#define HAS_SPECIAL     0

int main(int argc, char *argv[])
{
        if (HAS_SPECIAL)
                call();

        printf("Hey!");
}
==

This can be compiled.

So. I guess...

#ifdef CONFIG_CGROUP_MEM_RES_CTLR
#define do_memcg_kmem_account static_branch(&memcg_socket_limit_enabled)
#else
#define do_memcg_kmem_account 0
#endif

maybe good.(not tested.)


BTW, I don't think 'goto nocgroup' is good.



> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 3becb24..12a08bf 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -377,6 +377,40 @@ enum mem_type {
>  #define MEM_CGROUP_RECLAIM_SOFT_BIT	0x2
>  #define MEM_CGROUP_RECLAIM_SOFT		(1 << MEM_CGROUP_RECLAIM_SOFT_BIT)
>  
> +static inline bool mem_cgroup_is_root(struct mem_cgroup *memcg)
> +{
> +	return (memcg == root_mem_cgroup);
> +}
> +

Why do you need this move of definition ?



Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
