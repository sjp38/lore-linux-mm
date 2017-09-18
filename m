Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 067926B0253
	for <linux-mm@kvack.org>; Mon, 18 Sep 2017 02:20:57 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id e64so8510327wmi.0
        for <linux-mm@kvack.org>; Sun, 17 Sep 2017 23:20:56 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d35si128148edc.407.2017.09.17.23.20.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 17 Sep 2017 23:20:56 -0700 (PDT)
Date: Mon, 18 Sep 2017 08:20:45 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [v8 0/4] cgroup-aware OOM killer
Message-ID: <20170918062045.kcfsboxvfmlg2wjo@dhcp22.suse.cz>
References: <20170911131742.16482-1-guro@fb.com>
 <alpine.DEB.2.10.1709111334210.102819@chino.kir.corp.google.com>
 <20170913122914.5gdksbmkolum7ita@dhcp22.suse.cz>
 <20170913215607.GA19259@castle>
 <20170914134014.wqemev2kgychv7m5@dhcp22.suse.cz>
 <20170914160548.GA30441@castle>
 <20170915105826.hq5afcu2ij7hevb4@dhcp22.suse.cz>
 <20170915152301.GA29379@castle>
 <alpine.DEB.2.10.1709151249290.76069@chino.kir.corp.google.com>
 <20170915210807.GA5238@castle>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170915210807.GA5238@castle>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri 15-09-17 14:08:07, Roman Gushchin wrote:
> On Fri, Sep 15, 2017 at 12:55:55PM -0700, David Rientjes wrote:
> > On Fri, 15 Sep 2017, Roman Gushchin wrote:
> > 
> > > > But then you just enforce a structural restriction on your configuration
> > > > because
> > > > 	root
> > > >         /  \
> > > >        A    D
> > > >       /\   
> > > >      B  C
> > > > 
> > > > is a different thing than
> > > > 	root
> > > >         / | \
> > > >        B  C  D
> > > >
> > > 
> > > I actually don't have a strong argument against an approach to select
> > > largest leaf or kill-all-set memcg. I think, in practice there will be
> > > no much difference.
> > > 
> > > The only real concern I have is that then we have to do the same with
> > > oom_priorities (select largest priority tree-wide), and this will limit
> > > an ability to enforce the priority by parent cgroup.
> > > 
> > 
> > Yes, oom_priority cannot select the largest priority tree-wide for exactly 
> > that reason.  We need the ability to control from which subtree the kill 
> > occurs in ancestor cgroups.  If multiple jobs are allocated their own 
> > cgroups and they can own memory.oom_priority for their own subcontainers, 
> > this becomes quite powerful so they can define their own oom priorities.   
> > Otherwise, they can easily override the oom priorities of other cgroups.
> 
> I believe, it's a solvable problem: we can require CAP_SYS_RESOURCE to set
> the oom_priority below parent's value, or something like this.

As said in other email. We can make priorities hierarchical (in the same
sense as hard limit or others) so that children cannot override their
parent.

> But it looks more complex, and I'm not sure there are real examples,
> when we have to compare memcgs, which are on different levels
> (or in different subtrees).

Well, I have given you one that doesn't sounds completely insane to me
in other email. You may need an intermediate level for other than memcg
controller. The whole concept of significance of the hierarchy level
seems really odd to me. Or am I wrong here?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
