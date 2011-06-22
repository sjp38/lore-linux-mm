Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id D8B7B90016F
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 07:19:19 -0400 (EDT)
From: Stefan Assmann <sassmann@kpanic.de>
Subject: [PATCH v2 1/3] Add string parsing function get_next_ulong
Date: Wed, 22 Jun 2011 13:18:52 +0200
Message-Id: <1308741534-6846-2-git-send-email-sassmann@kpanic.de>
In-Reply-To: <1308741534-6846-1-git-send-email-sassmann@kpanic.de>
References: <1308741534-6846-1-git-send-email-sassmann@kpanic.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, tony.luck@intel.com, andi@firstfloor.org, mingo@elte.hu, hpa@zytor.com, rick@vanrein.org, rdunlap@xenotime.net, sassmann@kpanic.de

Adding this function to allow easy parsing of unsigned long values from the
beginning of strings. Convenience function to parse pointers from the kernel
command line.

Signed-off-by: Stefan Assmann <sassmann@kpanic.de>
Acked-by: Tony Luck <tony.luck@intel.com>
Acked-by: Andi Kleen <ak@linux.intel.com>
---
 include/linux/kernel.h |    1 +
 lib/cmdline.c          |   35 +++++++++++++++++++++++++++++++++++
 2 files changed, 36 insertions(+), 0 deletions(-)

diff --git a/include/linux/kernel.h b/include/linux/kernel.h
index 00cec4d..98c1916 100644
--- a/include/linux/kernel.h
+++ b/include/linux/kernel.h
@@ -280,6 +280,7 @@ extern int vsscanf(const char *, const char *, va_list)
 
 extern int get_option(char **str, int *pint);
 extern char *get_options(const char *str, int nints, int *ints);
+extern int get_next_ulong(char **str, unsigned long *val, char sep, int base);
 extern unsigned long long memparse(const char *ptr, char **retptr);
 
 extern int core_kernel_text(unsigned long addr);
diff --git a/lib/cmdline.c b/lib/cmdline.c
index f5f3ad8..82a6616 100644
--- a/lib/cmdline.c
+++ b/lib/cmdline.c
@@ -114,6 +114,41 @@ char *get_options(const char *str, int nints, int *ints)
 }
 
 /**
+ *	get_next_ulong - Parse unsigned long at the beginning of a string
+ *	@strp: (output) String to be parsed
+ *	@val: (output) unsigned long carrying the result
+ *	@sep: character specifying the separator
+ *	@base: number system of the parsed value
+ *
+ *	This function parses an unsigned long value at the beginning of a
+ *	string. The string may begin with a separator or an unsigned long
+ *	value.
+ *	After the function is run val will contain the parsed value and strp
+ *	will point to the character *after* the parsed unsigned long.
+ *
+ *	In the error case 0 is returned, val and *strp stay unaltered.
+ *	Otherwise return 1.
+ */
+int get_next_ulong(char **strp, unsigned long *val, char sep, int base)
+{
+	char *tmp;
+
+	if (!strp || !(*strp))
+		return 0;
+
+	tmp = *strp;
+	if (*tmp == sep)
+		tmp++;
+
+	*val = simple_strtoul(tmp, strp, base);
+
+	if (tmp == *strp)
+		return 0; /* no new value parsed */
+	else
+		return 1;
+}
+
+/**
  *	memparse - parse a string with mem suffixes into a number
  *	@ptr: Where parse begins
  *	@retptr: (output) Optional pointer to next char after parse completes
-- 
1.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
