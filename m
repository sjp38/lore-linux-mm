Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id A99D36B0081
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 01:24:47 -0400 (EDT)
Received: by dakp5 with SMTP id p5so7712617dak.14
        for <linux-mm@kvack.org>; Mon, 25 Jun 2012 22:24:47 -0700 (PDT)
Date: Mon, 25 Jun 2012 22:24:44 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 09/11] memcg: propagate kmem limiting information to
 children
In-Reply-To: <20120625162352.51997c5a.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.1206252224350.30072@chino.kir.corp.google.com>
References: <1340633728-12785-1-git-send-email-glommer@parallels.com> <1340633728-12785-10-git-send-email-glommer@parallels.com> <20120625162352.51997c5a.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Glauber Costa <glommer@parallels.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Frederic Weisbecker <fweisbec@gmail.com>, Pekka Enberg <penberg@kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, devel@openvz.org, kamezawa.hiroyu@jp.fujitsu.com, Tejun Heo <tj@kernel.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Suleiman Souhlal <suleiman@google.com>

On Mon, 25 Jun 2012, Andrew Morton wrote:

> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -287,7 +287,11 @@ struct mem_cgroup {
> >  	 * Should the accounting and control be hierarchical, per subtree?
> >  	 */
> >  	bool use_hierarchy;
> > -	bool kmem_accounted;
> > +	/*
> > +	 * bit0: accounted by this cgroup
> > +	 * bit1: accounted by a parent.
> > +	 */
> > +	volatile unsigned long kmem_accounted;
> 
> I suggest
> 
> 	unsigned long kmem_accounted;	/* See KMEM_ACCOUNTED_*, below */
> 
> >  	bool		oom_lock;
> >  	atomic_t	under_oom;
> > @@ -340,6 +344,9 @@ struct mem_cgroup {
> >  #endif
> >  };
> >  
> > +#define KMEM_ACCOUNTED_THIS	0
> > +#define KMEM_ACCOUNTED_PARENT	1
> 
> And then document the fields here.
> 

In hex, please?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
