Received: from atlas.CARNet.hr (zcalusic@atlas.CARNet.hr [161.53.123.163])
	by kvack.org (8.8.7/8.8.7) with ESMTP id UAA06902
	for <linux-mm@kvack.org>; Mon, 16 Nov 1998 20:21:26 -0500
Subject: Re: unexpected paging during large file reads in 2.1.127
References: <199811161959.TAA07259@dax.scot.redhat.com> <Pine.LNX.3.96.981116214348.26465A-100000@mirkwood.dummy.home> <199811162305.XAA07996@dax.scot.redhat.com>
Reply-To: Zlatko.Calusic@CARNet.hr
From: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
Date: 17 Nov 1998 02:21:14 +0100
In-Reply-To: "Stephen C. Tweedie"'s message of "Mon, 16 Nov 1998 23:05:56 GMT"
Message-ID: <87lnlb5d2t.fsf@atlas.CARNet.hr>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Linux-MM List <linux-mm@kvack.org>, Linux Kernel List <linux-kernel@vger.rutgers.edu>
Cc: Rik van Riel <H.H.vanRiel@phys.uu.nl>, "David J. Fred" <djf@ic.net>, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>


"Stephen C. Tweedie" <sct@redhat.com> writes:

> Hi,
> 
> On Mon, 16 Nov 1998 21:48:35 +0100 (CET), Rik van Riel
> <H.H.vanRiel@phys.uu.nl> said:
> 
> > On Mon, 16 Nov 1998, Stephen C. Tweedie wrote:
> >> The real cure is to disable page aging in the page cache completely.
> >> Now that we have disabled it for swap, it makes absolutely no sense at
> >> all to keep it in the page cache.
> 

[snip]

> No, we don't.  We don't evict just-read-in data, because we mark such
> pages as PG_Referenced.  It takes two complete shrink_mmap() passes
> before we can evict such pages.

I didn't find this in the source (in fact, add_to_page_cache clears
PG_referenced bit, if I understood source correctly). But, see below.

> 
> > resulting in us having to read it again and doing double
> > I/O with a badly performing program.
> 
> The reason why this used to happen was because the readahead failed to
> mark the new page as PG_Referenced.  I've been saying for _months_ that
> the right fix was to mark them referenced rather than to do page aging
> (and all of my benchmarks, without exception, back this up).  
> 

I must agree entirely, because with small patch you can find below,
performance is very very good. Thanks to marking readahead pages as
referenced, I've been able to see exact behaviour that I wanted for a
long time. And that is, if the page cache is too small, and we start
doing lots of I/O, then it should expand slightly. Otherwise it should
be quiet, I mean, we don't want any swapouts, since that would degrade
our I/O performance.

Everybody, try the attached patch (that Stephen was suggesting long
ago, IIRC) and see for yourself. My machine is flying now. :)

Index: 128.2/mm/filemap.c
--- 128.2/mm/filemap.c Mon, 16 Nov 1998 23:45:38 +0100 zcalusic (linux-2.1/y/b/29_filemap.c 1.2.4.1.1.1 644)
+++ 128.3(w)/mm/filemap.c Tue, 17 Nov 1998 01:41:53 +0100 zcalusic (linux-2.1/y/b/29_filemap.c 1.2.4.1.1.2 644)
@@ -172,20 +172,14 @@
 				delete_from_swap_cache(page);
 				return 1;
 			}
-			if (test_and_clear_bit(PG_referenced, &page->flags)) {
-				touch_page(page);
-				break;
-			}
-			age_page(page);
-			if (page->age)
+			if (test_and_clear_bit(PG_referenced, &page->flags))
 				break;
 			if (pgcache_under_min())
 				break;
 			remove_inode_page(page);
 			return 1;
 		}
-		/* It's not a cache page, so we don't do aging.
-		 * If it has been referenced recently, don't free it */
+		/* if page has been referenced recently, don't free it */
 		if (test_and_clear_bit(PG_referenced, &page->flags))
 			break;
 
@@ -212,8 +206,8 @@
 	struct page * page;
 	int count_max, count_min;
 
-	count_max = (limit<<2) >> (priority>>1);
-	count_min = (limit<<2) >> (priority);
+	count_max = (limit<<1) >> (priority>>1);
+	count_min = (limit<<1) >> (priority);
 
 	page = mem_map + clock;
 	do {
@@ -328,6 +322,7 @@
 			 */
 			page = mem_map + MAP_NR(page_cache);
 			add_to_page_cache(page, inode, offset, hash);
+			set_bit(PG_referenced, &page->flags);
 			inode->i_op->readpage(file, page);
 			page_cache = 0;
 		}

Regards,
-- 
Posted by Zlatko Calusic           E-mail: <Zlatko.Calusic@CARNet.hr>
---------------------------------------------------------------------
		 43% of all statistics are worthless.
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
