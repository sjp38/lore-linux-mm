Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id B91936B0074
	for <linux-mm@kvack.org>; Wed, 28 Nov 2012 18:29:29 -0500 (EST)
Received: by mail-qc0-f169.google.com with SMTP id t2so12790401qcq.14
        for <linux-mm@kvack.org>; Wed, 28 Nov 2012 15:29:28 -0800 (PST)
Date: Wed, 28 Nov 2012 15:29:30 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [patch] mm, memcg: avoid unnecessary function call when memcg
 is disabled
In-Reply-To: <20121121083505.GA8761@dhcp22.suse.cz>
Message-ID: <alpine.LNX.2.00.1211281509560.15410@eggly.anvils>
References: <alpine.DEB.2.00.1211191741060.24618@chino.kir.corp.google.com> <20121120134932.055bc192.akpm@linux-foundation.org> <20121121083505.GA8761@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ying Han <yinghan@google.com>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org

On Wed, 21 Nov 2012, Michal Hocko wrote:
> On Tue 20-11-12 13:49:32, Andrew Morton wrote:
> > On Mon, 19 Nov 2012 17:44:34 -0800 (PST)
> > David Rientjes <rientjes@google.com> wrote:
> > 
> > > While profiling numa/core v16 with cgroup_disable=memory on the command 
> > > line, I noticed mem_cgroup_count_vm_event() still showed up as high as 
> > > 0.60% in perftop.
> > > 
> > > This occurs because the function is called extremely often even when memcg 
> > > is disabled.
> > > 
> > > To fix this, inline the check for mem_cgroup_disabled() so we avoid the 
> > > unnecessary function call if memcg is disabled.
> > > 
> > > ...
> > >
> > > diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> > > --- a/include/linux/memcontrol.h
> > > +++ b/include/linux/memcontrol.h
> > > @@ -181,7 +181,14 @@ unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
> > >  						gfp_t gfp_mask,
> > >  						unsigned long *total_scanned);
> > >  
> > > -void mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_item idx);
> > > +void __mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_item idx);
> > > +static inline void mem_cgroup_count_vm_event(struct mm_struct *mm,
> > > +					     enum vm_event_item idx)
> > > +{
> > > +	if (mem_cgroup_disabled() || !mm)
> > > +		return;
> > > +	__mem_cgroup_count_vm_event(mm, idx);
> > > +}
> > 
> > Does the !mm case occur frequently enough to justify inlining it, or
> > should that test remain out-of-line?
> 
> Now that you've asked about it I started looking around and I cannot see
> how mm can ever be NULL. The condition is there since the very beginning
> (456f998e memcg: add the pagefault count into memcg stats) but all the
> callers are page fault handlers and those shouldn't have mm==NULL.
> Or is there anything obvious I am missing?
> 
> Ying, the whole thread starts https://lkml.org/lkml/2012/11/19/545 but
> the primary question is why we need !mm test for mem_cgroup_count_vm_event
> at all.

Here's a guess: as Ying's 456f998e patch started out in akpm's tree,
shmem.c was calling mem_cgroup_count_vm_event(current->mm, PGMAJFAULT).

Then I insisted that was inconsistent with how we usually account when
one task touches another's address space, and rearranged it to work on
vma->vm_mm instead.

Done the original way, if the touching task were a kernel daemon (KSM's
ksmd comes to my mind), then the current->mm could well have been NULL.

I agree with you that it looks redundant now.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
