Received: from haymarket.ed.ac.uk (haymarket.ed.ac.uk [129.215.128.53])
	by kvack.org (8.8.7/8.8.7) with ESMTP id LAA10267
	for <linux-mm@kvack.org>; Wed, 29 Jul 1998 11:55:06 -0400
Date: Wed, 29 Jul 1998 12:12:31 +0100
Message-Id: <199807291112.MAA01247@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: Page cache ageing: yae or nae?
In-Reply-To: <Pine.LNX.3.96.980728180533.6846A-100000@mirkwood.dummy.home>
References: <199807271051.LAA00702@dax.dcs.ed.ac.uk>
	<Pine.LNX.3.96.980728180533.6846A-100000@mirkwood.dummy.home>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, 28 Jul 1998 18:13:11 +0200 (CEST), Rik van Riel
<H.H.vanRiel@phys.uu.nl> said:

> On Mon, 27 Jul 1998, Stephen C. Tweedie wrote:
>> Could you let me know just what benchmarks you were running when you
>> added the first page ageing code to see a speedup?  I think we need to

> It's not really a benchmark; it's just that mp3s or
> quicktimes (played from disk instead of ram) run
> smoothly with page aging and skip without.

Right, but we don't need page aging to address that.  Currently we don't
set the page referenced bit on a readahead IO; setting that bit will be
sufficient to guard the page for at least one full pass of the
shrink_mmap scan.

Can you try the patch below (to 112-pre2) and see if it allows smooth
playback?  It disables page aging and restores the original shrink_mmap
loop limits, but adds the one-pass readahead protection.

--Stephen

----------------------------------------------------------------
--- mm/filemap.c.~1~	Wed Jul 29 11:50:58 1998
+++ mm/filemap.c	Wed Jul 29 12:01:31 1998
@@ -172,11 +172,13 @@
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
@@ -212,8 +214,8 @@
 	struct page * page;
 	int count_max, count_min;
 
-	count_max = (limit<<2) >> (priority>>1);
-	count_min = (limit<<2) >> (priority);
+	count_max = (limit<<1) >> (priority>>1);
+	count_min = (limit<<1) >> (priority);
 
 	page = mem_map + clock;
 	do {
@@ -322,6 +324,7 @@
 			 */
 			page = mem_map + MAP_NR(page_cache);
 			add_to_page_cache(page, inode, offset, hash);
+			set_bit(PG_referenced, &page->flags);
 			inode->i_op->readpage(file, page);
 			page_cache = 0;
 		}
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
