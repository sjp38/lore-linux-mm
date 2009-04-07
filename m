Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 740055F000B
	for <linux-mm@kvack.org>; Tue,  7 Apr 2009 03:45:10 -0400 (EDT)
Message-Id: <20090407072133.871329342@intel.com>
References: <20090407071729.233579162@intel.com>
Date: Tue, 07 Apr 2009 15:17:39 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 10/14] readahead: remove sync/async readahead call dependency
Content-Disposition: inline; filename=readahead-remove-call-dependancy.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ying Han <yinghan@google.com>, LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

The readahead call scheme is error-prone in that it expects on the call sites
to check for async readahead after doing any sync one. I.e. 

			if (!page)
				page_cache_sync_readahead();
			page = find_get_page();
			if (page && PageReadahead(page))
				page_cache_async_readahead();

This is because PG_readahead could be set by a sync readahead for the _current_
newly faulted in page, and the readahead code simply expects one more callback
on the same page to start the async readahead. If the caller fails to do so, it
will miss the PG_readahead bits and never able to start an async readahead.

Eliminate this insane constraint by piggy-backing the async part into the
current readahead window.

Now if an async readahead should be started immediately after a sync one,
the readahead logic itself will do it. So the following code becomes valid:
(the 'else' in particular)

			if (!page)
				page_cache_sync_readahead();
			else if (PageReadahead(page))
				page_cache_async_readahead();

Cc: Nick Piggin <npiggin@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/readahead.c |   10 ++++++++++
 1 file changed, 10 insertions(+)

--- mm.orig/mm/readahead.c
+++ mm/mm/readahead.c
@@ -446,6 +446,16 @@ ondemand_readahead(struct address_space 
 	ra->async_size = ra->size > req_size ? ra->size - req_size : ra->size;
 
 readit:
+	/*
+	 * Will this read hit the readahead marker made by itself?
+	 * If so, trigger the readahead marker hit now, and merge
+	 * the resulted next readahead window into the current one.
+	 */
+	if (offset == ra->start && ra->size == ra->async_size) {
+		ra->async_size = get_next_ra_size(ra, max);
+		ra->size += ra->async_size;
+	}
+
 	return ra_submit(ra, mapping, filp);
 }
 

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
