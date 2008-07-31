Subject: mm/hugetlb: Don't crash when HPAGE_SHIFT is 0
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Reply-To: benh@kernel.crashing.org
Content-Type: text/plain; charset=UTF-8
Date: Thu, 31 Jul 2008 16:04:28 +1000
Message-Id: <1217484268.11188.419.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel list <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Some platform decide whether they support huge pages at boot
time. On these, such as powerpc, HPAGE_SHIFT is a variable, not
a constant, and is set to 0 when there is no such support.

The patches to introduce multiple huge pages support broke that
causing the kernel to crash at boot time on machines such as
POWER3 which lack support for multiple page sizes.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---

Please apply upstream ASAP.

i>>?(resent with more useful mailing list address)

Index: linux-work/mm/hugetlb.c
===================================================================
--- linux-work.orig/mm/hugetlb.c	2008-07-31 15:28:03.000000000 +1000
+++ linux-work/mm/hugetlb.c	2008-07-31 15:31:29.000000000 +1000
@@ -1283,7 +1283,12 @@ module_exit(hugetlb_exit);
 
 static int __init hugetlb_init(void)
 {
-	BUILD_BUG_ON(HPAGE_SHIFT == 0);
+	/* Some platform decide whether they support huge pages at boot
+	 * time. On these, such as powerpc, HPAGE_SHIFT is set to 0 when
+	 * there is no such support
+	 */
+	if (HPAGE_SHIFT == 0)
+		return 0;
 
 	if (!size_to_hstate(default_hstate_size)) {
 		default_hstate_size = HPAGE_SIZE;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
