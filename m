Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2549B6B000C
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 08:42:01 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id d30-v6so539906edd.0
        for <linux-mm@kvack.org>; Tue, 17 Jul 2018 05:42:01 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g2-v6si827038edc.349.2018.07.17.05.41.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jul 2018 05:41:59 -0700 (PDT)
Date: Tue, 17 Jul 2018 14:41:55 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: cgroup-aware OOM killer, how to move forward
Message-ID: <20180717124155.GH7193@dhcp22.suse.cz>
References: <20180711223959.GA13981@castle.DHCP.thefacebook.com>
 <alpine.DEB.2.21.1807131423230.194789@chino.kir.corp.google.com>
 <20180713221602.GA15005@castle.DHCP.thefacebook.com>
 <alpine.DEB.2.21.1807131535420.202408@chino.kir.corp.google.com>
 <20180713230545.GA17467@castle.DHCP.thefacebook.com>
 <alpine.DEB.2.21.1807131608530.218060@chino.kir.corp.google.com>
 <20180713231630.GB17467@castle.DHCP.thefacebook.com>
 <alpine.DEB.2.21.1807162115180.157949@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1807162115180.157949@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Roman Gushchin <guro@fb.com>, linux-mm@kvack.org, akpm@linux-foundation.org, hannes@cmpxchg.org, tj@kernel.org, gthelen@google.com

On Mon 16-07-18 21:19:18, David Rientjes wrote:
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

No, this is mangling the interface again. I have already objected to
this [1]. group_oom only tells to tear the whole group down. How you
select this particular group is a completely different story. Conflating
those two things is a bad interface to start with. Killing the whold
cgroup or only a single process should be invariant for the particular
memcg regardless of what is the oom selection policy above in the
hierarchy. Either you are indivisible workload or you are not, full
stop.

If we really need a better control over how to select subtrees then this
should be a separate control knob. How should it look like is a matter
of discussion but it will be hard to find any consensus if the
single-knob-for-single-purpose approach is not clear.

[1] http://lkml.kernel.org/r/20180117160004.GH2900@dhcp22.suse.cz
-- 
Michal Hocko
SUSE Labs
