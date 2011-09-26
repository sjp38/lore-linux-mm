Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 2FDF59000BD
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 06:59:58 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id CC03E3EE0AE
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 19:59:54 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id B393B45DE7A
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 19:59:54 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9C48845DE61
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 19:59:54 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 908BC1DB802C
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 19:59:54 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5AEC71DB8038
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 19:59:54 +0900 (JST)
Date: Mon, 26 Sep 2011 19:59:06 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v3 4/7] per-cgroup tcp buffers control
Message-Id: <20110926195906.f1f5831c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1316393805-3005-5-git-send-email-glommer@parallels.com>
References: <1316393805-3005-1-git-send-email-glommer@parallels.com>
	<1316393805-3005-5-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, paul@paulmenage.org, lizf@cn.fujitsu.com, ebiederm@xmission.com, davem@davemloft.net, gthelen@google.com, netdev@vger.kernel.org, linux-mm@kvack.org, kirill@shutemov.name

On Sun, 18 Sep 2011 21:56:42 -0300
Glauber Costa <glommer@parallels.com> wrote:

> With all the infrastructure in place, this patch implements
> per-cgroup control for tcp memory pressure handling.
> 
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> CC: David S. Miller <davem@davemloft.net>
> CC: Hiroyouki Kamezawa <kamezawa.hiroyu@jp.fujitsu.com>
> CC: Eric W. Biederman <ebiederm@xmission.com>

a comment below.

> +int tcp_init_cgroup(struct proto *prot, struct cgroup *cgrp,
> +		    struct cgroup_subsys *ss)
> +{
> +	struct mem_cgroup *cg = mem_cgroup_from_cont(cgrp);
> +	unsigned long limit;
> +
> +	cg->tcp_memory_pressure = 0;
> +	atomic_long_set(&cg->tcp_memory_allocated, 0);
> +	percpu_counter_init(&cg->tcp_sockets_allocated, 0);
> +
> +	limit = nr_free_buffer_pages() / 8;
> +	limit = max(limit, 128UL);
> +
> +	cg->tcp_prot_mem[0] = sysctl_tcp_mem[0];
> +	cg->tcp_prot_mem[1] = sysctl_tcp_mem[1];
> +	cg->tcp_prot_mem[2] = sysctl_tcp_mem[2];
> +

Then, the parameter doesn't inherit parent's one ?

I think sockets_populate should pass 'parent' and


I think you should have a function 

    mem_cgroup_should_inherit_parent_settings(parent)

(This is because you made this feature as a part of memcg.
 please provide expected behavior.)

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
