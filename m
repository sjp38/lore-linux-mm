Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 03 of 11] prevent oom deadlocks during read/write operations
Message-Id: <71f1d848763c80f336f7.1199326149@v2.random>
In-Reply-To: <patchbomb.1199326146@v2.random>
Date: Thu, 03 Jan 2008 03:09:09 +0100
From: Andrea Arcangeli <andrea@cpushare.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

# HG changeset patch
# User Andrea Arcangeli <andrea@suse.de>
# Date 1199324664 -3600
# Node ID 71f1d848763c80f336f7f9f23dcbe8f7e43c82aa
# Parent  3ec0754b24738f5658baf2a1ebacc7d3f2c17283
prevent oom deadlocks during read/write operations

We need to react to SIGKILL during read/write with huge buffers or it
becomes too easy to prevent a SIGKILLED task to run do_exit promptly
after it has been selected for oom-killage.

Signed-off-by: Andrea Arcangeli <andrea@suse.de>

diff --git a/mm/filemap.c b/mm/filemap.c
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -927,6 +927,16 @@ page_ok:
 		isize = i_size_read(inode);
 		end_index = (isize - 1) >> PAGE_CACHE_SHIFT;
 		if (unlikely(!isize || index > end_index)) {
+			page_cache_release(page);
+			goto out;
+		}
+
+		if (unlikely(sigismember(&current->pending.signal, SIGKILL))) {
+			/*
+			 * Must not hang almost forever in D state in
+			 * presence of sigkill and lots of ram/swap
+			 * (think during OOM).
+			 */
 			page_cache_release(page);
 			goto out;
 		}
@@ -2063,6 +2073,16 @@ static ssize_t generic_perform_write_2co
 			break;
 		}
 
+		if (unlikely(sigismember(&current->pending.signal, SIGKILL))) {
+			/*
+			 * Must not hang almost forever in D state in
+			 * presence of sigkill and lots of ram/swap
+			 * (think during OOM).
+			 */
+			status = -ENOMEM;
+			break;
+		}
+
 		page = __grab_cache_page(mapping, index);
 		if (!page) {
 			status = -ENOMEM;
@@ -2230,6 +2250,16 @@ again:
 		 */
 		if (unlikely(iov_iter_fault_in_readable(i, bytes))) {
 			status = -EFAULT;
+			break;
+		}
+
+		if (unlikely(sigismember(&current->pending.signal, SIGKILL))) {
+			status = -ENOMEM;
+			/*
+			 * Must not hang almost forever in D state in
+			 * presence of sigkill and lots of ram/swap
+			 * (think during OOM).
+			 */
 			break;
 		}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
