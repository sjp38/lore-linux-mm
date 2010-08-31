Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 4C5006B007D
	for <linux-mm@kvack.org>; Tue, 31 Aug 2010 15:40:55 -0400 (EDT)
Message-Id: <20100831193924.266231784@chello.nl>
Date: Tue, 31 Aug 2010 21:26:21 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [RFC][PATCH 4/5] perf, x86: Fix up kmap_atomic type
References: <20100831192617.441439071@chello.nl>
Content-Disposition: inline; filename=kmap-x86-perf.patch
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Russell King <rmk@arm.linux.org.uk>, David Howells <dhowells@redhat.com>, Ralf Baechle <ralf@linux-mips.org>, David Miller <davem@davemloft.net>, Chris Metcalf <cmetcalf@tilera.com>, Paul Mackerras <paulus@samba.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

Now that the KM_type stuff is history, clean up the compiler warning.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 arch/x86/kernel/cpu/perf_event.c |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

Index: linux-2.6/arch/x86/kernel/cpu/perf_event.c
===================================================================
--- linux-2.6.orig/arch/x86/kernel/cpu/perf_event.c
+++ linux-2.6/arch/x86/kernel/cpu/perf_event.c
@@ -49,7 +49,6 @@ static unsigned long
 copy_from_user_nmi(void *to, const void __user *from, unsigned long n)
 {
 	unsigned long offset, addr = (unsigned long)from;
-	int type = in_nmi() ? KM_NMI : KM_IRQ0;
 	unsigned long size, len = 0;
 	struct page *page;
 	void *map;
@@ -63,9 +62,9 @@ copy_from_user_nmi(void *to, const void 
 		offset = addr & (PAGE_SIZE - 1);
 		size = min(PAGE_SIZE - offset, n - len);
 
-		map = kmap_atomic(page, type);
+		map = kmap_atomic(page);
 		memcpy(to, map+offset, size);
-		kunmap_atomic(map, type);
+		kunmap_atomic(map);
 		put_page(page);
 
 		len  += size;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
