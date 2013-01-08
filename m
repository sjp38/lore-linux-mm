Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 7B5B06B005A
	for <linux-mm@kvack.org>; Tue,  8 Jan 2013 03:38:55 -0500 (EST)
Date: Tue, 8 Jan 2013 17:38:53 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [patch]mm: make madvise(MADV_WILLNEED) support swap file prefetch
Message-ID: <20130108083853.GC4714@blaptop>
References: <20130107081237.GB21779@kernel.org>
 <20130107120630.82ba51ad.akpm@linux-foundation.org>
 <50eb8180.6887320a.3f90.58b0SMTPIN_ADDED_BROKEN@mx.google.com>
 <20130108042609.GA2459@kernel.org>
 <20130108053856.GA4714@blaptop>
 <20130108073229.GA9018@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130108073229.GA9018@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: Wanpeng Li <liwanp@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, hughd@google.com, riel@redhat.com

On Tue, Jan 08, 2013 at 03:32:29PM +0800, Shaohua Li wrote:
> On Tue, Jan 08, 2013 at 02:38:56PM +0900, Minchan Kim wrote:
> > Hi Shaohua,
> > 
> > On Tue, Jan 08, 2013 at 12:26:09PM +0800, Shaohua Li wrote:
> > > On Tue, Jan 08, 2013 at 10:16:07AM +0800, Wanpeng Li wrote:
> > > > On Mon, Jan 07, 2013 at 12:06:30PM -0800, Andrew Morton wrote:
> > > > >On Mon, 7 Jan 2013 16:12:37 +0800
> > > > >Shaohua Li <shli@kernel.org> wrote:
> > > > >
> > > > >> 
> > > > >> Make madvise(MADV_WILLNEED) support swap file prefetch. If memory is swapout,
> > > > >> this syscall can do swapin prefetch. It has no impact if the memory isn't
> > > > >> swapout.
> > > > >
> > > > >Seems sensible.
> > > > 
> > > > Hi Andrew and Shaohua,
> > > > 
> > > > What's the performance in the scenario of serious memory pressure? Since
> > > > in this case pages in swap are highly fragmented and cache hit is most
> > > > impossible. If WILLNEED path should add a check to skip readahead in
> > > > this case since swapin only leads to unnecessary memory allocation. 
> > > 
> > > pages in swap are not highly fragmented if you access memory sequentially. In
> > > that case, the pages you accessed will be added to lru list side by side. So if
> > > app does swap prefetch, we can do sequential disk access and merge small
> > > request to big one.
> > 
> > How can you make sure that the range of WILLNEED was always sequentially accesssed?
> 
> you can't guarantee this even for file access.

Indeed.

> 
> > > Another advantage is prefetch can drive high disk iodepth.  For sequential
> > 
> > What does it mean 'iodepth'? I failed to grep it in google. :(
> 
> io depth. How many requests are inflight at a givin time.

Thanks for the info!

> 
> > > access, this can cause big request. Even for random access, high iodepth has
> > > much better performance especially for SSD.
> > 
> > So you mean WILLNEED is always good in where both random and sequential in "SSD"?
> > Then, how about the "Disk"?
> 
> Hmm, even for hard disk, high iodepth random access is faster than single
> iodepth access. Today's disk is NCQ disk. But the speedup isn't that
> significant like a SSD. For sequential access, both harddisk and SSD have
> better performance with higher iodepth.
> 
> > Wanpeng's comment makes sense to me so I guess others can have a same question
> > about this patch. So it would be better to write your rationale in changelog.
> 
> I would, but the question is just like why app wants to prefetch file pages. I
> thought it's commonsense. The problem like memory allocation exists in file
> prefetch too. The advantages (better IO access, CPU and disk can operate in
> parallel and so on) apply for both file and swap prefetch.

Agreed. But I have a question about semantic of madvise(DONTNEED) of anon vma.
If Linux start to support it for anon, user can misunderstand it following as.

User might think we start to use anonymous pages in that range soon so he
gives the hint to kernel to map all pages of the range to page table in advance.
(ie, pre page fault like MAP_POPULATE) and if one of the page might be
swapped out, readahead it. What do you think about it?
For clarification, it would be better to add man page description with Ccing
man page maintainer.

> 
> prefetch should never be slower non-prefetch. That's another story if app is
> very wrong. we definitely don't need consider a wrong app. If the app doesn't
> know how to use the API, the app can just don't use it.

Fair enough.

> 
> Thanks,
> Shaohua
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
