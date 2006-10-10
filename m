Date: Mon, 9 Oct 2006 23:08:32 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [patch] mm: bug in set_page_dirty_buffers
Message-Id: <20061009230832.7245814e.akpm@osdl.org>
In-Reply-To: <20061010054832.GC24600@wotan.suse.de>
References: <20061010033412.GH15822@wotan.suse.de>
	<20061009205030.e247482e.akpm@osdl.org>
	<20061010035851.GK15822@wotan.suse.de>
	<20061009211404.ad112128.akpm@osdl.org>
	<20061010042144.GM15822@wotan.suse.de>
	<20061009213806.b158ea82.akpm@osdl.org>
	<20061010044745.GA24600@wotan.suse.de>
	<20061009220127.c4721d2d.akpm@osdl.org>
	<20061010052248.GB24600@wotan.suse.de>
	<20061009222905.ddd270a6.akpm@osdl.org>
	<20061010054832.GC24600@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linus Torvalds <torvalds@osdl.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux Memory Management List <linux-mm@kvack.org>, Greg KH <gregkh@suse.de>
List-ID: <linux-mm.kvack.org>

On Tue, 10 Oct 2006 07:48:33 +0200
Nick Piggin <npiggin@suse.de> wrote:

> On Mon, Oct 09, 2006 at 10:29:05PM -0700, Andrew Morton wrote:
> > On Tue, 10 Oct 2006 07:22:48 +0200
> > Nick Piggin <npiggin@suse.de> wrote:
> > 
> > > > > AFAIKS, it is just fs/buffer.c that is racy.
> > > > 
> > > > Need to review all ->set_page_dirty, ->writepage, ->invalidatepage, ->etc
> > > > implementations before we can say that.
> > 
> >     ^^^ this
> 
> ->writepage is called under page lock.
> 
> ->invalidatepage is called under page lock.
> 
> I think ->spd is the only one to worry about.
> 
> __set_page_dirty_nobuffers does use the tree_lock to ensure it hasn't been
> truncated. However it doe leave orphaned clean buffers which vmscan cannot
> reclaim. So probably we should not dirty it *until* we have verified it
> is still part of a mapping.
> 
> Similarly for __set_page_dirty_buffers.
> 
> Comments in ext3 look like it has spd under control.
> Reiserfs looks similar, but it does have the unchecked
> page->mapping problem that I fixed for spd_buffers.
> 
> Am I missing something?

Well it's a matter of reviewing all codepaths in the kernel which
manipulate internal page state and see if they're racy against their
->set_page_dirty().  All because of zap_pte_range().

The page lock protects internal page state.  It'd be better to fix
zap_pte_range().

How about we trylock the page and if that fails, back out and drop locks
and lock the page then dirty it and then resume the zap?  Negligible
overhead, would be nice and simple apart from that i_mmap_lock thing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
