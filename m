Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id E83486B004D
	for <linux-mm@kvack.org>; Wed,  8 Jul 2009 08:32:28 -0400 (EDT)
Date: Wed, 8 Jul 2009 08:40:56 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [rfc][patch 3/4] fs: new truncate sequence
Message-ID: <20090708124056.GA26701@infradead.org>
References: <20090707144423.GC2714@wotan.suse.de> <20090707144823.GE2714@wotan.suse.de> <20090707145820.GA9976@infradead.org> <20090707150257.GG2714@wotan.suse.de> <20090707150758.GA18075@infradead.org> <20090707154809.GH2714@wotan.suse.de> <20090707163042.GA14947@infradead.org> <20090708063225.GL2714@wotan.suse.de> <20090708104701.GA31419@infradead.org> <20090708123412.GQ2714@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090708123412.GQ2714@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org, Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 08, 2009 at 02:34:12PM +0200, Nick Piggin wrote:
> On Wed, Jul 08, 2009 at 06:47:01AM -0400, Christoph Hellwig wrote:
> > On Wed, Jul 08, 2009 at 08:32:25AM +0200, Nick Piggin wrote:
> > > Thanks for the patch, I think I will fold it in to the series. I
> > > think we probably do need to call simple_setsize in inode_setattr
> > > though (unless you propose to eventually convert every filesystem
> > > to define a .setattr). This would also require eg. your ext2
> > > conversion to strip ATTR_SIZE before passing through to inode_setattr.
> > 
> > Yes, we should eventually make .setattr mandatory.  Doing a default
> > action when a method lacks tends to cause more issues than it solves.
> > 
> > I'm happy to help in doing that part of the conversion (and also other
> > bits)
> 
> OK well here is what I have now for 3/4 and 4/4. Basically just
> folded your patch on top, changed ordering of some checks, have
> fs clear ATTR_SIZE before calling inode_setattr, add a .new_truncate
> field to check against rather than .truncate, and provide a default
> ATTR_SIZE handler in inode_setattr (simple_setsize).

Can we leave that last part out?  Converting those filesystems that do
not have a ->truncate method to a trivial ->setattr is easy, and I can
do it pretty soon (next week probably).

That allows us to get rid of all that ATTR_SIZE clearing which is pretty
ugly.

> +			 *
> +			 * Filesystems which define i_op->new_truncate must
> +			 * handle this themselves. Eventually this will go
> +			 * away because everyone will be converted.

s/define/set/ ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
