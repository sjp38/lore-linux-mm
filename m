Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id A96C56B0601
	for <linux-mm@kvack.org>; Thu, 10 May 2018 09:08:30 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id z7-v6so1347014wrg.11
        for <linux-mm@kvack.org>; Thu, 10 May 2018 06:08:30 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id k13-v6si987589edl.323.2018.05.10.06.08.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 May 2018 06:08:29 -0700 (PDT)
Date: Thu, 10 May 2018 14:08:04 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH v3 2/2] mm: ignore memory.min of abandoned memory cgroups
Message-ID: <20180510130758.GA9129@castle.DHCP.thefacebook.com>
References: <20180503114358.7952-1-guro@fb.com>
 <20180503114358.7952-2-guro@fb.com>
 <20180503173835.GA28437@cmpxchg.org>
 <20180509180734.GA4856@castle.DHCP.thefacebook.com>
 <20180509153805.2a940eac8c858398fb0f4b0c@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20180509153805.2a940eac8c858398fb0f4b0c@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tejun Heo <tj@kernel.org>

On Wed, May 09, 2018 at 03:38:05PM -0700, Andrew Morton wrote:
> > 
> > Memory controller implements the memory.low best-effort memory
> > protection mechanism, which works perfectly in many cases and
> > allows protecting working sets of important workloads from
> > sudden reclaim.
> > 
> > But its semantics has a significant limitation: it works
> > only as long as there is a supply of reclaimable memory.
> > This makes it pretty useless against any sort of slow memory
> > leaks or memory usage increases. This is especially true
> > for swapless systems. If swap is enabled, memory soft protection
> > effectively postpones problems, allowing a leaking application
> > to fill all swap area, which makes no sense.
> > The only effective way to guarantee the memory protection
> > in this case is to invoke the OOM killer.
> > 
> > It's possible to handle this case in userspace by reacting
> > on MEMCG_LOW events; but there is still a place for a fail-safe
> > in-kernel mechanism to provide stronger guarantees.
> > 
> > This patch introduces the memory.min interface for cgroup v2
> > memory controller. It works very similarly to memory.low
> > (sharing the same hierarchical behavior), except that it's
> > not disabled if there is no more reclaimable memory in the system.
> > 
> > If cgroup is not populated, its memory.min is ignored,
> > because otherwise even the OOM killer wouldn't be able
> > to reclaim the protected memory, and the system can stall.
> > 
> > ...
> >
> > --- a/Documentation/cgroup-v2.txt
> > +++ b/Documentation/cgroup-v2.txt
> > @@ -1002,6 +1002,29 @@ PAGE_SIZE multiple when read back.
> >  	The total amount of memory currently being used by the cgroup
> >  	and its descendants.
> >  
> > +  memory.min
> > +	A read-write single value file which exists on non-root
> > +	cgroups.  The default is "0".
> > +
> > +	Hard memory protection.  If the memory usage of a cgroup
> > +	is within its effective min boundary, the cgroup's memory
> > +	won't be reclaimed under any conditions. If there is no
> > +	unprotected reclaimable memory available, OOM killer
> > +	is invoked.
> > +
> > +	Effective low boundary is limited by memory.min values of
> > +	all ancestor cgroups. If there is memory.min overcommitment
> > +	(child cgroup or cgroups are requiring more protected memory
> > +	than parent will allow), then each child cgroup will get
> > +	the part of parent's protection proportional to its
> > +	actual memory usage below memory.min.
> > +
> > +	Putting more memory than generally available under this
> > +	protection is discouraged and may lead to constant OOMs.
> > +
> > +	If a memory cgroup is not populated with processes,
> > +	its memory.min is ignored.

Hello, Andrew!

> This is a copy-paste-edit of the memory.low description.  Could we
> please carefully check that it all remains accurate?  Should "Effective
> low boundary" be "Effective min boundary"?  Does overcommit still apply
> to .min?  etcetera.

Except this s/low/min replacement (good catch, thank you! diff below),
the rest looks fine to me. Memory.min and memory.low are similar
in their hierarchical behavior, so most of the things still apply to .min.

Also, can you, please, add
Reviewed-by: Randy Dunlap <rdunlap@infradead.org>
(which was accidentally lost between versions).

Thanks you!

--

diff --git a/Documentation/cgroup-v2.txt b/Documentation/cgroup-v2.txt
index 1764a627a120..f6725628bb4f 100644
--- a/Documentation/cgroup-v2.txt
+++ b/Documentation/cgroup-v2.txt
@@ -1012,7 +1012,7 @@ PAGE_SIZE multiple when read back.
        unprotected reclaimable memory available, OOM killer
        is invoked.
 
-       Effective low boundary is limited by memory.min values of
+       Effective min boundary is limited by memory.min values of
        all ancestor cgroups. If there is memory.min overcommitment
        (child cgroup or cgroups are requiring more protected memory
        than parent will allow), then each child cgroup will get
