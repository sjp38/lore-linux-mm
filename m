Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 7CD276B004D
	for <linux-mm@kvack.org>; Thu,  2 Jul 2009 03:19:46 -0400 (EDT)
Date: Thu, 2 Jul 2009 09:22:25 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH 02/11] vfs: Add better VFS support for page_mkwrite when blocksize < pagesize
Message-ID: <20090702072225.GC2714@wotan.suse.de>
References: <1245088797-29533-1-git-send-email-jack@suse.cz> <1245088797-29533-3-git-send-email-jack@suse.cz> <20090625161753.GB30755@wotan.suse.de> <20090625174754.GA21957@infradead.org> <20090626084225.GA12201@wotan.suse.de> <20090630173716.GA3150@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090630173716.GA3150@infradead.org>
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 30, 2009 at 01:37:17PM -0400, Christoph Hellwig wrote:
> On Fri, Jun 26, 2009 at 10:42:25AM +0200, Nick Piggin wrote:
> > Yes well we could get rid of ->truncate and have filesystems do it
> > themselves in setattr, but I figure that moving truncate into
> > generic setattr is helpful (makes conversions a bit easier too).
> > Did you see my patch? What do you think of that basic approach?
> 
> I was waiting for a patch series for your for this to appear, but
> noticed that you actually had a small proof of concept patch attached,
> sorry :)

No problem. I'm going to send out a patchset, I've just been working
on exploring different ideas and trying to work out bugs.


> Looking at your patch I really like that vmtruncate now really just
> does what it's name claims to - truncate the VM-information about
> the file (well, and the file size).   I'm not so happy about
> still keeping the two level setattr/truncate indirection.

In my patch series, i_size update eventually is moved out to the
filesystem too, and vmtruncate just is renamed to truncate_pagecache
(vmtruncate is not such a bad name, but rename will nicely break
unconverted modules).

 
> But instead of folding truncate into setattr I wonder if we should
> just add a new ->setsize (aka new trunacte) methodas a top-level
> entry point instead of ->setattr with ATTR_SIZE given that size
> changes don't have much in common with the reset of ->setattr.

OK that would be possible and makes sense I guess. The new truncate
which returns error could basically be renamed in-place. Shall we
continue to give ATTR_SIZE to setattr, or take that out completely?
I guess truncate can be considered special because it operates on
data not only metadata.

Looks like ->setsize would need a flag for ATTR_OPEN too? Any others?
I'll do a bit of an audit when I get around to it...

 
> The only bit shared is updating c/mtime and even that is conditional.
> So I'd say take most of your patch, but instead of doing an all at
> once migration migrate filesystems to the new ->setsize callback
> incrementally and eventually kill off the old code.  This means
> we'll need a new name for the new vmtruncate-lite but should otherwise
> be pretty easy.

Makes sense. I'll try to structure it to allow incremental changeover.

 
> > >  The only problem is the generic aops calling
> > > vmtruncate directly.
> > 
> > What should be done is require that filesystems trim blocks past
> > i_size in case of any errors. I actually need to fix up a few
> > existing bugs in this area too, so I'll look at this..
> 
> Basically we want ->setattr with ATTR_SIZE, execept that we already
> have i_sem and possibly other per-inode locks.  Take a look at
> 
> 	http://oss.sgi.com/archives/xfs/2008-04/msg00542.html
> 
> and
> 
> 	http://oss.sgi.com/archives/xfs/2009-03/msg00214.html

OK thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
