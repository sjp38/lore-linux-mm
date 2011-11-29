Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 94CF36B004D
	for <linux-mm@kvack.org>; Tue, 29 Nov 2011 08:26:16 -0500 (EST)
Message-Id: <20111129131456.145362960@intel.com>
Date: Tue, 29 Nov 2011 21:09:02 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 2/9] readahead: snap readahead request to EOF
References: <20111129130900.628549879@intel.com>
Content-Disposition: inline; filename=readahead-eof
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

If the file size is 20kb and readahead request is [0, 16kb),
it's better to expand the readahead request to [0, 20kb), which will
likely save one followup I/O for [16kb, 20kb).

If the readahead request already covers EOF, trimm it down to EOF.
Also don't set the PG_readahead mark to avoid an unnecessary future
invocation of the readahead code.

This special handling looks worthwhile because small to medium sized
files are pretty common.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/readahead.c |    8 ++++++++
 1 file changed, 8 insertions(+)

--- linux-next.orig/mm/readahead.c	2011-11-29 11:28:56.000000000 +0800
+++ linux-next/mm/readahead.c	2011-11-29 11:29:05.000000000 +0800
@@ -251,8 +251,16 @@ unsigned long max_sane_readahead(unsigne
 unsigned long ra_submit(struct file_ra_state *ra,
 		       struct address_space *mapping, struct file *filp)
 {
+	pgoff_t eof = ((i_size_read(mapping->host)-1) >> PAGE_CACHE_SHIFT) + 1;
+	pgoff_t start = ra->start;
 	int actual;
 
+	/* snap to EOF */
+	if (start + ra->size + ra->size / 2 > eof) {
+		ra->size = eof - start;
+		ra->async_size = 0;
+	}
+
 	actual = __do_page_cache_readahead(mapping, filp,
 					ra->start, ra->size, ra->async_size);
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
