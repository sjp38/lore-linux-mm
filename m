Date: Tue, 23 Jul 2002 14:07:41 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: [PATCH] urgent rmap bugfix
Message-ID: <Pine.LNX.4.44L.0207231401450.3086-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Andrew Morton <akpm@zip.com.au>, linux-kernel@vger.kernel.org, rmk@arm.linux.org.uk, linux-mm@kvack.org, Craig Kulesa <ckulesa@as.arizona.edu>
List-ID: <linux-mm.kvack.org>

Hi,

it turns out there was a subtle bug in Craig Kulesa's port of
the rmap patch to 2.5, which is only apparent on non-x86 machines
where pfn 0 isn't valid.

The problem was that zap_pte_range() would clear the pte before
page_remove_rmap() would get called. This means that on these
machines the pte chain would never be removed and the machine
would oops at page_alloc.c line 98...

Thanks to Russell King for helping track down this bug.

please apply,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

===== mm/rmap.c 1.3 vs edited =====
--- 1.3/mm/rmap.c	Tue Jul 16 18:46:30 2002
+++ edited/mm/rmap.c	Tue Jul 23 14:01:23 2002
@@ -163,7 +163,7 @@
 void page_remove_rmap(struct page * page, pte_t * ptep)
 {
 	struct pte_chain * pc, * prev_pc = NULL;
-	unsigned long pfn = pte_pfn(*ptep);
+	unsigned long pfn = page_to_pfn(page);

 	if (!page || !ptep)
 		BUG();


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
