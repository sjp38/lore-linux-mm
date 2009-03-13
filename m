Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 110546B003D
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 04:41:07 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2D8f5fS021076
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 13 Mar 2009 17:41:05 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id BBE6345DE62
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 17:41:04 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7EB7845DE55
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 17:41:04 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3927CE38004
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 17:41:04 +0900 (JST)
Received: from ml11.s.css.fujitsu.com (ml11.s.css.fujitsu.com [10.249.87.101])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id C857CE18005
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 17:41:03 +0900 (JST)
Message-ID: <b025ddee3cbbdaadeddd2d32220e5389.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <20090313071501.GK16897@balbir.in.ibm.com>
References: <20090312175603.17890.52593.sendpatchset@localhost.localdomain>
    <20090312175631.17890.30427.sendpatchset@localhost.localdomain>
    <d6757939628fe7646a00a0b3b69d277f.squirrel@webmail-b.css.fujitsu.com>
    <20090313071501.GK16897@balbir.in.ibm.com>
Date: Fri, 13 Mar 2009 17:41:03 +0900 (JST)
Subject: Re: [PATCH 4/4] Memory controller soft limit reclaim on contention
 (v5)
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-2022-jp
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Balbir Singh wrote:
> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-13
> 15:51:25]:
>
>> Balbir Singh wrote:
>> > Feature: Implement reclaim from groups over their soft limit
>> >
>> > From: Balbir Singh <balbir@linux.vnet.ibm.com>
>>
>> > +unsigned long mem_cgroup_soft_limit_reclaim(struct zonelist *zl,
>> gfp_t
>> > gfp_mask)
>> > +{
>> > +	unsigned long nr_reclaimed = 0;
>> > +	struct mem_cgroup *mem;
>> > +	unsigned long flags;
>> > +	unsigned long reclaimed;
>> > +
>> > +	/*
>> > +	 * This loop can run a while, specially if mem_cgroup's continuously
>> > +	 * keep exceeding their soft limit and putting the system under
>> > +	 * pressure
>> > +	 */
>> > +	do {
>> > +		mem = mem_cgroup_largest_soft_limit_node();
>> > +		if (!mem)
>> > +			break;
>> > +
>> > +		reclaimed = mem_cgroup_hierarchical_reclaim(mem, zl,
>> > +						gfp_mask,
>> > +						MEM_CGROUP_RECLAIM_SOFT);
>> > +		nr_reclaimed += reclaimed;
>> > +		spin_lock_irqsave(&memcg_soft_limit_tree_lock, flags);
>> > +		mem->usage_in_excess = res_counter_soft_limit_excess(&mem->res);
>> > +		__mem_cgroup_remove_exceeded(mem);
>> > +		if (mem->usage_in_excess)
>> > +			__mem_cgroup_insert_exceeded(mem);
>> > +		spin_unlock_irqrestore(&memcg_soft_limit_tree_lock, flags);
>> > +		css_put(&mem->css);
>> > +		cond_resched();
>> > +	} while (!nr_reclaimed);
>> > +	return nr_reclaimed;
>> > +}
>> > +
>>  Why do you never consider bad corner case....
>>  As I wrote many times, "order of global usage" doesn't mean the
>>  biggest user of memcg containes memory in zones which we want.
>>  So, please don't pust "mem" back to RB-tree if reclaimed is 0.
>>
>>  This routine seems toooo bad as v4.
>
> Are you talking about cases where a particular mem cgroup never
> allocated from a node? Thanks.. let me take a look at it
>
Using cpuset to test and limiting nodes for memory is an easy way,

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
