Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id C4DFD6B0010
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 13:55:49 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id n23-v6so6128606qtl.4
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 10:55:49 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id v87-v6si5297514qkl.392.2018.07.02.10.55.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Jul 2018 10:55:48 -0700 (PDT)
From: Chris von Recklinghausen <crecklin@redhat.com>
Subject: [PATCH v4] add param that allows bootline control of hardened usercopy
Date: Mon,  2 Jul 2018 13:55:43 -0400
Message-Id: <1530554143-17218-1-git-send-email-crecklin@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: keescook@chromium.org, labbott@redhat.com, pabeni@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com

From: root <root@dell-pr1700-02.lab.bos.redhat.com>

Enabling HARDENED_USERCOPY causes measurable regressions in
 networking performance, up to 8% under UDP flood.

I'm running an a small packet UDP flood using pktgen vs. a host b2b
connected. On the receiver side the UDP packets are processed by a
simple user space process that just reads and drops them:

https://github.com/netoptimizer/network-testing/blob/master/src/udp_sink.c

Not very useful from a functional PoV, but it helps to pin-point
bottlenecks in the networking stack.

When running a kernel with CONFIG_HARDENED_USERCOPY=y, I see a 5-8%
regression in the receive tput, compared to the same kernel without
this option enabled.

With CONFIG_HARDENED_USERCOPY=y, perf shows ~6% of CPU time spent
cumulatively in __check_object_size (~4%) and __virt_addr_valid (~2%).

The call-chain is:

__GI___libc_recvfrom
entry_SYSCALL_64_after_hwframe
do_syscall_64
__x64_sys_recvfrom
__sys_recvfrom
inet_recvmsg
udp_recvmsg
__check_object_size

udp_recvmsg() actually calls copy_to_iter() (inlined) and the latters
calls check_copy_size() (again, inlined).

A generic distro may want to enable HARDENED_USERCOPY in their default
kernel config, but at the same time, such distro may want to be able to
avoid the performance penalties in with the default configuration and
disable the stricter check on a per-boot basis.

This change adds a boot parameter that conditionally disables
HARDENED_USERCOPY at boot time.

Atomics needed by jump label code are not available on platforms with
CONFIG_BROKEN_ON_SMP set, so don't enable this functionality on those
platforms.

v3->v4:
	fix a couple of nits in commit comments
	declaration of bypass_usercopy_checks moved inside mm/usercopy.c and
		made static
	add blurb to commit comments about not enabling this functionality on
		platforms with CONFIG_BROKEN_ON_SMP set.
v2->v3:
	add benchmark details to commit comments
	Don't add new item to Documentation/admin-guide/kernel-parameters.rst
	rename boot param to "hardened_usercopy="
	update description in Documentation/admin-guide/kernel-parameters.txt
	static_branch_likely -> static_branch_unlikely
	add __ro_after_init versions of DEFINE_STATIC_KEY_FALSE,
		DEFINE_STATIC_KEY_TRUE
	disable_huc_atboot -> enable_checks (strtobool "on" == true)

v1->v2:
	remove CONFIG_HUC_DEFAULT_OFF
	default is now enabled, boot param disables
	move check to __check_object_size so as to not break optimization of
		__builtin_constant_p()
	include linux/atomic.h before linux/jump_label.h

Signed-off-by: Chris von Recklinghausen <crecklin@redhat.com>
---
 Documentation/admin-guide/kernel-parameters.txt | 11 ++++++++
 include/linux/jump_label.h                      |  6 +++++
 mm/usercopy.c                                   | 35 +++++++++++++++++++++++++
 3 files changed, 52 insertions(+)

diff --git a/Documentation/admin-guide/kernel-parameters.txt b/Documentation/admin-guide/kernel-parameters.txt
index efc7aa7..560d4dc 100644
--- a/Documentation/admin-guide/kernel-parameters.txt
+++ b/Documentation/admin-guide/kernel-parameters.txt
@@ -816,6 +816,17 @@
 	disable=	[IPV6]
 			See Documentation/networking/ipv6.txt.
 
+	hardened_usercopy=
+                        [KNL] Under CONFIG_HARDENED_USERCOPY, whether
+                        hardening is enabled for this boot. Hardened
+                        usercopy checking is used to protect the kernel
+                        from reading or writing beyond known memory
+                        allocation boundaries as a proactive defense
+                        against bounds-checking flaws in the kernel's
+                        copy_to_user()/copy_from_user() interface.
+                on      Perform hardened usercopy checks (default).
+                off     Disable hardened usercopy checks.
+
 	disable_radix	[PPC]
 			Disable RADIX MMU mode on POWER9
 
diff --git a/include/linux/jump_label.h b/include/linux/jump_label.h
index b46b541..1a0b6f1 100644
--- a/include/linux/jump_label.h
+++ b/include/linux/jump_label.h
@@ -299,12 +299,18 @@ struct static_key_false {
 #define DEFINE_STATIC_KEY_TRUE(name)	\
 	struct static_key_true name = STATIC_KEY_TRUE_INIT
 
+#define DEFINE_STATIC_KEY_TRUE_RO(name)	\
+	struct static_key_true name __ro_after_init = STATIC_KEY_TRUE_INIT
+
 #define DECLARE_STATIC_KEY_TRUE(name)	\
 	extern struct static_key_true name
 
 #define DEFINE_STATIC_KEY_FALSE(name)	\
 	struct static_key_false name = STATIC_KEY_FALSE_INIT
 
+#define DEFINE_STATIC_KEY_FALSE_RO(name)	\
+	struct static_key_false name __ro_after_init = STATIC_KEY_FALSE_INIT
+
 #define DECLARE_STATIC_KEY_FALSE(name)	\
 	extern struct static_key_false name
 
diff --git a/mm/usercopy.c b/mm/usercopy.c
index e9e9325..a5f8be5 100644
--- a/mm/usercopy.c
+++ b/mm/usercopy.c
@@ -20,6 +20,10 @@
 #include <linux/sched/task.h>
 #include <linux/sched/task_stack.h>
 #include <linux/thread_info.h>
+#ifndef CONFIG_BROKEN_ON_SMP
+#include <linux/atomic.h>
+#include <linux/jump_label.h>
+#endif
 #include <asm/sections.h>
 
 /*
@@ -240,6 +244,10 @@ static inline void check_heap_object(const void *ptr, unsigned long n,
 	}
 }
 
+#ifndef CONFIG_BROKEN_ON_SMP
+static DEFINE_STATIC_KEY_FALSE_RO(bypass_usercopy_checks);
+#endif
+
 /*
  * Validates that the given object is:
  * - not bogus address
@@ -248,6 +256,11 @@ static inline void check_heap_object(const void *ptr, unsigned long n,
  */
 void __check_object_size(const void *ptr, unsigned long n, bool to_user)
 {
+#ifndef CONFIG_BROKEN_ON_SMP
+	if (static_branch_unlikely(&bypass_usercopy_checks))
+		return;
+#endif
+
 	/* Skip all tests if size is zero. */
 	if (!n)
 		return;
@@ -279,3 +292,25 @@ void __check_object_size(const void *ptr, unsigned long n, bool to_user)
 	check_kernel_text_object((const unsigned long)ptr, n, to_user);
 }
 EXPORT_SYMBOL(__check_object_size);
+
+#ifndef CONFIG_BROKEN_ON_SMP
+EXPORT_SYMBOL(bypass_usercopy_checks);
+
+static bool enable_checks __initdata = true;
+
+static int __init parse_hardened_usercopy(char *str)
+{
+	return strtobool(str, &enable_checks);
+}
+
+__setup("hardened_usercopy=", parse_hardened_usercopy);
+
+static int __init set_hardened_usercopy(void)
+{
+	if (enable_checks == false)
+		static_branch_enable(&bypass_usercopy_checks);
+	return 1;
+}
+
+late_initcall(set_hardened_usercopy);
+#endif
-- 
1.8.3.1
