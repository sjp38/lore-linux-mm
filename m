Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 69D089000BD
	for <linux-mm@kvack.org>; Fri, 30 Sep 2011 20:09:11 -0400 (EDT)
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by e37.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p9105iD9032145
	for <linux-mm@kvack.org>; Fri, 30 Sep 2011 18:05:44 -0600
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p9108v8g151264
	for <linux-mm@kvack.org>; Fri, 30 Sep 2011 18:08:59 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p9108vI5021023
	for <linux-mm@kvack.org>; Fri, 30 Sep 2011 18:08:57 -0600
Subject: [RFCv3][PATCH 1/4] replace string_get_size() arrays
From: Dave Hansen <dave@linux.vnet.ibm.com>
Date: Fri, 30 Sep 2011 17:08:56 -0700
Message-Id: <20111001000856.DD623081@kernel>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, rientjes@google.com, James.Bottomley@HansenPartnership.com, hpa@zytor.com, Dave Hansen <dave@linux.vnet.ibm.com>


Instead of explicitly storing the entire string for each
possible units, just store the thing that varies: the
first character.

We have to special-case the 'B' unit (index==0).

This shaves about 100 bytes off of my .o file.

Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>
---

 linux-2.6.git-dave/lib/string_helpers.c |   30 ++++++++++++++++++++----------
 1 file changed, 20 insertions(+), 10 deletions(-)

diff -puN lib/string_helpers.c~string_get_size-pow2 lib/string_helpers.c
--- linux-2.6.git/lib/string_helpers.c~string_get_size-pow2	2011-09-30 16:50:31.628981352 -0700
+++ linux-2.6.git-dave/lib/string_helpers.c	2011-09-30 17:04:02.211607364 -0700
@@ -8,6 +8,23 @@
 #include <linux/module.h>
 #include <linux/string_helpers.h>
 
+static const char byte_units[] = "_KMGTPEZY";
+
+static char *__units_str(enum string_size_units unit, char *buf, int index)
+{
+	int place = 0;
+
+	/* index=0 is plain 'B' with no other unit */
+	if (index) {
+		buf[place++] = byte_units[index];
+		if (unit == STRING_UNITS_2)
+			buf[place++] = 'i';
+	}
+	buf[place++] = 'B';
+	buf[place++] = '\0';
+	return buf;
+}
+
 /**
  * string_get_size - get the size in the specified units
  * @size:	The size to be converted
@@ -23,26 +40,19 @@
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
 	const unsigned int divisor[] = {
 		[STRING_UNITS_10] = 1000,
 		[STRING_UNITS_2] = 1024,
 	};
 	int i, j;
 	u64 remainder = 0, sf_cap;
+	char unit_buf[4];
 	char tmp[8];
 
 	tmp[0] = '\0';
 	i = 0;
 	if (size >= divisor[units]) {
-		while (size >= divisor[units] && units_str[units][i]) {
+		while (size >= divisor[units] && (i < strlen(byte_units))) {
 			remainder = do_div(size, divisor[units]);
 			i++;
 		}
@@ -61,7 +71,7 @@ int string_get_size(u64 size, const enum
 	}
 
 	snprintf(buf, len, "%lld%s %s", (unsigned long long)size,
-		 tmp, units_str[units][i]);
+		 tmp, __units_str(units, unit_buf, i));
 
 	return 0;
 }
diff -puN include/linux/string_helpers.h~string_get_size-pow2 include/linux/string_helpers.h
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
