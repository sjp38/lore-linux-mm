Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id CDB196B003D
	for <linux-mm@kvack.org>; Thu,  2 Apr 2009 05:04:21 -0400 (EDT)
Date: Thu, 2 Apr 2009 11:04:21 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] mm: close page_mkwrite races
Message-ID: <20090402090421.GB22256@wotan.suse.de>
References: <20090330135307.GP31000@wotan.suse.de> <20090330135613.GQ31000@wotan.suse.de> <Pine.LNX.4.64.0903311244200.19769@cobra.newdream.net> <20090401160241.ec2f4573.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090401160241.ec2f4573.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Sage Weil <sage@newdream.net>, trond.myklebust@fys.uio.no, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 01, 2009 at 04:02:41PM -0700, Andrew Morton wrote:
> On Tue, 31 Mar 2009 12:55:16 -0700 (PDT)
> Sage Weil <sage@newdream.net> wrote:
> 
> > On Mon, 30 Mar 2009, Nick Piggin wrote:
> > > [Fixed linux-mm address. Please reply here]
> > > 
> > > Hi,
> > > 
> > > I'd like opinions on this patch (applies on top of the previous
> > > page_mkwrite fixes in -mm). I was not going to ask to merge it
> > > immediately however it appears that fsblock is not the only one who
> > > needs it...
> > > --
> > > 
> > > I want to have the page be protected by page lock between page_mkwrite
> > > notification to the filesystem, and the actual setting of the page
> > > dirty. Do this by allowing the filesystem to return a locked page from
> > > page_mkwrite, and have the page fault code keep it held until after it
> > > calls set_page_dirty.
> > > 
> > > I need this in fsblock because I am working to ensure filesystem metadata
> > > can be correctly allocated and refcounted. This means that page cleaning
> > > should not require memory allocation.
> 
> wot?  "page cleaning" involves writeout.  How can we avoid doing
> allocations there?

Oh, guaranteed allocations like from mempools are fine of course.
But yeah the changelog is slightly more fsblock oriented than it
probably needs to be... I didn't really edit it after taking out
of my series.


> > > Without this patch, then for example we could get a concurrent writeout
> > > after the page_mkwrite (which allocates page metadata required to clean
> > > it), but before the set_page_dirty. The writeout will clean the page and
> > > notice that the metadata is now unused and may be deallocated (because
> > > it appears clean as set_page_dirty hasn't been called yet). So at this
> > > point the page may be dirtied via the pte without enough metadata to be
> > > able to write it back.
> > > 
> > > Sage needs this race closed for ceph, and Trond maybe for NFS.
> > 
> > I ran a few tests and this fixes the problem for me (although fyi the 
> > patch didn't apply cleanly on top of your previously posted page_mkwrite 
> > prototype change patch, due to some differences in block_page_mkwrite).
> 
> What is "the problem"?  Can we get "the problem"'s description included
> in the changelog?
> 
> The patch is fairly ugly, somewhat costly and makes things (even) more
> complex.    Sigh.

I guess it is another step toward being able to pull page_mkwrite into
->fault which will avoid one lock/unlock cycle and lots of stuff in
the main fault path.
 
Also fixes bug of course.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
