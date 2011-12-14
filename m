Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id C763A6B02C2
	for <linux-mm@kvack.org>; Wed, 14 Dec 2011 02:48:50 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id D8B9C3EE0BC
	for <linux-mm@kvack.org>; Wed, 14 Dec 2011 16:48:48 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id B7C0545DEB7
	for <linux-mm@kvack.org>; Wed, 14 Dec 2011 16:48:48 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9A9CF45DE9E
	for <linux-mm@kvack.org>; Wed, 14 Dec 2011 16:48:48 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7AFE61DB803B
	for <linux-mm@kvack.org>; Wed, 14 Dec 2011 16:48:48 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 33758E08002
	for <linux-mm@kvack.org>; Wed, 14 Dec 2011 16:48:48 +0900 (JST)
Date: Wed, 14 Dec 2011 16:47:34 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 0/4] memcg: simplify LRU handling.
Message-Id: <20111214164734.4d7d6d97.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>


This series is onto linux-next + 
memcg-add-mem_cgroup_replace_page_cache-to-fix-lru-issue.patch

The 1st purpose of this patch is reduce overheads of mem_cgroup_add/del_lru.
They uses some atomic ops. After this patch, lru handling routine will be

==
struct lruvec *mem_cgroup_lru_add_list(struct zone *zone, struct page *page,
                                       enum lru_list lru)
{
        struct mem_cgroup_per_zone *mz;
        struct mem_cgroup *memcg;
        struct page_cgroup *pc;

        if (mem_cgroup_disabled())
                return &zone->lruvec;

        pc = lookup_page_cgroup(page);
        memcg = pc->mem_cgroup;
        VM_BUG_ON(!memcg);
        mz = page_cgroup_zoneinfo(memcg, page);
        /* compound_order() is stabilized through lru_lock */
        MEM_CGROUP_ZSTAT(mz, lru) += 1 << compound_order(page);
        return &mz->lruvec;
}
==

simple and no atomic ops. Because of Johannes works in linux-next,
this can be archived by very straightforward way.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
