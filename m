Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id DF9806B004F
	for <linux-mm@kvack.org>; Tue, 29 Nov 2011 19:44:27 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id F33463EE0BC
	for <linux-mm@kvack.org>; Wed, 30 Nov 2011 09:44:23 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id D549445DEE6
	for <linux-mm@kvack.org>; Wed, 30 Nov 2011 09:44:23 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id ACA0B45DEE1
	for <linux-mm@kvack.org>; Wed, 30 Nov 2011 09:44:23 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9F63A1DB803B
	for <linux-mm@kvack.org>; Wed, 30 Nov 2011 09:44:23 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3D9FF1DB8043
	for <linux-mm@kvack.org>; Wed, 30 Nov 2011 09:44:23 +0900 (JST)
Date: Wed, 30 Nov 2011 09:43:05 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v7 02/10] foundations of per-cgroup memory pressure
 controlling.
Message-Id: <20111130094305.9c69ecd8.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1322611021-1730-3-git-send-email-glommer@parallels.com>
References: <1322611021-1730-1-git-send-email-glommer@parallels.com>
	<1322611021-1730-3-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, paul@paulmenage.org, lizf@cn.fujitsu.com, ebiederm@xmission.com, davem@davemloft.net, gthelen@google.com, netdev@vger.kernel.org, linux-mm@kvack.org, kirill@shutemov.name, avagin@parallels.com, devel@openvz.org, eric.dumazet@gmail.com, cgroups@vger.kernel.org

On Tue, 29 Nov 2011 21:56:53 -0200
Glauber Costa <glommer@parallels.com> wrote:

> This patch replaces all uses of struct sock fields' memory_pressure,
> memory_allocated, sockets_allocated, and sysctl_mem to acessor
> macros. Those macros can either receive a socket argument, or a mem_cgroup
> argument, depending on the context they live in.
> 
> Since we're only doing a macro wrapping here, no performance impact at all is
> expected in the case where we don't have cgroups disabled.
> 
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> CC: David S. Miller <davem@davemloft.net>
> CC: Hiroyouki Kamezawa <kamezawa.hiroyu@jp.fujitsu.com>
> CC: Eric W. Biederman <ebiederm@xmission.com>
> CC: Eric Dumazet <eric.dumazet@gmail.com>
<snip>

> +static inline bool
> +memcg_memory_pressure(struct proto *prot, struct mem_cgroup *memcg)
> +{
> +	if (!prot->memory_pressure)
> +		return false;
> +	return !!prot->memory_pressure;
> +}

I think you should take a deep breath and write patech relaxedly, and do enough test.

This should be

	return !!*prot->memory_pressure;

BTW, I don't like to receive tons of everyday-update even if you're in hurry.





>  static void proto_seq_printf(struct seq_file *seq, struct proto *proto)
>  {
> +	struct mem_cgroup *memcg = mem_cgroup_from_task(current);
> +
>  	seq_printf(seq, "%-9s %4u %6d  %6ld   %-3s %6u   %-3s  %-10s "
>  			"%2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c\n",
>  		   proto->name,
>  		   proto->obj_size,
>  		   sock_prot_inuse_get(seq_file_net(seq), proto),
> -		   proto->memory_allocated != NULL ? atomic_long_read(proto->memory_allocated) : -1L,
> -		   proto->memory_pressure != NULL ? *proto->memory_pressure ? "yes" : "no" : "NI",
> +		   sock_prot_memory_allocated(proto, memcg),
> +		   sock_prot_memory_pressure(proto, memcg),

I wonder I should say NO, here. (Networking guys are ok ??)

IIUC, this means there is no way to see aggregated sockstat of all system.
And the result depends on the cgroup which the caller is under control.

I think you should show aggregated sockstat(global + per-memcg) here and 
show per-memcg ones via /cgroup interface or add private_sockstat to show
per cgroup summary.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
