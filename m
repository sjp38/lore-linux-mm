Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp02.au.ibm.com (8.13.1/8.13.1) with ESMTP id mAB4lRkW026324
	for <linux-mm@kvack.org>; Tue, 11 Nov 2008 15:47:27 +1100
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mAB4mDFS261746
	for <linux-mm@kvack.org>; Tue, 11 Nov 2008 15:48:13 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mAB4mCGU011706
	for <linux-mm@kvack.org>; Tue, 11 Nov 2008 15:48:13 +1100
Message-ID: <49190E5F.2050109@linux.vnet.ibm.com>
Date: Tue, 11 Nov 2008 10:17:27 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][mm] [PATCH 3/4] Memory cgroup hierarchical reclaim (v2)
References: <20081108091009.32236.26177.sendpatchset@localhost.localdomain> <20081108091100.32236.89666.sendpatchset@localhost.localdomain> <20081111120607.5ffe8a9c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081111120607.5ffe8a9c.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, Nick Piggin <nickpiggin@yahoo.com.au>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Sat, 08 Nov 2008 14:41:00 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
>> This patch introduces hierarchical reclaim. When an ancestor goes over its
>> limit, the charging routine points to the parent that is above its limit.
>> The reclaim process then starts from the last scanned child of the ancestor
>> and reclaims until the ancestor goes below its limit.
>>
>> Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
>> ---
>>
>>  mm/memcontrol.c |  152 +++++++++++++++++++++++++++++++++++++++++++++++---------
>>  1 file changed, 128 insertions(+), 24 deletions(-)
>>
>> diff -puN mm/memcontrol.c~memcg-hierarchical-reclaim mm/memcontrol.c
>> --- linux-2.6.28-rc2/mm/memcontrol.c~memcg-hierarchical-reclaim	2008-11-08 14:09:32.000000000 +0530
>> +++ linux-2.6.28-rc2-balbir/mm/memcontrol.c	2008-11-08 14:09:32.000000000 +0530
>> @@ -132,6 +132,11 @@ struct mem_cgroup {
>>  	 * statistics.
>>  	 */
>>  	struct mem_cgroup_stat stat;
>> +	/*
>> +	 * While reclaiming in a hiearchy, we cache the last child we
>> +	 * reclaimed from.
>> +	 */
>> +	struct mem_cgroup *last_scanned_child;
>>  };
>>  static struct mem_cgroup init_mem_cgroup;
>>  
>> @@ -467,6 +472,124 @@ unsigned long mem_cgroup_isolate_pages(u
>>  	return nr_taken;
>>  }
>>  
>> +static struct mem_cgroup *
>> +mem_cgroup_from_res_counter(struct res_counter *counter)
>> +{
>> +	return container_of(counter, struct mem_cgroup, res);
>> +}
>> +
>> +/*
>> + * Dance down the hierarchy if needed to reclaim memory. We remember the
>> + * last child we reclaimed from, so that we don't end up penalizing
>> + * one child extensively based on its position in the children list.
>> + *
>> + * root_mem is the original ancestor that we've been reclaim from.
>> + */
>> +static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *mem,
>> +						struct mem_cgroup *root_mem,
>> +						gfp_t gfp_mask)
>> +{
>> +	struct cgroup *cg_current, *cgroup;
>> +	struct mem_cgroup *mem_child;
>> +	int ret = 0;
>> +
>> +	/*
>> +	 * Reclaim unconditionally and don't check for return value.
>> +	 * We need to reclaim in the current group and down the tree.
>> +	 * One might think about checking for children before reclaiming,
>> +	 * but there might be left over accounting, even after children
>> +	 * have left.
>> +	 */
>> +	try_to_free_mem_cgroup_pages(mem, gfp_mask);
>> +
>> +	if (res_counter_check_under_limit(&root_mem->res))
>> +		return 0;
>> +
>> +	if (list_empty(&mem->css.cgroup->children))
>> +		return 0;
>> +
>> +	/*
>> +	 * Scan all children under the mem_cgroup mem
>> +	 */
>> +	if (!mem->last_scanned_child)
>> +		cgroup = list_first_entry(&mem->css.cgroup->children,
>> +				struct cgroup, sibling);
>> +	else
>> +		cgroup = mem->last_scanned_child->css.cgroup;
>> +
> 
> Who guarantee this last_scan_child is accessible at this point ?
> 

Good catch! I'll fix this in mem_cgroup_destroy. It'll need some locking around
it as well.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
