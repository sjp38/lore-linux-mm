Received: from renko.ucs.ed.ac.uk (renko.ucs.ed.ac.uk [129.215.13.3])
	by kvack.org (8.8.7/8.8.7) with ESMTP id JAA21793
	for <linux-mm@kvack.org>; Mon, 14 Sep 1998 09:38:41 -0400
Date: Mon, 14 Sep 1998 14:21:27 +0100
Message-Id: <199809141321.OAA02594@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: memory management and the status of
Sender: owner-linux-mm@kvack.org
To: Woody <woody@localline.com>
Cc: linux-kernel@vger.rutgers.edu, Stephen Tweedie <sct@redhat.com>, Alan Cox <number6@the-village.bc.nu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Sat, 05 Sep 1998 11:28:13 -0500, Woody <woody@localline.com> said:

> What is the status with memory management under linux? 

Which kernel?  There are quite a number of things which are subtly
different here between 2.0 and 2.1.

> Right now, I have 80M of physical memory, where 78 of it is being used
> and my swap isn't even being touched. So what do you get? You get
> choppy mp3's while your running your nice, window manager and running
> netscape, etc., etc., etc.,...It's very annoying....if swap were to be
> used, I wouldn't have this problem...

Do you have evidence for that?

For what it's worth, there _is_ a problem in 2.0 which we realised when
doing some of the 2.1 changes.  I've not been able to get any report on
just how important a problem it is, but you may well be able to help
here.  It is nothing to do with use of swap, however.

The problem is that the normal file readahead algorithm does not mark
its pages as referenced.  The implication is that if you have a fairly
small amount of unshared cache, there is a bigger chance that the
readahead data will be selected for reuse by the page cache cleaner.

> it's pretty bad that I can boot into my Winnuts OS and have no
> problems, yet, Linux, which I feel is a superior OS, can't even handle
> damn memory issues! Is the coding for this issue THAT hard that we
> can't get it fixed, and fixed now?

Calm down.  This type of hysterics is just offensive and makes it less
likely that anyone will want to help you.  In particular, you have
offered absolutely no evidence that the swapping issue has anything at
all to do with your problem.

Anyway, here's the patch.

----------------------------------------------------------------
--- mm/filemap.c~	Thu Jul  2 21:02:48 1998
+++ mm/filemap.c	Mon Sep 14 14:12:10 1998
@@ -286,6 +286,7 @@
 			 */
 			page = mem_map + MAP_NR(page_cache);
 			add_to_page_cache(page, inode, offset, hash);
+			set_bit(PG_referenced, &page->flags);
 			inode->i_op->readpage(inode, page);
 			page_cache = 0;
 		}
----------------------------------------------------------------

The other possibility is that it's an interrupt issue, especially if you
are running a non-DMA-driven IDE disk setup.  In that case, hdparm -u
may be your friend.

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
