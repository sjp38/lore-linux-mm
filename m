Subject: Re: [patch] mm: bug in set_page_dirty_buffers
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20061010052248.GB24600@wotan.suse.de>
References: <Pine.LNX.4.64.0610091951350.3952@g5.osdl.org>
	 <20061009202039.b6948a93.akpm@osdl.org>
	 <20061010033412.GH15822@wotan.suse.de>
	 <20061009205030.e247482e.akpm@osdl.org>
	 <20061010035851.GK15822@wotan.suse.de>
	 <20061009211404.ad112128.akpm@osdl.org>
	 <20061010042144.GM15822@wotan.suse.de>
	 <20061009213806.b158ea82.akpm@osdl.org>
	 <20061010044745.GA24600@wotan.suse.de>
	 <20061009220127.c4721d2d.akpm@osdl.org>
	 <20061010052248.GB24600@wotan.suse.de>
Content-Type: text/plain
Date: Tue, 10 Oct 2006 08:48:56 +0200
Message-Id: <1160462936.27479.4.camel@taijtu>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>, Linux Memory Management List <linux-mm@kvack.org>, Greg KH <gregkh@suse.de>
List-ID: <linux-mm.kvack.org>

On Tue, 2006-10-10 at 07:22 +0200, Nick Piggin wrote:
> On Mon, Oct 09, 2006 at 10:01:27PM -0700, Andrew Morton wrote:
> > On Tue, 10 Oct 2006 06:47:45 +0200
> > Nick Piggin <npiggin@suse.de> wrote:
> > > > There we can trylock all the pages and bale if any fail.
> > > 
> > > Hmm, try_to_unmap is OK because the page is already locked. page_remove_rmap
> > > isn't allowed to fail.
> > 
> > I was talking about try_to_unmap_cluster().
> 
> But page_remove_rmap's many callers are still screwed. Take do_wp_page,
> for example.

> > It can probably be made to work.  But a sane interface is "when dinking
> > with page internals, lock the page".
> 
> I disagree because it will lead to horrible hacks because many callers
> can't sleep. If anything I would much prefer an innermost-spinlock in
> page->flags that specifically excludes truncate. Actually tree_lock can
> do that now, provided we pin mapping in all callers to set_page_dirty
> (which we should do).

Yeah, but we're hard working to eradicate tree lock; I have ran into
this problem before; that is, zap_pte_range and co. not being able to
lock the page. I'd really like to see that fixed.

In my current concurrent pagecache patches I've abused your PG_nonewrefs
and made it this page internal (bit)spinlock, but it just doesn't look
nice to have both this lock and PG_locked.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
