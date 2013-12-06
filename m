Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f44.google.com (mail-bk0-f44.google.com [209.85.214.44])
	by kanga.kvack.org (Postfix) with ESMTP id 71A436B007B
	for <linux-mm@kvack.org>; Fri,  6 Dec 2013 12:35:10 -0500 (EST)
Received: by mail-bk0-f44.google.com with SMTP id d7so411094bkh.17
        for <linux-mm@kvack.org>; Fri, 06 Dec 2013 09:35:09 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id np3si26905141bkb.269.2013.12.06.09.35.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 06 Dec 2013 09:35:09 -0800 (PST)
Date: Fri, 6 Dec 2013 12:34:38 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 7/8] mm, memcg: allow processes handling oom
 notifications to access reserves
Message-ID: <20131206173438.GE21724@cmpxchg.org>
References: <20131120152251.GA18809@dhcp22.suse.cz>
 <alpine.DEB.2.02.1311201917520.7167@chino.kir.corp.google.com>
 <20131128115458.GK2761@dhcp22.suse.cz>
 <alpine.DEB.2.02.1312021504170.13465@chino.kir.corp.google.com>
 <alpine.DEB.2.02.1312032116440.29733@chino.kir.corp.google.com>
 <alpine.DEB.2.02.1312032118570.29733@chino.kir.corp.google.com>
 <20131204054533.GZ3556@cmpxchg.org>
 <alpine.DEB.2.02.1312041742560.20115@chino.kir.corp.google.com>
 <20131205025026.GA26777@htj.dyndns.org>
 <alpine.DEB.2.02.1312051537550.7717@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1312051537550.7717@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, Li Zefan <lizefan@huawei.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On Thu, Dec 05, 2013 at 03:49:57PM -0800, David Rientjes wrote:
> On Wed, 4 Dec 2013, Tejun Heo wrote:
> 
> > Hello,
> > 
> 
> Tejun, how are you?
> 
> > Umm.. without delving into details, aren't you basically creating a
> > memory cgroup inside a memory cgroup?  Doesn't sound like a
> > particularly well thought-out plan to me.
> > 
> 
> I agree that we wouldn't need such support if we are only addressing memcg 
> oom conditions.  We could do things like A/memory.limit_in_bytes == 128M 
> and A/b/memory.limit_in_bytes == 126MB and then attach the process waiting 
> on A/b/memory.oom_control to A and that would work perfect.
> 
> However, we also need to discuss system oom handling.  We have an interest 
> in being able to allow userspace to handle system oom conditions since the 
> policy will differ depending on machine and we can't encode every possible 
> mechanism into the kernel.  For example, on system oom we want to kill a 
> process from the lowest priority top-level memcg.  We lack that ability 
> entirely in the kernel and since the sum of our top-level memcgs 
> memory.limit_in_bytes exceeds the amount of present RAM, we run into these 
> oom conditions a _lot_.

A simple and natural solution to this is to have the global OOM killer
respect cgroups.  You go through all the effort of carefully grouping
tasks into bigger entities that you then arrange hierarchically.  The
global OOM killer should not just treat all tasks as equal peers.

We can add a per-cgroup OOM priority knob and have the global OOM
handler pick victim tasks from the one or more groups that have the
lowest priority.

Out of the box, every cgroup has the same priority, which means we can
add this feature without changing the default behavior.

> So the first step, in my opinion, is to add a system oom notification on 
> the root memcg's memory.oom_control which currently allows registering an 
> eventfd() notification but never actually triggers.  I did that in a patch 
> and it is was merged into -mm but was pulled out for later discussion.
> 
> Then, we need to ensure that the userspace that is registered to handle 
> such events and that is difficult to do when the system is oom.  The 
> proposal is to allow such processes, now marked as PF_OOM_HANDLER, to be 
> able to access pre-defined per-zone memory reserves in the page allocator.  
> The only special handling for PF_OOM_HANDLER in the page allocator itself 
> would be under such oom conditions (memcg oom conditions have no problem 
> allocating the memory, only charging it).  The amount of reserves would be 
> defined as memory.oom_reserve_in_bytes from within the root memcg as 
> defined by this patch, i.e. allow this amount of memory to be allocated in 
> the page allocator for PF_OOM_HANDLER below the per-zone min watermarks.
> 
> This, I believe, is the cleanest interface for users who choose to use a 
> non-default policy by setting memory.oom_reserve_in_bytes and constrains 
> all of the code to memcg which you have to configure for such support.
> 
> The system oom condition is not addressed in this patch series, although 
> the PF_OOM_HANDLER bit can be used for that purpose.  I didn't post that 
> patch because the notification on the root memcg's memory.oom_control in 
> such conditions is currently being debated, so we need to solve that issue 
> first.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
