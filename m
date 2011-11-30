Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 5B2BF6B004D
	for <linux-mm@kvack.org>; Tue, 29 Nov 2011 21:13:10 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 150DC3EE0BD
	for <linux-mm@kvack.org>; Wed, 30 Nov 2011 11:13:04 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id EA98E45DE6F
	for <linux-mm@kvack.org>; Wed, 30 Nov 2011 11:13:03 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9A4A445DE69
	for <linux-mm@kvack.org>; Wed, 30 Nov 2011 11:13:03 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 19A061DB8040
	for <linux-mm@kvack.org>; Wed, 30 Nov 2011 11:13:03 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id C380F1DB803A
	for <linux-mm@kvack.org>; Wed, 30 Nov 2011 11:13:02 +0900 (JST)
Date: Wed, 30 Nov 2011 11:11:52 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v7 00/10] Request for Inclusion: per-cgroup tcp memory
 pressure
Message-Id: <20111130111152.6b1c7366.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1322611021-1730-1-git-send-email-glommer@parallels.com>
References: <1322611021-1730-1-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, paul@paulmenage.org, lizf@cn.fujitsu.com, ebiederm@xmission.com, davem@davemloft.net, gthelen@google.com, netdev@vger.kernel.org, linux-mm@kvack.org, kirill@shutemov.name, avagin@parallels.com, devel@openvz.org, eric.dumazet@gmail.com, cgroups@vger.kernel.org

On Tue, 29 Nov 2011 21:56:51 -0200
Glauber Costa <glommer@parallels.com> wrote:

> Hi,
> 
> This patchset implements per-cgroup tcp memory pressure controls. It did not change
> significantly since last submission: rather, it just merges the comments Kame had.
> Most of them are style-related and/or Documentation, but there are two real bugs he
> managed to spot (thanks)
> 
> Please let me know if there is anything else I should address.
> 

After reading all codes again, I feel some strange. Could you clarify ?

Here.
==
+void sock_update_memcg(struct sock *sk)
+{
+	/* right now a socket spends its whole life in the same cgroup */
+	if (sk->sk_cgrp) {
+		WARN_ON(1);
+		return;
+	}
+	if (static_branch(&memcg_socket_limit_enabled)) {
+		struct mem_cgroup *memcg;
+
+		BUG_ON(!sk->sk_prot->proto_cgroup);
+
+		rcu_read_lock();
+		memcg = mem_cgroup_from_task(current);
+		if (!mem_cgroup_is_root(memcg))
+			sk->sk_cgrp = sk->sk_prot->proto_cgroup(memcg);
+		rcu_read_unlock();
==

sk->sk_cgrp is set to a memcg without any reference count.

Then, no check for preventing rmdir() and freeing memcgroup.

Is there some css_get() or mem_cgroup_get() somewhere ?

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
