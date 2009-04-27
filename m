Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 98B4A6B0095
	for <linux-mm@kvack.org>; Mon, 27 Apr 2009 03:45:26 -0400 (EDT)
From: Neil Brown <neilb@suse.de>
Date: Mon, 27 Apr 2009 17:46:21 +1000
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <18933.25293.145925.707478@notabene.brown>
Subject: Re: [PATCH] Fix race between callers of read_cache_page_async and
 invalidate_inode_pages.
In-Reply-To: message from Andrew Morton on Sunday April 26
References: <18933.16534.862316.787808@notabene.brown>
	<20090426223744.72edc7f4.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, David Woodhouse <dwmw2@infradead.org>
List-ID: <linux-mm.kvack.org>

On Sunday April 26, akpm@linux-foundation.org wrote:
> On Mon, 27 Apr 2009 15:20:22 +1000 Neil Brown <neilb@suse.de> wrote:
> 
> hrm.  And where is it written that PageError() will remain inviolable
> after it has been set?

  ...it follows as night the day....

What use would PageError be if it can just disappear when you most
want to test it?
Then again, what use is PageUptodate if it can just disappear?  My
other thought for fixing this was to change truncate_complete_page to
not clear PageUptodate.....
Oh.  That's already been done in 2.6.27-rc2.

So I guess this isn't a bug in mainline anymore... sorry for the noise :-)
(I'll just go quietly fix some enterprise kernels).
> 
> A safer and more formal (albeit somewhat slower) fix would be to lock
> the page and check its state under the lock.
> 
> y:/usr/src/linux-2.6.30-rc3> grep -r ClearPageError . | wc -l
> 21

I think each of these do one of:
   - clear the error after a successful read
   - clear the error before a read attempt
   - clear the error before a write
all (I think) while the page is locked.  None of these would
invalidate the change I made. (and I still think that it would read
better to say
   if (PageError(page))
     goto error;

than
   if (!PageUptodate(page))
     goto error;

but no matter).

Thanks anyway.
NeilBrown

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
