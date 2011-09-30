Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 95E8C9000BD
	for <linux-mm@kvack.org>; Fri, 30 Sep 2011 14:02:57 -0400 (EDT)
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e35.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p8UHfkJA000787
	for <linux-mm@kvack.org>; Fri, 30 Sep 2011 11:41:46 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p8UI2gfa037274
	for <linux-mm@kvack.org>; Fri, 30 Sep 2011 12:02:45 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p8UI2f4Y029461
	for <linux-mm@kvack.org>; Fri, 30 Sep 2011 12:02:42 -0600
Subject: [RFC][PATCH 1/4] break up string_get_size()
From: Dave Hansen <dave@linux.vnet.ibm.com>
Date: Fri, 30 Sep 2011 11:02:41 -0700
Message-Id: <20110930180241.D69D5E9C@kernel>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, rientjes@google.com, James.Bottomley@HansenPartnership.com, hpa@zytor.com, Dave Hansen <dave@linux.vnet.ibm.com>


I started to break up string_get_size() in to some pieces
so that I could pick and choose which bits I wanted.  I
ended up not re-using this function.  But, I think this
still stands by itself since it makes the code much more
self-explanatory.

Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>
---

 linux-2.6.git-dave/lib/string_helpers.c |   19 ++++++++++++++-----
 1 file changed, 14 insertions(+), 5 deletions(-)

diff -puN lib/string_helpers.c~break-up-string_get_size lib/string_helpers.c
--- linux-2.6.git/lib/string_helpers.c~break-up-string_get_size	2011-09-30 10:58:32.909418688 -0700
+++ linux-2.6.git-dave/lib/string_helpers.c	2011-09-30 10:58:32.953418603 -0700
@@ -8,6 +8,18 @@
 #include <linux/module.h>
 #include <linux/string_helpers.h>
 
+static int calc_sf_digit_room(u64 size)
+{
+	u64 sf_cap;
+	int digits;
+
+	sf_cap = size;
+	for (digits = 0; sf_cap*10 < 1000; digits++)
+		sf_cap *= 10;
+
+	return digits;
+}
+
 /**
  * string_get_size - get the size in the specified units
  * @size:	The size to be converted
@@ -36,7 +48,7 @@ int string_get_size(u64 size, const enum
 		[STRING_UNITS_2] = 1024,
 	};
 	int i, j;
-	u64 remainder = 0, sf_cap;
+	u64 remainder = 0;
 	char tmp[8];
 
 	tmp[0] = '\0';
@@ -47,10 +59,7 @@ int string_get_size(u64 size, const enum
 			i++;
 		}
 
-		sf_cap = size;
-		for (j = 0; sf_cap*10 < 1000; j++)
-			sf_cap *= 10;
-
+		j = calc_sf_digit_room(size);
 		if (j) {
 			remainder *= 1000;
 			do_div(remainder, divisor[units]);
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
