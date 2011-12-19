Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id E8D126B005C
	for <linux-mm@kvack.org>; Mon, 19 Dec 2011 05:36:33 -0500 (EST)
Message-Id: <20111219102357.846551861@intel.com>
Date: Mon, 19 Dec 2011 18:23:18 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 10/10] readahead: snap readahead request to EOF
References: <20111219102308.488847921@intel.com>
Content-Disposition: inline; filename=readahead-eof
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, Jan Kara <jack@suse.cz>, Wu Fengguang <fengguang.wu@intel.com>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

If the file size is 20kb and readahead request is [0, 16kb),
it's better to expand the readahead request to [0, 20kb), which will
likely save one followup I/O for the ending [16kb, 20kb).

If the readahead request already covers EOF, trimm it down to EOF.
Also don't set the PG_readahead mark to avoid an unnecessary future
invocation of the readahead code.

This special handling looks worthwhile because small to medium sized
files are pretty common.

Acked-by: Jan Kara <jack@suse.cz>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/readahead.c |   21 +++++++++++++++++++++
 1 file changed, 21 insertions(+)

--- linux-next.orig/mm/readahead.c	2011-12-19 16:09:45.000000000 +0800
+++ linux-next/mm/readahead.c	2011-12-19 16:10:04.000000000 +0800
@@ -457,6 +457,25 @@ unsigned long max_sane_readahead(unsigne
 		+ node_page_state(numa_node_id(), NR_FREE_PAGES)) / 2);
 }
 
+static void snap_to_eof(struct file_ra_state *ra, struct address_space *mapping)
+{
+	pgoff_t eof = ((i_size_read(mapping->host)-1) >> PAGE_CACHE_SHIFT) + 1;
+	pgoff_t start = ra->start;
+	unsigned int size = ra->size;
+
+	/*
+	 * skip backwards and random reads
+	 */
+	if (ra->pattern > RA_PATTERN_MMAP_AROUND)
+		return;
+
+	size += min(size / 2, ra->ra_pages / 4);
+	if (start + size > eof) {
+		ra->size = eof - start;
+		ra->async_size = 0;
+	}
+}
+
 /*
  * Submit IO for the read-ahead request in file_ra_state.
  */
@@ -468,6 +487,8 @@ unsigned long ra_submit(struct file_ra_s
 {
 	int actual;
 
+	snap_to_eof(ra, mapping);
+
 	actual = __do_page_cache_readahead(mapping, filp,
 					ra->start, ra->size, ra->async_size);
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
