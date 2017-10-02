Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 66E0E6B0033
	for <linux-mm@kvack.org>; Mon,  2 Oct 2017 08:24:39 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id r83so11842654pfj.5
        for <linux-mm@kvack.org>; Mon, 02 Oct 2017 05:24:39 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t6si7603635pfh.213.2017.10.02.05.24.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 02 Oct 2017 05:24:38 -0700 (PDT)
Date: Mon, 2 Oct 2017 14:24:34 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [v8 0/4] cgroup-aware OOM killer
Message-ID: <20171002122434.llbaarb6yw3o3mx3@dhcp22.suse.cz>
References: <20170926112134.r5eunanjy7ogjg5n@dhcp22.suse.cz>
 <20170926121300.GB23139@castle.dhcp.TheFacebook.com>
 <20170926133040.uupv3ibkt3jtbotf@dhcp22.suse.cz>
 <20170926172610.GA26694@cmpxchg.org>
 <CAAAKZws88uF2dVrXwRV0V6AH5X68rWy7AfJxTxYjpuiyiNJFWA@mail.gmail.com>
 <20170927074319.o3k26kja43rfqmvb@dhcp22.suse.cz>
 <CAAAKZws2CFExeg6A9AzrGjiHnFHU1h2xdk6J5Jw2kqxy=V+_YQ@mail.gmail.com>
 <20170927162300.GA5623@castle.DHCP.thefacebook.com>
 <CAAAKZwtApj-FgRc2V77nEb3BUd97Rwhgf-b-k0zhf1u+Y4fqxA@mail.gmail.com>
 <CALvZod7iaOEeGmDJA0cZvJWpuzc-hMRn3PG2cfzcMniJtAjKqA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALvZod7iaOEeGmDJA0cZvJWpuzc-hMRn3PG2cfzcMniJtAjKqA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Tim Hockin <thockin@hockin.org>, Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, David Rientjes <rientjes@google.com>, Linux MM <linux-mm@kvack.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Cgroups <cgroups@vger.kernel.org>, linux-doc@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Sun 01-10-17 16:29:48, Shakeel Butt wrote:
> >
> > Going back to Michal's example, say the user configured the following:
> >
> >        root
> >       /    \
> >      A      D
> >     / \
> >    B   C
> >
> > A global OOM event happens and we find this:
> > - A > D
> > - B, C, D are oomgroups
> >
> > What the user is telling us is that B, C, and D are compound memory
> > consumers. They cannot be divided into their task parts from a memory
> > point of view.
> >
> > However, the user doesn't say the same for A: the A subtree summarizes
> > and controls aggregate consumption of B and C, but without groupoom
> > set on A, the user says that A is in fact divisible into independent
> > memory consumers B and C.
> >
> > If we don't have to kill all of A, but we'd have to kill all of D,
> > does it make sense to compare the two?
> >
> 
> I think Tim has given very clear explanation why comparing A & D makes
> perfect sense. However I think the above example, a single user system
> where a user has designed and created the whole hierarchy and then
> attaches different jobs/applications to different nodes in this
> hierarchy, is also a valid scenario.

Yes and nobody is disputing that, really. I guess the main disconnect
here is that different people want to have more detailed control over
the victim selection while the patchset tries to handle the most
simplistic scenario when a no userspace control over the selection is
required. And I would claim that this will be a last majority of setups
and we should address it first.

A more fine grained control needs some more thinking to come up with a
sensible and long term sustainable API. Just look back and see at the
oom_score_adj story and how it ended up unusable in the end (well apart
from never/always kill corner cases). Let's not repeat that again now.

I strongly believe that we can come up with something - be it priority
based, BFP based or module based selection. But let's start simple with
the most basic scenario first with a most sensible semantic implemented.

I believe the latest version (v9) looks sensible from the semantic point
of view and we should focus on making it into a mergeable shape.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
