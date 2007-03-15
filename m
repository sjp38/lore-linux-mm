Message-ID: <45F96CCB.4000709@redhat.com>
Date: Thu, 15 Mar 2007 11:56:59 -0400
From: Chuck Ebbert <cebbert@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/filemap.c: unconditionally call mark_page_accessed
References: <Pine.GSO.4.64.0703081612290.1080@cpu102.cs.uwaterloo.ca> <20070312142012.GH30777@atrey.karlin.mff.cuni.cz> <20070312143900.GB6016@wotan.suse.de> <20070312151355.GB23532@duck.suse.cz> <Pine.GSO.4.64.0703121247210.7679@cpu102.cs.uwaterloo.ca> <20070312173500.GF23532@duck.suse.cz> <Pine.GSO.4.64.0703131438580.8193@cpu102.cs.uwaterloo.ca> <20070313185554.GA5105@duck.suse.cz> <Pine.GSO.4.64.0703141218530.28958@cpu102.cs.uwaterloo.ca>
In-Reply-To: <Pine.GSO.4.64.0703141218530.28958@cpu102.cs.uwaterloo.ca>
Content-Type: multipart/mixed;
 boundary="------------060500060806000801000906"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ashif Harji <asharji@cs.uwaterloo.ca>
Cc: linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Jan Kara <jack@suse.cz>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------060500060806000801000906
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Ashif Harji wrote:
> 
> This patch unconditionally calls mark_page_accessed to prevent pages,
> especially for small files, from being evicted from the page cache
> despite frequent access.
> 
> Signed-off-by: Ashif Harji <asharji@beta.uwaterloo.ca>
> 

I like mine better -- it leaves the comment:



--------------060500060806000801000906
Content-Type: text/plain;
 name="linux-2.6-fix_mark_page_accessed.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="linux-2.6-fix_mark_page_accessed.patch"

From: Chuck Ebbert <cebbert@redhat.com>

Always mark page as accessed when reading multiple times.
Original idea and patch by Ashif Harji <asharji@cs.uwaterloo.ca>

Signed-off-by: Chuck Ebbert <cebbert@redhat.com>

--- 2.6.20.2-t.orig/mm/filemap.c
+++ 2.6.20.2-t/mm/filemap.c
@@ -887,7 +887,6 @@
 	unsigned long offset;
 	unsigned long last_index;
 	unsigned long next_index;
-	unsigned long prev_index;
 	loff_t isize;
 	struct page *cached_page;
 	int error;
@@ -896,7 +895,6 @@
 	cached_page = NULL;
 	index = *ppos >> PAGE_CACHE_SHIFT;
 	next_index = index;
-	prev_index = ra.prev_page;
 	last_index = (*ppos + desc->count + PAGE_CACHE_SIZE-1) >> PAGE_CACHE_SHIFT;
 	offset = *ppos & ~PAGE_CACHE_MASK;
 
@@ -945,11 +943,9 @@
 
 		/*
 		 * When (part of) the same page is read multiple times
-		 * in succession, only mark it as accessed the first time.
+		 * in succession, always mark it accessed.
 		 */
-		if (prev_index != index)
-			mark_page_accessed(page);
-		prev_index = index;
+		mark_page_accessed(page);
 
 		/*
 		 * Ok, we have the page, and it's up-to-date, so

--------------060500060806000801000906--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
