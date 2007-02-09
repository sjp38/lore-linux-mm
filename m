Date: Fri, 9 Feb 2007 00:41:51 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [patch 0/3] 2.6.20 fix for PageUptodate memorder problem (try
 2)
In-Reply-To: <20070208111421.30513.77904.sendpatchset@linux.site>
Message-ID: <Pine.LNX.4.64.0702090027580.29905@blonde.wat.veritas.com>
References: <20070208111421.30513.77904.sendpatchset@linux.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@osdl.org>, Linux Memory Management <linux-mm@kvack.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Linux Kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, 8 Feb 2007, Nick Piggin wrote:
> Still no independent confirmation as to whether this is a problem or not.

I'm trying to convince myself none of your patch is necessary.  Probably
shall fail.  But how come we've survived for years with such an issue?

> Updated some comments, added diffstats to patches, don't use
> __SetPageUptodate as an internal page-flags.h private function.

Depressed by profusion of PageUptodate_UpperAndlowercasevariants.
Those rmbs, you really only want them when it says "yes", don't you?

> 
> I would like to eventually get an ack from Hugh regarding the anon memory
> and especially swap side of the equation,

Plea noted.  I'm pondering.  "Eventually" indeed.  OTOH I expect you're
right to criticize anon/swap PageUptodate being set where it was needed
to get by, rather than where it was natural to do so.

> and a glance from whoever put the
> smp_wmb()s into the copy functions (Was it Ben H or Anton maybe?)

From: Linus Torvalds <torvalds@ppc970.osdl.org>
Date: Thu, 14 Oct 2004 04:00:06 +0000 (-0700)
Subject: Fix threaded user page write memory ordering
X-Git-Tag: v2.6.9-final~3
X-Git-Url: http://127.0.0.1:1234/?p=.git;a=commitdiff_plain;h=538ce05c0ef4055cf29a92a4abcdf139d180a0f9;hp=8c225dbc5a7b13801a8254aae0ccebab8e4bece7

Fix threaded user page write memory ordering

Make sure we order the writes to a newly created page
with the page table update that potentially exposes the
page to another CPU.

This is a no-op on any architecture where getting the
page table spinlock will already do the ordering (notably
x86), but other architectures can care.
---

diff --git a/include/linux/highmem.h b/include/linux/highmem.h
index 232d8fd..7153aef 100644
--- a/include/linux/highmem.h
+++ b/include/linux/highmem.h
@@ -40,6 +40,8 @@ static inline void clear_user_highpage(s
 	void *addr = kmap_atomic(page, KM_USER0);
 	clear_user_page(addr, vaddr, page);
 	kunmap_atomic(addr, KM_USER0);
+	/* Make sure this page is cleared on other CPU's too before using it */
+	smp_wmb();
 }
 
 static inline void clear_highpage(struct page *page)
@@ -73,6 +75,8 @@ static inline void copy_user_highpage(st
 	copy_user_page(vto, vfrom, vaddr, to);
 	kunmap_atomic(vfrom, KM_USER0);
 	kunmap_atomic(vto, KM_USER1);
+	/* Make sure this page is cleared on other CPU's too before using it */
+	smp_wmb();
 }
 
 static inline void copy_highpage(struct page *to, struct page *from)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
