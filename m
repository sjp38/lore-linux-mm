Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id E34D26B0253
	for <linux-mm@kvack.org>; Tue, 31 Oct 2017 18:21:26 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id n137so2191847iod.20
        for <linux-mm@kvack.org>; Tue, 31 Oct 2017 15:21:26 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j91sor194576iod.276.2017.10.31.15.21.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 31 Oct 2017 15:21:25 -0700 (PDT)
Date: Tue, 31 Oct 2017 15:21:23 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RESEND v12 0/6] cgroup-aware OOM killer
In-Reply-To: <20171031075408.67au22uk6dkpu7vv@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1710311513590.123444@chino.kir.corp.google.com>
References: <20171019185218.12663-1-guro@fb.com> <20171019194534.GA5502@cmpxchg.org> <alpine.DEB.2.10.1710221715010.70210@chino.kir.corp.google.com> <20171026142445.GA21147@cmpxchg.org> <alpine.DEB.2.10.1710261359550.75887@chino.kir.corp.google.com>
 <20171027093107.GA29492@castle.dhcp.TheFacebook.com> <alpine.DEB.2.10.1710301430170.105449@chino.kir.corp.google.com> <20171031075408.67au22uk6dkpu7vv@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, 31 Oct 2017, Michal Hocko wrote:

> > I'm not ignoring them, I have stated that we need the ability to protect 
> > important cgroups on the system without oom disabling all attached 
> > processes.  If that is implemented as a memory.oom_score_adj with the same 
> > semantics as /proc/pid/oom_score_adj, i.e. a proportion of available 
> > memory (the limit), it can also address the issues pointed out with the 
> > hierarchical approach in v8.
> 
> No it cannot and it would be a terrible interface to have as well. You
> do not want to permanently tune oom_score_adj to compensate for
> structural restrictions on the hierarchy.
> 

memory.oom_score_adj would never need to be permanently tuned, just as 
/proc/pid/oom_score_adj need never be permanently tuned.  My response was 
an answer to Roman's concern that "v8 has it's own limitations," but I 
haven't seen a concrete example where the oom killer is forced to kill 
from the non-preferred cgroup while the user has power of biasing against 
certain cgroups with memory.oom_score_adj.  Do you have such a concrete 
example that we can work with?

> I believe, and Roman has pointed that out as well already, that further
> improvements can be implemented without changing user visible behavior
> as and add-on. If you disagree then you better come with a solid proof
> that all of us wrong and reasonable semantic cannot be achieved that
> way.

We simply cannot determine if improvements can be implemented in the 
future without user-visible changes if those improvements are unknown or 
undecided at this time.  It may require hierarchical accounting when 
making a choice between siblings, as suggested with oom_score_adj.  The 
only thing that we need to agree on is that userspace needs to have some 
kind of influence over victim selection: the oom killer killing an 
important user process is an extremely sensitive thing.  If the patchset 
lacks the ability to have that influence, and such an ability would impact 
the heuristic overall, it's better to introduce that together as a 
complete patchset rather than merging an incomplete feature when it's 
known the user needs some control, asking the user to workaround it by 
setting all processes to oom disabled in a preferred mem cgroup, and then 
changing the heuristic again.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
