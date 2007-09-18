Subject: Re: [PATCH/RFC 11/14] Reclaim Scalability: swap backed pages are
	nonreclaimable when no swap space available
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <46EDEC2D.9070004@redhat.com>
References: <20070914205359.6536.98017.sendpatchset@localhost>
	 <20070914205512.6536.89432.sendpatchset@localhost>
	 <46EDEC2D.9070004@redhat.com>
Content-Type: text/plain
Date: Tue, 18 Sep 2007 13:46:13 -0400
Message-Id: <1190137573.5035.52.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, mel@csn.ul.ie, clameter@sgi.com, balbir@linux.vnet.ibm.com, andrea@suse.de, a.p.zijlstra@chello.nl, eric.whitney@hp.com, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

On Sun, 2007-09-16 at 22:53 -0400, Rik van Riel wrote:
> Lee Schermerhorn wrote:
> > PATCH/RFC  11/14 Reclaim Scalability: treat swap backed pages as
> > 	non-reclaimable when no swap space is available.
> > 
> > Against:  2.6.23-rc4-mm1
> > 
> > Move swap backed pages [anon, shmem/tmpfs] to noreclaim list when
> > nr_swap_pages goes to zero.   Use Rik van Riel's page_anon() 
> > function in page_reclaimable() to detect swap backed pages.
> > 
> > Depends on NORECLAIM_NO_SWAP Kconfig sub-option of NORECLAIM
> > 
> > TODO:   Splice zones' noreclaim list when "sufficient" swap becomes
> > available--either by being freed by other pages or by additional 
> > swap being added.  How much is "sufficient" swap?  Don't want to
> > splice huge noreclaim lists every time a swap page gets freed.
> 
> Yet another reason for my LRU list split between filesystem
> backed and swap backed pages: we can simply stop scanning the
> anon lists when swap space is full and resume scanning when
> swap space becomes available.


Hi, Rik:

It occurs to me that we probably don't want to stop scanning the anon
lists [active/inactive] when swap space is full.  We might have LOTS of
anon pages that already have swap space allocated to them that can be
reclaimed.  It's just those that don't already have swap space that
aren't reclaimable until more swap space becomes available.

Or did I misunderstand you?

Hmmm,  swap in [do_swap_page()] will free swap if it's > 1/2 full, so
that would reenable scanning the anon lists.  Still, wouldn't it be
possible to have resident PageSwapCache() pages that we'd want to find
and reclaim under memory pressure, even when !nr_swap_pages?

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
