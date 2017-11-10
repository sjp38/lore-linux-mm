Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id B4CA4440D3D
	for <linux-mm@kvack.org>; Fri, 10 Nov 2017 14:32:13 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id v78so8385387pfk.8
        for <linux-mm@kvack.org>; Fri, 10 Nov 2017 11:32:13 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id p25si10163149pfk.312.2017.11.10.11.32.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Nov 2017 11:32:12 -0800 (PST)
Subject: [PATCH 25/30] x86, kaiser: add debugfs file to turn KAISER on/off at runtime
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Fri, 10 Nov 2017 11:31:53 -0800
References: <20171110193058.BECA7D88@viggo.jf.intel.com>
In-Reply-To: <20171110193058.BECA7D88@viggo.jf.intel.com>
Message-Id: <20171110193153.D45596C9@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, dave.hansen@linux.intel.com, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org


From: Dave Hansen <dave.hansen@linux.intel.com>

This will be used in a few patches.  Right now, it's not wired up
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
--- a/arch/x86/mm/kaiser.c~kaiser-dynamic-debugfs	2017-11-10 11:22:18.900244925 -0800
+++ b/arch/x86/mm/kaiser.c	2017-11-10 11:22:18.904244925 -0800
@@ -29,6 +29,7 @@
 #include <linux/string.h>
 #include <linux/types.h>
 #include <linux/bug.h>
+#include <linux/debugfs.h>
 #include <linux/init.h>
 #include <linux/interrupt.h>
 #include <linux/spinlock.h>
@@ -457,3 +458,50 @@ void kaiser_remove_mapping(unsigned long
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
