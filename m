Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id F1B2B6B003D
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 02:51:29 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2D6pRxj029639
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 13 Mar 2009 15:51:27 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id CD5AB2AEA81
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 15:51:26 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id AF4A41EF082
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 15:51:26 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id A33E61DB8048
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 15:51:26 +0900 (JST)
Received: from ml11.s.css.fujitsu.com (ml11.s.css.fujitsu.com [10.249.87.101])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 583061DB8041
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 15:51:26 +0900 (JST)
Message-ID: <d6757939628fe7646a00a0b3b69d277f.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <20090312175631.17890.30427.sendpatchset@localhost.localdomain>
References: <20090312175603.17890.52593.sendpatchset@localhost.localdomain>
    <20090312175631.17890.30427.sendpatchset@localhost.localdomain>
Date: Fri, 13 Mar 2009 15:51:25 +0900 (JST)
Subject: Re: [PATCH 4/4] Memory controller soft limit reclaim on contention
 (v5)
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-2022-jp
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Balbir Singh wrote:
> Feature: Implement reclaim from groups over their soft limit
>
> From: Balbir Singh <balbir@linux.vnet.ibm.com>

> +unsigned long mem_cgroup_soft_limit_reclaim(struct zonelist *zl, gfp_t
> gfp_mask)
> +{
> +	unsigned long nr_reclaimed = 0;
> +	struct mem_cgroup *mem;
> +	unsigned long flags;
> +	unsigned long reclaimed;
> +
> +	/*
> +	 * This loop can run a while, specially if mem_cgroup's continuously
> +	 * keep exceeding their soft limit and putting the system under
> +	 * pressure
> +	 */
> +	do {
> +		mem = mem_cgroup_largest_soft_limit_node();
> +		if (!mem)
> +			break;
> +
> +		reclaimed = mem_cgroup_hierarchical_reclaim(mem, zl,
> +						gfp_mask,
> +						MEM_CGROUP_RECLAIM_SOFT);
> +		nr_reclaimed += reclaimed;
> +		spin_lock_irqsave(&memcg_soft_limit_tree_lock, flags);
> +		mem->usage_in_excess = res_counter_soft_limit_excess(&mem->res);
> +		__mem_cgroup_remove_exceeded(mem);
> +		if (mem->usage_in_excess)
> +			__mem_cgroup_insert_exceeded(mem);
> +		spin_unlock_irqrestore(&memcg_soft_limit_tree_lock, flags);
> +		css_put(&mem->css);
> +		cond_resched();
> +	} while (!nr_reclaimed);
> +	return nr_reclaimed;
> +}
> +
 Why do you never consider bad corner case....
 As I wrote many times, "order of global usage" doesn't mean the
 biggest user of memcg containes memory in zones which we want.
 So, please don't pust "mem" back to RB-tree if reclaimed is 0.

 This routine seems toooo bad as v4.
 Nack again.

Regards,
-Kame




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
