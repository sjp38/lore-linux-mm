Received: from uow.edu.au (IDENT:akpm@localhost [127.0.0.1])
          by pwold011.asiapac.nortel.com (8.9.3/8.9.3) with ESMTP id LAA14579
          for <linux-mm@kvack.org>; Wed, 12 Jul 2000 11:53:45 +1000
Message-ID: <396BCFA8.C033D94A@uow.edu.au>
Date: Wed, 12 Jul 2000 01:53:44 +0000
From: Andrew Morton <andrewm@uow.edu.au>
MIME-Version: 1.0
Subject: vmtruncate question
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

The flushes which surround the second call to zap_page_range()
would appear to be flushing more memory than is to be
zapped.  Is this correct, or should it be:

--- memory.c.orig	Wed Jul 12 11:49:08 2000
+++ memory.c	Wed Jul 12 11:49:31 2000
@@ -980,9 +980,9 @@
 			partial_clear(mpnt, start);
 			start = (start + ~PAGE_MASK) & PAGE_MASK;
 		}
-		flush_cache_range(mm, start, end);
+		flush_cache_range(mm, start, start + len);
 		zap_page_range(mm, start, len);
-		flush_tlb_range(mm, start, end);
+		flush_tlb_range(mm, start, start + len);
 	} while ((mpnt = mpnt->vm_next_share) != NULL);
 out_unlock:
 	spin_unlock(&mapping->i_shared_lock);
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
