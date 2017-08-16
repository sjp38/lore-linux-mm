Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7D17A6B025F
	for <linux-mm@kvack.org>; Wed, 16 Aug 2017 10:44:17 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id n88so6243031wrb.0
        for <linux-mm@kvack.org>; Wed, 16 Aug 2017 07:44:17 -0700 (PDT)
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id d93si979676wma.132.2017.08.16.07.44.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Aug 2017 07:44:16 -0700 (PDT)
Date: Wed, 16 Aug 2017 15:43:44 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [v5 4/4] mm, oom, docs: describe the cgroup-aware OOM killer
Message-ID: <20170816144344.GA29131@castle.DHCP.thefacebook.com>
References: <20170814183213.12319-1-guro@fb.com>
 <20170814183213.12319-5-guro@fb.com>
 <alpine.DEB.2.10.1708141544280.63207@chino.kir.corp.google.com>
 <20170815141350.GA4510@castle.DHCP.thefacebook.com>
 <alpine.DEB.2.10.1708151349280.104516@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1708151349280.104516@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Aug 15, 2017 at 01:56:24PM -0700, David Rientjes wrote:
> On Tue, 15 Aug 2017, Roman Gushchin wrote:
> 
> > > > diff --git a/Documentation/cgroup-v2.txt b/Documentation/cgroup-v2.txt
> > > > index dec5afdaa36d..22108f31e09d 100644
> > > > --- a/Documentation/cgroup-v2.txt
> > > > +++ b/Documentation/cgroup-v2.txt
> > > > @@ -48,6 +48,7 @@ v1 is available under Documentation/cgroup-v1/.
> > > >         5-2-1. Memory Interface Files
> > > >         5-2-2. Usage Guidelines
> > > >         5-2-3. Memory Ownership
> > > > +       5-2-4. Cgroup-aware OOM Killer
> > > 
> > > Random curiousness, why cgroup-aware oom killer and not memcg-aware oom 
> > > killer?
> > 
> > I don't think we use the term "memcg" somewhere in v2 docs.
> > Do you think that "Memory cgroup-aware OOM killer" is better?
> > 
> 
> I think it would be better to not describe it as its own entity, but 
> rather a part of how the memory cgroup works, so simply describing it in 
> section 5-2, perhaps as its own subsection, as how the oom killer works 
> when using the memory cgroup is sufficient.  I wouldn't separate it out as 
> a distinct cgroup feature in the documentation.

Ok I've got the idea, let me look, what I can do.
I'll post an updated version soon.

> 
> > > > +	cgroups.  The default is "0".
> > > > +
> > > > +	Defines whether the OOM killer should treat the cgroup
> > > > +	as a single entity during the victim selection.
> > > 
> > > Isn't this true independent of the memory.oom_kill_all_tasks setting?  
> > > The cgroup aware oom killer will consider memcg's as logical units when 
> > > deciding what to kill with or without memory.oom_kill_all_tasks, right?
> > > 
> > > I think you cover this fact in the cgroup aware oom killer section below 
> > > so this might result in confusion if described alongside a setting of
> > > memory.oom_kill_all_tasks.
> > > 
> 
> I assume this is fixed so that it's documented that memory cgroups are 
> considered logical units by the oom killer and that 
> memory.oom_kill_all_tasks is separate?  The former defines the policy on 
> how a memory cgroup is targeted and the latter defines the mechanism it 
> uses to free memory.

Yes, I've fixed this. Thanks!

> > > > +Cgroup-aware OOM Killer
> > > > +~~~~~~~~~~~~~~~~~~~~~~~
> > > > +
> > > > +Cgroup v2 memory controller implements a cgroup-aware OOM killer.
> > > > +It means that it treats memory cgroups as first class OOM entities.
> > > > +
> > > > +Under OOM conditions the memory controller tries to make the best
> > > > +choise of a victim, hierarchically looking for the largest memory
> > > > +consumer. By default, it will look for the biggest task in the
> > > > +biggest leaf cgroup.
> > > > +
> > > > +Be default, all cgroups have oom_priority 0, and OOM killer will
> > > > +chose the largest cgroup recursively on each level. For non-root
> > > > +cgroups it's possible to change the oom_priority, and it will cause
> > > > +the OOM killer to look athe the priority value first, and compare
> > > > +sizes only of cgroups with equal priority.
> > > 
> > > Maybe some description of "largest" would be helpful here?  I think you 
> > > could briefly describe what is accounted for in the decisionmaking.
> > 
> > I'm afraid that it's too implementation-defined to be described.
> > Do you have an idea, how to describe it without going too much into details?
> > 
> 
> The point is that "largest cgroup" is ambiguous here: largest in what 
> sense?  The cgroup with the largest number of processes attached?  Using 
> the largest amount of memory?
> 
> I think the documentation should clearly define that the oom killer 
> selects the memory cgroup that has the most memory managed at each level.

No problems, I'll add a clarification.

Thank you!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
