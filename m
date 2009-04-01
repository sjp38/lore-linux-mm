Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id E8B366B003D
	for <linux-mm@kvack.org>; Wed,  1 Apr 2009 19:06:07 -0400 (EDT)
Date: Wed, 1 Apr 2009 16:02:41 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] mm: close page_mkwrite races
Message-Id: <20090401160241.ec2f4573.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0903311244200.19769@cobra.newdream.net>
References: <20090330135307.GP31000@wotan.suse.de>
	<20090330135613.GQ31000@wotan.suse.de>
	<Pine.LNX.4.64.0903311244200.19769@cobra.newdream.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Sage Weil <sage@newdream.net>
Cc: npiggin@suse.de, trond.myklebust@fys.uio.no, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 31 Mar 2009 12:55:16 -0700 (PDT)
Sage Weil <sage@newdream.net> wrote:

> On Mon, 30 Mar 2009, Nick Piggin wrote:
> > [Fixed linux-mm address. Please reply here]
> > 
> > Hi,
> > 
> > I'd like opinions on this patch (applies on top of the previous
> > page_mkwrite fixes in -mm). I was not going to ask to merge it
> > immediately however it appears that fsblock is not the only one who
> > needs it...
> > --
> > 
> > I want to have the page be protected by page lock between page_mkwrite
> > notification to the filesystem, and the actual setting of the page
> > dirty. Do this by allowing the filesystem to return a locked page from
> > page_mkwrite, and have the page fault code keep it held until after it
> > calls set_page_dirty.
> > 
> > I need this in fsblock because I am working to ensure filesystem metadata
> > can be correctly allocated and refcounted. This means that page cleaning
> > should not require memory allocation.

wot?  "page cleaning" involves writeout.  How can we avoid doing
allocations there?

> > Without this patch, then for example we could get a concurrent writeout
> > after the page_mkwrite (which allocates page metadata required to clean
> > it), but before the set_page_dirty. The writeout will clean the page and
> > notice that the metadata is now unused and may be deallocated (because
> > it appears clean as set_page_dirty hasn't been called yet). So at this
> > point the page may be dirtied via the pte without enough metadata to be
> > able to write it back.
> > 
> > Sage needs this race closed for ceph, and Trond maybe for NFS.
> 
> I ran a few tests and this fixes the problem for me (although fyi the 
> patch didn't apply cleanly on top of your previously posted page_mkwrite 
> prototype change patch, due to some differences in block_page_mkwrite).

What is "the problem"?  Can we get "the problem"'s description included
in the changelog?

The patch is fairly ugly, somewhat costly and makes things (even) more
complex.    Sigh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
