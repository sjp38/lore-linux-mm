Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id BF7246B0047
	for <linux-mm@kvack.org>; Fri, 27 Feb 2009 08:52:55 -0500 (EST)
Subject: Re: [patch][rfc] mm: new address space calls
From: Chris Mason <chris.mason@oracle.com>
In-Reply-To: <20090227112622.GA13428@wotan.suse.de>
References: <20090225104839.GG22785@wotan.suse.de>
	 <1235595597.32346.77.camel@think.oraclecorp.com>
	 <20090226051702.GA25605@wotan.suse.de>
	 <1235654505.26790.12.camel@think.oraclecorp.com>
	 <20090227112622.GA13428@wotan.suse.de>
Content-Type: text/plain
Date: Fri, 27 Feb 2009 08:52:47 -0500
Message-Id: <1235742767.10511.7.camel@think.oraclecorp.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 2009-02-27 at 12:26 +0100, Nick Piggin wrote:
> On Thu, Feb 26, 2009 at 08:21:45AM -0500, Chris Mason wrote:
> > > > One problem I have with the btrfs extent state code is that I might
> > > > choose to release the extent state in releasepage, but the VM might not
> > > > choose to free the page.  So I've got an up to date page without any of
> > > > the rest of my state.
> > > 
> > > I'm not sure. What semantics do you want there? In most cases (including
> > > fsblock default case where the filesystem does not have a pin), we're
> > > happy to leave clean, uptodate pages in pagecache in that case.
> > 
> > Right, but it really limits the state that we can keep outside the page
> > bits.  Take a subpage block, where we know the first 1k is up to date.
> > releasepage comes and we free our tracking that says the first 1k is up
> > to date, but the VM doesn't free the page.
> > 
> > Now we have a page where the uptodate bit isn't set, but the first 1k
> > has valid data.  We have to reread it.
> 
> Well I don't see how that limits us? Either we prefer to keep the
> metadata, or we throw it away and it is inevitable that we lose
> information. 
> 

We can't have metadata that isn't freed by releasepage unless we want to
pin the page completely.  There was a time when the btrfs metadata had a
bit for 'this block needs defrag', and I ended up not being able to use
it because releasepage was consistently freeing my extra data while the
page was still around.

> Regardless of whether you store the data in a tree of extends in the
> inode, or per-page buffers, you have the same problem (buffer heads
> have that same problem too).
> 

Right.

> 
> > I'd like a form of releasepage that knows if the vm is going to really
> > get rid of the page.  Or another callback that happens when the VM is
> > sure the page will be freed so we can drop extra metadata that doesn't
> > pin the page, but we always want to stay with the page.
> 
> Well, for page reclaim/invalidate/truncate, we have releasepage that you
> can use even if the metadata is stored outside the page, just set PagePrivate
> and it will still get called when the page is about to be freed.
> 

For clean pages, shrink_page_list seems to check the page count after
the releasepage call.  It was a big enough window for me to see it in
practice under normal workloads.

> There are *some* races that can result in the page subsequently not being
> freed, but I don't think that should be a big deal. I don't want to add
> a callback in the pagecache remove path if possible, but we can try to
> rework or improve things if btrfs needs something specific..

Btrfs doesn't need it today, but it should help once I finally get
subpage blocks going again (and metadata defrag as well).

-chris


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
