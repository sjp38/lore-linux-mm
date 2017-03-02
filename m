Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 462186B0038
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 09:01:13 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id u48so29025508wrc.0
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 06:01:13 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id 191si11176066wmp.56.2017.03.02.06.01.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Mar 2017 06:01:11 -0800 (PST)
Date: Thu, 2 Mar 2017 09:01:01 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH V5 6/6] proc: show MADV_FREE pages info in smaps
Message-ID: <20170302140101.GA16021@cmpxchg.org>
References: <cover.1487965799.git.shli@fb.com>
 <89efde633559de1ec07444f2ef0f4963a97a2ce8.1487965799.git.shli@fb.com>
 <20170301133624.GF1124@dhcp22.suse.cz>
 <20170301183149.GA14277@cmpxchg.org>
 <20170301185735.GA24905@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170301185735.GA24905@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Shaohua Li <shli@fb.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kernel-team@fb.com, minchan@kernel.org, hughd@google.com, riel@redhat.com, mgorman@techsingularity.net, akpm@linux-foundation.org

On Wed, Mar 01, 2017 at 07:57:35PM +0100, Michal Hocko wrote:
> On Wed 01-03-17 13:31:49, Johannes Weiner wrote:
> > On Wed, Mar 01, 2017 at 02:36:24PM +0100, Michal Hocko wrote:
> > > @@ -474,7 +474,7 @@ static int madvise_free_single_vma(struct vm_area_struct *vma,
> > >  	madvise_free_page_range(&tlb, vma, start, end);
> > >  	mmu_notifier_invalidate_range_end(mm, start, end);
> > >  	tlb_finish_mmu(&tlb, start, end);
> > > -
> > > +	lru_add_drain_all();
> > 
> > A full drain on all CPUs is very expensive and IMO not justified for
> > some per-cpu fuzz factor in the stats. I'd take hampering the stats
> > over hampering the syscall any day; only a subset of MADV_FREE users
> > will look at the stats.
> > 
> > And while the aggregate error can be large on machines with many CPUs
> > (notably the machines on which you absolutely don't want to send IPIs
> > to all cores each time a thread madvises some pages!),
> 
> I am not sure I understand. Where would we trigger IPIs?
> lru_add_drain_all relies on workqueus.

Brainfart on my end, s,IPIs,sync work items,.

That doesn't change my point, though. These things are expensive, and
we had scalability issues with them in the past. See for example
4dd72b4a47a5 ("mm: fadvise: avoid expensive remote LRU cache draining
after FADV_DONTNEED").

> > the pages of a
> > single process are not likely to be spread out across more than a few
> > CPUs.
> 
> Then we can simply only flushe lru_lazyfree_pvecs which should reduce
> the unrelated noise from other pagevecs.

The problem isn't flushing other pagevecs once we're already scheduled
on a CPU, the problem is scheduling work on all cpus and then waiting
for completion.

> > The error when reading a specific smaps should be completely ok.
> > 
> > In numbers: even if your process is madvising from 16 different CPUs,
> > the error in its smaps file will peak at 896K in the worst case. That
> > level of concurrency tends to come with much bigger memory quantities
> > for that amount of error to matter.
> 
> It is still an unexpected behavior IMHO and an implementation detail
> which leaks to the userspace.

We have per-cpu fuzz in every single vmstat counter. Look at
calculate_normal_threshold() in vmstat.c and the sample thresholds for
when per-cpu deltas are flushed. In the vast majority of machines, the
per-cpu error in these counters is much higher than what we get with
pagevecs holding back a few pages.

It's not that I think you're wrong: it *is* an implementation detail.
But we take a bit of incoherency from batching all over the place, so
it's a little odd to take a stand over this particular instance of it
- whether demanding that it'd be fixed, or be documented, which would
only suggest to users that this is special when it really isn't etc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
