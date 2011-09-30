Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 664B69000BD
	for <linux-mm@kvack.org>; Fri, 30 Sep 2011 16:32:23 -0400 (EDT)
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by e9.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p8UJulD6006804
	for <linux-mm@kvack.org>; Fri, 30 Sep 2011 15:56:47 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p8UKWLNp226480
	for <linux-mm@kvack.org>; Fri, 30 Sep 2011 16:32:21 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p8UKWKYZ018699
	for <linux-mm@kvack.org>; Fri, 30 Sep 2011 16:32:21 -0400
Subject: [RFCv2][PATCH 1/4] break units out of string_get_size()
From: Dave Hansen <dave@linux.vnet.ibm.com>
Date: Fri, 30 Sep 2011 13:32:19 -0700
Message-Id: <20110930203219.60D507CB@kernel>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, rientjes@google.com, James.Bottomley@HansenPartnership.com, hpa@zytor.com, Dave Hansen <dave@linux.vnet.ibm.com>


I would like to use these (well one of them) arrays in
another function.  Might as well break both versions
out for consistency.

Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>
---

 linux-2.6.git-dave/lib/string_helpers.c |   25 +++++++++++++------------
 1 file changed, 13 insertions(+), 12 deletions(-)

diff -puN lib/string_helpers.c~string_get_size-pow2 lib/string_helpers.c
--- linux-2.6.git/lib/string_helpers.c~string_get_size-pow2	2011-09-30 12:58:43.856800824 -0700
+++ linux-2.6.git-dave/lib/string_helpers.c	2011-09-30 12:58:43.864800812 -0700
@@ -8,6 +8,19 @@
 #include <linux/module.h>
 #include <linux/string_helpers.h>
 
+const char *units_10[] = { "B", "kB", "MB", "GB", "TB", "PB",
+			   "EB", "ZB", "YB", NULL};
+const char *units_2[] = {"B", "KiB", "MiB", "GiB", "TiB", "PiB",
+			 "EiB", "ZiB", "YiB", NULL };
+static const char **units_str[] = {
+	[STRING_UNITS_10] =  units_10,
+	[STRING_UNITS_2] = units_2,
+};
+static const unsigned int divisor[] = {
+	[STRING_UNITS_10] = 1000,
+	[STRING_UNITS_2] = 1024,
+};
+
 /**
  * string_get_size - get the size in the specified units
  * @size:	The size to be converted
@@ -23,18 +36,6 @@
 int string_get_size(u64 size, const enum string_size_units units,
 		    char *buf, int len)
 {
-	const char *units_10[] = { "B", "kB", "MB", "GB", "TB", "PB",
-				   "EB", "ZB", "YB", NULL};
-	const char *units_2[] = {"B", "KiB", "MiB", "GiB", "TiB", "PiB",
-				 "EiB", "ZiB", "YiB", NULL };
-	const char **units_str[] = {
-		[STRING_UNITS_10] =  units_10,
-		[STRING_UNITS_2] = units_2,
-	};
-	const unsigned int divisor[] = {
-		[STRING_UNITS_10] = 1000,
-		[STRING_UNITS_2] = 1024,
-	};
 	int i, j;
 	u64 remainder = 0, sf_cap;
 	char tmp[8];
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
