Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 9156B6B0085
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 09:51:55 -0400 (EDT)
Date: Wed, 17 Jun 2009 15:53:31 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH 07/11] vfs: Unmap underlying metadata of new data buffers only when buffer is mapped
Message-ID: <20090617135331.GA20678@wotan.suse.de>
References: <1245088797-29533-1-git-send-email-jack@suse.cz> <1245088797-29533-8-git-send-email-jack@suse.cz> <20090617103543.GB29931@wotan.suse.de> <20090617120520.GD2612@duck.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090617120520.GD2612@duck.suse.cz>
Sender: owner-linux-mm@kvack.org
To: Jan Kara <jack@suse.cz>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 17, 2009 at 02:05:20PM +0200, Jan Kara wrote:
> On Wed 17-06-09 12:35:43, Nick Piggin wrote:
> > On Mon, Jun 15, 2009 at 07:59:54PM +0200, Jan Kara wrote:
> > > When we do delayed allocation of some buffer, we want to signal to VFS that
> > > the buffer is new (set buffer_new) so that it properly zeros out everything.
> > > But we don't have the buffer mapped yet so we cannot really unmap underlying
> > > metadata in this state. Make VFS avoid doing unmapping of metadata when the
> > > buffer is not yet mapped.
> > 
> > Is this a seperate bugfix for delalloc filesystems? What is the error
> > case of attempting to unmap underlying metadata of non mapped buffer?
> > Won't translate to a serious bug will it?
>   If you do unmap_underlying_metadata on !mapped buffer, the kernel will
> oops because it will try to dereference bh->b_bdev which is NULL. Ext4 or
> XFS workaround this issue by setting b_bdev to the real device and b_blocknr
> to ~0 so unmap_underlying_metadata does not oops.  As I didn't want to do
> the same hack in ext3, I need this patch...

OK, just trying to understand the patchset. It would be nice to
merge this ASAP as well and remove the ext4 and xfs hacks.


>   You're right it's not directly connected with the mkwrite problem and
> can go in separately. Given how late it is, I'd like to get patch number 2
> reviewed (generic mkwrite changes), so that it can go together with patch
> number 4 (ext4 fixes) in the current merge window. The rest is not that
> urgent since it's not oopsable and you can hit it only when running out
> of space (or hitting quota limit)...

Sorry I was so late with looking at it. I am reading it now though
(especially #2) ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
