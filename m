Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id DF391831F4
	for <linux-mm@kvack.org>; Thu, 18 May 2017 15:07:50 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id j83so31345821ioi.11
        for <linux-mm@kvack.org>; Thu, 18 May 2017 12:07:50 -0700 (PDT)
Received: from resqmta-ch2-08v.sys.comcast.net (resqmta-ch2-08v.sys.comcast.net. [2001:558:fe21:29:69:252:207:40])
        by mx.google.com with ESMTPS id u126si20127124itb.26.2017.05.18.12.07.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 May 2017 12:07:50 -0700 (PDT)
Date: Thu, 18 May 2017 14:07:45 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC 1/6] mm, page_alloc: fix more premature OOM due to race
 with cpuset update
In-Reply-To: <20170518172424.GB30148@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.20.1705181351120.29348@east.gentwo.org>
References: <fda99ddc-94f5-456e-6560-d4991da452a6@suse.cz> <alpine.DEB.2.20.1704301628460.21533@east.gentwo.org> <20170517092042.GH18247@dhcp22.suse.cz> <alpine.DEB.2.20.1705170855430.7925@east.gentwo.org> <20170517140501.GM18247@dhcp22.suse.cz>
 <alpine.DEB.2.20.1705170943090.8714@east.gentwo.org> <20170517145645.GO18247@dhcp22.suse.cz> <alpine.DEB.2.20.1705171021570.9487@east.gentwo.org> <20170518090846.GD25462@dhcp22.suse.cz> <alpine.DEB.2.20.1705181154450.27641@east.gentwo.org>
 <20170518172424.GB30148@dhcp22.suse.cz>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Li Zefan <lizefan@huawei.com>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-api@vger.kernel.org

On Thu, 18 May 2017, Michal Hocko wrote:

> > See above. OOM Kill in a cpuset does not kill an innocent task but a task
> > that does an allocation in that specific context meaning a task in that
> > cpuset that also has a memory policty.
>
> No, the oom killer will chose the largest task in the specific NUMA
> domain. If you just fail such an allocation then a page fault would get
> VM_FAULT_OOM and pagefault_out_of_memory would kill a task regardless of
> the cpusets.

Ok someone screwed up that code. There still is the determination that we
have a constrained alloc:

oom_kill:
	/*
         * Check if there were limitations on the allocation (only relevant for
         * NUMA and memcg) that may require different handling.
         */
        constraint = constrained_alloc(oc);
        if (constraint != CONSTRAINT_MEMORY_POLICY)
                oc->nodemask = NULL;
        check_panic_on_oom(oc, constraint);

-- Ok. A constrained failing alloc used to terminate the allocating
	process here. But it falls through to selecting a "bad process"


        if (!is_memcg_oom(oc) && sysctl_oom_kill_allocating_task &&
            current->mm && !oom_unkillable_task(current, NULL, oc->nodemask) &&
            current->signal->oom_score_adj != OOM_SCORE_ADJ_MIN) {
                get_task_struct(current);
                oc->chosen = current;
                oom_kill_process(oc, "Out of memory (oom_kill_allocating_task)");
                return true;
        }

--  A constrained allocation should not get here but fail the process that
	attempts the alloc.

        select_bad_process(oc);


Can we restore the old behavior? If I just specify the right memory policy
I can cause other processes to just be terminated?


> > Regardless of that the point earlier was that the moving logic can avoid
> > creating temporary situations of empty sets of nodes by analysing the
> > memory policies etc and only performing moves when doing so is safe.
>
> How are you going to do that in a raceless way? Moreover the whole
> discussion is about _failing_ allocations on an empty cpuset and
> mempolicy intersection.

Again this is only working for processes that are well behaved and it
never worked in a different way before. There was always the assumption
that a process does not allocate in the areas that have allocation
constraints and that the process does not change memory policies nor
store them somewhere for late etc etc. HPC apps typically allocate memory
on startup and then go through long times of processing and I/O.

The idea that cpuset node to node migration will work with a running
process that does abitrary activity is a pipe dream that we should give
up. There must be constraints on a process in order to allow this to work
and as far as I can tell this is best done in userspace with a library and
by putting requirements on the applications that desire to be movable that
way.

F.e. an application that does not use memory policies or other allocation
constraints should be fine. That has been working.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
