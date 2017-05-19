Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9B37C831F4
	for <linux-mm@kvack.org>; Fri, 19 May 2017 03:37:53 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id d127so13351299wmf.15
        for <linux-mm@kvack.org>; Fri, 19 May 2017 00:37:53 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n41si8855905edn.180.2017.05.19.00.37.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 19 May 2017 00:37:52 -0700 (PDT)
Date: Fri, 19 May 2017 09:37:48 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC 1/6] mm, page_alloc: fix more premature OOM due to race
 with cpuset update
Message-ID: <20170519073748.GB13041@dhcp22.suse.cz>
References: <20170517092042.GH18247@dhcp22.suse.cz>
 <alpine.DEB.2.20.1705170855430.7925@east.gentwo.org>
 <20170517140501.GM18247@dhcp22.suse.cz>
 <alpine.DEB.2.20.1705170943090.8714@east.gentwo.org>
 <20170517145645.GO18247@dhcp22.suse.cz>
 <alpine.DEB.2.20.1705171021570.9487@east.gentwo.org>
 <20170518090846.GD25462@dhcp22.suse.cz>
 <alpine.DEB.2.20.1705181154450.27641@east.gentwo.org>
 <20170518172424.GB30148@dhcp22.suse.cz>
 <alpine.DEB.2.20.1705181351120.29348@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1705181351120.29348@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Li Zefan <lizefan@huawei.com>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-api@vger.kernel.org

On Thu 18-05-17 14:07:45, Cristopher Lameter wrote:
> On Thu, 18 May 2017, Michal Hocko wrote:
> 
> > > See above. OOM Kill in a cpuset does not kill an innocent task but a task
> > > that does an allocation in that specific context meaning a task in that
> > > cpuset that also has a memory policty.
> >
> > No, the oom killer will chose the largest task in the specific NUMA
> > domain. If you just fail such an allocation then a page fault would get
> > VM_FAULT_OOM and pagefault_out_of_memory would kill a task regardless of
> > the cpusets.
> 
> Ok someone screwed up that code. There still is the determination that we
> have a constrained alloc:

It would be much more easier if you read emails more carefully. In order
to have a constrained OOM you have to have either a non-null nodemask or
zonelist which. And as I've said above you do not have them from the
pagefault_out_of_memory context. The whole point of this discussion is
_that_ failing allocations will not work currently!

> oom_kill:
> 	/*
>          * Check if there were limitations on the allocation (only relevant for
>          * NUMA and memcg) that may require different handling.
>          */
>         constraint = constrained_alloc(oc);
>         if (constraint != CONSTRAINT_MEMORY_POLICY)
>                 oc->nodemask = NULL;
>         check_panic_on_oom(oc, constraint);
> 
> -- Ok. A constrained failing alloc used to terminate the allocating
> 	process here. But it falls through to selecting a "bad process"

This behavior is there for ~10 years.
[...]
> Can we restore the old behavior? If I just specify the right memory policy
> I can cause other processes to just be terminated?

Not normally. Because out_of_memory called from the page allocator
context makes sure to kill tasks from the same NUMA domain (see
oom_unkillable_task).
 
> > > Regardless of that the point earlier was that the moving logic can avoid
> > > creating temporary situations of empty sets of nodes by analysing the
> > > memory policies etc and only performing moves when doing so is safe.
> >
> > How are you going to do that in a raceless way? Moreover the whole
> > discussion is about _failing_ allocations on an empty cpuset and
> > mempolicy intersection.
> 
> Again this is only working for processes that are well behaved and it
> never worked in a different way before. There was always the assumption
> that a process does not allocate in the areas that have allocation
> constraints and that the process does not change memory policies nor
> store them somewhere for late etc etc. HPC apps typically allocate memory
> on startup and then go through long times of processing and I/O.

I would call it a bad design which then triggered a lot of work to make
it semi-working over years. This is what Vlastimil tries to address now.
And yes that might mean we would have to do some restrictions on the
semantics. But as you know this is a user visible API and changing
something that has been fundamentally underdefined initially is quite
hard to fix.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
