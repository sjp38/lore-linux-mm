MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14619.15021.76570.36949@charged.uio.no>
Date: Fri, 12 May 2000 00:56:45 +0200 (CEST)
Subject: Re: PATCH: rewrite of invalidate_inode_pages
In-Reply-To: <ytthfc4hfmp.fsf@vexeta.dc.fi.udc.es>
References: <ytt4s84ix4z.fsf@vexeta.dc.fi.udc.es>
	<shsg0roen70.fsf@charged.uio.no>
	<ytthfc4hfmp.fsf@vexeta.dc.fi.udc.es>
Reply-To: trond.myklebust@fys.uio.no
From: Trond Myklebust <trond.myklebust@fys.uio.no>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Juan J. Quintela" <quintela@fi.udc.es>
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@transmeta.com>, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

>>>>> " " == Juan J Quintela <quintela@fi.udc.es> writes:

     > (I have removed the locking to clarify the example).  It can be
     > that I am not understanding something obvious, but I think that
     > the old code also invalidates oll the pages.

No it doesn't. If there are locked pages it skips them. In the end we 
should find ourselves with a ring of locked pages, so we're doing the
equivalent of the loop

  while (head != curr) {
      curr = curr->next;
      if (PageLocked(page))
	    continue;
      .... This code is no longer called 'cos all pages are locked .....
  }


     > new one, liberates all the non_locked pages and then sleeps
     > waiting one page to become unlocked.  the other version when

This is wrong. The reason is that under NFS, the rpciod can call
invalidate_inode_pages(). If it sleeps on a locked page, then it means
we must have some page IO in progress on that page. Who serves page IO
under NFS? rpciod.
So we deadlock...

As I said. The whole idea behind invalidate_inode_pages() is to serve
the need of NFS (and any future filesystems) for non-blocking
invalidation of the page cache.

Cheers,
  Trond
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
