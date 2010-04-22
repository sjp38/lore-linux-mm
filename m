Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7A81D6B01F4
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 12:14:09 -0400 (EDT)
Date: Thu, 22 Apr 2010 17:13:47 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 04/14] mm,migration: Allow the migration of
	PageSwapCache pages
Message-ID: <20100422161347.GF30306@csn.ul.ie>
References: <20100421153421.GM30306@csn.ul.ie> <alpine.DEB.2.00.1004211038020.4959@router.home> <20100422092819.GR30306@csn.ul.ie> <20100422184621.0aaaeb5f.kamezawa.hiroyu@jp.fujitsu.com> <x2l28c262361004220313q76752366l929a8959cd6d6862@mail.gmail.com> <20100422193106.9ffad4ec.kamezawa.hiroyu@jp.fujitsu.com> <20100422195153.d91c1c9e.kamezawa.hiroyu@jp.fujitsu.com> <20100422141404.GA30306@csn.ul.ie> <p2y28c262361004220718m3a5e3e2ekee1fef7ebdae8e73@mail.gmail.com> <20100422154003.GC30306@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20100422154003.GC30306@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 22, 2010 at 04:40:03PM +0100, Mel Gorman wrote:
> On Thu, Apr 22, 2010 at 11:18:14PM +0900, Minchan Kim wrote:
> > On Thu, Apr 22, 2010 at 11:14 PM, Mel Gorman <mel@csn.ul.ie> wrote:
> > > On Thu, Apr 22, 2010 at 07:51:53PM +0900, KAMEZAWA Hiroyuki wrote:
> > >> On Thu, 22 Apr 2010 19:31:06 +0900
> > >> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > >>
> > >> > On Thu, 22 Apr 2010 19:13:12 +0900
> > >> > Minchan Kim <minchan.kim@gmail.com> wrote:
> > >> >
> > >> > > On Thu, Apr 22, 2010 at 6:46 PM, KAMEZAWA Hiroyuki
> > >> > > <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > >> >
> > >> > > > Hmm..in my test, the case was.
> > >> > > >
> > >> > > > Before try_to_unmap:
> > >> > > >        mapcount=1, SwapCache, remap_swapcache=1
> > >> > > > After remap
> > >> > > >        mapcount=0, SwapCache, rc=0.
> > >> > > >
> > >> > > > So, I think there may be some race in rmap_walk() and vma handling or
> > >> > > > anon_vma handling. migration_entry isn't found by rmap_walk.
> > >> > > >
> > >> > > > Hmm..it seems this kind patch will be required for debug.
> > >> > >
> > >>
> > >> Ok, here is my patch for _fix_. But still testing...
> > >> Running well at least for 30 minutes, where I can see bug in 10minutes.
> > >> But this patch is too naive. please think about something better fix.
> > >>
> > >> ==
> > >> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > >>
> > >> At adjust_vma(), vma's start address and pgoff is updated under
> > >> write lock of mmap_sem. This means the vma's rmap information
> > >> update is atoimic only under read lock of mmap_sem.
> > >>
> > >>
> > >> Even if it's not atomic, in usual case, try_to_ummap() etc...
> > >> just fails to decrease mapcount to be 0. no problem.
> > >>
> > >> But at page migration's rmap_walk(), it requires to know all
> > >> migration_entry in page tables and recover mapcount.
> > >>
> > >> So, this race in vma's address is critical. When rmap_walk meet
> > >> the race, rmap_walk will mistakenly get -EFAULT and don't call
> > >> rmap_one(). This patch adds a lock for vma's rmap information.
> > >> But, this is _very slow_.
> > >
> > > Ok wow. That is exceptionally well-spotted. This looks like a proper bug
> > > that compaction exposes as opposed to a bug that compaction introduces.
> > >
> > >> We need something sophisitcated, light-weight update for this..
> > >>
> > >
> > > In the event the VMA is backed by a file, the mapping i_mmap_lock is taken for
> > > the duration of the update and is  taken elsewhere where the VMA information
> > > is read such as rmap_walk_file()
> > >
> > > In the event the VMA is anon, vma_adjust currently talks no locks and your
> > > patch introduces a new one but why not use the anon_vma lock here? Am I
> > > missing something that requires the new lock?
> > 
> > rmap_walk_anon doesn't hold vma's anon_vma->lock.
> > It holds page->anon_vma->lock.
> > 
> 
> Of course, thank you for pointing out my error. With multiple
> anon_vma's, the locking is a bit of a mess. We cannot hold spinlocks on
> two vma's in the same list at the same time without potentially causing
> a livelock.

Incidentally, I now belatedly see why Kamezawa introduced a new lock. I
assume it was to get around this mess.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
