Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 05E176B0033
	for <linux-mm@kvack.org>; Wed,  1 Feb 2017 04:18:52 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id yr2so76457689wjc.4
        for <linux-mm@kvack.org>; Wed, 01 Feb 2017 01:18:51 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q4si24065974wrc.328.2017.02.01.01.18.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 01 Feb 2017 01:18:49 -0800 (PST)
Date: Wed, 1 Feb 2017 09:18:44 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC] cpuset: Enable changing of top_cpuset's mems_allowed
 nodemask
Message-ID: <20170201091844.6hhbzqg465qg7uql@suse.de>
References: <20170130203003.dm2ydoi3e6cbbwcj@suse.de>
 <20170131142237.27097-1-khandual@linux.vnet.ibm.com>
 <20170131160029.ubt6fvw6oh2fgxpd@suse.de>
 <c6864b3c-1b7f-ded9-eea4-538262631813@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <c6864b3c-1b7f-ded9-eea4-538262631813@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, vbabka@suse.cz, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dave.hansen@intel.com, dan.j.williams@intel.com

On Wed, Feb 01, 2017 at 01:01:24PM +0530, Anshuman Khandual wrote:
> On 01/31/2017 09:30 PM, Mel Gorman wrote:
> > On Tue, Jan 31, 2017 at 07:52:37PM +0530, Anshuman Khandual wrote:
> >> At present, top_cpuset.mems_allowed is same as node_states[N_MEMORY] and it
> >> cannot be changed at the runtime. Maximum possible node_states[N_MEMORY]
> >> also gets reflected in top_cpuset.effective_mems interface. It prevents some
> >> one from removing or restricting memory placement which will be applicable
> >> system wide on a given memory node through cpuset mechanism which might be
> >> limiting. This solves the problem by enabling update_nodemask() function to
> >> accept changes to top_cpuset.mems_allowed as well. Once changed, it also
> >> updates the value of top_cpuset.effective_mems. Updates all it's task's
> >> mems_allowed nodemask as well. It calls cpuset_inc() to make sure cpuset
> >> is accounted for in the buddy allocator through cpusets_enabled() check.
> >>
> > 
> > What's the point of allowing the root cpuset to be restricted?
> 
> After an extended period of run time on a system, currently if we have
> to run HW diagnostics and dump (which are run out of band) for debug
> purpose, we have to stop further allocations to the node. Hot plugging
> the memory node out of the kernel will achieve this. But it can also
> be made possible by just enabling top_cpuset.memory_migrate and then
> restricting all the allocations by removing the node from top_cpuset.
> mems_allowed nodemask. This will force all the existing allocations
> out of the target node.
> 

So would creating a restricted cpuset and migrating all tasks from the
root cpuset into it.

> More importantly it also extends the cpuset memory restriction feature
> to the logical completion without adding any regressions for the
> existing use cases. Then why not do this ? Does it add any overhead ?
> 

It violates the expectation that the root cgroup can access all
resources. Once enabled, there is some overhead in the page allocator as
it must check all cpusets even for tasks that weren't configured to be
isolated.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
