Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 80C856B005A
	for <linux-mm@kvack.org>; Thu, 29 Nov 2012 08:29:00 -0500 (EST)
Date: Thu, 29 Nov 2012 14:28:54 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH] memcg: do not check for mm in mem_cgroup_count_vm_event
 disabled
Message-ID: <20121129132854.GB27887@dhcp22.suse.cz>
References: <alpine.DEB.2.00.1211191741060.24618@chino.kir.corp.google.com>
 <20121120134932.055bc192.akpm@linux-foundation.org>
 <20121121083505.GA8761@dhcp22.suse.cz>
 <alpine.LNX.2.00.1211281509560.15410@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.1211281509560.15410@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org

On Wed 28-11-12 15:29:30, Hugh Dickins wrote:
> On Wed, 21 Nov 2012, Michal Hocko wrote:
> > On Tue 20-11-12 13:49:32, Andrew Morton wrote:
> > > On Mon, 19 Nov 2012 17:44:34 -0800 (PST)
> > > David Rientjes <rientjes@google.com> wrote:
[...]
> > > > -void mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_item idx);
> > > > +void __mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_item idx);
> > > > +static inline void mem_cgroup_count_vm_event(struct mm_struct *mm,
> > > > +					     enum vm_event_item idx)
> > > > +{
> > > > +	if (mem_cgroup_disabled() || !mm)
> > > > +		return;
> > > > +	__mem_cgroup_count_vm_event(mm, idx);
> > > > +}
> > > 
> > > Does the !mm case occur frequently enough to justify inlining it, or
> > > should that test remain out-of-line?
> > 
> > Now that you've asked about it I started looking around and I cannot see
> > how mm can ever be NULL. The condition is there since the very beginning
> > (456f998e memcg: add the pagefault count into memcg stats) but all the
> > callers are page fault handlers and those shouldn't have mm==NULL.
> > Or is there anything obvious I am missing?
> > 
> > Ying, the whole thread starts https://lkml.org/lkml/2012/11/19/545 but
> > the primary question is why we need !mm test for mem_cgroup_count_vm_event
> > at all.
> 
> Here's a guess: as Ying's 456f998e patch started out in akpm's tree,
> shmem.c was calling mem_cgroup_count_vm_event(current->mm, PGMAJFAULT).
> 
> Then I insisted that was inconsistent with how we usually account when
> one task touches another's address space, and rearranged it to work on
> vma->vm_mm instead.

Thanks Hugh!
 
> Done the original way, if the touching task were a kernel daemon (KSM's
> ksmd comes to my mind), then the current->mm could well have been NULL.
> 
> I agree with you that it looks redundant now.

Andrew could you please pick this up?
---
