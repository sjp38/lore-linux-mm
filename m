Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 55DD76B004F
	for <linux-mm@kvack.org>; Thu, 25 Jun 2009 12:17:41 -0400 (EDT)
Date: Thu, 25 Jun 2009 18:17:53 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH 02/11] vfs: Add better VFS support for page_mkwrite when blocksize < pagesize
Message-ID: <20090625161753.GB30755@wotan.suse.de>
References: <1245088797-29533-1-git-send-email-jack@suse.cz> <1245088797-29533-3-git-send-email-jack@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1245088797-29533-3-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
To: Jan Kara <jack@suse.cz>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 15, 2009 at 07:59:49PM +0200, Jan Kara wrote:
> page_mkwrite() is meant to be used by filesystems to allocate blocks under a
> page which is becoming writeably mmapped in some process address space. This
> allows a filesystem to return a page fault if there is not enough space
> available, user exceeds quota or similar problem happens, rather than silently
> discarding data later when writepage is called.
> 
> On filesystems where blocksize < pagesize the situation is more complicated.
> Think for example that blocksize = 1024, pagesize = 4096 and a process does:
>   ftruncate(fd, 0);
>   pwrite(fd, buf, 1024, 0);
>   map = mmap(NULL, 4096, PROT_WRITE, MAP_SHARED, fd, 0);
>   map[0] = 'a';  ----> page_mkwrite() for index 0 is called
>   ftruncate(fd, 10000); /* or even pwrite(fd, buf, 1, 10000) */
>   fsync(fd); ----> writepage() for index 0 is called
> 
> At the moment page_mkwrite() is called, filesystem can allocate only one block
> for the page because i_size == 1024. Otherwise it would create blocks beyond
> i_size which is generally undesirable. But later at writepage() time, we would
> like to have blocks allocated for the whole page (and in principle we have to
> allocate them because user could have filled the page with data after the
> second ftruncate()). This patch introduces a framework which allows filesystems
> to handle this with a reasonable effort.
> 
> The idea is following: Before we extend i_size, we obtain a special lock blocking
> page_mkwrite() on the page straddling i_size. Then we writeprotect the page,
> change i_size and unlock the special lock. This way, page_mkwrite() is called for
> a page each time a number of blocks needed to be allocated for a page increases.


Sorry for late reply here, I'm not sure if the ptach was ready for this
merge window anyway if it has not been in Andrew or Al's trees.

Well... I can't really find any hole in your code, but I'm not completely
sure I like the design. I have done some thinking about the problem
when working on fsblock.

This is adding a whole new layer of synchronisation, which isn't exactly
trivial. What I had been thinking about is doing just page based
synchronisation. Now that page_mkwrite has been changed to allow page
lock held, I think it can work cleanly from the vm/pagecache perspective.

The biggest problem I ran into is the awful structuring of truncate from
below the vfs (so I gave up then).

I have been working to clean up and complete (at least to an RFC stage)
patches to improve this, at which point, doing the page_mkclean thing
on the last partial page should be quite trivial I think.

Basically the problems is that i_op->truncate a) cannot return an error
(which is causing problems missing -EIO today anyway), and b) is called
after i_size update which makes it not possible to error-out without
races anyway, and c) does not get the old i_size so you can't unmap the
last partial page with it.

My patch is basically moving ->truncate call into setattr, and have
the filesystem call vmtruncate. I've jt to clean up loose ends.

Now I may be speaking too soon. It might trun out that my fix is
complex as well, but let me just give you an RFC and we can discuss.

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
