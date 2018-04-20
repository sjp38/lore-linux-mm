Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0D1986B0005
	for <linux-mm@kvack.org>; Fri, 20 Apr 2018 13:21:53 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id k27-v6so9249284wre.23
        for <linux-mm@kvack.org>; Fri, 20 Apr 2018 10:21:53 -0700 (PDT)
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id w35si3711840edw.206.2018.04.20.10.21.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Apr 2018 10:21:51 -0700 (PDT)
Date: Fri, 20 Apr 2018 18:20:45 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH 1/2] mm: introduce memory.min
Message-ID: <20180420172039.GA4965@castle.DHCP.thefacebook.com>
References: <20180420163632.3978-1-guro@fb.com>
 <527af98a-8d7f-42ab-9ba8-71444ef7e25f@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <527af98a-8d7f-42ab-9ba8-71444ef7e25f@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, kernel-team@fb.com, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tejun Heo <tj@kernel.org>

On Fri, Apr 20, 2018 at 10:01:04AM -0700, Randy Dunlap wrote:
> On 04/20/18 09:36, Roman Gushchin wrote:
> 
> > ---
> >  Documentation/cgroup-v2.txt  | 20 +++++++++
> >  include/linux/memcontrol.h   | 15 ++++++-
> >  include/linux/page_counter.h | 11 ++++-
> >  mm/memcontrol.c              | 99 ++++++++++++++++++++++++++++++++++++--------
> >  mm/page_counter.c            | 63 ++++++++++++++++++++--------
> >  mm/vmscan.c                  | 19 ++++++++-
> >  6 files changed, 189 insertions(+), 38 deletions(-)
> > 
> > diff --git a/Documentation/cgroup-v2.txt b/Documentation/cgroup-v2.txt
> > index 657fe1769c75..49c846020f96 100644
> > --- a/Documentation/cgroup-v2.txt
> > +++ b/Documentation/cgroup-v2.txt
> > @@ -1002,6 +1002,26 @@ PAGE_SIZE multiple when read back.
> >  	The total amount of memory currently being used by the cgroup
> >  	and its descendants.
> >  
> > +  memory.min
> > +	A read-write single value file which exists on non-root
> > +	cgroups.  The default is "0".
> > +
> > +	Hard memory protection.  If the memory usage of a cgroup
> > +	is within its effectife min boundary, the cgroup's memory
> 
> 	              effective
> 
> > +	won't be reclaimed under any conditions. If there is no
> > +	unprotected reclaimable memory available, OOM killer
> > +	is invoked.
> > +
> > +	Effective low boundary is limited by memory.min values of
> > +	all ancestor cgroups. If there is memory.mn overcommitment
> 
> 	                                  memory.min ? overcommit
> 
> > +	(child cgroup or cgroups are requiring more protected memory,
> 
> 	                                          drop ending ','  ^^
> 
> > +	than parent will allow), then each child cgroup will get
> > +	the part of parent's protection proportional to the its
> 
> 	                                             to its
> 
> > +	actual memory usage below memory.min.
> > +
> > +	Putting more memory than generally available under this
> > +	protection is discouraged and may lead to constant OOMs.
> > +
> >    memory.low
> >  	A read-write single value file which exists on non-root
> >  	cgroups.  The default is "0".
> 
> 
> -- 
> ~Randy


Hi, Randy!

An updated version below.

Thanks!

------------------------------------------------------------
