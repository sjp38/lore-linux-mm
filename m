Subject: Re: PATCH: rewrite of invalidate_inode_pages
References: <ytt4s84ix4z.fsf@vexeta.dc.fi.udc.es>
From: Trond Myklebust <trond.myklebust@fys.uio.no>
Date: 12 May 2000 00:28:35 +0200
In-Reply-To: "Juan J. Quintela"'s message of "11 May 2000 23:40:12 +0200"
Message-ID: <shsg0roen70.fsf@charged.uio.no>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Juan J. Quintela" <quintela@fi.udc.es>
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@transmeta.com>, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

You seem to assume that invalidate_inode_pages() is supposed to
invalidate *all* pages in the inode. This is NOT the case, and any
rewrite is going to lead to hard lockups if you try to make it so.

Most calls to invalidate_inode_pages() are made while we hold the page
lock for some page that has just been updated (and hence we know is up
to date). The reason is that under NFS, we receive a set of attributes
as part of the result from READ/WRITE/... If this triggers a cache
invalidation, then we do not want to invalidate the page that we know
is safe, hence we call invalidate_inode_pages() before the newly read
in page is unlocked.

Your code of the form

    while (head != head->next) {
... 
   }

without some alternative method of exit will therefore lock up under NFS.

Filesystems which want to make sure they clear out locked pages should
use truncate_inode_pages() instead.

Cheers,
  Trond
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
