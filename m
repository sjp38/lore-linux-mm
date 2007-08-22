Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 03 of 24] prevent oom deadlocks during read/write operations
Message-Id: <5566f2af006a171cd47d.1187786930@v2.random>
In-Reply-To: <patchbomb.1187786927@v2.random>
Date: Wed, 22 Aug 2007 14:48:50 +0200
From: Andrea Arcangeli <andrea@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

# HG changeset patch
# User Andrea Arcangeli <andrea@suse.de>
# Date 1187778124 -7200
# Node ID 5566f2af006a171cd47d596c6654f51beca74203
# Parent  90afd499e8ca0dfd2e0284372dca50f2e6149700
prevent oom deadlocks during read/write operations

We need to react to SIGKILL during read/write with huge buffers or it
becomes too easy to prevent a SIGKILLED task to run do_exit promptly
after it has been selected for oom-killage.

Signed-off-by: Andrea Arcangeli <andrea@suse.de>

diff --git a/mm/filemap.c b/mm/filemap.c
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -925,6 +925,13 @@ page_ok:
 			goto out;
 		}
 
+		if (unlikely(sigismember(&current->pending.signal, SIGKILL)))
+			/*
+			 * Must not hang almost forever in D state in presence of sigkill
+			 * and lots of ram/swap (think during OOM).
+			 */
+			break;
+
 		/* nr is the maximum number of bytes to copy from this page */
 		nr = PAGE_CACHE_SIZE;
 		if (index == end_index) {
@@ -1868,6 +1875,13 @@ generic_file_buffered_write(struct kiocb
 		unsigned long index;
 		unsigned long offset;
 		size_t copied;
+
+		if (unlikely(sigismember(&current->pending.signal, SIGKILL)))
+			/*
+			 * Must not hang almost forever in D state in presence of sigkill
+			 * and lots of ram/swap (think during OOM).
+			 */
+			break;
 
 		offset = (pos & (PAGE_CACHE_SIZE -1)); /* Within page */
 		index = pos >> PAGE_CACHE_SHIFT;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
