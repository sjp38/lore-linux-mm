MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14619.16278.813629.967654@charged.uio.no>
Date: Fri, 12 May 2000 01:17:42 +0200 (CEST)
Subject: Re: PATCH: rewrite of invalidate_inode_pages
In-Reply-To: <yttbt2chf46.fsf@vexeta.dc.fi.udc.es>
References: <Pine.LNX.4.10.10005111445370.819-100000@penguin.transmeta.com>
	<yttya5ghhtr.fsf@vexeta.dc.fi.udc.es>
	<shsd7msemwu.fsf@charged.uio.no>
	<yttbt2chf46.fsf@vexeta.dc.fi.udc.es>
Reply-To: trond.myklebust@fys.uio.no
From: Trond Myklebust <trond.myklebust@fys.uio.no>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Juan J. Quintela" <quintela@fi.udc.es>
Cc: Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

>>>>> " " == Juan J Quintela <quintela@fi.udc.es> writes:

     > Then you want only invalidate the non_locked pages: do you

That's right. This patch looks much more appropriate.

     > + while (count == ITERATIONS) {
     > + spin_lock(&pagecache_lock);
     > + spin_lock(&pagemap_lru_lock);
     > + head = &inode->i_mapping->pages;
     > + curr = head->next;
     > + count = 0;
     > +
     > + while ((curr != head) && (count++ < ITERATIONS)) {

Just one question: Isn't it better to do it all in 1 iteration through
the loop rather than doing it in batches of 100 pages?
You can argue that you're freeing up the spinlocks for the duration of
the loop_and_test, but is that really going to make a huge difference
to SMP performance?

Cheers,
  Trond
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
