Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id E58656B004F
	for <linux-mm@kvack.org>; Fri, 13 Jan 2012 03:31:31 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id EBEED3EE0BC
	for <linux-mm@kvack.org>; Fri, 13 Jan 2012 17:31:29 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id CF13545DE58
	for <linux-mm@kvack.org>; Fri, 13 Jan 2012 17:31:29 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id B504845DD6E
	for <linux-mm@kvack.org>; Fri, 13 Jan 2012 17:31:29 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id A69BEE08009
	for <linux-mm@kvack.org>; Fri, 13 Jan 2012 17:31:29 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 594AFE08005
	for <linux-mm@kvack.org>; Fri, 13 Jan 2012 17:31:29 +0900 (JST)
Date: Fri, 13 Jan 2012 17:30:01 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC] [PATCH 0/7 v2] memcg: page_cgroup diet
Message-Id: <20120113173001.ee5260ca.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Ying Han <yinghan@google.com>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, cgroups@vger.kernel.org, "bsingharora@gmail.com" <bsingharora@gmail.com>

This is just an RFC for dumping my queue to share and get better idea.
Patch order may not be clean. Advice is welcomed.

Now, struct page_cgroup is defined as
==
struct page_cgroup {
        unsigned long flags;
        struct mem_cgroup *mem_cgroup;
};
==

We want to remove ->flags to shrink the size (and integrate into 'struct page').
To do that, we need to remove some flags.

Now, flag is defined as
==
        PCG_LOCK,  /* Lock for pc->mem_cgroup and following bits. */
        PCG_CACHE, /* charged as cache */
        PCG_USED, /* this object is in use. */
        PCG_MIGRATION, /* under page migration */
        /* flags for mem_cgroup and file and I/O status */
        PCG_MOVE_LOCK, /* For race between move_account v.s. following bits */
        PCG_FILE_MAPPED, /* page is accounted as "mapped" */
==
We have 6bits now.

This patch series removes PCG_CACHE, PCG_MOVE_LOCK, PCG_FILE_MAPPED.
Then, if we use low 3bits of ->mem_cgroup for PCG_LOCK, PCG_USED, PCG_MIGRATION,
we can remove pc->flags, I guess.

To remove flags, this patch modifes page-stat accounting. After this set, 
per-memcg page stat accounting will be

	mem_cgroup_begin_update_page_stat() --(A)
	modify page status
	mem_cgroup_update_page_stat()
	mem_cgroup_end_update_page_stat()   --(B)

Between (A) and (B), it's guaranteed the page's pc->mem_cgroup will not be moved.
By this change, move_account() can make use of page's information rather than
page_cgroup's flag and we don't have to duplicate flags in page_cgroup.
I think this is saner and allow us to add more per-memcg vmstat without any
new flags.

I'm now testing but don't see additional overheads.

Thanks,
-Kame




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
