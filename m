Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 4DEF09000BD
	for <linux-mm@kvack.org>; Fri, 30 Sep 2011 20:09:39 -0400 (EDT)
Received: from /spool/local
	by us.ibm.com with XMail ESMTP
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Fri, 30 Sep 2011 18:09:37 -0600
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p91090Lb165302
	for <linux-mm@kvack.org>; Fri, 30 Sep 2011 18:09:00 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p9108xto015765
	for <linux-mm@kvack.org>; Fri, 30 Sep 2011 18:09:00 -0600
Subject: [RFCv3][PATCH 3/4] add seq_print_pow2() function
From: Dave Hansen <dave@linux.vnet.ibm.com>
Date: Fri, 30 Sep 2011 17:08:58 -0700
References: <20111001000856.DD623081@kernel>
In-Reply-To: <20111001000856.DD623081@kernel>
Message-Id: <20111001000858.D1CD9117@kernel>
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

 linux-2.6.git-dave/fs/seq_file.c            |   11 +++++++++++
 linux-2.6.git-dave/include/linux/seq_file.h |    2 ++
 2 files changed, 13 insertions(+)

diff -puN fs/seq_file.c~add-seq_print_size fs/seq_file.c
--- linux-2.6.git/fs/seq_file.c~add-seq_print_size	2011-09-30 16:41:04.169957332 -0700
+++ linux-2.6.git-dave/fs/seq_file.c	2011-09-30 16:41:04.181957311 -0700
@@ -386,6 +386,17 @@ int seq_printf(struct seq_file *m, const
 }
 EXPORT_SYMBOL(seq_printf);
 
+/*
+ * Prints output with KiB/MiB/etc... suffixes
+ */
+int seq_print_pow2(struct seq_file *seq, u64 size)
+{
+	u64 shifted_size;
+	char unit_str[4];
+	shifted_size = string_get_size_pow2(size, unit_str);
+	return seq_printf(seq, "%llu%s", shifted_size, unit_str);
+}
+
 /**
  *	mangle_path -	mangle and copy path to buffer beginning
  *	@s: buffer start
diff -puN include/linux/seq_file.h~add-seq_print_size include/linux/seq_file.h
--- linux-2.6.git/include/linux/seq_file.h~add-seq_print_size	2011-09-30 16:41:04.173957325 -0700
+++ linux-2.6.git-dave/include/linux/seq_file.h	2011-09-30 16:41:04.181957311 -0700
@@ -3,6 +3,7 @@
 
 #include <linux/types.h>
 #include <linux/string.h>
+#include <linux/string_helpers.h>
 #include <linux/mutex.h>
 #include <linux/cpumask.h>
 #include <linux/nodemask.h>
@@ -83,6 +84,7 @@ int seq_escape(struct seq_file *, const 
 int seq_putc(struct seq_file *m, char c);
 int seq_puts(struct seq_file *m, const char *s);
 int seq_write(struct seq_file *seq, const void *data, size_t len);
+int seq_print_pow2(struct seq_file *seq, u64 size);
 
 int seq_printf(struct seq_file *, const char *, ...)
 	__attribute__ ((format (printf,2,3)));
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
