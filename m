Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id D3E416B0007
	for <linux-mm@kvack.org>; Fri, 13 Jul 2018 18:39:17 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id az8-v6so20190923plb.15
        for <linux-mm@kvack.org>; Fri, 13 Jul 2018 15:39:17 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id j24-v6sor3979109pfe.146.2018.07.13.15.39.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 13 Jul 2018 15:39:16 -0700 (PDT)
Date: Fri, 13 Jul 2018 15:39:15 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: cgroup-aware OOM killer, how to move forward
In-Reply-To: <20180713221602.GA15005@castle.DHCP.thefacebook.com>
Message-ID: <alpine.DEB.2.21.1807131535420.202408@chino.kir.corp.google.com>
References: <20180711223959.GA13981@castle.DHCP.thefacebook.com> <alpine.DEB.2.21.1807131423230.194789@chino.kir.corp.google.com> <20180713221602.GA15005@castle.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, mhocko@kernel.org, hannes@cmpxchg.org, tj@kernel.org, gthelen@google.com

On Fri, 13 Jul 2018, Roman Gushchin wrote:

> > No objection, of course, this was always the mechanism vs policy 
> > separation that I was referring to.  Having the ability to kill all 
> > processes attached to the cgroup when one of its processes is selected is 
> > useful, and we have our own patches that do just that, with the exception 
> > that it's triggerable by the user.
> 
> Perfect! I'll prepare the patchset.
> 

I mean, I separated it out completely in my own 
https://marc.info/?l=linux-kernel&m=152175564704473 as part of a patch 
series that completely fixes all of the issues with the cgroup aware oom 
killer, so of course there's no objection to separating it out.

> > 
> > One of the things that I really like about cgroup v2, though, is what 
> > appears to be an implicit, but rather apparent, goal to minimize the 
> > number of files for each controller.  It's very clean.  So I'd suggest 
> > that we consider memory.group_oom, or however it is named, to allow for 
> > future development.
> > 
> > For example, rather than simply being binary, we'd probably want the 
> > ability to kill all eligible processes attached directly to the victim's 
> > mem cgroup *or* all processes attached to its subtree as well.
> > 
> > I'd suggest it be implemented to accept a string, "default"/"process", 
> > "local" or "tree"/"hierarchy", or better names, to define the group oom 
> > mechanism for the mem cgroup that is oom when one of its processes is 
> > selected as a victim.
> 
> I would prefer to keep it boolean to match the simplicity of cgroup v2 API.
> In v2 hierarchy processes can't be attached to non-leaf cgroups,
> so I don't see the place for the 3rd meaning.
> 

All cgroup v2 files do not need to be boolean and the only way you can add 
a subtree oom kill is to introduce yet another file later.  Please make it 
tristate so that you can define a mechanism of default (process only), 
local cgroup, or subtree, and so we can avoid adding another option later 
that conflicts with the proposed one.  This should be easy.
