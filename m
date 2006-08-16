Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k7GE1QkX008989
	for <linux-mm@kvack.org>; Wed, 16 Aug 2006 10:01:26 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k7GE1NJJ290804
	for <linux-mm@kvack.org>; Wed, 16 Aug 2006 10:01:23 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k7GE1N84026699
	for <linux-mm@kvack.org>; Wed, 16 Aug 2006 10:01:23 -0400
Message-ID: <44E32517.7040704@in.ibm.com>
Date: Wed, 16 Aug 2006 19:30:55 +0530
From: Balbir Singh <balbir@in.ibm.com>
Reply-To: balbir@in.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] "challenged" memory controller
References: <20060815192047.EE4A0960@localhost.localdomain>
In-Reply-To: <20060815192047.EE4A0960@localhost.localdomain>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: dave@sr71.net
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

dave@sr71.net wrote:
> I've been toying with a little memory controller for the past
> few weeks, on and off.  My goal was to create something simple
> and hackish that would at least be a toy to play with in the
> process of creating something that might actually be feasible.
> 
> I call it "challenged" because it has some definite limitations.
> However, it only adds about 50 lines of code to generic areas
> of the VM, and I haven't been the slightest bit careful, yet.
> I think it probably also breaks CONFIG_PM and !CONFIG_CPUSETS,
> but those are "features". ;)
> 
> It uses cpusets for now, just because they are there, and are
> relatively easy to modify.  The page->cpuset bit is only
> temporary, and I have some plans to remove it later.
> 
> How does it work?  It adds two fields to the scan control
> structure.  One that tells the scan to only pay attention to
> _any_ cpuset over its memory limits, and the other to tell it
> to only scan pages for a _particular_ cpuset.
> 
> I've been pretty indiscriminately hacking away, so I have the
> feeling that there are some more efficient and nicer ways to
> hook into the page scanning logic.  Comments are very welcome.
> 
> Signed-off-by: Dave Hansen <haveblue@us.ibm.com>

<snip>

> +int shrink_cpuset(struct cpuset *cs, gfp_t gfpmask, int tries)
> +{
> +	int nr_shrunk = 0;
> +	while (cpuset_amount_over_memory_max(cs)) {
> +		if (tries-- < 0)
> +			break;
> +		nr_shrunk += shrink_all_memory(10, cs);

shrink_all_memory() is also called from kernel/power/main.c (from 
suspend_prepare()) and we have no cpuset context available from there. We could 
try passing a NULL cpuset maybe?



> +	}
> +	return 0;
> +}
> +
> +int cpuset_inc_nr_pages(struct cpuset *cs, int nr, gfp_t gfpmask)
> +{
> +	int ret;
> +	if (!cs)
> +		return 0;
> +	cs->mems_nr_pages += nr;
> +	if (cpuset_amount_over_memory_max(cs)) {
> +		if (!(gfpmask & __GFP_WAIT))
> +			return -ENOMEM;
> +		ret = shrink_cpuset(cs, gfpmask, 50);
> +	}

We could use __GFP_REPEAT, __GFP_NOFAIL, __GFP_NORETRY to determine the retry 
policy.



> +	if (cpuset_amount_over_memory_max(cs))
> +		return -ENOMEM;
> +	return 0;
> +}

<snip>

-- 

	Balbir Singh,
	Linux Technology Center,
	IBM Software Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
