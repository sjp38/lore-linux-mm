Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id F09FD6B0011
	for <linux-mm@kvack.org>; Wed,  4 May 2011 22:37:43 -0400 (EDT)
Date: Wed, 4 May 2011 22:37:15 -0400
From: Stephen Wilson <wilsons@start.ca>
Subject: Re: [PATCH 0/8] avoid allocation in show_numa_map()
Message-ID: <20110505023715.GA4569@fibrous.localdomain>
References: <1303947349-3620-1-git-send-email-wilsons@start.ca> <20110504161020.e2d0a7f2.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110504161020.e2d0a7f2.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Stephen Wilson <wilsons@start.ca>, Alexander Viro <viro@zeniv.linux.org.uk>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jeremy Fitzhardinge <jeremy@goop.org>

On Wed, May 04, 2011 at 04:10:20PM -0700, Andrew Morton wrote:
> On Wed, 27 Apr 2011 19:35:41 -0400
> Stephen Wilson <wilsons@start.ca> wrote:
> 
> > Recently a concern was raised[1] that performing an allocation while holding a
> > reference on a tasks mm could lead to a stalemate in the oom killer.  The
> > concern was specific to the goings-on in /proc.  Hugh Dickins stated the issue
> > thusly:
> > 
> >     ...imagine what happens if the system is out of memory, and the mm
> >     we're looking at is selected for killing by the OOM killer: while we
> >     wait in __get_free_page for more memory, no memory is freed from the
> >     selected mm because it cannot reach exit_mmap while we hold that
> >     reference.
> > 
> > The primary goal of this series is to eliminate repeated allocation/free cycles
> > currently happening in show_numa_maps() while we hold a reference to an mm.
> > 
> > The strategy is to perform the allocation once when /proc/pid/numa_maps is
> > opened, before a reference on the target tasks mm is taken.
> > 
> > Unfortunately, show_numa_maps() is implemented in mm/mempolicy.c while the
> > primary procfs implementation  lives in fs/proc/task_mmu.c.  This makes
> > clean cooperation between show_numa_maps() and the other seq_file operations
> > (start(), stop(), etc) difficult.
> > 
> > 
> > Patches 1-5 convert show_numa_maps() to use the generic walk_page_range()
> > functionality instead of the mempolicy.c specific page table walking logic.
> > Also, get_vma_policy() is exported.  This makes the show_numa_maps()
> > implementation independent of mempolicy.c. 
> > 
> > Patch 6 moves show_numa_maps() and supporting routines over to
> > fs/proc/task_mmu.c.
> > 
> > Finally, patches 7 and 8 provide minor cleanup and eliminates the troublesome
> > allocation.
> > 
> >  
> > Please note that moving show_numa_maps() into fs/proc/task_mmu.c essentially
> > reverts 1a75a6c825 and 48fce3429d.  Also, please see the discussion at [2].  My
> > main justifications for moving the code back into task_mmu.c is:
> > 
> >   - Having the show() operation "miles away" from the corresponding
> >     seq_file iteration operations is a maintenance burden. 
> >     
> >   - The need to export ad hoc info like struct proc_maps_private is
> >     eliminated.
> > 
> > 
> > These patches are based on v2.6.39-rc5.
> 
> The patches look reasonable.  It would be nice to get some more review
> happening (poke).

If anyone would like me to resend the series please let me know.

> > 
> > Please note that this series is VERY LIGHTLY TESTED.  I have been using
> > CONFIG_NUMA_EMU=y thus far as I will not have access to a real NUMA system for
> > another week or two.
> 
> "lightly tested" evokes fear, but the patches don't look too scary to
> me.

Indeed.  I hope to have some real hardware to test the patches on by
the end of the week; fingers crossed.  Will certainly address any
issues that come up at that time. 


> Did you look at using apply_to_page_range()?

I did not look into it deeply, no.  The main reason for using
walk_page_range() was that it supports hugetlb vma's in the same way as
was done in mempolicy.c's check_huge_range().  The algorithm was a very
natural fit so I ran with it.


> I'm trying to remember why we're carrying both walk_page_range() and
> apply_to_page_range() but can't immediately think of a reason.
>
> There's also an apply_to_page_range_batch() in -mm but that code is
> broken on PPC and not much is happening with it, so it will probably go
> away again.


-- 
steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
