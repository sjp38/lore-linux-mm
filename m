Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 2A1D3900137
	for <linux-mm@kvack.org>; Fri,  2 Sep 2011 09:34:51 -0400 (EDT)
Date: Fri, 2 Sep 2011 14:34:43 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 2/3] compaction: compact unevictable page
Message-ID: <20110902133443.GO14369@suse.de>
References: <cover.1321112552.git.minchan.kim@gmail.com>
 <8ef02605a7a76b176167d90a285033afa8513326.1321112552.git.minchan.kim@gmail.com>
 <20110831111954.GB17512@redhat.com>
 <20110831144150.GA1860@barrios-desktop>
 <20110901140254.GH14369@suse.de>
 <CAEwNFnCmZ5tJ2Fy9Qt8=GBZN2=YhrX4ZiWmMPx0mAVXtvZj_Pg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAEwNFnCmZ5tJ2Fy9Qt8=GBZN2=YhrX4ZiWmMPx0mAVXtvZj_Pg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Johannes Weiner <jweiner@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>

On Fri, Sep 02, 2011 at 01:48:54PM +0900, Minchan Kim wrote:
> On Thu, Sep 1, 2011 at 11:02 PM, Mel Gorman <mgorman@suse.de> wrote:
> > On Wed, Aug 31, 2011 at 11:41:50PM +0900, Minchan Kim wrote:
> >> On Wed, Aug 31, 2011 at 01:19:54PM +0200, Johannes Weiner wrote:
> >> > On Sun, Nov 13, 2011 at 01:37:42AM +0900, Minchan Kim wrote:
> >> > > Now compaction doesn't handle mlocked page as it uses __isolate_lru_page
> >> > > which doesn't consider unevicatable page. It has been used by just lumpy so
> >> > > it was pointless that it isolates unevictable page. But the situation is
> >> > > changed. Compaction could handle unevictable page and it can help getting
> >> > > big contiguos pages in fragment memory by many pinned page with mlock.
> >> >
> >> > This may result in applications unexpectedly faulting and waiting on
> >> > mlocked pages under migration.  I wonder how realtime people feel
> >> > about that?
> >>
> >> I didn't consider it but it's very important point.
> >> The migrate_page can call pageout on dirty page so RT process could wait on the
> >> mlocked page during very long time.
> >
> > On the plus side, the filesystem that is likely to suffer from this
> > is btrfs. The other important cases avoid the writeout.
> 
> You mean only btrfs does write in reclaim context?

In compaction context. It ultimately uses fallback_migrate_page
because btrfs_extent_io_ops lacks a migratepage hook.

> >> I can mitigate it with isolating mlocked page in case of !sync but still we can't
> >> guarantee the time because we can't know how many vmas point the page so that try_to_unmap
> >> could spend lots of time.
> >>
> >
> > This loss of guarantee arguably violates POSIX 1B as part of the
> > real-time extension. The wording is "The function mlock shall cause
> > those whole pages containing any part of the address space of the
> > process starting at address addr and continuing for len bytes to be
> > memory resident until unlocked or until the process exits or execs
> > another process image."
> >
> > It defines locking as "memory locking guarantees the residence of
> > portions of the address space. It is implementation defined whether
> > locking memory guarantees fixed translation between virtual addresses
> > (as seen by the process) and physical addresses."
> >
> > As it's up to the implementation whether to preserve the physical
> > page mapping, it's allowed for compaction to move that page. However,
> > as it mlock is recommended for use by time-critical applications,
> > I fear we would be breaking developer expectations on the behaviour
> > of mlock even if it is permitted by POSIX.
> 
> Agree.
> 
> >
> >> We can think it's a trade off between high order allocation VS RT latency.
> >> Now I am biasing toward RT latency as considering mlock man page.
> >>
> >> Any thoughts?
> >>
> >
> > At the very least it should not be the default behaviour. I do not have
> > suggestions on how it could be enabled though. It's a bit obscure to
> > have as a kernel parameter or even a proc tunable and it's not a perfect
> > for /sys/kernel/mm/transparent_hugepage/defrag either.
> >
> > How big of a problem is it that mlocked pages are not compacted at the
> > moment?
> 
> I found it by just code review and didn't see any reports about that.
> But it is quite possible that someone calls mlock with small request sparsely.

This is done for security-sensitive applications to avoid any
possibility that information would leak to swap by accident. Consider
for example a gpg passphrase being written to swap. It's why users are
allowed to mlock a very small amount of memory.

I would expect these pages to only be locked for a very short time.

> And logically, compaction could be a feature to solve it if user
> endures the pain.
> (But still, I am not sure how many of user on mlock can bear it)
> 
> We can solve a bit that by another approach if it's really problem
> with RT processes. The another approach is to separate mlocked pages
> with allocation time like below pseudo patch which just show the
> concept)
> 
> ex)
> diff --git a/include/linux/highmem.h b/include/linux/highmem.h
> index 3a93f73..8ae2e60 100644
> --- a/include/linux/highmem.h
> +++ b/include/linux/highmem.h
> @@ -175,7 +175,8 @@ static inline struct page *
>  alloc_zeroed_user_highpage_movable(struct vm_area_struct *vma,
>                                         unsigned long vaddr)
>  {
> -       return __alloc_zeroed_user_highpage(__GFP_MOVABLE, vma, vaddr);
> +       gfp_t gfp_flag = vma->vm_flags & VM_LCOKED ? 0 : __GFP_MOVABLE;
> +       return __alloc_zeroed_user_highpage(gfp_flag, vma, vaddr);
>  }
> 
> But it's a solution about newly allocated page on mlocked vma.
> Old pages in the VMA is still a problem.

Agreed, and because of this, I think it would only help a small number
of cases.

> We can solve it at mlock system call through migrating the pages to
> UNMOVABLE block.
> 

That's an interesting proposal.

> What we need is just VOC. Who know there are such systems which call
> mlock call frequently with small pages?

The security-sensitive applications are the only ones I know of that
mlock small amounts but the locking is very short-lived. I'm not aware
of other examples.

> If any customer doesn't require it strongly, I can drop this patch.
> 

I'm not aware of anyone suffering from this problem. However, in the
even we find such a case, I like your proposal of migrating pages to
UNMOVABLE blocks at mlock() time as a solution.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
