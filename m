Date: Mon, 21 Nov 2005 12:00:38 -0200
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: [PATCH] properly account readahead file major faults
Message-ID: <20051121140038.GA27349@logos.cnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org, linux-mm@kvack.org
Cc: Wu Fengguang <wfg@mail.ustc.edu.cn>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi,

The fault accounting of filemap_dopage() is currently unable to account
for readahead pages as major faults.

Which means that getrusage's major fault reporting is pretty useless.

Fix that by using the PageReferenced and PageActive bits: allows
differentiation between newly accessed pages and reaccessed pages.

Follows the output of "/usr/bin/time -v"  of an app which reads
10MB through a mapping on cold pagecache.

BEFORE PATCH:
Size: 10MB
Loops: 10
opening ./scan-testfile
reading scan-testfile, length = 10MB
	Command being timed: "./scan-shared 10 10"
<snip>
	Major (requiring I/O) page faults: 225
	Minor (reclaiming a frame) page faults: 2437

AFTER PATCH:
Size: 10MB
Loops: 10
opening ./scan-testfile
reading scan-testfile, length = 10MB
	Command being timed: "./scan-shared 10 10"
<>snip>
	Major (requiring I/O) page faults: 2562
	Minor (reclaiming a frame) page faults: 101



Signed-off-by: Marcelo Tosatti <marcelo.tosatti@cyclades.com>

diff --git a/mm/filemap.c b/mm/filemap.c
index 5d6e4c2..8655443 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1237,14 +1237,6 @@ retry_find:
 		if (ra->mmap_miss > ra->mmap_hit + MMAP_LOTSAMISS)
 			goto no_cached_page;
 
-		/*
-		 * To keep the pgmajfault counter straight, we need to
-		 * check did_readaround, as this is an inner loop.
-		 */
-		if (!did_readaround) {
-			majmin = VM_FAULT_MAJOR;
-			inc_page_state(pgmajfault);
-		}
 		did_readaround = 1;
 		ra_pages = max_sane_readahead(file->f_ra.ra_pages);
 		if (ra_pages) {
@@ -1273,6 +1265,15 @@ success:
 	/*
 	 * Found the page and have a reference on it.
 	 */
+	if (PageActive(page) && !PageReferenced(page)) {
+  		/* only account active pages as major faults, since inactive
+		 * pages might have their referenced bit cleaned by 
+		 * memory scanning.
+		 */
+		majmin = VM_FAULT_MAJOR;
+		inc_page_state(pgmajfault);
+	}
+
 	mark_page_accessed(page);
 	if (type)
 		*type = majmin;
@@ -1312,10 +1313,6 @@ no_cached_page:
 	return NULL;
 
 page_not_uptodate:
-	if (!did_readaround) {
-		majmin = VM_FAULT_MAJOR;
-		inc_page_state(pgmajfault);
-	}
 	lock_page(page);
 
 	/* Did it get unhashed while we waited for it? */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
