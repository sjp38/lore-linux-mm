Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id NAA12476
	for <linux-mm@kvack.org>; Mon, 9 Sep 2002 13:57:22 -0700 (PDT)
Message-ID: <3D7D0B20.6E595E0B@digeo.com>
Date: Mon, 09 Sep 2002 13:57:04 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: [PATCH] modified segq for 2.5
References: <3D7CF077.FB251EC7@digeo.com> <Pine.LNX.4.44L.0209091622470.1857-100000@imladris.surriel.com> <3D7D09D7.2AE5AD71@digeo.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>, William Lee Irwin III <wli@holomorphy.com>, sfkaplan@cs.amherst.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> 
> Rik van Riel wrote:
> >
> > ...
> > > > Hmmm indeed, I forgot this.  Note that IO completion state is
> > > > too late, since then you'll have already pushed other pages
> > > > out to the inactive list...
> > >
> > > OK.  So how would you like to handle those pages?
> >
> > Move them to the inactive list the moment we're done writing
> > them, that is, the moment we move on to the next page. We
> > wouldn't want to move the last page from /var/log/messages to
> > the inactive list all the time ;)
> 
> The moment "who" has done writing them?  Some writeout
> comes in via shrink_foo() and a ton of writeout comes in
> via balance_dirty_pages(), pdflush, etc.
> 
> Do we need to distinguish between the various contexts?

Forget I said that.

I added this:

--- 2.5.34/fs/mpage.c~segq	Mon Sep  9 13:53:25 2002
+++ 2.5.34-akpm/fs/mpage.c	Mon Sep  9 13:54:07 2002
@@ -583,10 +583,9 @@ mpage_writepages(struct address_space *m
 				bio = mpage_writepage(bio, page, get_block,
 						&last_block_in_bio, &ret);
 			}
-			if ((current->flags & PF_MEMALLOC) &&
-					!PageActive(page) && PageLRU(page)) {
+			if (PageActive(page) && PageLRU(page)) {
 				if (!pagevec_add(&pvec, page))
-					pagevec_deactivate_inactive(&pvec);
+					pagevec_deactivate_active(&pvec);
 				page = NULL;
 			}
 			if (ret == -EAGAIN && page) {
@@ -612,7 +611,7 @@ mpage_writepages(struct address_space *m
 	 * Leave any remaining dirty pages on ->io_pages
 	 */
 	write_unlock(&mapping->page_lock);
-	pagevec_deactivate_inactive(&pvec);
+	pagevec_deactivate_active(&pvec);
 	if (bio)
 		mpage_bio_submit(WRITE, bio);
 	return ret;
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
