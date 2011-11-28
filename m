Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 490D66B0088
	for <linux-mm@kvack.org>; Sun, 27 Nov 2011 22:26:18 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id B60CD3EE081
	for <linux-mm@kvack.org>; Mon, 28 Nov 2011 12:26:12 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 992CB45DE69
	for <linux-mm@kvack.org>; Mon, 28 Nov 2011 12:26:12 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 813BB45DE61
	for <linux-mm@kvack.org>; Mon, 28 Nov 2011 12:26:12 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 75AB91DB802C
	for <linux-mm@kvack.org>; Mon, 28 Nov 2011 12:26:12 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 41FAF1DB8038
	for <linux-mm@kvack.org>; Mon, 28 Nov 2011 12:26:12 +0900 (JST)
Date: Mon, 28 Nov 2011 12:24:52 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v6 06/10] tcp buffer limitation: per-cgroup limit
Message-Id: <20111128122452.734d93c0.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1322242696-27682-7-git-send-email-glommer@parallels.com>
References: <1322242696-27682-1-git-send-email-glommer@parallels.com>
	<1322242696-27682-7-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, lizf@cn.fujitsu.com, ebiederm@xmission.com, davem@davemloft.net, paul@paulmenage.org, gthelen@google.com, netdev@vger.kernel.org, linux-mm@kvack.org, kirill@shutemov.name, avagin@parallels.com, devel@openvz.org, eric.dumazet@gmail.com, cgroups@vger.kernel.org


some comments.

On Fri, 25 Nov 2011 15:38:12 -0200
Glauber Costa <glommer@parallels.com> wrote:

> This patch uses the "tcp.limit_in_bytes" field of the kmem_cgroup to
> effectively control the amount of kernel memory pinned by a cgroup.
> 
> This value is ignored in the root cgroup, and in all others,
> caps the value specified by the admin in the net namespaces'
> view of tcp_sysctl_mem.
> 
> If namespaces are being used, the admin is allowed to set a
> value bigger than cgroup's maximum, the same way it is allowed
> to set pretty much unlimited values in a real box.
> 
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> CC: David S. Miller <davem@davemloft.net>
> CC: Hiroyouki Kamezawa <kamezawa.hiroyu@jp.fujitsu.com>
> CC: Eric W. Biederman <ebiederm@xmission.com>

<snip>

>  EXPORT_SYMBOL(tcp_destroy_cgroup);
> +
> +int tcp_update_limit(struct mem_cgroup *memcg, u64 val)
> +{
> +	struct net *net = current->nsproxy->net_ns;
> +	struct tcp_memcontrol *tcp;
> +	struct cg_proto *cg_proto;
> +	int i;
> +	int ret;
> +
> +	cg_proto = tcp_prot.proto_cgroup(memcg);
> +	if (!cg_proto)
> +		return -EINVAL;
> +
> +	tcp = tcp_from_cgproto(cg_proto);
> +
> +	ret = res_counter_set_limit(&tcp->tcp_memory_allocated, val);

Here, you changed the limit.

> +	if (ret)
> +		return ret;
> +
> +	val >>= PAGE_SHIFT;

Here, you modifies 'val'

> +
> +	for (i = 0; i < 3; i++)
> +		tcp->tcp_prot_mem[i] = min_t(long, val,
> +					     net->ipv4.sysctl_tcp_mem[i]);
> +
> +	if (val == RESOURCE_MAX)
> +		jump_label_dec(&memcg_socket_limit_enabled);

the 'val' never be RESOUECE_MAX.


> +	else {
> +		u64 old_lim;
> +		old_lim = res_counter_read_u64(&tcp->tcp_memory_allocated,
> +					       RES_LIMIT);

old_lim is not already overwritten ?

> +		if (old_lim == RESOURCE_MAX)
> +			jump_label_inc(&memcg_socket_limit_enabled);
> +	}
> +	return 0;
> +}
> +

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
