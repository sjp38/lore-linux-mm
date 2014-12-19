Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id AC8D16B0032
	for <linux-mm@kvack.org>; Fri, 19 Dec 2014 16:15:11 -0500 (EST)
Received: by mail-wi0-f171.google.com with SMTP id bs8so3151725wib.10
        for <linux-mm@kvack.org>; Fri, 19 Dec 2014 13:15:11 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id cu5si5467137wib.48.2014.12.19.13.15.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Dec 2014 13:15:10 -0800 (PST)
Date: Fri, 19 Dec 2014 16:15:05 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] memcg: Provide knob for force OOM into the memcg
Message-ID: <20141219211505.GA6838@phnom.home.cmpxchg.org>
References: <1418736335-30915-1-git-send-email-cpandya@codeaurora.org>
 <20141216165922.GA30984@phnom.home.cmpxchg.org>
 <549172F1.5050303@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <549172F1.5050303@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chintan Pandya <cpandya@codeaurora.org>
Cc: mhocko@suse.cz, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Dec 17, 2014 at 05:41:29PM +0530, Chintan Pandya wrote:
> 
> >Why do you move tasks around during runtime?  Rather than scanning
> >thousands or millions of page table entries to relocate a task and its
> >private memory to another configuration domain, wouldn't it be easier to
> >just keep the task in a dedicated cgroup and reconfigure that instead?
> 
> Your suggestion is good. But in specific cases, we may have no choice but to
> migrate.
> 
> Take a case of an Android system where a process/app will never gets killed
> until there is really no scope of holding it any longer in RAM. So, when
> that process was running as a foreground process, it has to belong to a
> group which has no memory limit and cannot be killed. Now, when the same
> process goes into background and sits idle, it can be compressed and cached
> into some space in RAM. These cached processes are ever growing list and can
> be capped with some limit. Naturally, these processes belongs to different
> category and hence different cgroup which just controls such cached
> processes.

This is a valid usecase that should supported, but there has to be a
better way to do it then to move potentially hundreds of megabytes,
page by page, during the task switch.  It's a massive amount of work.

But there are also several problematic design implications in moving
memory along with a task.

For one, moving a task involves two separate cgroups that can have an
arbitrary number of controllers attached to them.  If this complex
operation fails, you have no idea which component is at fault - was it
a generic cgroup problem, or does the move violate a rule in one of
the controllers?  And *if* it fails, what action do you take?  Does
the app simply remain a foreground app?  Likewise, if you move the
task but fail to migrate some pages, do you leave them behind in the
foreground group where they are exempt from reclaim?  Conflating task
organization and resource control like this just isn't a good idea.

Secondly, memory tracked through cgroups does not belong to the task,
it belongs to the cgroup, and we are limited to unreliable heuristics
when determining a task-page relationship.  The pages that can't be
attributed properly - like unmapped page cache - again will be left
behind, polluting your reclaim-exempt foreground group.

Another aspect is that the foreground domain is variable in size, but
you are assigning it a minimum amount of space by statically limiting
the background apps.  If the foreground doesn't use that space, you
end up killing cached apps for no reason and waste even more memory.
Imagine you run a large app like Maps and then switch to a tiny note
taking app to look something up.  Now you're kicking Maps out of the
cache for no reason.

The last point is a much more generic problem.  Static limits are not
suited to efficiently partition a machine for realistic workloads.
This is why version 2 will move away from the idea of static hard
limits as the primary means of partitioning, and towards a model that
has the user configure upper and lower boundaries for the expected
workingset size of each group.  Static limits will be relegated to
failsafe measures and hard requirements.

Setting a group's lower boundary will tell the kernel how much memory
the group requires at a minimum to function properly, and the kernel
will try to avoid reclaiming and OOM killing groups within their lower
boundary at the expense of groups that are in excess of theirs.  Your
configuration can be rephrased using this: by putting all apps into
their own groups, and setting the lower boundary to infinity for the
foreground apps and to zero for the background apps, the kernel will
always reclaim and OOM kill the background apps first.

You get the same foreground app protection as before, but with several
advantages.

Firstly, it separates the task grouping of an app from memory policy,
which allows you to track your apps as self-contained bundles of tasks
and memory.  You are no longer required to conflate unrelated apps for
the sake of memory policy, only to reshuffle and break them apart
again using inaccurate separation heuristics that will end up
polluting *both* domains.

Secondly, background apps will no longer get killed based on a static
quota, but based on actual memory pressure.  You configure the policy,
and the kernel decides on demand where to get the required memory.

And lastly, you don't have to physically move thousands of pages on
every task switch anymore, AND pay the synchronization overhead that
stems from pages changing cgroups during runtime.

Your use case is valid, but charge migration doesn't seem to be the
right answer here.  And I really doubt it's ever the right answer.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
