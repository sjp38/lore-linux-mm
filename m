Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 661885F0048
	for <linux-mm@kvack.org>; Wed, 20 Oct 2010 00:08:33 -0400 (EDT)
From: Greg Thelen <gthelen@google.com>
Subject: Re: [PATCH v3 07/11] memcg: add dirty limits to mem_cgroup
References: <1287448784-25684-1-git-send-email-gthelen@google.com>
	<1287448784-25684-8-git-send-email-gthelen@google.com>
	<20101020095056.48098b34.nishimura@mxp.nes.nec.co.jp>
Date: Tue, 19 Oct 2010 21:08:20 -0700
Message-ID: <xr93iq0x1p6z.fsf@ninji.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> writes:

>> +static unsigned long long
>> +memcg_hierarchical_free_pages(struct mem_cgroup *mem)
>> +{
>> +	struct cgroup *cgroup;
>> +	unsigned long long min_free, free;
>> +
>> +	min_free = res_counter_read_u64(&mem->res, RES_LIMIT) -
>> +		res_counter_read_u64(&mem->res, RES_USAGE);
>> +	cgroup = mem->css.cgroup;
>> +	if (!mem->use_hierarchy)
>> +		goto out;
>> +
>> +	while (cgroup->parent) {
>> +		cgroup = cgroup->parent;
>> +		mem = mem_cgroup_from_cont(cgroup);
>> +		if (!mem->use_hierarchy)
>> +			break;
>> +		free = res_counter_read_u64(&mem->res, RES_LIMIT) -
>> +			res_counter_read_u64(&mem->res, RES_USAGE);
>> +		min_free = min(min_free, free);
>> +	}
>> +out:
>> +	/* Translate free memory in pages */
>> +	return min_free >> PAGE_SHIFT;
>> +}
>> +
> I think you can simplify this function using parent_mem_cgroup().
>
> 	unsigned long free, min_free = ULLONG_MAX;
>
> 	while (mem) {
> 		free = res_counter_read_u64(&mem->res, RES_LIMIT) -
> 			res_counter_read_u64(&mem->res, RES_USAGE);
> 		min_free = min(min_free, free);
> 		mem = parent_mem_cgroup();
> 	}
>
> 	/* Translate free memory in pages */
> 	return min_free >> PAGE_SHIFT;
>
> And, IMHO, we should return min(global_page_state(NR_FREE_PAGES), min_free >> PAGE_SHIFT).
> Because we are allowed to set no-limit(or a very big limit) in memcg,
> so min_free can be very big if we don't set a limit against all the memcg's in hierarchy.
>
>
> Thanks,
> Dasiuke Nishimura.

Thank you.  This is a good suggestion.  I will update the page to include this.

--
Greg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
