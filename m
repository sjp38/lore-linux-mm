Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 6699F6B0055
	for <linux-mm@kvack.org>; Sat,  4 Jul 2009 10:56:47 -0400 (EDT)
Date: Sat, 4 Jul 2009 11:18:01 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 02/11] vfs: Add better VFS support for page_mkwrite
	when blocksize < pagesize
Message-ID: <20090704151801.GA19682@infradead.org>
References: <1245088797-29533-1-git-send-email-jack@suse.cz> <1245088797-29533-3-git-send-email-jack@suse.cz> <20090625161753.GB30755@wotan.suse.de> <20090625174754.GA21957@infradead.org> <20090626084225.GA12201@wotan.suse.de> <20090630173716.GA3150@infradead.org> <20090702072225.GC2714@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090702072225.GC2714@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Christoph Hellwig <hch@infradead.org>, Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 02, 2009 at 09:22:25AM +0200, Nick Piggin wrote:
> > Looking at your patch I really like that vmtruncate now really just
> > does what it's name claims to - truncate the VM-information about
> > the file (well, and the file size).   I'm not so happy about
> > still keeping the two level setattr/truncate indirection.
> 
> In my patch series, i_size update eventually is moved out to the
> filesystem too, and vmtruncate just is renamed to truncate_pagecache
> (vmtruncate is not such a bad name, but rename will nicely break
> unconverted modules).

Good, that's a much better calling and naming convention.

> > But instead of folding truncate into setattr I wonder if we should
> > just add a new ->setsize (aka new trunacte) methodas a top-level
> > entry point instead of ->setattr with ATTR_SIZE given that size
> > changes don't have much in common with the reset of ->setattr.
> 
> OK that would be possible and makes sense I guess. The new truncate
> which returns error could basically be renamed in-place. Shall we
> continue to give ATTR_SIZE to setattr, or take that out completely?
> I guess truncate can be considered special because it operates on
> data not only metadata.
> 
> Looks like ->setsize would need a flag for ATTR_OPEN too? Any others?
> I'll do a bit of an audit when I get around to it...

In the end ATTR_SIZE should not be passed to ->setattr anymore, and
->setsize should become mandatory.  For the transition I would recommend
calling ->setsize if present else fall back to the current way.  That
way we can migreate one filesystem per patch to the new scheme.

I would suggest giving the flags to ->setsize their own namespace with
two flags so far SETSIZE_FTRUNCATE (need to update the file size and
have a file struct available) and SETSIZE_OPEN for the ATTR_OPEN case.

That beeing said I reallye hate the conditiona file argument for
ftrunctate (currently hidden inside struct iattr), maybe we're better
off having am optional int (*ftruncate)(struct file *) method for those
filesystems that need it, with a fallback to ->setsize.

And yeah, maybe ->setsize might better be left as ->truncate, but if
we want a nicely bisectable migration we'd have to rename the old
truncate to e.g. ->old_truncate before.  That's probably worth having
the better naming in the end.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
