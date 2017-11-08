Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 29CF86B0305
	for <linux-mm@kvack.org>; Wed,  8 Nov 2017 14:47:46 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id a8so3013288pfc.6
        for <linux-mm@kvack.org>; Wed, 08 Nov 2017 11:47:46 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id x8si4371417plv.620.2017.11.08.11.47.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Nov 2017 11:47:44 -0800 (PST)
Subject: [PATCH 25/30] x86, kaiser: add debugfs file to turn KAISER on/off at runtime
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Wed, 08 Nov 2017 11:47:33 -0800
References: <20171108194646.907A1942@viggo.jf.intel.com>
In-Reply-To: <20171108194646.907A1942@viggo.jf.intel.com>
Message-Id: <20171108194733.A1246470@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, dave.hansen@linux.intel.com, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org


From: Dave Hansen <dave.hansen@linux.intel.com>

We will use this in a few patches.  Right now, it's not wired up
to do anything useful.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Moritz Lipp <moritz.lipp@iaik.tugraz.at>
Cc: Daniel Gruss <daniel.gruss@iaik.tugraz.at>
Cc: Michael Schwarz <michael.schwarz@iaik.tugraz.at>
Cc: Richard Fellner <richard.fellner@student.tugraz.at>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Kees Cook <keescook@google.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: x86@kernel.org
---

 b/arch/x86/mm/kaiser.c |   48 ++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 48 insertions(+)

diff -puN arch/x86/mm/kaiser.c~kaiser-dynamic-debugfs arch/x86/mm/kaiser.c
--- a/arch/x86/mm/kaiser.c~kaiser-dynamic-debugfs	2017-11-08 10:45:39.690681369 -0800
+++ b/arch/x86/mm/kaiser.c	2017-11-08 10:45:39.693681369 -0800
@@ -18,6 +18,7 @@
 #include <linux/string.h>
 #include <linux/types.h>
 #include <linux/bug.h>
+#include <linux/debugfs.h>
 #include <linux/init.h>
 #include <linux/interrupt.h>
 #include <linux/spinlock.h>
@@ -446,3 +447,50 @@ void kaiser_remove_mapping(unsigned long
 	 */
 	__native_flush_tlb_global();
 }
+
+int kaiser_enabled = 1;
+static ssize_t kaiser_enabled_read_file(struct file *file, char __user *user_buf,
+			     size_t count, loff_t *ppos)
+{
+	char buf[32];
+	unsigned int len;
+
+	len = sprintf(buf, "%d\n", kaiser_enabled);
+	return simple_read_from_buffer(user_buf, count, ppos, buf, len);
+}
+
+static ssize_t kaiser_enabled_write_file(struct file *file,
+		 const char __user *user_buf, size_t count, loff_t *ppos)
+{
+	char buf[32];
+	ssize_t len;
+	unsigned int enable;
+
+	len = min(count, sizeof(buf) - 1);
+	if (copy_from_user(buf, user_buf, len))
+		return -EFAULT;
+
+	buf[len] = '\0';
+	if (kstrtoint(buf, 0, &enable))
+		return -EINVAL;
+
+	if (enable > 1)
+		return -EINVAL;
+
+	WRITE_ONCE(kaiser_enabled, enable);
+	return count;
+}
+
+static const struct file_operations fops_kaiser_enabled = {
+	.read = kaiser_enabled_read_file,
+	.write = kaiser_enabled_write_file,
+	.llseek = default_llseek,
+};
+
+static int __init create_kaiser_enabled(void)
+{
+	debugfs_create_file("kaiser-enabled", S_IRUSR | S_IWUSR,
+			    arch_debugfs_dir, NULL, &fops_kaiser_enabled);
+	return 0;
+}
+late_initcall(create_kaiser_enabled);
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
