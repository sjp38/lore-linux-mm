Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id A86B86B0003
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 15:43:13 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id 123-v6so3293637qkg.8
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 12:43:13 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id l2-v6si1794883qkc.377.2018.07.03.12.43.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Jul 2018 12:43:12 -0700 (PDT)
From: Chris von Recklinghausen <crecklin@redhat.com>
Subject: [PATCH v7] add param that allows bootline control of hardened  usercopy
Date: Tue,  3 Jul 2018 15:43:08 -0400
Message-Id: <1530646988-25546-1-git-send-email-crecklin@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: keescook@chromium.org, labbott@redhat.com, pabeni@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com

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

v6->v7:
	remove EXPORT_SYMBOL(bypass_usercopy_checks);
	remove mention of CONFIG_JUMP_LABEL from commit comments
v5->v6:
	no need to key off of anything - build errors were when jump label
		code was in include/linux/thread_info.h.
v4->v5:
	key off of CONFIG_JUMP_LABEL, not CONFIG_SMP_BROKEN.

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
 .../admin-guide/kernel-parameters.txt         | 11 ++++++++
 include/linux/jump_label.h                    |  6 +++++
 mm/usercopy.c                                 | 25 +++++++++++++++++++
 3 files changed, 42 insertions(+)

diff --git a/Documentation/admin-guide/kernel-parameters.txt b/Documentation/admin-guide/kernel-parameters.txt
index efc7aa7a0670..560d4dc66f02 100644
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
index b46b541c67c4..1a0b6f17a5d6 100644
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
index e9e9325f7638..852eb4e53f06 100644
--- a/mm/usercopy.c
+++ b/mm/usercopy.c
@@ -20,6 +20,8 @@
 #include <linux/sched/task.h>
 #include <linux/sched/task_stack.h>
 #include <linux/thread_info.h>
+#include <linux/atomic.h>
+#include <linux/jump_label.h>
 #include <asm/sections.h>
 
 /*
@@ -240,6 +242,8 @@ static inline void check_heap_object(const void *ptr, unsigned long n,
 	}
 }
 
+static DEFINE_STATIC_KEY_FALSE_RO(bypass_usercopy_checks);
+
 /*
  * Validates that the given object is:
  * - not bogus address
@@ -248,6 +252,9 @@ static inline void check_heap_object(const void *ptr, unsigned long n,
  */
 void __check_object_size(const void *ptr, unsigned long n, bool to_user)
 {
+	if (static_branch_unlikely(&bypass_usercopy_checks))
+		return;
+
 	/* Skip all tests if size is zero. */
 	if (!n)
 		return;
@@ -279,3 +286,21 @@ void __check_object_size(const void *ptr, unsigned long n, bool to_user)
 	check_kernel_text_object((const unsigned long)ptr, n, to_user);
 }
 EXPORT_SYMBOL(__check_object_size);
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
-- 
2.17.0
