Subject: Re: PATCH: rewrite of invalidate_inode_pages
References: <ytt4s84ix4z.fsf@vexeta.dc.fi.udc.es>
	<shsg0roen70.fsf@charged.uio.no>
From: "Juan J. Quintela" <quintela@fi.udc.es>
In-Reply-To: Trond Myklebust's message of "12 May 2000 00:28:35 +0200"
Date: 12 May 2000 00:43:42 +0200
Message-ID: <ytthfc4hfmp.fsf@vexeta.dc.fi.udc.es>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@transmeta.com>, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

>>>>> "trond" == Trond Myklebust <trond.myklebust@fys.uio.no> writes:

Hi Trond

trond> You seem to assume that invalidate_inode_pages() is supposed to
trond> invalidate *all* pages in the inode. This is NOT the case, and any
trond> rewrite is going to lead to hard lockups if you try to make it so.

Or I don't understand some obvious (the big probability) or the old
code also try to invalidate *all* the pages in the inode.  If there
are some locked page we do a goto repeat, we do 

       head = &inode->i_mapping->pages;
and 
       curr = head->next; 

and then the test is:
    while(head != curr)

I can't see any difference with doing:

    head = &inode->i_mapping->pages;
    while (head != head->next)

(I have removed the locking to clarify the example).
It can be that I am not understanding something obvious, but I think
that the old code also invalidates oll the pages.

trond> Most calls to invalidate_inode_pages() are made while we hold the page
trond> lock for some page that has just been updated (and hence we know is up
trond> to date). The reason is that under NFS, we receive a set of attributes
trond> as part of the result from READ/WRITE/... If this triggers a cache
trond> invalidation, then we do not want to invalidate the page that we know
trond> is safe, hence we call invalidate_inode_pages() before the newly read
trond> in page is unlocked.

I think that the old code will not finish until we liberate all the
pages, the only way to go out the code is the continue or the end of
the loop, that does a goto before the loop.  I think that the only
real difference between the two codes (locking issues aside) is that
the old version does busy waiting, and new one, liberates all the
non_locked pages and then sleeps waiting one page to become unlocked.
the other version when find one page locked will continue until it
liberates one non locked page, and then will "repeat" the process from
the begining.  If my reasoning is wrong, please point me where, I can
see where.

Thanks a lot for your comments and your good work.

Later, Juan.

-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
