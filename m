Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id E94349000BD
	for <linux-mm@kvack.org>; Fri, 30 Sep 2011 14:03:16 -0400 (EDT)
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by e6.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p8UHd4Jc028109
	for <linux-mm@kvack.org>; Fri, 30 Sep 2011 13:39:04 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p8UI3D4j095332
	for <linux-mm@kvack.org>; Fri, 30 Sep 2011 14:03:13 -0400
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p8UI2iKE028878
	for <linux-mm@kvack.org>; Fri, 30 Sep 2011 12:02:45 -0600
Subject: [RFC][PATCH 3/4] add seq_print_size() function
From: Dave Hansen <dave@linux.vnet.ibm.com>
Date: Fri, 30 Sep 2011 11:02:43 -0700
References: <20110930180241.D69D5E9C@kernel>
In-Reply-To: <20110930180241.D69D5E9C@kernel>
Message-Id: <20110930180243.403953DC@kernel>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, rientjes@google.com, James.Bottomley@HansenPartnership.com, hpa@zytor.com, Dave Hansen <dave@linux.vnet.ibm.com>


In order to get nice, human-readable output, we are going to
use MiB/KiB, etc... in numa_maps.  Introduce a helper to do
the conversion from a raw integer over to a string.

I thought about doing this as a new printk() format specifier.
That would be interesting, but it's hard to argue with this
since it's so short and sweet.

Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>
---

 linux-2.6.git-dave/fs/seq_file.c            |   15 +++++++++++++++
 linux-2.6.git-dave/include/linux/seq_file.h |    3 +++
 2 files changed, 18 insertions(+)

diff -puN fs/seq_file.c~add-seq_print_size fs/seq_file.c
--- linux-2.6.git/fs/seq_file.c~add-seq_print_size	2011-09-30 10:52:22.302140723 -0700
+++ linux-2.6.git-dave/fs/seq_file.c	2011-09-30 10:52:22.322140685 -0700
@@ -386,6 +386,21 @@ int seq_printf(struct seq_file *m, const
 }
 EXPORT_SYMBOL(seq_printf);
 
+/*
+ * Prints output with MiB/MB/KB/etc... suffixes
+ */
+int seq_print_size(struct seq_file *seq, u64 size,
+			const enum string_size_units units)
+{
+	int ret;
+	u64 remainder;
+	char *size_str;
+	remainder = find_size_units(&size, units, &size_str);
+	ret += seq_printf(seq, "%llu", size);
+	ret += seq_puts(seq, size_str);
+	return ret;
+}
+
 /**
  *	mangle_path -	mangle and copy path to buffer beginning
  *	@s: buffer start
diff -puN include/linux/seq_file.h~add-seq_print_size include/linux/seq_file.h
--- linux-2.6.git/include/linux/seq_file.h~add-seq_print_size	2011-09-30 10:52:22.314140700 -0700
+++ linux-2.6.git-dave/include/linux/seq_file.h	2011-09-30 10:52:22.322140685 -0700
@@ -3,6 +3,7 @@
 
 #include <linux/types.h>
 #include <linux/string.h>
+#include <linux/string_helpers.h>
 #include <linux/mutex.h>
 #include <linux/cpumask.h>
 #include <linux/nodemask.h>
@@ -83,6 +84,8 @@ int seq_escape(struct seq_file *, const 
 int seq_putc(struct seq_file *m, char c);
 int seq_puts(struct seq_file *m, const char *s);
 int seq_write(struct seq_file *seq, const void *data, size_t len);
+int seq_print_size(struct seq_file *seq, u64 size,
+			const enum string_size_units units);
 
 int seq_printf(struct seq_file *, const char *, ...)
 	__attribute__ ((format (printf,2,3)));
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
