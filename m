Date: Sat, 14 Oct 2006 07:04:18 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 6/6] mm: fix pagecache write deadlocks
Message-ID: <20061014050418.GB23740@wotan.suse.de>
References: <20061013143516.15438.8802.sendpatchset@linux.site> <20061013143616.15438.77140.sendpatchset@linux.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20061013143616.15438.77140.sendpatchset@linux.site>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management <linux-mm@kvack.org>
Cc: Neil Brown <neilb@suse.de>, Andrew Morton <akpm@osdl.org>, Anton Altaparmakov <aia21@cam.ac.uk>, Chris Mason <chris.mason@oracle.com>, Linux Kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, Oct 13, 2006 at 06:44:52PM +0200, Nick Piggin wrote:
> From: Andrew Morton <akpm@osdl.org> and Nick Piggin <npiggin@suse.de>
> 
> The idea is to modify the core write() code so that it won't take a pagefault
> while holding a lock on the pagecache page. There are a number of different
> deadlocks possible if we try to do such a thing:

Here is a patch to improve the comment a little. This is a pretty tricky
situation so we must be clear as to why it works.
--

Comment was not entirely clear about why we must eliminate all other
possibilities.

Signed-off-by: Nick Piggin <npiggin@suse.de>

Index: linux-2.6/mm/filemap.c
===================================================================
--- linux-2.6.orig/mm/filemap.c
+++ linux-2.6/mm/filemap.c
@@ -1946,12 +1946,19 @@ retry_noprogress:
 		if (!PageUptodate(page)) {
 			/*
 			 * If the page is not uptodate, we cannot allow a
-			 * partial commit_write, because that might expose
-			 * uninitialised data.
+			 * partial commit_write because when we unlock the
+			 * page below, someone else might bring it uptodate
+			 * and we lose our write. We cannot allow a full
+			 * commit_write, because that exposes uninitialised
+			 * data. We cannot zero the rest of the file and do
+			 * a full commit_write because that exposes transient
+			 * zeroes.
 			 *
-			 * We will enter the single-segment path below, which
-			 * should get the filesystem to bring the page
-			 * uputodate for us next time.
+			 * Abort the operation entirely with a zero length
+			 * commit_write. Retry.  We will enter the
+			 * single-segment path below, which should get the
+			 * filesystem to bring the page uputodate for us next
+			 * time.
 			 */
 			if (unlikely(copied != bytes))
 				copied = 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
