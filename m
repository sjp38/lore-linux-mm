Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 0A55C6B004D
	for <linux-mm@kvack.org>; Thu, 23 Jul 2009 07:49:43 -0400 (EDT)
Subject: Re: [PATCH 06/10] ksm: identify PageKsm pages
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20090723110655.f08cdcdc.kamezawa.hiroyu@jp.fujitsu.com>
References: <1247851850-4298-1-git-send-email-ieidus@redhat.com>
	 <1247851850-4298-2-git-send-email-ieidus@redhat.com>
	 <1247851850-4298-3-git-send-email-ieidus@redhat.com>
	 <1247851850-4298-4-git-send-email-ieidus@redhat.com>
	 <1247851850-4298-5-git-send-email-ieidus@redhat.com>
	 <1247851850-4298-6-git-send-email-ieidus@redhat.com>
	 <1247851850-4298-7-git-send-email-ieidus@redhat.com>
	 <20090721175139.GE2239@random.random> <4A660101.3000307@redhat.com>
	 <Pine.LNX.4.64.0907221346040.529@sister.anvils>
	 <20090723110655.f08cdcdc.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain
Date: Thu, 23 Jul 2009 07:49:43 -0400
Message-Id: <1248349783.5674.2.camel@useless.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Izik Eidus <ieidus@redhat.com>, akpm@linux-foundation.org, chrisw@redhat.com, avi@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, nickpiggin@yahoo.com.au, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2009-07-23 at 11:06 +0900, KAMEZAWA Hiroyuki wrote:
> On Wed, 22 Jul 2009 13:54:06 +0100 (BST)
> Hugh Dickins <hugh.dickins@tiscali.co.uk> wrote:
> 
> > On Tue, 21 Jul 2009, Rik van Riel wrote:
> > > Andrea Arcangeli wrote:
> > > > > -	if (PageAnon(old_page)) {
> > > > > +	if (PageAnon(old_page) && !PageKsm(old_page)) {
> > > > >    if (!trylock_page(old_page)) {
> > > > >     page_cache_get(old_page);
> > > > >     pte_unmap_unlock(page_table, ptl);
> > > > 
> > > > What exactly does it buy to have PageAnon return 1 on ksm pages,
> > > > besides requiring the above additional check (that if we stick to the
> > > > above code, I would find safer to move inside reuse_swap_page).
> > > 
> > > I guess that if they are to remain unswappable, they
> > > should go onto the unevictable list.
> > 
> > The KSM pages are not put on any LRU, so wouldn't be slowing vmscan
> > down with futile scans: isn't the unevictable list for pages which
> > belong to another LRU once they become evictable again?
> > 
> > (At this instant I've forgotten why there's an unevictable list at
> > all - somewhere in vmscan.c which is accustomed to dealing with
> > pages on lists, so easier to have them on a list than not?)
> > 
> I forget, too. But in short thinking, Unevictable pages should be
> on LRU (marked as PG_lru) for isolating page (from LRU) called by
> page migration etc.
> 
> isolate_lru_page()
> 	-> put page on private list
> 	-> do some work
> 	-> putback_lru_page()
> 
> sequence is useful at handling pages in a list.
> Because mlock/munclock can be called arbitrarily, unevicatable lru
> works enough good for making above kinds of code simpler.

Right.  Quoting from Documentation/vm/unevictable-lru.txt:

The Unevictable LRU infrastructure maintains unevictable pages on an additional
LRU list for a few reasons:
 
 (1) We get to "treat unevictable pages just like we treat other pages in the
     system - which means we get to use the same code to manipulate them, the
     same code to isolate them (for migrate, etc.), the same code to keep track
     of the statistics, etc..." [Rik van Riel]

 (2) We want to be able to migrate unevictable pages between nodes for memory
     defragmentation, workload management and memory hotplug.  The linux kernel
     can only migrate pages that it can successfully isolate from the LRU
     lists.  If we were to maintain pages elsewhere than on an LRU-like list,
     where they can be found by isolate_lru_page(), we would prevent their
     migration, unless we reworked migration code to find the unevictable pages
     itself.


I guess "a few" became "a couple" over time...

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
