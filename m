Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id DBFEE6B002C
	for <linux-mm@kvack.org>; Sun, 16 Oct 2011 20:33:57 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 290D93EE081
	for <linux-mm@kvack.org>; Mon, 17 Oct 2011 09:33:54 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0E7A245DE7A
	for <linux-mm@kvack.org>; Mon, 17 Oct 2011 09:33:54 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id E955445DE61
	for <linux-mm@kvack.org>; Mon, 17 Oct 2011 09:33:53 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id D97C01DB803F
	for <linux-mm@kvack.org>; Mon, 17 Oct 2011 09:33:53 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id A55641DB803E
	for <linux-mm@kvack.org>; Mon, 17 Oct 2011 09:33:53 +0900 (JST)
Date: Mon, 17 Oct 2011 09:32:57 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] [PATCH 0/4] memcg: Kernel memory accounting.
Message-Id: <20111017093257.054e9af6.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1318639110-27714-1-git-send-email-ssouhlal@FreeBSD.org>
References: <1318639110-27714-1-git-send-email-ssouhlal@FreeBSD.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Suleiman Souhlal <ssouhlal@FreeBSD.org>
Cc: glommer@parallels.com, gthelen@google.com, yinghan@google.com, jbottomley@parallels.com, suleiman@google.com, linux-mm@kvack.org

On Fri, 14 Oct 2011 17:38:26 -0700
Suleiman Souhlal <ssouhlal@FreeBSD.org> wrote:

> This patch series introduces kernel memory accounting to memcg.
> It currently only accounts for slab.
> 
> With this, kernel memory gets counted in a memcg's usage_in_bytes.
> 
> Slab gets accounted per-page, by using per-cgroup kmem_caches that
> get created the first time an allocation of that type is done by
> that cgroup.
> This means that we only have to do charges/uncharges in the slow
> path of the slab allocator, which should have low performance
> impacts.
> 
> A per-cgroup kmem_cache will appear in slabinfo named like its
> original cache, with the cgroup's name in parenthesis.
> On cgroup deletion, the accounting gets moved to the root cgroup
> and any existing cgroup kmem_cache gets "dead" appended to its
> name, to indicate that its accounting was migrated.
> 
> TODO:
> 	- Per-memcg slab shrinking (we have patches for that already).
> 	- Make it support the other slab allocators.
> 	- Come up with a scheme that does not require holding
> 	  rcu_read_lock in the whole slab allocation path.
> 	- Account for other types of kernel memory than slab.
> 	- Migrate to the parent cgroup instead of root on cgroup
> 	  deletion.
> 

Could you show rough perforamance score ?

For example,
Assume cgroup dir as

  /cgroup/memory <--- root
		|-A  memory.use_hierarchy=1   no limit
		  |-B                         no limit
1) Compare kernel make 'sys time' under root, A, B.
2) run unixbench under root, A, B.

I think you may have some numbers already.

Thanks,
-Kame








--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
