Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 72C416B02B4
	for <linux-mm@kvack.org>; Fri,  9 Jun 2017 10:09:06 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id v102so8592070wrc.8
        for <linux-mm@kvack.org>; Fri, 09 Jun 2017 07:09:06 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id m26si1405244edj.60.2017.06.09.07.09.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 09 Jun 2017 07:09:05 -0700 (PDT)
Date: Fri, 9 Jun 2017 10:08:53 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC PATCH 2/2] mm, oom: do not trigger out_of_memory from the
 #PF
Message-ID: <20170609140853.GA14760@cmpxchg.org>
References: <20170519112604.29090-1-mhocko@kernel.org>
 <20170519112604.29090-3-mhocko@kernel.org>
 <20170608143606.GK19866@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170608143606.GK19866@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Vladimir Davydov <vdavydov.dev@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu, Jun 08, 2017 at 04:36:07PM +0200, Michal Hocko wrote:
> Does anybody see any problem with the patch or I can send it for the
> inclusion?
> 
> On Fri 19-05-17 13:26:04, Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > Any allocation failure during the #PF path will return with VM_FAULT_OOM
> > which in turn results in pagefault_out_of_memory. This can happen for
> > 2 different reasons. a) Memcg is out of memory and we rely on
> > mem_cgroup_oom_synchronize to perform the memcg OOM handling or b)
> > normal allocation fails.
> > 
> > The later is quite problematic because allocation paths already trigger
> > out_of_memory and the page allocator tries really hard to not fail
> > allocations. Anyway, if the OOM killer has been already invoked there
> > is no reason to invoke it again from the #PF path. Especially when the
> > OOM condition might be gone by that time and we have no way to find out
> > other than allocate.
> > 
> > Moreover if the allocation failed and the OOM killer hasn't been
> > invoked then we are unlikely to do the right thing from the #PF context
> > because we have already lost the allocation context and restictions and
> > therefore might oom kill a task from a different NUMA domain.
> > 
> > An allocation might fail also when the current task is the oom victim
> > and there are no memory reserves left and we should simply bail out
> > from the #PF rather than invoking out_of_memory.
> > 
> > This all suggests that there is no legitimate reason to trigger
> > out_of_memory from pagefault_out_of_memory so drop it. Just to be sure
> > that no #PF path returns with VM_FAULT_OOM without allocation print a
> > warning that this is happening before we restart the #PF.
> > 
> > Signed-off-by: Michal Hocko <mhocko@suse.com>

I don't agree with this patch.

The warning you replace the oom call with indicates that we never
expect a VM_FAULT_OOM to leak to this point. But should there be a
leak, it's infinitely better to tickle the OOM killer again - even if
that call is then fairly inaccurate and without alloc context - than
infinite re-invocations of the #PF when the VM_FAULT_OOM comes from a
context - existing or future - that isn't allowed to trigger the OOM.

I'm not a fan of defensive programming, but is this call to OOM more
expensive than the printk() somehow? And how certain are you that no
VM_FAULT_OOMs will leak, given how spread out page fault handlers and
how complex the different allocation contexts inside them are?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
