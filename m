From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199910282328.QAA86411@google.engr.sgi.com>
Subject: [PATCH] kanoj-mm22-2.3.23 mprotect/mremap minor fixes
Date: Thu, 28 Oct 1999 16:28:01 -0700 (PDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@transmeta.com
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Linus,

These are two small patches. The mprotect patch is needed to protect 
the pte updates from kswapd. The mremap patch is needed in the context
of clone's, where a clone of the process doing the mremap() might 
drag the old translation into the tlb right after mremamp() has done
the flush_tlb_range(), but before it has invalidated the old pte.

Thanks.

Kanoj

--- /usr/tmp/p_rdiff_a002W5/mprotect.c	Thu Oct 28 16:20:56 1999
+++ mm/mprotect.c	Thu Oct 28 14:08:55 1999
@@ -72,11 +72,13 @@
 	flush_cache_range(current->mm, beg, end);
 	if (start >= end)
 		BUG();
+	spin_lock(&current->mm->page_table_lock);
 	do {
 		change_pmd_range(dir, start, end - start, newprot);
 		start = (start + PGDIR_SIZE) & PGDIR_MASK;
 		dir++;
 	} while (start && (start < end));
+	spin_unlock(&current->mm->page_table_lock);
 	flush_tlb_range(current->mm, beg, end);
 	return;
 }
--- /usr/tmp/p_rdiff_a002WE/mremap.c	Thu Oct 28 16:21:12 1999
+++ mm/mremap.c	Thu Oct 28 14:14:40 1999
@@ -93,7 +93,6 @@
 	unsigned long offset = len;
 
 	flush_cache_range(mm, old_addr, old_addr + len);
-	flush_tlb_range(mm, old_addr, old_addr + len);
 
 	/*
 	 * This is not the clever way to do this, but we're taking the
@@ -105,6 +104,7 @@
 		if (move_one_page(mm, old_addr + offset, new_addr + offset))
 			goto oops_we_failed;
 	}
+	flush_tlb_range(mm, old_addr, old_addr + len);
 	return 0;
 
 	/*
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
