Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 432746B03A3
	for <linux-mm@kvack.org>; Mon, 10 Apr 2017 10:17:41 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id t189so3041489wmt.9
        for <linux-mm@kvack.org>; Mon, 10 Apr 2017 07:17:41 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id n33si21516836wrb.159.2017.04.10.07.17.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Apr 2017 07:17:39 -0700 (PDT)
Date: Mon, 10 Apr 2017 10:17:34 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 2/4] mm: memcontrol: re-use global VM event enum
Message-ID: <20170410141734.GB16119@cmpxchg.org>
References: <20170404220148.28338-1-hannes@cmpxchg.org>
 <20170404220148.28338-2-hannes@cmpxchg.org>
 <20170406084923.GB2268@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170406084923.GB2268@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Thu, Apr 06, 2017 at 11:49:24AM +0300, Vladimir Davydov wrote:
> On Tue, Apr 04, 2017 at 06:01:46PM -0400, Johannes Weiner wrote:
> > The current duplication is a high-maintenance mess, and it's painful
> > to add new items.
> > 
> > This increases the size of the event array, but we'll eventually want
> > most of the VM events tracked on a per-cgroup basis anyway.
> > 
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> 
> Although the increase in the mem_cgroup struct introduced by this patch
> looks scary, I agree this is a reasonable step toward unification of
> vmstat, as most vm_even_item entries do make sense to be accounted per
> cgroup as well.
> 
> Acked-by: Vladimir Davydov <vdavydov.dev@gmail.com>

Thanks!

> > @@ -608,9 +601,9 @@ static void mem_cgroup_charge_statistics(struct mem_cgroup *memcg,
> >  
> >  	/* pagein of a big page is an event. So, ignore page size */
> >  	if (nr_pages > 0)
> > -		__this_cpu_inc(memcg->stat->events[MEM_CGROUP_EVENTS_PGPGIN]);
> > +		__this_cpu_inc(memcg->stat->events[PGPGIN]);
> >  	else {
> > -		__this_cpu_inc(memcg->stat->events[MEM_CGROUP_EVENTS_PGPGOUT]);
> > +		__this_cpu_inc(memcg->stat->events[PGPGOUT]);
> >  		nr_pages = -nr_pages; /* for event */
> >  	}
> 
> AFAIR this doesn't exactly match system-wide PGPGIN/PGPGOUT: they are
> supposed to account only paging events involving IO while currently they
> include faulting in zero pages and zapping a process address space.
> Probably, this should be revised before rolling out to cgroup v2.

Yeah, that stat item doesn't make much sense in cgroup1. Cgroup2
doesn't export it at all right now. Should we export it in the future,
we can add special MEMCG1_PGPGIN_SILLY events and let cgroup2 use the
real thing. Or remove/fix the stats in cgroup1, because I cannot think
how this would be useful at all right now, anyway.

But it's ooold behavior, so no urgency to tackle this right now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
