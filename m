Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id AD1FB900194
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 15:46:17 -0400 (EDT)
Received: from wpaz17.hot.corp.google.com (wpaz17.hot.corp.google.com [172.24.198.81])
	by smtp-out.google.com with ESMTP id p5MJkD8u006661
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 12:46:13 -0700
Received: from pzk37 (pzk37.prod.google.com [10.243.19.165])
	by wpaz17.hot.corp.google.com with ESMTP id p5MJk7we002335
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 12:46:11 -0700
Received: by pzk37 with SMTP id 37so827756pzk.29
        for <linux-mm@kvack.org>; Wed, 22 Jun 2011 12:46:07 -0700 (PDT)
Message-ID: <4E02467C.6090106@google.com>
Date: Wed, 22 Jun 2011 12:46:04 -0700
From: Mike Ditto <mditto@google.com>
MIME-Version: 1.0
Subject: [PATCH] x86: e820: Eliminate bubble sort from sanitize_e820_map
References: <1308741534-6846-1-git-send-email-sassmann@kpanic.de> <20110622110034.89ee399c.akpm@linux-foundation.org>
In-Reply-To: <20110622110034.89ee399c.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Stefan Assmann <sassmann@kpanic.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, tony.luck@intel.com, andi@firstfloor.org, mingo@elte.hu, hpa@zytor.com, rick@vanrein.org, rdunlap@xenotime.net, Nancy Yuen <yuenn@google.com>

Replace the bubble sort in sanitize_e820_map() with a call to the generic
kernel sort function to avoid pathological performance with large maps.

On large (thousands of entries) E820 maps, the previous code took minutes
to run; with this change it's now milliseconds.

Signed-off-by: Mike Ditto <mditto@google.com>
---
This is a small independent part of Google's BadRAM changes mentioned in
another thread.

 arch/x86/kernel/e820.c |   59 +++++++++++++++++++----------------------------
 1 files changed, 24 insertions(+), 35 deletions(-)

diff --git a/arch/x86/kernel/e820.c b/arch/x86/kernel/e820.c
index 3e2ef84..e2e212a 100644
--- a/arch/x86/kernel/e820.c
+++ b/arch/x86/kernel/e820.c
@@ -18,6 +18,7 @@
 #include <linux/acpi.h>
 #include <linux/firmware-map.h>
 #include <linux/memblock.h>
+#include <linux/sort.h>

 #include <asm/e820.h>
 #include <asm/proto.h>
@@ -226,22 +227,38 @@ void __init e820_print_map(char *who)
  *	   ____________________33__
  *	   ______________________4_
  */
+struct change_member {
+	struct e820entry *pbios; /* pointer to original bios entry */
+	unsigned long long addr; /* address for this change point */
+};
+
+static int __init cpcompare(const void *a, const void *b)
+{
+	struct change_member * const *app = a, * const *bpp = b;
+	const struct change_member *ap = *app, *bp = *bpp;
+
+	/*
+	 * Inputs are pointers to two elements of change_point[].  If their
+	 * addresses are unequal, their difference dominates.  If the addresses
+	 * are equal, then consider one that represents the end of its region
+	 * to be greater than one that does not.
+	 */
+	if (ap->addr != bp->addr)
+		return ap->addr > bp->addr ? 1 : -1;
+
+	return (ap->addr != ap->pbios->addr) - (bp->addr != bp->pbios->addr);
+}

 int __init sanitize_e820_map(struct e820entry *biosmap, int max_nr_map,
 			     u32 *pnr_map)
 {
-	struct change_member {
-		struct e820entry *pbios; /* pointer to original bios entry */
-		unsigned long long addr; /* address for this change point */
-	};
 	static struct change_member change_point_list[2*E820_X_MAX] __initdata;
 	static struct change_member *change_point[2*E820_X_MAX] __initdata;
 	static struct e820entry *overlap_list[E820_X_MAX] __initdata;
 	static struct e820entry new_bios[E820_X_MAX] __initdata;
-	struct change_member *change_tmp;
 	unsigned long current_type, last_type;
 	unsigned long long last_addr;
-	int chgidx, still_changing;
+	int chgidx;
 	int overlap_entries;
 	int new_bios_entry;
 	int old_nr, new_nr, chg_nr;
@@ -278,35 +295,7 @@ int __init sanitize_e820_map(struct e820entry *biosmap, int max_nr_map,
 	chg_nr = chgidx;

 	/* sort change-point list by memory addresses (low -> high) */
-	still_changing = 1;
-	while (still_changing)	{
-		still_changing = 0;
-		for (i = 1; i < chg_nr; i++)  {
-			unsigned long long curaddr, lastaddr;
-			unsigned long long curpbaddr, lastpbaddr;
-
-			curaddr = change_point[i]->addr;
-			lastaddr = change_point[i - 1]->addr;
-			curpbaddr = change_point[i]->pbios->addr;
-			lastpbaddr = change_point[i - 1]->pbios->addr;
-
-			/*
-			 * swap entries, when:
-			 *
-			 * curaddr > lastaddr or
-			 * curaddr == lastaddr and curaddr == curpbaddr and
-			 * lastaddr != lastpbaddr
-			 */
-			if (curaddr < lastaddr ||
-			    (curaddr == lastaddr && curaddr == curpbaddr &&
-			     lastaddr != lastpbaddr)) {
-				change_tmp = change_point[i];
-				change_point[i] = change_point[i-1];
-				change_point[i-1] = change_tmp;
-				still_changing = 1;
-			}
-		}
-	}
+	sort(change_point, chg_nr, sizeof *change_point, cpcompare, 0);

 	/* create a new bios memory map, removing overlaps */
 	overlap_entries = 0;	 /* number of entries in the overlap table */
-- 
1.7.3.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
