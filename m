Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4E6DD6B0006
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 04:12:34 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id f13-v6so533501edr.10
        for <linux-mm@kvack.org>; Wed, 18 Jul 2018 01:12:34 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x41-v6si1826438edb.66.2018.07.18.01.12.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jul 2018 01:12:32 -0700 (PDT)
Date: Wed, 18 Jul 2018 10:12:30 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: cgroup-aware OOM killer, how to move forward
Message-ID: <20180718081230.GP7193@dhcp22.suse.cz>
References: <alpine.DEB.2.21.1807131423230.194789@chino.kir.corp.google.com>
 <20180713221602.GA15005@castle.DHCP.thefacebook.com>
 <alpine.DEB.2.21.1807131535420.202408@chino.kir.corp.google.com>
 <20180713230545.GA17467@castle.DHCP.thefacebook.com>
 <alpine.DEB.2.21.1807131608530.218060@chino.kir.corp.google.com>
 <20180713231630.GB17467@castle.DHCP.thefacebook.com>
 <alpine.DEB.2.21.1807162115180.157949@chino.kir.corp.google.com>
 <20180717173844.GB14909@castle.DHCP.thefacebook.com>
 <20180717194945.GM7193@dhcp22.suse.cz>
 <20180717200641.GB18762@castle.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180717200641.GB18762@castle.DHCP.thefacebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, akpm@linux-foundation.org, hannes@cmpxchg.org, tj@kernel.org, gthelen@google.com

On Tue 17-07-18 13:06:42, Roman Gushchin wrote:
> On Tue, Jul 17, 2018 at 09:49:46PM +0200, Michal Hocko wrote:
> > On Tue 17-07-18 10:38:45, Roman Gushchin wrote:
> > [...]
> > > Let me show my proposal on examples. Let's say we have the following hierarchy,
> > > and the biggest process (or the process with highest oom_score_adj) is in D.
> > > 
> > >   /
> > >   |
> > >   A
> > >   |
> > >   B
> > >  / \
> > > C   D
> > > 
> > > Let's look at different examples and intended behavior:
> > > 1) system-wide OOM
> > >   - default settings: the biggest process is killed
> > >   - D/memory.group_oom=1: all processes in D are killed
> > >   - A/memory.group_oom=1: all processes in A are killed
> > > 2) memcg oom in B
> > >   - default settings: the biggest process is killed
> > >   - A/memory.group_oom=1: the biggest process is killed
> > 
> > Huh? Why would you even consider A here when the oom is below it?
> > /me confused
> 
> I do not.
> This is exactly a counter-example: A's memory.group_oom
> is not considered at all in this case,
> because A is above ooming cgroup.

OK, it confused me.

> > 
> > >   - B/memory.group_oom=1: all processes in B are killed
> > 
> >     - B/memory.group_oom=0 &&
> > >   - D/memory.group_oom=1: all processes in D are killed
> > 
> > What about?
> >     - B/memory.group_oom=1 && D/memory.group_oom=0
> 
> All tasks in B are killed.

so essentially find a task, traverse the memcg hierarchy from the
victim's memcg up to the oom root as long as memcg.group_oom = 1?
If the resulting memcg.group_oom == 1 then kill the whole sub tree.
Right?

> Group_oom set to 1 means that the workload can't tolerate
> killing of a random process, so in this case it's better
> to guarantee consistency for B.

OK, but then if D itself is OOM then we do not care about consistency
all of the sudden? I have hard time to think about a sensible usecase.
-- 
Michal Hocko
SUSE Labs
