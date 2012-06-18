Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 8550F6B0073
	for <linux-mm@kvack.org>; Mon, 18 Jun 2012 08:39:19 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 293E53EE0B5
	for <linux-mm@kvack.org>; Mon, 18 Jun 2012 21:39:18 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id F36E945DE59
	for <linux-mm@kvack.org>; Mon, 18 Jun 2012 21:39:17 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id DAED745DE56
	for <linux-mm@kvack.org>; Mon, 18 Jun 2012 21:39:17 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id CD8761DB804F
	for <linux-mm@kvack.org>; Mon, 18 Jun 2012 21:39:17 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 865D01DB8047
	for <linux-mm@kvack.org>; Mon, 18 Jun 2012 21:39:17 +0900 (JST)
Message-ID: <4FDF20ED.4090401@jp.fujitsu.com>
Date: Mon, 18 Jun 2012 21:37:01 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4 23/25] memcg: propagate kmem limiting information to
 children
References: <1340015298-14133-1-git-send-email-glommer@parallels.com> <1340015298-14133-24-git-send-email-glommer@parallels.com>
In-Reply-To: <1340015298-14133-24-git-send-email-glommer@parallels.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Cristoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, cgroups@vger.kernel.org, devel@openvz.org, linux-kernel@vger.kernel.org, Frederic Weisbecker <fweisbec@gmail.com>, Suleiman Souhlal <suleiman@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>

(2012/06/18 19:28), Glauber Costa wrote:
> The current memcg slab cache management fails to present satisfatory hierarchical
> behavior in the following scenario:
> 
> ->  /cgroups/memory/A/B/C
> 
> * kmem limit set at A
> * A and B empty taskwise
> * bash in C does find /
> 
> Because kmem_accounted is a boolean that was not set for C, no accounting
> would be done. This is, however, not what we expect.
> 

Hmm....do we need this new routines even while we have mem_cgroup_iter() ?

Doesn't this work ?

	struct mem_cgroup {
		.....
		bool kmem_accounted_this;
		atomic_t kmem_accounted;
		....
	}

at set limit

	....set_limit(memcg) {

		if (newly accounted) {
			mem_cgroup_iter() {
				atomic_inc(&iter->kmem_accounted)
			}
		} else {
			mem_cgroup_iter() {
				atomic_dec(&iter->kmem_accounted);
			}
	}


hm ? Then, you can see kmem is accounted or not by atomic_read(&memcg->kmem_accounted);

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
