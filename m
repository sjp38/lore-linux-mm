From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20070910112031.3097.69533.sendpatchset@skynet.skynet.ie>
In-Reply-To: <20070910112011.3097.8438.sendpatchset@skynet.skynet.ie>
References: <20070910112011.3097.8438.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 1/13] ia64: parse kernel parameter hugepagesz= in early boot
Date: Mon, 10 Sep 2007 12:20:31 +0100 (IST)
Sender: owner-linux-mm@kvack.org
Subject: ia64: parse kernel parameter hugepagesz= in early boot
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Parse hugepagesz with early_param() instead of __setup().  __setup()
is called after the memory allocator has been initialised and the
pageblock bitmaps already setup.  In tests on one IA64 there did not
seem to be any problem with using early_param() and in fact may be
more correct as it guarantees the parameter is handled before the
parsing of hugepages=.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Acked-by: Andy Whitcroft <apw@shadowen.org>
Acked-by: Christoph Lameter <clameter@sgi.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 arch/ia64/Kconfig          |    5 +++++
 arch/ia64/mm/hugetlbpage.c |    4 ++--
 2 files changed, 7 insertions(+), 2 deletions(-)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc5-clean/arch/ia64/Kconfig linux-2.6.23-rc5-001-ia64-parse-kernel-parameter-hugepagesz=-in-early-boot/arch/ia64/Kconfig
--- linux-2.6.23-rc5-clean/arch/ia64/Kconfig	2007-09-01 07:08:24.000000000 +0100
+++ linux-2.6.23-rc5-001-ia64-parse-kernel-parameter-hugepagesz=-in-early-boot/arch/ia64/Kconfig	2007-09-02 16:18:48.000000000 +0100
@@ -54,6 +54,11 @@ config ARCH_HAS_ILOG2_U64
 	bool
 	default n
 
+config HUGETLB_PAGE_SIZE_VARIABLE
+	bool
+	depends on HUGETLB_PAGE
+	default y
+
 config GENERIC_FIND_NEXT_BIT
 	bool
 	default y
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc5-clean/arch/ia64/mm/hugetlbpage.c linux-2.6.23-rc5-001-ia64-parse-kernel-parameter-hugepagesz=-in-early-boot/arch/ia64/mm/hugetlbpage.c
--- linux-2.6.23-rc5-clean/arch/ia64/mm/hugetlbpage.c	2007-09-01 07:08:24.000000000 +0100
+++ linux-2.6.23-rc5-001-ia64-parse-kernel-parameter-hugepagesz=-in-early-boot/arch/ia64/mm/hugetlbpage.c	2007-09-02 16:18:48.000000000 +0100
@@ -194,6 +194,6 @@ static int __init hugetlb_setup_sz(char 
 	 * override here with new page shift.
 	 */
 	ia64_set_rr(HPAGE_REGION_BASE, hpage_shift << 2);
-	return 1;
+	return 0;
 }
-__setup("hugepagesz=", hugetlb_setup_sz);
+early_param("hugepagesz", hugetlb_setup_sz);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
