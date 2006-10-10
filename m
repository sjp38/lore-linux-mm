Date: Tue, 10 Oct 2006 07:48:33 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] mm: bug in set_page_dirty_buffers
Message-ID: <20061010054832.GC24600@wotan.suse.de>
References: <20061010033412.GH15822@wotan.suse.de> <20061009205030.e247482e.akpm@osdl.org> <20061010035851.GK15822@wotan.suse.de> <20061009211404.ad112128.akpm@osdl.org> <20061010042144.GM15822@wotan.suse.de> <20061009213806.b158ea82.akpm@osdl.org> <20061010044745.GA24600@wotan.suse.de> <20061009220127.c4721d2d.akpm@osdl.org> <20061010052248.GB24600@wotan.suse.de> <20061009222905.ddd270a6.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20061009222905.ddd270a6.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Linus Torvalds <torvalds@osdl.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux Memory Management List <linux-mm@kvack.org>, Greg KH <gregkh@suse.de>
List-ID: <linux-mm.kvack.org>

On Mon, Oct 09, 2006 at 10:29:05PM -0700, Andrew Morton wrote:
> On Tue, 10 Oct 2006 07:22:48 +0200
> Nick Piggin <npiggin@suse.de> wrote:
> 
> > > > AFAIKS, it is just fs/buffer.c that is racy.
> > > 
> > > Need to review all ->set_page_dirty, ->writepage, ->invalidatepage, ->etc
> > > implementations before we can say that.
> 
>     ^^^ this

->writepage is called under page lock.

->invalidatepage is called under page lock.

I think ->spd is the only one to worry about.

__set_page_dirty_nobuffers does use the tree_lock to ensure it hasn't been
truncated. However it doe leave orphaned clean buffers which vmscan cannot
reclaim. So probably we should not dirty it *until* we have verified it
is still part of a mapping.

Similarly for __set_page_dirty_buffers.

Comments in ext3 look like it has spd under control.
Reiserfs looks similar, but it does have the unchecked
page->mapping problem that I fixed for spd_buffers.

Am I missing something?

> > I disagree because it will lead to horrible hacks because many callers
> > can't sleep. If anything I would much prefer an innermost-spinlock in
> > page->flags that specifically excludes truncate. Actually tree_lock can
> > do that now, provided we pin mapping in all callers to set_page_dirty
> > (which we should do).
> > 
> > Then the locking protocol is up to fs/buffer.c. You could set a bit in
> > the buffer "BH_Invalidated" in truncate before clearing dirty, and test
> > for that bit in set_page_dirty_buffers?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
