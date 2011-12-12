Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 7DDF66B0088
	for <linux-mm@kvack.org>; Sun, 11 Dec 2011 19:34:29 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 86DEC3EE0B6
	for <linux-mm@kvack.org>; Mon, 12 Dec 2011 09:34:27 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4E54945DE58
	for <linux-mm@kvack.org>; Mon, 12 Dec 2011 09:34:27 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1F15045DE51
	for <linux-mm@kvack.org>; Mon, 12 Dec 2011 09:34:27 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0C1E01DB8044
	for <linux-mm@kvack.org>; Mon, 12 Dec 2011 09:34:27 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id A86D21DB803E
	for <linux-mm@kvack.org>; Mon, 12 Dec 2011 09:34:26 +0900 (JST)
Date: Mon, 12 Dec 2011 09:33:13 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v8 3/9] socket: initial cgroup code.
Message-Id: <20111212093313.20f274b3.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4EE20254.6000308@parallels.com>
References: <1323120903-2831-1-git-send-email-glommer@parallels.com>
	<1323120903-2831-4-git-send-email-glommer@parallels.com>
	<20111209110550.fc740b81.kamezawa.hiroyu@jp.fujitsu.com>
	<4EE20254.6000308@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, lizf@cn.fujitsu.com, ebiederm@xmission.com, davem@davemloft.net, gthelen@google.com, netdev@vger.kernel.org, linux-mm@kvack.org, kirill@shutemov.name, avagin@parallels.com, devel@openvz.org, eric.dumazet@gmail.com, cgroups@vger.kernel.org, hannes@cmpxchg.org, mhocko@suse.cz, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujtsu.com>

On Fri, 9 Dec 2011 10:43:00 -0200
Glauber Costa <glommer@parallels.com> wrote:

> On 12/09/2011 12:05 AM, KAMEZAWA Hiroyuki wrote:
> > On Mon,  5 Dec 2011 19:34:57 -0200
> > Glauber Costa<glommer@parallels.com>  wrote:
> >
> >> The goal of this work is to move the memory pressure tcp
> >> controls to a cgroup, instead of just relying on global
> >> conditions.
> >>
> >> To avoid excessive overhead in the network fast paths,
> >> the code that accounts allocated memory to a cgroup is
> >> hidden inside a static_branch(). This branch is patched out
> >> until the first non-root cgroup is created. So when nobody
> >> is using cgroups, even if it is mounted, no significant performance
> >> penalty should be seen.
> >>
> >> This patch handles the generic part of the code, and has nothing
> >> tcp-specific.
> >>
> >> Signed-off-by: Glauber Costa<glommer@parallels.com>
> >> CC: Kirill A. Shutemov<kirill@shutemov.name>
> >> CC: KAMEZAWA Hiroyuki<kamezawa.hiroyu@jp.fujtsu.com>
> >> CC: David S. Miller<davem@davemloft.net>
> >> CC: Eric W. Biederman<ebiederm@xmission.com>
> >> CC: Eric Dumazet<eric.dumazet@gmail.com>
> >
> > I already replied Reviewed-by: but...
> Feel free. Reviews, the more, the merrier.
> 
> >
> >
> >> +/* Writing them here to avoid exposing memcg's inner layout */
> >> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
> >> +#ifdef CONFIG_INET
> >> +#include<net/sock.h>
> >> +
> >> +static bool mem_cgroup_is_root(struct mem_cgroup *memcg);
> >> +void sock_update_memcg(struct sock *sk)
> >> +{
> >> +	/* A socket spends its whole life in the same cgroup */
> >> +	if (sk->sk_cgrp) {
> >> +		WARN_ON(1);
> >> +		return;
> >> +	}
> >> +	if (static_branch(&memcg_socket_limit_enabled)) {
> >> +		struct mem_cgroup *memcg;
> >> +
> >> +		BUG_ON(!sk->sk_prot->proto_cgroup);
> >> +
> >> +		rcu_read_lock();
> >> +		memcg = mem_cgroup_from_task(current);
> >> +		if (!mem_cgroup_is_root(memcg)) {
> >> +			mem_cgroup_get(memcg);
> >> +			sk->sk_cgrp = sk->sk_prot->proto_cgroup(memcg);
> >> +		}
> >> +		rcu_read_unlock();
> >> +	}
> >> +}
> >
> > Here, you do mem_cgroup_get() if !mem_cgroup_is_root().
> >
> >
> >> +EXPORT_SYMBOL(sock_update_memcg);
> >> +
> >> +void sock_release_memcg(struct sock *sk)
> >> +{
> >> +	if (static_branch(&memcg_socket_limit_enabled)&&  sk->sk_cgrp) {
> >> +		struct mem_cgroup *memcg;
> >> +		WARN_ON(!sk->sk_cgrp->memcg);
> >> +		memcg = sk->sk_cgrp->memcg;
> >> +		mem_cgroup_put(memcg);
> >> +	}
> >> +}
> >>
> >
> > You don't check !mem_cgroup_is_root(). Hm, root memcg will not be freed
> > by this ?
> >
> No, I don't. But I check if sk->sk_cgrp is filled. So it is implied, 
> because we only fill in this value if !mem_cgroup_is_root().

Ah, ok. thank you.
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
