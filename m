Subject: Re: classzone-VM + mapped pages out of lru_cache
References: <Pine.LNX.4.21.0005041702560.2512-100000@alpha.random>
From: Trond Myklebust <trond.myklebust@fys.uio.no>
Date: 04 May 2000 18:48:38 +0200
In-Reply-To: Andrea Arcangeli's message of "Thu, 4 May 2000 17:19:03 +0200 (CEST)"
Message-ID: <shsya5q2rdl.fsf@charged.uio.no>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: "Juan J. Quintela" <quintela@fi.udc.es>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

>>>>> " " == Andrea Arcangeli <andrea@suse.de> writes:

     > This untested patch should fix the problem also in 2.2.15 (the
     > same way I fixed it in classzone patch):

     > --- 2.2.15/mm/filemap.c Thu May 4 13:00:40 2000
     > +++ /tmp/filemap.c Thu May 4 17:11:18 2000
     > @@ -68,7 +68,7 @@
 
     >  	p = &inode->i_pages; while ((page = *p) != NULL) {
     > - if (PageLocked(page)) {
     > + if (PageLocked(page) || atomic_read(&page->count) > 1) {
     >  			p = &page->next; continue;
     >  		}


     > Trond, what do you think about it?

Not good. If I'm running /bin/bash, and somebody on the server updates
/bin/bash, then I don't want to reboot my machine. With the above
patch, then all new processes will receive a mixture of pages from the
old and the new file until by some accident I manage to clear the
cache of the bad pages.

We have to insist on the PageLocked() both in 2.2.x and 2.3.x because
only pages which are in the process of being read in are safe. If we
know we're scheduled to write out a full page then that would be safe
too, but that is the only such case.

Cheers,
  Trond

PS: It would be nice to have truncate_inode_pages() work in the same
way as it does now: waiting on pages and locking them. This is useful
for reading in the directory pages, since they need to be read in
sequentially (please see the proposed patch I put on l-k earlier
today).
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
