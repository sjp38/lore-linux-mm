Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 2E00D6B0169
	for <linux-mm@kvack.org>; Sun, 14 Aug 2011 09:11:08 -0400 (EDT)
Date: Sun, 14 Aug 2011 15:10:53 +0200
From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: [PATCH] mm: fix wrong vmap address calculations with odd NR_CPUS
 values
Message-ID: <20110814151053.65ffc8fe@stein>
In-Reply-To: <20110814145212.312c8626@stein>
References: <20110814145212.312c8626@stein>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Nick Piggin <npiggin@kernel.dk>, Clemens Ladisch <clemens@ladisch.de>, Pavel Kysilka <goldenfish@linuxsoft.cz>, "Matias A. Fonzo" <selk@dragora.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: Clemens Ladisch <clemens@ladisch.de>
Date: Tue, 21 Jun 2011 22:09:50 +0200

Commit db64fe02258f (mm: rewrite vmap layer) introduced code that does
address calculations under the assumption that VMAP_BLOCK_SIZE is
a power of two.  However, this might not be true if CONFIG_NR_CPUS is
not set to a power of two.

Wrong vmap_block index/offset values could lead to memory corruption.
However, this has never been observed in practice (or never been
diagnosed correctly); what caught this was the BUG_ON in vb_alloc() that
checks for inconsistent vmap_block indices.

To fix this, ensure that VMAP_BLOCK_SIZE always is a power of two.

BugLink: https://bugzilla.kernel.org/show_bug.cgi?id=31572
Reported-by: Pavel Kysilka <goldenfish@linuxsoft.cz>
Reported-by: Matias A. Fonzo <selk@dragora.org>
Signed-off-by: Clemens Ladisch <clemens@ladisch.de>
Signed-off-by: Stefan Richter <stefanr@s5r6.in-berlin.de>
Cc: 2.6.28+ <stable@kernel.org>
---
Resend with corrected Cc list; sorry.

This fixes instant and fully repeatable crashes if NR_CPUS is not a power
of two and vm_map_ram() or something like that is executed, for example
firewire-ohci probe in its 2.6.38+ incarnation.

 mm/vmalloc.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 1d34d75..d3d451b 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -732,9 +732,10 @@ static void free_unmap_vmap_area_addr(unsigned long addr)
 #define VMAP_BBMAP_BITS_MIN	(VMAP_MAX_ALLOC*2)
 #define VMAP_MIN(x, y)		((x) < (y) ? (x) : (y)) /* can't use min() */
 #define VMAP_MAX(x, y)		((x) > (y) ? (x) : (y)) /* can't use max() */
-#define VMAP_BBMAP_BITS		VMAP_MIN(VMAP_BBMAP_BITS_MAX,		\
-					VMAP_MAX(VMAP_BBMAP_BITS_MIN,	\
-						VMALLOC_PAGES / NR_CPUS / 16))
+#define VMAP_BBMAP_BITS		\
+		VMAP_MIN(VMAP_BBMAP_BITS_MAX,	\
+		VMAP_MAX(VMAP_BBMAP_BITS_MIN,	\
+			VMALLOC_PAGES / roundup_pow_of_two(NR_CPUS) / 16))
 
 #define VMAP_BLOCK_SIZE		(VMAP_BBMAP_BITS * PAGE_SIZE)
 
-- 
1.7.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
