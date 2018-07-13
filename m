Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id C058B6B0007
	for <linux-mm@kvack.org>; Fri, 13 Jul 2018 17:34:52 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id g11-v6so54356pgs.13
        for <linux-mm@kvack.org>; Fri, 13 Jul 2018 14:34:52 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 62-v6sor8944753plb.54.2018.07.13.14.34.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 13 Jul 2018 14:34:51 -0700 (PDT)
Date: Fri, 13 Jul 2018 14:34:49 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: cgroup-aware OOM killer, how to move forward
In-Reply-To: <20180711223959.GA13981@castle.DHCP.thefacebook.com>
Message-ID: <alpine.DEB.2.21.1807131423230.194789@chino.kir.corp.google.com>
References: <20180711223959.GA13981@castle.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, mhocko@kernel.org, hannes@cmpxchg.org, tj@kernel.org, gthelen@google.com

On Wed, 11 Jul 2018, Roman Gushchin wrote:

> I was thinking on how to move forward with the cgroup-aware OOM killer.
> It looks to me, that we all agree on the "cleanup" part of the patchset:
> it's a nice feature to be able to kill all tasks in the cgroup
> to guarantee the consistent state of the workload.
> All our disagreements are related to the victim selection algorithm.
> 
> So, I wonder, if the right thing to do is to split the problem.
> We can agree on the "cleanup" part, which is useful by itself,
> merge it upstream, and then return to the victim selection
> algorithm.
> 
> So, here is my proposal:
> let's introduce the memory.group_oom knob with the following semantics:
> if the knob is set, the OOM killer can kill either none, either all
> tasks in the cgroup*.
> It can perfectly work with the current OOM killer (as a "cleanup" option),
> and allows _any_ further approach on the OOM victim selection.
> It also doesn't require any mount/boot/tree-wide options.
> 
> How does it sound?
> 

No objection, of course, this was always the mechanism vs policy 
separation that I was referring to.  Having the ability to kill all 
processes attached to the cgroup when one of its processes is selected is 
useful, and we have our own patches that do just that, with the exception 
that it's triggerable by the user.

One of the things that I really like about cgroup v2, though, is what 
appears to be an implicit, but rather apparent, goal to minimize the 
number of files for each controller.  It's very clean.  So I'd suggest 
that we consider memory.group_oom, or however it is named, to allow for 
future development.

For example, rather than simply being binary, we'd probably want the 
ability to kill all eligible processes attached directly to the victim's 
mem cgroup *or* all processes attached to its subtree as well.

I'd suggest it be implemented to accept a string, "default"/"process", 
"local" or "tree"/"hierarchy", or better names, to define the group oom 
mechanism for the mem cgroup that is oom when one of its processes is 
selected as a victim.

> * More precisely: if the OOM killer kills a task,
> it will traverse the cgroup tree up to the OOM domain (OOMing memcg or root),
> looking for the highest-level cgroup with group_oom set. Then it will
> kill all tasks in such cgroup, if it does exist.
> 

All such processes that are not oom disabled, yes.
