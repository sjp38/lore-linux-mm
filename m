Received: from f03n05e
	by ausmtp02.au.ibm.com (IBM AP 1.0) with ESMTP id RAA109886
	for <linux-mm@kvack.org>; Wed, 29 Mar 2000 17:56:49 +1000
From: pnilesh@in.ibm.com
Received: from d73mta05.au.ibm.com (f06n05s [9.185.166.67])
	by f03n05e (8.8.8m2/8.8.7) with SMTP id RAA03834
	for <linux-mm@kvack.org>; Wed, 29 Mar 2000 17:58:02 +1000
Message-ID: <CA2568B1.002BB512.00@d73mta05.au.ibm.com>
Date: Wed, 29 Mar 2000 13:16:37 +0530
Subject: Re: how text page of executable are shared ?
Mime-Version: 1.0
Content-type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


Hi,

No, the page count will be three at least.  The presence of the page
in the page cache counts as one, and both of the page-table mappings of
the page each count as a further reference.

So when no process is pointing to a page in page cache the count will be
one.
But what is the difference if we have this to zero any way it is not being
refernced by any process.
Or can we have a page cache entry with page count as zero ?

Also all the pages which are present in the memory for any process will
also be part of the page hash queue and if they belong to a file then they
will also be on the inode queue.
Am I right.




Yes.  swap_out() is responsible for unlinking pages from process page
tables.  In the case you describe, the page will still have outstanding
references, from the other process and from the page cache.  Only when
the page cache cleanup function (shrink_mmap) gets called, after all of
the ptes to the page have been cleared, will the page be freed.

If you think about it, this is natural: when a process pages in a binary
and then exits, we really want the pages still to remain in memory so
that if you immediately rerun the program, we don't have to go back to
disk for the pages.  The process exiting acts a bit like a complete
swap_out, freeing up the pte reference to the page, but the page still
remains in the page cache until the memory is needed for something else.

> Q    When a page of a file is in page hash queue, does this page have
page
> table entry in any process ?

It may have, but it doesn't have to.

> Q     Can this be discarded right away , if the need arises?

Not without first doing a swap_out() on all the references to the page.
The Linux VM does its swapout based on virtual, not physical, page
scanning (although shrink_mmap() is physical).

--Stephen



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
