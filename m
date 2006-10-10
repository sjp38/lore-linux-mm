Date: Tue, 10 Oct 2006 07:22:48 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] mm: bug in set_page_dirty_buffers
Message-ID: <20061010052248.GB24600@wotan.suse.de>
References: <Pine.LNX.4.64.0610091951350.3952@g5.osdl.org> <20061009202039.b6948a93.akpm@osdl.org> <20061010033412.GH15822@wotan.suse.de> <20061009205030.e247482e.akpm@osdl.org> <20061010035851.GK15822@wotan.suse.de> <20061009211404.ad112128.akpm@osdl.org> <20061010042144.GM15822@wotan.suse.de> <20061009213806.b158ea82.akpm@osdl.org> <20061010044745.GA24600@wotan.suse.de> <20061009220127.c4721d2d.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20061009220127.c4721d2d.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Linus Torvalds <torvalds@osdl.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux Memory Management List <linux-mm@kvack.org>, Greg KH <gregkh@suse.de>
List-ID: <linux-mm.kvack.org>

On Mon, Oct 09, 2006 at 10:01:27PM -0700, Andrew Morton wrote:
> On Tue, 10 Oct 2006 06:47:45 +0200
> Nick Piggin <npiggin@suse.de> wrote:
> > > There we can trylock all the pages and bale if any fail.
> > 
> > Hmm, try_to_unmap is OK because the page is already locked. page_remove_rmap
> > isn't allowed to fail.
> 
> I was talking about try_to_unmap_cluster().

But page_remove_rmap's many callers are still screwed. Take do_wp_page,
for example.

> > > But where?  locking the page is the preferred way to solve this stuff. 
> > > (Well, locking the buffers might work, but isn't needed, and locking the
> > > page covers other stuff)
> > 
> > AFAIKS, it is just fs/buffer.c that is racy.
> 
> Need to review all ->set_page_dirty, ->writepage, ->invalidatepage, ->etc
> implementations before we can say that.
> 
> > Why can't it use
> > mapping->private_lock or the buffer bit spinlock?
> 
> block_invalidatepage() wants to do lock_buffer().
> 
> It can probably be made to work.  But a sane interface is "when dinking
> with page internals, lock the page".

I disagree because it will lead to horrible hacks because many callers
can't sleep. If anything I would much prefer an innermost-spinlock in
page->flags that specifically excludes truncate. Actually tree_lock can
do that now, provided we pin mapping in all callers to set_page_dirty
(which we should do).

Then the locking protocol is up to fs/buffer.c. You could set a bit in
the buffer "BH_Invalidated" in truncate before clearing dirty, and test
for that bit in set_page_dirty_buffers?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
