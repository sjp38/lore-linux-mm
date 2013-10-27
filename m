Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f50.google.com (mail-pb0-f50.google.com [209.85.160.50])
	by kanga.kvack.org (Postfix) with ESMTP id 6C2FA6B0036
	for <linux-mm@kvack.org>; Sun, 27 Oct 2013 13:31:03 -0400 (EDT)
Received: by mail-pb0-f50.google.com with SMTP id uo5so3414572pbc.37
        for <linux-mm@kvack.org>; Sun, 27 Oct 2013 10:31:03 -0700 (PDT)
Received: from psmtp.com ([74.125.245.142])
        by mx.google.com with SMTP id ll9si10812623pab.37.2013.10.27.10.31.00
        for <linux-mm@kvack.org>;
        Sun, 27 Oct 2013 10:31:01 -0700 (PDT)
Received: by mail-ob0-f202.google.com with SMTP id wn1so561425obc.5
        for <linux-mm@kvack.org>; Sun, 27 Oct 2013 10:30:59 -0700 (PDT)
From: Greg Thelen <gthelen@google.com>
Subject: [PATCH v2 1/3] percpu: add test module for various percpu operations
Date: Sun, 27 Oct 2013 10:30:15 -0700
Message-Id: <1382895017-19067-2-git-send-email-gthelen@google.com>
In-Reply-To: <1382895017-19067-1-git-send-email-gthelen@google.com>
References: <1382895017-19067-1-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, handai.szj@taobao.com, Andrew Morton <akpm@linux-foundation.org>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, Greg Thelen <gthelen@google.com>

Tests various percpu operations.

Enable with CONFIG_PERCPU_TEST=m.

Signed-off-by: Greg Thelen <gthelen@google.com>
Acked-by: Tejun Heo <tj@kernel.org>
---
 lib/Kconfig.debug |   9 ++++
 lib/Makefile      |   2 +
 lib/percpu_test.c | 138 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 149 insertions(+)
 create mode 100644 lib/percpu_test.c

diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index 06344d9..9fdb452 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -1472,6 +1472,15 @@ config INTERVAL_TREE_TEST
 	help
 	  A benchmark measuring the performance of the interval tree library
 
+config PERCPU_TEST
+	tristate "Per cpu operations test"
+	depends on m && DEBUG_KERNEL
+	help
+	  Enable this option to build test module which validates per-cpu
+	  operations.
+
+	  If unsure, say N.
+
 config ATOMIC64_SELFTEST
 	bool "Perform an atomic64_t self-test at boot"
 	help
diff --git a/lib/Makefile b/lib/Makefile
index f3bb2cb..bb016e1 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -157,6 +157,8 @@ obj-$(CONFIG_INTERVAL_TREE_TEST) += interval_tree_test.o
 
 interval_tree_test-objs := interval_tree_test_main.o interval_tree.o
 
+obj-$(CONFIG_PERCPU_TEST) += percpu_test.o
+
 obj-$(CONFIG_ASN1) += asn1_decoder.o
 
 obj-$(CONFIG_FONT_SUPPORT) += fonts/
diff --git a/lib/percpu_test.c b/lib/percpu_test.c
new file mode 100644
index 0000000..fcca49e
--- /dev/null
+++ b/lib/percpu_test.c
@@ -0,0 +1,138 @@
+#include <linux/module.h>
+
+/* validate @native and @pcp counter values match @expected */
+#define CHECK(native, pcp, expected)                                    \
+	do {                                                            \
+		WARN((native) != (expected),                            \
+		     "raw %ld (0x%lx) != expected %ld (0x%lx)",         \
+		     (long)(native), (long)(native),                    \
+		     (long)(expected), (long)(expected));               \
+		WARN(__this_cpu_read(pcp) != (expected),                \
+		     "pcp %ld (0x%lx) != expected %ld (0x%lx)",         \
+		     (long)__this_cpu_read(pcp), (long)__this_cpu_read(pcp), \
+		     (long)(expected), (long)(expected));               \
+	} while (0)
+
+static DEFINE_PER_CPU(long, long_counter);
+static DEFINE_PER_CPU(unsigned long, ulong_counter);
+
+static int __init percpu_test_init(void)
+{
+	/*
+	 * volatile prevents compiler from optimizing it uses, otherwise the
+	 * +ul_one and -ul_one below would replace with inc/dec instructions.
+	 */
+	volatile unsigned int ui_one = 1;
+	long l = 0;
+	unsigned long ul = 0;
+
+	pr_info("percpu test start\n");
+
+	preempt_disable();
+
+	l += -1;
+	__this_cpu_add(long_counter, -1);
+	CHECK(l, long_counter, -1);
+
+	l += 1;
+	__this_cpu_add(long_counter, 1);
+	CHECK(l, long_counter, 0);
+
+	ul = 0;
+	__this_cpu_write(ulong_counter, 0);
+
+	ul += 1UL;
+	__this_cpu_add(ulong_counter, 1UL);
+	CHECK(ul, ulong_counter, 1);
+
+	ul += -1UL;
+	__this_cpu_add(ulong_counter, -1UL);
+	CHECK(ul, ulong_counter, 0);
+
+	ul += -(unsigned long)1;
+	__this_cpu_add(ulong_counter, -(unsigned long)1);
+	CHECK(ul, ulong_counter, -1);
+
+	ul = 0;
+	__this_cpu_write(ulong_counter, 0);
+
+	ul -= 1;
+	__this_cpu_dec(ulong_counter);
+	CHECK(ul, ulong_counter, 0xffffffffffffffff);
+	CHECK(ul, ulong_counter, -1);
+
+	l += -ui_one;
+	__this_cpu_add(long_counter, -ui_one);
+	CHECK(l, long_counter, 0xffffffff);
+
+	l += ui_one;
+	__this_cpu_add(long_counter, ui_one);
+	CHECK(l, long_counter, 0x100000000);
+
+
+	l = 0;
+	__this_cpu_write(long_counter, 0);
+
+	l -= ui_one;
+	__this_cpu_sub(long_counter, ui_one);
+	CHECK(l, long_counter, -1);
+
+	l = 0;
+	__this_cpu_write(long_counter, 0);
+
+	l += ui_one;
+	__this_cpu_add(long_counter, ui_one);
+	CHECK(l, long_counter, 1);
+
+	l += -ui_one;
+	__this_cpu_add(long_counter, -ui_one);
+	CHECK(l, long_counter, 0x100000000);
+
+	l = 0;
+	__this_cpu_write(long_counter, 0);
+
+	l -= ui_one;
+	this_cpu_sub(long_counter, ui_one);
+	CHECK(l, long_counter, -1);
+	CHECK(l, long_counter, 0xffffffffffffffff);
+
+	ul = 0;
+	__this_cpu_write(ulong_counter, 0);
+
+	ul += ui_one;
+	__this_cpu_add(ulong_counter, ui_one);
+	CHECK(ul, ulong_counter, 1);
+
+	ul = 0;
+	__this_cpu_write(ulong_counter, 0);
+
+	ul -= ui_one;
+	__this_cpu_sub(ulong_counter, ui_one);
+	CHECK(ul, ulong_counter, -1);
+	CHECK(ul, ulong_counter, 0xffffffffffffffff);
+
+	ul = 3;
+	__this_cpu_write(ulong_counter, 3);
+
+	ul = this_cpu_sub_return(ulong_counter, ui_one);
+	CHECK(ul, ulong_counter, 2);
+
+	ul = __this_cpu_sub_return(ulong_counter, ui_one);
+	CHECK(ul, ulong_counter, 1);
+
+	preempt_enable();
+
+	pr_info("percpu test done\n");
+	return -EAGAIN;  /* Fail will directly unload the module */
+}
+
+static void __exit percpu_test_exit(void)
+{
+}
+
+module_init(percpu_test_init)
+module_exit(percpu_test_exit)
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Greg Thelen");
+MODULE_DESCRIPTION("percpu operations test");
-- 
1.8.4.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
