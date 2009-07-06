Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id B718B6B004F
	for <linux-mm@kvack.org>; Mon,  6 Jul 2009 04:32:48 -0400 (EDT)
Date: Mon, 6 Jul 2009 11:08:04 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH 02/11] vfs: Add better VFS support for page_mkwrite when blocksize < pagesize
Message-ID: <20090706090804.GM2714@wotan.suse.de>
References: <1245088797-29533-1-git-send-email-jack@suse.cz> <1245088797-29533-3-git-send-email-jack@suse.cz> <20090625161753.GB30755@wotan.suse.de> <20090625174754.GA21957@infradead.org> <20090626084225.GA12201@wotan.suse.de> <20090630173716.GA3150@infradead.org> <20090702072225.GC2714@wotan.suse.de> <20090704151801.GA19682@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090704151801.GA19682@infradead.org>
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, Jul 04, 2009 at 11:18:01AM -0400, Christoph Hellwig wrote:
> On Thu, Jul 02, 2009 at 09:22:25AM +0200, Nick Piggin wrote:
> > I guess truncate can be considered special because it operates on
> > data not only metadata.
> > 
> > Looks like ->setsize would need a flag for ATTR_OPEN too? Any others?
> > I'll do a bit of an audit when I get around to it...
> 
> In the end ATTR_SIZE should not be passed to ->setattr anymore, and
> ->setsize should become mandatory.  For the transition I would recommend
> calling ->setsize if present else fall back to the current way.  That
> way we can migreate one filesystem per patch to the new scheme.
> 
> I would suggest giving the flags to ->setsize their own namespace with
> two flags so far SETSIZE_FTRUNCATE (need to update the file size and
> have a file struct available) and SETSIZE_OPEN for the ATTR_OPEN case.
> 
> That beeing said I reallye hate the conditiona file argument for
> ftrunctate (currently hidden inside struct iattr), maybe we're better
> off having am optional int (*ftruncate)(struct file *) method for those
> filesystems that need it, with a fallback to ->setsize.

OK, hmm, but I wonder -- most of the time do_truncate will need to
call notify_change anyway, so I wonder if avoiding the double
indirection saves us anything? (It requires 2 indirect calls either
way). And if we call ->setsize from ->setattr, then a filesystem
which implements its own ->setattr could avoid one of those indirect
calls. Not so if do_truncate has to call ->setattr then ->setsize.

We definitely could call the method ->ftruncate, however (regardless
of where we call it from). In fact, we could just have a single new
->ftruncate where struct file * argument is NULL if not called via
an open file. This should also solve the namimg issue without
renaming the old method (having both ->truncate and ->ftruncate
could be slightly confusing at a glance, but we will remove
->truncate ASAP).

Anyway, let me finish the first draft and post my series and we
can go over it further.


> And yeah, maybe ->setsize might better be left as ->truncate, but if
> we want a nicely bisectable migration we'd have to rename the old
> truncate to e.g. ->old_truncate before.  That's probably worth having
> the better naming in the end.

It is definitely better to not break things as my first patch has
done. I think it should not be too hard to have intermediate steps.

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
