Date: Wed, 14 Mar 2007 15:58:43 -0400 (EDT)
From: Ashif Harji <asharji@cs.uwaterloo.ca>
Subject: [PATCH] mm/filemap.c: unconditionally call mark_page_accessed
In-Reply-To: <20070313185554.GA5105@duck.suse.cz>
Message-ID: <Pine.GSO.4.64.0703141218530.28958@cpu102.cs.uwaterloo.ca>
References: <Pine.GSO.4.64.0703081612290.1080@cpu102.cs.uwaterloo.ca>
 <20070312142012.GH30777@atrey.karlin.mff.cuni.cz> <20070312143900.GB6016@wotan.suse.de>
 <20070312151355.GB23532@duck.suse.cz> <Pine.GSO.4.64.0703121247210.7679@cpu102.cs.uwaterloo.ca>
 <20070312173500.GF23532@duck.suse.cz> <Pine.GSO.4.64.0703131438580.8193@cpu102.cs.uwaterloo.ca>
 <20070313185554.GA5105@duck.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Nick Piggin <npiggin@suse.de>, Jan Kara <jack@suse.cz>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

This patch unconditionally calls mark_page_accessed to prevent pages, 
especially for small files, from being evicted from the page cache despite 
frequent access.

Signed-off-by: Ashif Harji <asharji@beta.uwaterloo.ca>

---

If the same page of a file is repeatedly accessed (without accessing other 
pages of that file) via the same file descriptor, mark_page_accessed is 
never called after the first time the page is accessed.

The implication of this code is that for files of size less than or equal 
to a single page, the page associated with such a file is likely to get 
evicted from the cache regardless of how frequently it is accessed. 
However, this behaviour also occurs with files of any size if the same 
page is repeatedly accessed.

As a benchmark, I have an experimental web server that uses sendfile to 
repeatedly transmit files.  The files are based on the static portion of 
the SPECweb99 fileset and range in size to model a reasonable workload. 
With this workload, a significant number of the requests are for files of 
size 4 KB or less.

By changing the kernel to always call mark_page_accessed, the server 
throughput is increased by as much as 20%.  With one test, for example, 
without the change I get throughput of around 868 Mbps.  After making the 
change, performance increases to 1111 Mbps.

Using a configuration that should be unaffected by the change, performance 
was around 855 Mbps without the change and around 851 Mbps with the 
change.  As expected the change had no appreciable effect.

See thread http://lkml.org/lkml/2007/3/9/403 for additional discussion on 
this change.

This patch is for kernel version 2.6.20.1.

Andrew, can you also put this change into the -mm kernels for testing?


--- linux-2.6.20.1/mm/filemap.c.orig	2007-03-14 10:31:58.000000000 -0500
+++ linux-2.6.20.1/mm/filemap.c	2007-03-13 16:11:54.000000000 -0500
@@ -943,12 +943,7 @@ page_ok:
  		if (mapping_writably_mapped(mapping))
  			flush_dcache_page(page);

-		/*
-		 * When (part of) the same page is read multiple times
-		 * in succession, only mark it as accessed the first time.
-		 */
-		if (prev_index != index)
-			mark_page_accessed(page);
+		mark_page_accessed(page);
  		prev_index = index;

  		/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
