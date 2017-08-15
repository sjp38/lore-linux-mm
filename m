Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5D4406B025F
	for <linux-mm@kvack.org>; Tue, 15 Aug 2017 10:14:20 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id f23so5736933pgn.15
        for <linux-mm@kvack.org>; Tue, 15 Aug 2017 07:14:20 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id k1si5595541pfc.321.2017.08.15.07.14.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Aug 2017 07:14:19 -0700 (PDT)
Date: Tue, 15 Aug 2017 15:13:50 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [v5 4/4] mm, oom, docs: describe the cgroup-aware OOM killer
Message-ID: <20170815141350.GA4510@castle.DHCP.thefacebook.com>
References: <20170814183213.12319-1-guro@fb.com>
 <20170814183213.12319-5-guro@fb.com>
 <alpine.DEB.2.10.1708141544280.63207@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1708141544280.63207@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, Aug 14, 2017 at 03:52:26PM -0700, David Rientjes wrote:
> On Mon, 14 Aug 2017, Roman Gushchin wrote:
> 
> > diff --git a/Documentation/cgroup-v2.txt b/Documentation/cgroup-v2.txt
> > index dec5afdaa36d..22108f31e09d 100644
> > --- a/Documentation/cgroup-v2.txt
> > +++ b/Documentation/cgroup-v2.txt
> > @@ -48,6 +48,7 @@ v1 is available under Documentation/cgroup-v1/.
> >         5-2-1. Memory Interface Files
> >         5-2-2. Usage Guidelines
> >         5-2-3. Memory Ownership
> > +       5-2-4. Cgroup-aware OOM Killer
> 
> Random curiousness, why cgroup-aware oom killer and not memcg-aware oom 
> killer?

I don't think we use the term "memcg" somewhere in v2 docs.
Do you think that "Memory cgroup-aware OOM killer" is better?

> 
> >       5-3. IO
> >         5-3-1. IO Interface Files
> >         5-3-2. Writeback
> > @@ -1002,6 +1003,37 @@ PAGE_SIZE multiple when read back.
> >  	high limit is used and monitored properly, this limit's
> >  	utility is limited to providing the final safety net.
> >  
> > +  memory.oom_kill_all_tasks
> > +
> > +	A read-write single value file which exits on non-root
> 
> s/exits/exists/

Fixed. Thanks!

> 
> > +	cgroups.  The default is "0".
> > +
> > +	Defines whether the OOM killer should treat the cgroup
> > +	as a single entity during the victim selection.
> 
> Isn't this true independent of the memory.oom_kill_all_tasks setting?  
> The cgroup aware oom killer will consider memcg's as logical units when 
> deciding what to kill with or without memory.oom_kill_all_tasks, right?
> 
> I think you cover this fact in the cgroup aware oom killer section below 
> so this might result in confusion if described alongside a setting of
> memory.oom_kill_all_tasks.
> 
> > +
> > +	If set, OOM killer will kill all belonging tasks in
> > +	corresponding cgroup is selected as an OOM victim.
> 
> Maybe
> 
> "If set, the OOM killer will kill all threads attached to the memcg if 
> selected as an OOM victim."
> 
> is better?

Fixed to the following (to conform with core v2 concepts):
  If set, OOM killer will kill all processes attached to the cgroup
  if selected as an OOM victim.

> 
> > +
> > +	Be default, OOM killer respect /proc/pid/oom_score_adj value
> > +	-1000, and will never kill the task, unless oom_kill_all_tasks
> > +	is set.
> > +
> > +  memory.oom_priority
> > +
> > +	A read-write single value file which exits on non-root
> 
> s/exits/exists/

Fixed.

> 
> > +	cgroups.  The default is "0".
> > +
> > +	An integer number within the [-10000, 10000] range,
> > +	which defines the order in which the OOM killer selects victim
> > +	memory cgroups.
> > +
> > +	OOM killer prefers memory cgroups with larger priority if they
> > +	are populated with elegible tasks.
> 
> s/elegible/eligible/

Fixed.

> 
> > +
> > +	The oom_priority value is compared within sibling cgroups.
> > +
> > +	The root cgroup has the oom_priority 0, which cannot be changed.
> > +
> >    memory.events
> >  	A read-only flat-keyed file which exists on non-root cgroups.
> >  	The following entries are defined.  Unless specified
> > @@ -1206,6 +1238,36 @@ POSIX_FADV_DONTNEED to relinquish the ownership of memory areas
> >  belonging to the affected files to ensure correct memory ownership.
> >  
> >  
> > +Cgroup-aware OOM Killer
> > +~~~~~~~~~~~~~~~~~~~~~~~
> > +
> > +Cgroup v2 memory controller implements a cgroup-aware OOM killer.
> > +It means that it treats memory cgroups as first class OOM entities.
> > +
> > +Under OOM conditions the memory controller tries to make the best
> > +choise of a victim, hierarchically looking for the largest memory
> > +consumer. By default, it will look for the biggest task in the
> > +biggest leaf cgroup.
> > +
> > +Be default, all cgroups have oom_priority 0, and OOM killer will
> > +chose the largest cgroup recursively on each level. For non-root
> > +cgroups it's possible to change the oom_priority, and it will cause
> > +the OOM killer to look athe the priority value first, and compare
> > +sizes only of cgroups with equal priority.
> 
> Maybe some description of "largest" would be helpful here?  I think you 
> could briefly describe what is accounted for in the decisionmaking.

I'm afraid that it's too implementation-defined to be described.
Do you have an idea, how to describe it without going too much into details?

> s/athe/at the/

Fixed.

> 
> Reading through this, it makes me wonder if doing s/cgroup/memcg/ over 
> most of it would be better.

I don't think memcg is a good user term, but I agree, that it's necessary
to highlight the fact that a user should enable memory controller to get
this functionality.
Added a corresponding note.

Thanks!

Roman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
