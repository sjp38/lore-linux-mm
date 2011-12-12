Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 678C76B016A
	for <linux-mm@kvack.org>; Mon, 12 Dec 2011 08:49:20 -0500 (EST)
Received: by faao14 with SMTP id o14so785431faa.14
        for <linux-mm@kvack.org>; Mon, 12 Dec 2011 05:49:18 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20111212131118.GA15249@tiehlicka.suse.cz>
References: <CAJd=RBB_AoJmyPd7gfHn+Kk39cn-+Wn-pFvU0ZWRZhw2fxoihw@mail.gmail.com>
	<alpine.LSU.2.00.1112111520510.2297@eggly>
	<20111212131118.GA15249@tiehlicka.suse.cz>
Date: Mon, 12 Dec 2011 21:49:18 +0800
Message-ID: <CAJd=RBAZT0zVnMm7i7P4J9Qg+LvTYh25RwFP7JZnN9dxwWp55g@mail.gmail.com>
Subject: Re: [PATCH] mm: memcg: keep root group unchanged if fail to create new
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Hugh Dickins <hughd@google.com>, Balbir Singh <bsingharora@gmail.com>, David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon, Dec 12, 2011 at 9:11 PM, Michal Hocko <mhocko@suse.cz> wrote:
>
> Hillf could you update the patch please?
>
Hi Michal,

Please review again, thanks.
Hillf

===CUT HERE===
From: Hillf Danton <dhillf@gmail.com>
Subject: [PATCH] mm: memcg: keep root group unchanged if fail to create new

If the request is to create non-root group and we fail to meet it, we should
leave the root unchanged.

Signed-off-by: Hillf Danton <dhillf@gmail.com>
Acked-by: Hugh Dickins <hughd@google.com>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---

--- a/mm/memcontrol.c	Fri Dec  9 21:57:40 2011
+++ b/mm/memcontrol.c	Mon Dec 12 21:47:14 2011
@@ -4848,9 +4848,9 @@ mem_cgroup_create(struct cgroup_subsys *
 		int cpu;
 		enable_swap_cgroup();
 		parent = NULL;
-		root_mem_cgroup = memcg;
 		if (mem_cgroup_soft_limit_tree_init())
 			goto free_out;
+		root_mem_cgroup = memcg;
 		for_each_possible_cpu(cpu) {
 			struct memcg_stock_pcp *stock =
 						&per_cpu(memcg_stock, cpu);
@@ -4888,7 +4888,6 @@ mem_cgroup_create(struct cgroup_subsys *
 	return &memcg->css;
 free_out:
 	__mem_cgroup_free(memcg);
-	root_mem_cgroup = NULL;
 	return ERR_PTR(error);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
