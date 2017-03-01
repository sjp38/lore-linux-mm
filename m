Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id DC37D6B0038
	for <linux-mm@kvack.org>; Wed,  1 Mar 2017 13:31:58 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id v66so20120298wrc.4
        for <linux-mm@kvack.org>; Wed, 01 Mar 2017 10:31:58 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id m144si7937770wma.137.2017.03.01.10.31.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Mar 2017 10:31:56 -0800 (PST)
Date: Wed, 1 Mar 2017 13:31:49 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH V5 6/6] proc: show MADV_FREE pages info in smaps
Message-ID: <20170301183149.GA14277@cmpxchg.org>
References: <cover.1487965799.git.shli@fb.com>
 <89efde633559de1ec07444f2ef0f4963a97a2ce8.1487965799.git.shli@fb.com>
 <20170301133624.GF1124@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170301133624.GF1124@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Shaohua Li <shli@fb.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kernel-team@fb.com, minchan@kernel.org, hughd@google.com, riel@redhat.com, mgorman@techsingularity.net, akpm@linux-foundation.org

On Wed, Mar 01, 2017 at 02:36:24PM +0100, Michal Hocko wrote:
> On Fri 24-02-17 13:31:49, Shaohua Li wrote:
> > show MADV_FREE pages info of each vma in smaps. The interface is for
> > diganose or monitoring purpose, userspace could use it to understand
> > what happens in the application. Since userspace could dirty MADV_FREE
> > pages without notice from kernel, this interface is the only place we
> > can get accurate accounting info about MADV_FREE pages.
> 
> I have just got to test this patchset and noticed something that was a
> bit surprising
> 
> madvise(mmap(len), len, MADV_FREE)
> Size:             102400 kB
> Rss:              102400 kB
> Pss:              102400 kB
> Shared_Clean:          0 kB
> Shared_Dirty:          0 kB
> Private_Clean:    102400 kB
> Private_Dirty:         0 kB
> Referenced:            0 kB
> Anonymous:        102400 kB
> LazyFree:         102368 kB
> 
> It took me a some time to realize that LazyFree is not accurate because
> there are still pages on the per-cpu lru_lazyfree_pvecs. I believe this
> is an implementation detail which shouldn't be visible to the userspace.
> Should we simply drain the pagevec? A crude way would be to simply
> lru_add_drain_all after we are done with the given range. We can also
> make this lru_lazyfree_pvecs specific but I am not sure this is worth
> the additional code.
> ---
> diff --git a/mm/madvise.c b/mm/madvise.c
> index dc5927c812d3..d2c318db16c9 100644
> --- a/mm/madvise.c
> +++ b/mm/madvise.c
> @@ -474,7 +474,7 @@ static int madvise_free_single_vma(struct vm_area_struct *vma,
>  	madvise_free_page_range(&tlb, vma, start, end);
>  	mmu_notifier_invalidate_range_end(mm, start, end);
>  	tlb_finish_mmu(&tlb, start, end);
> -
> +	lru_add_drain_all();

A full drain on all CPUs is very expensive and IMO not justified for
some per-cpu fuzz factor in the stats. I'd take hampering the stats
over hampering the syscall any day; only a subset of MADV_FREE users
will look at the stats.

And while the aggregate error can be large on machines with many CPUs
(notably the machines on which you absolutely don't want to send IPIs
to all cores each time a thread madvises some pages!), the pages of a
single process are not likely to be spread out across more than a few
CPUs. The error when reading a specific smaps should be completely ok.

In numbers: even if your process is madvising from 16 different CPUs,
the error in its smaps file will peak at 896K in the worst case. That
level of concurrency tends to come with much bigger memory quantities
for that amount of error to matter.

IMO this is a non-issue.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
