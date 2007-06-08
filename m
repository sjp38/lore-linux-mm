Received: from Relay2.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx2.suse.de (Postfix) with ESMTP id 3850A21951
	for <linux-mm@kvack.org>; Fri,  8 Jun 2007 22:06:36 +0200 (CEST)
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 03 of 16] prevent oom deadlocks during read/write operations
Message-Id: <532a5f712848ee75d827.1181332981@v2.random>
In-Reply-To: <patchbomb.1181332978@v2.random>
Date: Fri, 08 Jun 2007 22:03:01 +0200
From: Andrea Arcangeli <andrea@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

# HG changeset patch
# User Andrea Arcangeli <andrea@suse.de>
# Date 1181332960 -7200
# Node ID 532a5f712848ee75d827bfe233b9364a709e1fc1
# Parent  d64cb81222748354bf5b16258197217465f35aeb
prevent oom deadlocks during read/write operations

We need to react to SIGKILL during read/write with huge buffers or it
becomes too easy to prevent a SIGKILLED task to run do_exit promptly
after it has been selected for oom-killage.

Signed-off-by: Andrea Arcangeli <andrea@suse.de>

diff --git a/mm/filemap.c b/mm/filemap.c
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -894,6 +894,13 @@ void do_generic_mapping_read(struct addr
 		struct page *page;
 		unsigned long nr, ret;
 
+		if (unlikely(sigismember(&current->pending.signal, SIGKILL)))
+			/*
+			 * Must not hang almost forever in D state in presence of sigkill
+			 * and lots of ram/swap (think during OOM).
+			 */
+			break;
+
 		/* nr is the maximum number of bytes to copy from this page */
 		nr = PAGE_CACHE_SIZE;
 		if (index >= end_index) {
@@ -2105,6 +2112,13 @@ generic_file_buffered_write(struct kiocb
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
