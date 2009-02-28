Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 449886B003D
	for <linux-mm@kvack.org>; Sat, 28 Feb 2009 00:52:25 -0500 (EST)
Date: Sat, 28 Feb 2009 06:52:21 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch][rfc] mm: new address space calls
Message-ID: <20090228055221.GB28496@wotan.suse.de>
References: <20090225104839.GG22785@wotan.suse.de> <1235595597.32346.77.camel@think.oraclecorp.com> <20090226051702.GA25605@wotan.suse.de> <1235654505.26790.12.camel@think.oraclecorp.com> <20090227112622.GA13428@wotan.suse.de> <1235742767.10511.7.camel@think.oraclecorp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1235742767.10511.7.camel@think.oraclecorp.com>
Sender: owner-linux-mm@kvack.org
To: Chris Mason <chris.mason@oracle.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 27, 2009 at 08:52:47AM -0500, Chris Mason wrote:
> On Fri, 2009-02-27 at 12:26 +0100, Nick Piggin wrote:
> > Well I don't see how that limits us? Either we prefer to keep the
> > metadata, or we throw it away and it is inevitable that we lose
> > information. 
> > 
> 
> We can't have metadata that isn't freed by releasepage unless we want to
> pin the page completely.  There was a time when the btrfs metadata had a
> bit for 'this block needs defrag', and I ended up not being able to use
> it because releasepage was consistently freeing my extra data while the
> page was still around.

Hmm, it sounds like that data perhaps is more a property of the
filesystem / block management rather than the pagecache (OK, it's
a blurry line)...

But I mean 'this block neds defrag' sounds like important metadata
even if the page is *not* still around? (but the block is)

Having your own private metadata, perhaps with the ->shrinker callback
is an option. In fsblock actually for the block mapping cache tree,
I don't use a shrinker, because (I'm lazy and) reclaim will eventaully
reclaim the inode in which case the tree will be taken down with the
new aop->release callback.

But in theory even when the in-memory inode goes away, the block mapping
is still valid metadata, so you could keep it around somewhere (in which
case it would need a shrinker callback).


> > > I'd like a form of releasepage that knows if the vm is going to really
> > > get rid of the page.  Or another callback that happens when the VM is
> > > sure the page will be freed so we can drop extra metadata that doesn't
> > > pin the page, but we always want to stay with the page.
> > 
> > Well, for page reclaim/invalidate/truncate, we have releasepage that you
> > can use even if the metadata is stored outside the page, just set PagePrivate
> > and it will still get called when the page is about to be freed.
> > 
> 
> For clean pages, shrink_page_list seems to check the page count after
> the releasepage call.  It was a big enough window for me to see it in
> practice under normal workloads.

Oh yes, you would see it, but it just shouldn't be *too* common I think.
It's a hard race to close. You would ned to effectively take a spinlock
to prevent pagecache lookup over the releasepage call (OK, with lockless
pagecache it is no longer really tree_lock, but setting page->_count to
0, which causes lookup to basically do equivalent spinning anyway).

Of course it still may be closed with a new callback at pagecache
removal time... but I'm not convinced you need one yet ;) Maybe I don't
understand the requirements properly yet.

 
> > There are *some* races that can result in the page subsequently not being
> > freed, but I don't think that should be a big deal. I don't want to add
> > a callback in the pagecache remove path if possible, but we can try to
> > rework or improve things if btrfs needs something specific..
> 
> Btrfs doesn't need it today, but it should help once I finally get
> subpage blocks going again (and metadata defrag as well).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
