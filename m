Received: by wx-out-0506.google.com with SMTP id h31so502003wxd.11
        for <linux-mm@kvack.org>; Thu, 10 Jan 2008 07:56:08 -0800 (PST)
Message-ID: <4df4ef0c0801100756v2a536cc5xa80d9d1cfdae073a@mail.gmail.com>
Date: Thu, 10 Jan 2008 18:56:07 +0300
From: "Anton Salikhmetov" <salikhmetov@gmail.com>
Subject: Re: [PATCH][RFC][BUG] updating the ctime and mtime time stamps in msync()
In-Reply-To: <20080110104543.398baf5c@bree.surriel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <1199728459.26463.11.camel@codedot>
	 <20080109155015.4d2d4c1d@cuia.boston.redhat.com>
	 <26932.1199912777@turing-police.cc.vt.edu>
	 <20080109170633.292644dc@cuia.boston.redhat.com>
	 <20080109223340.GH25527@unthought.net>
	 <20080109184141.287189b8@bree.surriel.com>
	 <4df4ef0c0801091603y2bf507e1q2b99971c6028d1f3@mail.gmail.com>
	 <20080110085120.GK25527@unthought.net>
	 <4df4ef0c0801100253m6c08e4a3t917959c030533f80@mail.gmail.com>
	 <20080110104543.398baf5c@bree.surriel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Jakob Oestergaard <jakob@unthought.net>, Valdis.Kletnieks@vt.edu, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

2008/1/10, Rik van Riel <riel@redhat.com>:
> On Thu, 10 Jan 2008 13:53:59 +0300
> "Anton Salikhmetov" <salikhmetov@gmail.com> wrote:
>
> > Indeed, if msync() is called with MS_SYNC an explicit sync is
> > triggered, and Rik's suggestion would work. However, the POSIX
> > standard requires a call to msync() with MS_ASYNC to update the
> > st_ctime and st_mtime stamps too. No explicit sync of the inode data
> > is triggered in the current implementation of msync(). Hence Rik's
> > suggestion would fail to satisfy POSIX in the latter case.
>
> Since your patch is already changing msync(), has it occurred
> to you that your patch could change msync() to do the right
> thing?

No, not quite. Peter Staubach mentioned an issue in my solution:

>>>

> The patch adds a call to the file_update_time() function to change
> the file metadata before syncing. The patch also contains
> substantial code cleanup: consolidated error check
> for function parameters, using the PAGE_ALIGN() macro instead of
> "manual" alignment check, improved readability of the loop,
> which traverses the process memory regions, updated comments.
>
>

These changes catch the simple case, where the file is mmap'd,
modified via the mmap'd region, and then an msync is done,
all on a mostly quiet system.

However, I don't see how they will work if there has been
something like a sync(2) done after the mmap'd region is
modified and the msync call.  When the inode is written out
as part of the sync process, I_DIRTY_PAGES will be cleared,
thus causing a miss in this code.

The I_DIRTY_PAGES check here is good, but I think that there
needs to be some code elsewhere too, to catch the case where
I_DIRTY_PAGES is being cleared, but the time fields still need
to be updated.

<<<

So I'm working on my next solution for this bug now.

>
> --
> All rights reversed.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
