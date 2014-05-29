Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f48.google.com (mail-pb0-f48.google.com [209.85.160.48])
	by kanga.kvack.org (Postfix) with ESMTP id 8FECB6B0035
	for <linux-mm@kvack.org>; Thu, 29 May 2014 19:12:56 -0400 (EDT)
Received: by mail-pb0-f48.google.com with SMTP id rr13so1016046pbb.21
        for <linux-mm@kvack.org>; Thu, 29 May 2014 16:12:56 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id ah1si2880167pbc.97.2014.05.29.16.12.55
        for <linux-mm@kvack.org>;
        Thu, 29 May 2014 16:12:55 -0700 (PDT)
Date: Thu, 29 May 2014 16:12:53 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] page_alloc: skip cpuset enforcement for lower zone
 allocations (v4)
Message-Id: <20140529161253.73ff978f723972f503123fe8@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.02.1405291555120.9336@chino.kir.corp.google.com>
References: <20140523193706.GA22854@amt.cnet>
	<20140526185344.GA19976@amt.cnet>
	<53858A06.8080507@huawei.com>
	<20140528224324.GA1132@amt.cnet>
	<20140529184303.GA20571@amt.cnet>
	<alpine.DEB.2.02.1405291555120.9336@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Li Zefan <lizefan@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Lai Jiangshan <laijs@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>

On Thu, 29 May 2014 16:01:55 -0700 (PDT) David Rientjes <rientjes@google.com> wrote:

> There are still three issues with this, two of which are only minor and 
> one that needs more thought:
> 
>  (1) this doesn't affect only cpusets which the changelog indicates, it 
>      also bypasses mempolicies for GFP_DMA and GFP_DMA32 allocations since
>      the nodemask != NULL in the page allocator when there is an effective
>      mempolicy.  That may be precisely what you're trying to do (do the
>      same for mempolicies as you're doing for cpusets), but the comment 
>      now in the code specifically refers to cpusets.  Can you make a case
>      for the mempolicies exception as well?  Otherwise, we'll need to do
> 
> 	if (!nodemask && gfp_zone(gfp_mask) < policy_zone)
> 		nodemask = &node_states[N_ONLINE];
> 
> And the two minors:
> 
>  (2) this should be &node_states[N_MEMORY], not &node_states[N_ONLINE] 
>      since memoryless nodes should not be included.  Note that
>      guarantee_online_mems() looks at N_MEMORY and
>      cpuset_current_mems_allowed is defined for N_MEMORY without
>      cpusets.
> 
>  (3) it's unnecessary for this to be after the "retry_cpuset" label and
>      check the gfp mask again if we need to relook at the allowed cpuset
>      mask.

OK, thanks, I made the patch go away for now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
