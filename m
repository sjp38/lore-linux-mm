Received: from haymarket.ed.ac.uk (haymarket.ed.ac.uk [129.215.128.53])
	by kvack.org (8.8.7/8.8.7) with ESMTP id PAA07871
	for <linux-mm@kvack.org>; Wed, 19 Aug 1998 15:28:09 -0400
Date: Wed, 19 Aug 1998 16:19:47 +0100
Message-Id: <199808191519.QAA07314@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: Page cache ageing: yae or nae? (fwd)
In-Reply-To: <Pine.LNX.3.96.980817213852.335A-100000@dragon.bogus>
References: <199808171401.PAA03007@dax.dcs.ed.ac.uk>
	<Pine.LNX.3.96.980817213852.335A-100000@dragon.bogus>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <arcangeli@mbox.queen.it>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Zlatko.Calusic@CARNet.hr, Rik van Riel <H.H.vanRiel@phys.uu.nl>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, 17 Aug 1998 21:51:33 +0200 (CEST), Andrea Arcangeli
<arcangeli@mbox.queen.it> said:

>> It _does_ throw unused pages out, by making it far easier to age pages.
>> I thought that was what we wanted: is 2.0 performing badly for you?  Is
>> this behaviour that bad?

> Bingo! After some minutes of testing seems work very well! I think we need
> this patch. The swapin/swapout seems avoided. Please Stephen forward your
> patch to Linus. I rediffed it since it doesn' t apply clean to 115.

Any other comments?  Please?  We are getting VERY close to 2.2, and we
need to have this resolved one way or the other.  This patch works well
for me in all cases, but I really need to know if there are other cases
where the page cache ageing wins other than the readahead streaming.

--Stephen


----------------------------------------------------------------
--- linux/mm/filemap.c.orig	Sat Aug  8 15:23:11 1998
+++ linux/mm/filemap.c	Mon Aug 17 18:46:19 1998
@@ -172,10 +172,12 @@
 				break;
 			}
 			age_page(page);
+#if 0
 			if (page->age)
 				break;
 			if (page_cache_size * 100 < (page_cache.min_percent * num_physpages))
 				break;
+#endif
 			if (PageSwapCache(page)) {
 				delete_from_swap_cache(page);
 				return 1;
@@ -211,8 +213,8 @@
 	struct page * page;
 	int count_max, count_min;
 
-	count_max = (limit<<2) >> (priority>>1);
-	count_min = (limit<<2) >> (priority);
+	count_max = (limit<<1) >> (priority>>1);
+	count_min = (limit<<1) >> (priority);
 
 	page = mem_map + clock;
 	do {
@@ -327,6 +329,7 @@
 			 */
 			page = mem_map + MAP_NR(page_cache);
 			add_to_page_cache(page, inode, offset, hash);
+			set_bit(PG_referenced, &page->flags);
 			inode->i_op->readpage(file, page);
 			page_cache = 0;
 		}
----------------------------------------------------------------
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
