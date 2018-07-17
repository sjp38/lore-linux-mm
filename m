Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id CD2376B0006
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 13:39:38 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id b7-v6so1326038qtp.14
        for <linux-mm@kvack.org>; Tue, 17 Jul 2018 10:39:38 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id x4-v6si1851878qvj.116.2018.07.17.10.39.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jul 2018 10:39:37 -0700 (PDT)
Date: Tue, 17 Jul 2018 10:38:45 -0700
From: Roman Gushchin <guro@fb.com>
Subject: Re: cgroup-aware OOM killer, how to move forward
Message-ID: <20180717173844.GB14909@castle.DHCP.thefacebook.com>
References: <20180711223959.GA13981@castle.DHCP.thefacebook.com>
 <alpine.DEB.2.21.1807131423230.194789@chino.kir.corp.google.com>
 <20180713221602.GA15005@castle.DHCP.thefacebook.com>
 <alpine.DEB.2.21.1807131535420.202408@chino.kir.corp.google.com>
 <20180713230545.GA17467@castle.DHCP.thefacebook.com>
 <alpine.DEB.2.21.1807131608530.218060@chino.kir.corp.google.com>
 <20180713231630.GB17467@castle.DHCP.thefacebook.com>
 <alpine.DEB.2.21.1807162115180.157949@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1807162115180.157949@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, mhocko@kernel.org, hannes@cmpxchg.org, tj@kernel.org, gthelen@google.com

On Mon, Jul 16, 2018 at 09:19:18PM -0700, David Rientjes wrote:
> On Fri, 13 Jul 2018, Roman Gushchin wrote:
> 
> > > > > All cgroup v2 files do not need to be boolean and the only way you can add 
> > > > > a subtree oom kill is to introduce yet another file later.  Please make it 
> > > > > tristate so that you can define a mechanism of default (process only), 
> > > > > local cgroup, or subtree, and so we can avoid adding another option later 
> > > > > that conflicts with the proposed one.  This should be easy.
> > > > 
> > > > David, we're adding a cgroup v2 knob, and in cgroup v2 a memory cgroup
> > > > either has a sub-tree, either attached processes. So, there is no difference
> > > > between local cgroup and subtree.
> > > > 
> > > 
> > > Uhm, what?  We're talking about a common ancestor reaching its limit, so 
> > > it's oom, and it has multiple immediate children with their own processes 
> > > attached.  The difference is killing all processes attached to the 
> > > victim's cgroup or all processes under the oom mem cgroup's subtree.
> > > 
> > 
> > But it's a binary decision, no?
> > If memory.group_oom set, the whole sub-tree will be killed. Otherwise not.
> > 
> 
> No, if memory.max is reached and memory.group_oom is set, my understanding 
> of your proposal is that a process is chosen and all eligible processes 
> attached to its mem cgroup are oom killed.  My desire for a tristate is so 
> that it can be specified that all processes attached to the *subtree* are 
> oom killed.  With single unified hierarchy mandated by cgroup v2, we can 
> separate descendant cgroups for use with other controllers and enforce 
> memory.max by an ancestor.
> 
> Making this a boolean value is only preventing it from becoming 
> extensible.  If memory.group_oom only is effective for the victim's mem 
> cgroup, it becomes impossible to specify that all processes in the subtree 
> should be oom killed as a result of the ancestor limit without adding yet 
> another tunable.

Let me show my proposal on examples. Let's say we have the following hierarchy,
and the biggest process (or the process with highest oom_score_adj) is in D.

  /
  |
  A
  |
  B
 / \
C   D

Let's look at different examples and intended behavior:
1) system-wide OOM
  - default settings: the biggest process is killed
  - D/memory.group_oom=1: all processes in D are killed
  - A/memory.group_oom=1: all processes in A are killed
2) memcg oom in B
  - default settings: the biggest process is killed
  - A/memory.group_oom=1: the biggest process is killed
  - B/memory.group_oom=1: all processes in B are killed
  - D/memory.group_oom=1: all processes in D are killed

Please, note, that processes can't be attached directly to A and B,
so "all processes in A are killed" means all processes in the sub-tree
are killed. Immortal processes (oom_score_adj=-1000) are excluded.

I believe, that this model is full and doesn't require any further
extension.

Thanks!
