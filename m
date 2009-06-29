Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1B4046B004D
	for <linux-mm@kvack.org>; Mon, 29 Jun 2009 01:52:44 -0400 (EDT)
Date: Mon, 29 Jun 2009 07:54:21 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH 02/11] vfs: Add better VFS support for page_mkwrite when blocksize < pagesize
Message-ID: <20090629055421.GG11450@wotan.suse.de>
References: <1245088797-29533-1-git-send-email-jack@suse.cz> <1245088797-29533-3-git-send-email-jack@suse.cz> <20090625161753.GB30755@wotan.suse.de> <20090626122141.GB32125@duck.suse.cz> <20090626125505.GD11450@wotan.suse.de> <20090626160851.GA22335@duck.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090626160851.GA22335@duck.suse.cz>
Sender: owner-linux-mm@kvack.org
To: Jan Kara <jack@suse.cz>, OM@suse.de
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 26, 2009 at 06:08:51PM +0200, Jan Kara wrote:
> On Fri 26-06-09 14:55:05, Nick Piggin wrote:
> > On Fri, Jun 26, 2009 at 02:21:41PM +0200, Jan Kara wrote:
> > >   So if you have any idea how to better solve this, you are welcome ;).
> > 
> > Ah thanks, the write(2) case I missed. That does get complex to
> > do with the page lock.
> > 
> > I agree with the semantics you are aiming for, and I agree we should
> > not try to allocate blocks when extending i_size.
> > 
> > We actually could update i_size after dropping the page lock in
> > these paths. That would give a window where we can page_mkclean
> > the old partial page before the i_size update.
>   Yes, that would be fine and make things simpler...

Hopefully.

 
> > However this does actually require that we remove the partial-page
> > zeroing that writepage does. I think it does it in order to attempt
> > to write zeroes into the fs even if the app does mmaped writes
> > past i_size... but it is pretty dumb anyway really because the
> > behaviour is undefined anyway so there is no problem if weird
> > stuff gets written there (it should be zeroed out when extending
> > the file anyway), and also there is nothing to prevent races of
> > subsequent mmapped writes before the DMA completes.
>   We definitely don't zero out the last page when extending the file. But
> if we do it, we should be fine as you write. I'll try to write a patch...
> (I'm on vacation next week though so probably after that).

What I mean is that as of today, write(2) is required to hold page lock
of the page it is operating on if it writes anything past i_size. It
must hold that lock until i_size is extended to include the new data.
If it does not hold the lock, then eg. block_write_full_page can zero
out that data incorrectly

        /*
         * The page straddles i_size.  It must be zeroed out on each and every
         * writepage invokation because it may be mmapped.  "A file is mapped
         * in multiples of the page size.  For a file that is not a multiple of
         * the  page size, the remaining memory is zeroed when mapped, and
         * writes to that region are not written out to the file."
         */

But I argue this is bogus anyway because it is completely racy, and
it should be undefined behaviour anyway. So I think it would be fine
to remove it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
