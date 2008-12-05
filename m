Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mB58RZQS007536
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 5 Dec 2008 17:27:35 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id E80E245DE55
	for <linux-mm@kvack.org>; Fri,  5 Dec 2008 17:27:34 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 784FC45DE61
	for <linux-mm@kvack.org>; Fri,  5 Dec 2008 17:27:34 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 51C001DB8051
	for <linux-mm@kvack.org>; Fri,  5 Dec 2008 17:27:34 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9B4871DB8049
	for <linux-mm@kvack.org>; Fri,  5 Dec 2008 17:27:33 +0900 (JST)
Date: Fri, 5 Dec 2008 17:26:42 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 0/4] cgroup ID and css refcnt change and memcg
 hierarchy (2008/12/05)
Message-Id: <20081205172642.565661b1.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "menage@google.com" <menage@google.com>
List-ID: <linux-mm.kvack.org>

This is a patch set onto mmotm-2.6.28-Dec30.

Still RFC. I'm considering whether I can make this simpler....

Major changes from previous one
	- css->refcnt is unified.
	  I think distributed refcnt is a crazy idea...
	- applied comments to previous version.
	- OOM Kill handler is fixed. (this was broken by hierarchy) 

I may not be able to reply quickly in weekend, sorry.

After this, memcg's hierarchical reclaim will be
==
static struct mem_cgroup *
mem_cgroup_select_victim(struct mem_cgroup *root_mem)
{
        struct cgroup *cgroup, *root_cgroup;
        struct mem_cgroup *ret;
        int nextid, rootid, depth, found;

        root_cgroup = root_mem->css.cgroup;
        rootid = cgroup_id(root_cgroup);
        depth = cgroup_depth(root_cgroup);
        found = 0;

        rcu_read_lock();
        if (!root_mem->use_hierarchy) {
                spin_lock(&root_mem->reclaim_param_lock);
                root_mem->scan_age++;
                spin_unlock(&root_mem->reclaim_param_lock);
                css_get(&root_mem->css);
                ret = root_mem;
        }

        while (!ret) {
                /* ID:0 is not used by cgroup-id */
                nextid = root_mem->last_scanned_child + 1;
                cgroup = cgroup_get_next(nextid, rootid, depth, &found);
                if (cgroup) {
                        spin_lock(&root_mem->reclaim_param_lock);
                        root_mem->last_scanned_child = found;
                        spin_unlock(&root_mem->reclaim_param_lock);
                        ret = mem_cgroup_from_cont(cgroup);
                        if (!css_tryget(&ret->css))
                                ret = NULL;
                } else {
                        spin_lock(&root_mem->reclaim_param_lock);
                        root_mem->scan_age++;
                        root_mem->last_scanned_child = 0;
                        spin_unlock(&root_mem->reclaim_param_lock);
                }
        }
        rcu_read_unlock();
        return ret;
}

/*
 * root_mem is the original ancestor that we've been reclaim from.
 * root_mem cannot be freed while walking because there are children.
 */
static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
                                                gfp_t gfp_mask, bool noswap)
{
        struct mem_cgroup *victim;
        unsigned long start_age;
        int ret = 0;
        int total = 0;

        start_age = root_mem->scan_age;
        /* allows visit twice (under this memcg, ->scan_age is shared.) */
        while (time_after((start_age + 2UL), root_mem->scan_age)) {
                victim = mem_cgroup_select_victim(root_mem);
                ret = try_to_free_mem_cgroup_pages(victim,
                                gfp_mask, noswap, get_swappiness(victim));
                css_put(&victim->css);
                if (mem_cgroup_check_under_limit(root_mem))
                        return 1;
                total += ret;
        }

        ret = total;
        if (mem_cgroup_check_under_limit(root_mem))
                ret = 1;

        return ret;
}
==
This can be reused for soft-limit or something fancy featrues.


Regards,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
