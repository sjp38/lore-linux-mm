Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5AF336B038A
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 02:39:55 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id j5so74619042pfb.3
        for <linux-mm@kvack.org>; Wed, 01 Mar 2017 23:39:55 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id 1si6744256plh.210.2017.03.01.23.39.53
        for <linux-mm@kvack.org>;
        Wed, 01 Mar 2017 23:39:54 -0800 (PST)
Date: Thu, 2 Mar 2017 16:39:47 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH V5 6/6] proc: show MADV_FREE pages info in smaps
Message-ID: <20170302073947.GA32690@bbox>
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
Cc: Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@fb.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kernel-team@fb.com, hughd@google.com, riel@redhat.com, mgorman@techsingularity.net, akpm@linux-foundation.org

On Wed, Mar 01, 2017 at 07:57:35PM +0100, Michal Hocko wrote:
> On Wed 01-03-17 13:31:49, Johannes Weiner wrote:
> > On Wed, Mar 01, 2017 at 02:36:24PM +0100, Michal Hocko wrote:
> > > On Fri 24-02-17 13:31:49, Shaohua Li wrote:
> > > > show MADV_FREE pages info of each vma in smaps. The interface is for
> > > > diganose or monitoring purpose, userspace could use it to understand
> > > > what happens in the application. Since userspace could dirty MADV_FREE
> > > > pages without notice from kernel, this interface is the only place we
> > > > can get accurate accounting info about MADV_FREE pages.
> > > 
> > > I have just got to test this patchset and noticed something that was a
> > > bit surprising
> > > 
> > > madvise(mmap(len), len, MADV_FREE)
> > > Size:             102400 kB
> > > Rss:              102400 kB
> > > Pss:              102400 kB
> > > Shared_Clean:          0 kB
> > > Shared_Dirty:          0 kB
> > > Private_Clean:    102400 kB
> > > Private_Dirty:         0 kB
> > > Referenced:            0 kB
> > > Anonymous:        102400 kB
> > > LazyFree:         102368 kB
> > > 
> > > It took me a some time to realize that LazyFree is not accurate because
> > > there are still pages on the per-cpu lru_lazyfree_pvecs. I believe this
> > > is an implementation detail which shouldn't be visible to the userspace.
> > > Should we simply drain the pagevec? A crude way would be to simply
> > > lru_add_drain_all after we are done with the given range. We can also
> > > make this lru_lazyfree_pvecs specific but I am not sure this is worth
> > > the additional code.
> > > ---
> > > diff --git a/mm/madvise.c b/mm/madvise.c
> > > index dc5927c812d3..d2c318db16c9 100644
> > > --- a/mm/madvise.c
> > > +++ b/mm/madvise.c
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
> 
> > the pages of a
> > single process are not likely to be spread out across more than a few
> > CPUs.
> 
> Then we can simply only flushe lru_lazyfree_pvecs which should reduce
> the unrelated noise from other pagevecs.
> 
> > The error when reading a specific smaps should be completely ok.
> > 
> > In numbers: even if your process is madvising from 16 different CPUs,
> > the error in its smaps file will peak at 896K in the worst case. That
> > level of concurrency tends to come with much bigger memory quantities
> > for that amount of error to matter.
> 
> It is still an unexpected behavior IMHO and an implementation detail
> which leaks to the userspace.
>  
> > IMO this is a non-issue.
> 
> I will not insist if there is a general consensus on this and it is a
> documented behavior, though. 

We cannot gurantee with that even draining because madvise_free can
miss some of pages easily with several conditions.
First of all, userspace can never know how many of pages are mapped
in there at the moment. As well, one of page in the range can be
swapped out or is going migrating, fail to try_lockpage and so on.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
