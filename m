Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 1E3C09000BD
	for <linux-mm@kvack.org>; Fri, 30 Sep 2011 20:09:01 -0400 (EDT)
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by e9.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p8UNXOGm019830
	for <linux-mm@kvack.org>; Fri, 30 Sep 2011 19:33:24 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p9108xPG257366
	for <linux-mm@kvack.org>; Fri, 30 Sep 2011 20:08:59 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p9108wgE030160
	for <linux-mm@kvack.org>; Fri, 30 Sep 2011 21:08:58 -0300
Subject: [RFCv3][PATCH 2/4] add string_get_size_pow2()
From: Dave Hansen <dave@linux.vnet.ibm.com>
Date: Fri, 30 Sep 2011 17:08:57 -0700
References: <20111001000856.DD623081@kernel>
In-Reply-To: <20111001000856.DD623081@kernel>
Message-Id: <20111001000857.263EF954@kernel>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, rientjes@google.com, James.Bottomley@HansenPartnership.com, hpa@zytor.com, Dave Hansen <dave@linux.vnet.ibm.com>


This is a specialized version of string_get_size().

It only works on powers-of-two, and only outputs in
KiB/MiB/etc...  Doing it this way means that we do
not have to do any division like string_get_size()
does.

Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>
---

 linux-2.6.git-dave/include/linux/string_helpers.h |    1 
 linux-2.6.git-dave/lib/string_helpers.c           |   23 ++++++++++++++++++++++
 2 files changed, 24 insertions(+)

diff -puN include/linux/string_helpers.h~string_get_size-pow2-1 include/linux/string_helpers.h
--- linux-2.6.git/include/linux/string_helpers.h~string_get_size-pow2-1	2011-09-30 17:03:00.511708995 -0700
+++ linux-2.6.git-dave/include/linux/string_helpers.h	2011-09-30 17:03:00.535708956 -0700
@@ -10,6 +10,7 @@ enum string_size_units {
 	STRING_UNITS_2,		/* use binary powers of 2^10 */
 };
 
+u64 string_get_size_pow2(u64 size, char *unit_ret);
 int string_get_size(u64 size, enum string_size_units units,
 		    char *buf, int len);
 
diff -puN lib/string_helpers.c~string_get_size-pow2-1 lib/string_helpers.c
--- linux-2.6.git/lib/string_helpers.c~string_get_size-pow2-1	2011-09-30 17:03:00.515708988 -0700
+++ linux-2.6.git-dave/lib/string_helpers.c	2011-09-30 17:03:00.535708956 -0700
@@ -25,6 +25,29 @@ static char *__units_str(enum string_siz
 	return buf;
 }
 
+u64 string_get_size_pow2(u64 size, char *unit_ret)
+{
+	int log2;
+	int unit_index;
+
+	if (!size) {
+		__units_str(STRING_UNITS_2, unit_ret, 0);
+		return 0;
+	} else {
+		log2 = ilog2(size);
+	}
+
+	/* KiB is log2=0->9, MiB is 10->19, etc... */
+	unit_index = log2 / 10;
+	__units_str(STRING_UNITS_2, unit_ret, unit_index);
+
+	/* 512 aka 2^9 is the largest integer without
+	 * overflowing to the next power-of-two, so
+	 * use %10 to make it max out there */
+	return (1 << (log2 % 10));
+}
+EXPORT_SYMBOL(string_get_size_pow2);
+
 /**
  * string_get_size - get the size in the specified units
  * @size:	The size to be converted
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
