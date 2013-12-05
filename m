Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f174.google.com (mail-qc0-f174.google.com [209.85.216.174])
	by kanga.kvack.org (Postfix) with ESMTP id 34D016B0035
	for <linux-mm@kvack.org>; Thu,  5 Dec 2013 18:50:04 -0500 (EST)
Received: by mail-qc0-f174.google.com with SMTP id n7so4154926qcx.5
        for <linux-mm@kvack.org>; Thu, 05 Dec 2013 15:50:04 -0800 (PST)
Received: from mail-yh0-x231.google.com (mail-yh0-x231.google.com [2607:f8b0:4002:c01::231])
        by mx.google.com with ESMTPS id s9si45692205qak.129.2013.12.05.15.50.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 05 Dec 2013 15:50:02 -0800 (PST)
Received: by mail-yh0-f49.google.com with SMTP id z20so13111498yhz.8
        for <linux-mm@kvack.org>; Thu, 05 Dec 2013 15:50:01 -0800 (PST)
Date: Thu, 5 Dec 2013 15:49:57 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 7/8] mm, memcg: allow processes handling oom notifications
 to access reserves
In-Reply-To: <20131205025026.GA26777@htj.dyndns.org>
Message-ID: <alpine.DEB.2.02.1312051537550.7717@chino.kir.corp.google.com>
References: <20131119134007.GD20655@dhcp22.suse.cz> <alpine.DEB.2.02.1311192352070.20752@chino.kir.corp.google.com> <20131120152251.GA18809@dhcp22.suse.cz> <alpine.DEB.2.02.1311201917520.7167@chino.kir.corp.google.com> <20131128115458.GK2761@dhcp22.suse.cz>
 <alpine.DEB.2.02.1312021504170.13465@chino.kir.corp.google.com> <alpine.DEB.2.02.1312032116440.29733@chino.kir.corp.google.com> <alpine.DEB.2.02.1312032118570.29733@chino.kir.corp.google.com> <20131204054533.GZ3556@cmpxchg.org>
 <alpine.DEB.2.02.1312041742560.20115@chino.kir.corp.google.com> <20131205025026.GA26777@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, Li Zefan <lizefan@huawei.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On Wed, 4 Dec 2013, Tejun Heo wrote:

> Hello,
> 

Tejun, how are you?

> Umm.. without delving into details, aren't you basically creating a
> memory cgroup inside a memory cgroup?  Doesn't sound like a
> particularly well thought-out plan to me.
> 

I agree that we wouldn't need such support if we are only addressing memcg 
oom conditions.  We could do things like A/memory.limit_in_bytes == 128M 
and A/b/memory.limit_in_bytes == 126MB and then attach the process waiting 
on A/b/memory.oom_control to A and that would work perfect.

However, we also need to discuss system oom handling.  We have an interest 
in being able to allow userspace to handle system oom conditions since the 
policy will differ depending on machine and we can't encode every possible 
mechanism into the kernel.  For example, on system oom we want to kill a 
process from the lowest priority top-level memcg.  We lack that ability 
entirely in the kernel and since the sum of our top-level memcgs 
memory.limit_in_bytes exceeds the amount of present RAM, we run into these 
oom conditions a _lot_.

So the first step, in my opinion, is to add a system oom notification on 
the root memcg's memory.oom_control which currently allows registering an 
eventfd() notification but never actually triggers.  I did that in a patch 
and it is was merged into -mm but was pulled out for later discussion.

Then, we need to ensure that the userspace that is registered to handle 
such events and that is difficult to do when the system is oom.  The 
proposal is to allow such processes, now marked as PF_OOM_HANDLER, to be 
able to access pre-defined per-zone memory reserves in the page allocator.  
The only special handling for PF_OOM_HANDLER in the page allocator itself 
would be under such oom conditions (memcg oom conditions have no problem 
allocating the memory, only charging it).  The amount of reserves would be 
defined as memory.oom_reserve_in_bytes from within the root memcg as 
defined by this patch, i.e. allow this amount of memory to be allocated in 
the page allocator for PF_OOM_HANDLER below the per-zone min watermarks.

This, I believe, is the cleanest interface for users who choose to use a 
non-default policy by setting memory.oom_reserve_in_bytes and constrains 
all of the code to memcg which you have to configure for such support.

The system oom condition is not addressed in this patch series, although 
the PF_OOM_HANDLER bit can be used for that purpose.  I didn't post that 
patch because the notification on the root memcg's memory.oom_control in 
such conditions is currently being debated, so we need to solve that issue 
first.

Your opinions and suggestions are more than helpful, thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
