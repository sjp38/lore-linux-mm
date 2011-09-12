Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 79857900137
	for <linux-mm@kvack.org>; Mon, 12 Sep 2011 07:56:10 -0400 (EDT)
Date: Mon, 12 Sep 2011 12:56:05 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 03/10] mm: Add support for a filesystem to control swap
 files
Message-ID: <20110912115605.GB3207@suse.de>
References: <1315566054-17209-1-git-send-email-mgorman@suse.de>
 <1315566054-17209-4-git-send-email-mgorman@suse.de>
 <20110909130007.GA11810@infradead.org>
 <20110909131550.GV14369@suse.de>
 <20110909133611.GB8155@infradead.org>
 <1315818285.26517.18.camel@twins>
 <20110912093058.GA3207@suse.de>
 <1315821369.26517.21.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1315821369.26517.21.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Christoph Hellwig <hch@infradead.org>, Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, Linux-NFS <linux-nfs@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Miller <davem@davemloft.net>, Trond Myklebust <Trond.Myklebust@netapp.com>, Neil Brown <neilb@suse.de>

On Mon, Sep 12, 2011 at 11:56:09AM +0200, Peter Zijlstra wrote:
> On Mon, 2011-09-12 at 10:34 +0100, Mel Gorman wrote:
> > On Mon, Sep 12, 2011 at 11:04:45AM +0200, Peter Zijlstra wrote:
> > > On Fri, 2011-09-09 at 09:36 -0400, Christoph Hellwig wrote:
> > > > The equivalent of ->direct_IO should be used for both reads and writes.
> > > 
> > > So the difference between DIO and swapIO is that swapIO needs the block
> > > map pinned in memory.. So at the very least you'll need those
> > > swap_{activate,deactivate} aops. The read/write-page thingies could
> > > indeed be shared with DIO.
> > > 
> > 
> > I'm travelling at the moment so it'll be later in the week when I investigate
> > properly but I agree swap_[de|a]ctivate are still necessary. NFS does not
> > need to pin a block map but it's still necessary for calling xs_set_memalloc.
> 
> Right.. but I think the hope was that we could replace the current swap
> bmap hackery with this and simplify the normal swap bits. But yeah,
> networked filesystems don't really bother with block maps on the client
> side ;-)

I took a look at what was involved with doing the block lookups in
ext4. It's what led to patch 4 of this series because it was necessary that
the filesystem get the same information as the generic handler. It got a
bit messy but looked like it would have worked if I kept at it. I stopped
because I did nt see a major advantage with swap_writepage() looking up
the block map instead of having looked it up in advance with bmap() but
I could have missed something.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
