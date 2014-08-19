Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 5BDCE6B0035
	for <linux-mm@kvack.org>; Tue, 19 Aug 2014 17:26:28 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id et14so11010310pad.9
        for <linux-mm@kvack.org>; Tue, 19 Aug 2014 14:26:28 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id gk1si28696467pbd.79.2014.08.19.14.26.23
        for <linux-mm@kvack.org>;
        Tue, 19 Aug 2014 14:26:24 -0700 (PDT)
Subject: [PATCH] [RFC] TAINT_PERFORMANCE
From: Dave Hansen <dave@sr71.net>
Date: Tue, 19 Aug 2014 14:26:04 -0700
Message-Id: <20140819212604.6C94DF09@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com, peterz@infradead.org, mingo@redhat.com, ak@linux.intel.com, tim.c.chen@linux.intel.com, akpm@linux-foundation.org, cl@linux.com, penberg@kernel.org, linux-mm@kvack.org


From: Dave Hansen <dave.hansen@linux.intel.com>

I have more than once myself been the victim of an accidentally-
enabled kernel config option being mistaken for a true
performance problem.

I'm sure I've also taken profiles or performance measurements
and assumed they were real-world when really I was measuing the
performance with an option that nobody turns on in production.

A warning like this late in boot will help remind folks when
these kinds of things are enabled.

As for the patch...

I originally wanted this for CONFIG_DEBUG_VM, but I think it also
applies to things like lockdep and slab debugging.  See the patch
for the list of offending config options.  I'm open to adding
more, but this seemed like a good list to start.

This could be done with Kconfig and an #ifdef to save us 8 bytes
of text and the entry in the late_initcall() section.  Doing it
this way lets us keep the list of these things in one spot, and
also gives us a convenient way to dump out the name of the
offending option.

The dump_stack() is really just to be loud.

For anybody that *really* cares, I put the whole thing under
#ifdef CONFIG_DEBUG_KERNEL.

The messages look like this:

[    2.534574] CONFIG_LOCKDEP enabled
[    2.536392] Do not use this kernel for performance measurement.
[    2.547189] CPU: 0 PID: 1 Comm: swapper/0 Not tainted 3.16.0-10473-gc8d6637-dirty #800
[    2.558075] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
[    2.564483]  0000000080000000 ffff88009c70be78 ffffffff817ce318 0000000000000000
[    2.582505]  ffffffff81dca5b6 ffff88009c70be88 ffffffff81dca5e2 ffff88009c70bef8
[    2.588589]  ffffffff81000377 0000000000000000 0007000700000142 ffffffff81b78968
[    2.592638] Call Trace:
[    2.593762]  [<ffffffff817ce318>] dump_stack+0x4e/0x68
[    2.597742]  [<ffffffff81dca5b6>] ? oops_setup+0x2e/0x2e
[    2.601247]  [<ffffffff81dca5e2>] performance_taint+0x2c/0x3c
[    2.603498]  [<ffffffff81000377>] do_one_initcall+0xe7/0x290
[    2.606556]  [<ffffffff81db3215>] kernel_init_freeable+0x106/0x19a
[    2.609718]  [<ffffffff81db29e8>] ? do_early_param+0x86/0x86
[    2.613772]  [<ffffffff817bcfc0>] ? rest_init+0x150/0x150
[    2.617333]  [<ffffffff817bcfce>] kernel_init+0xe/0xf0
[    2.620840]  [<ffffffff817dbc7c>] ret_from_fork+0x7c/0xb0
[    2.624718]  [<ffffffff817bcfc0>] ? rest_init+0x150/0x150

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: ak@linux.intel.com
Cc: tim.c.chen@linux.intel.com
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
---

 b/include/linux/kernel.h |    1 +
 b/kernel/panic.c         |   40 ++++++++++++++++++++++++++++++++++++++++
 2 files changed, 41 insertions(+)

diff -puN include/linux/kernel.h~taint-performance include/linux/kernel.h
--- a/include/linux/kernel.h~taint-performance	2014-08-19 11:38:07.424005355 -0700
+++ b/include/linux/kernel.h	2014-08-19 11:38:20.960615904 -0700
@@ -471,6 +471,7 @@ extern enum system_states {
 #define TAINT_OOT_MODULE		12
 #define TAINT_UNSIGNED_MODULE		13
 #define TAINT_SOFTLOCKUP		14
+#define TAINT_PERFORMANCE		15
 
 extern const char hex_asc[];
 #define hex_asc_lo(x)	hex_asc[((x) & 0x0f)]
diff -puN kernel/panic.c~taint-performance kernel/panic.c
--- a/kernel/panic.c~taint-performance	2014-08-19 11:38:28.928975233 -0700
+++ b/kernel/panic.c	2014-08-19 14:14:23.444983711 -0700
@@ -225,6 +225,7 @@ static const struct tnt tnts[] = {
 	{ TAINT_OOT_MODULE,		'O', ' ' },
 	{ TAINT_UNSIGNED_MODULE,	'E', ' ' },
 	{ TAINT_SOFTLOCKUP,		'L', ' ' },
+	{ TAINT_PERFORMANCE,		'Q', ' ' },
 };
 
 /**
@@ -501,3 +502,42 @@ static int __init oops_setup(char *s)
 	return 0;
 }
 early_param("oops", oops_setup);
+
+#ifdef CONFIG_DEBUG_KERNEL
+#define TAINT_PERF_IF(x) do {						\
+		if (IS_ENABLED(CONFIG_##x)) {				\
+			do_taint = 1;					\
+			pr_warn("CONFIG_%s enabled\n",	__stringify(x));\
+		}							\
+	} while (0)
+
+static int __init performance_taint(void)
+{
+	int do_taint = 0;
+
+	/*
+	 * This should list any kernel options that can substantially
+	 * affect performance.  This is intended to give a big, fat
+	 * warning during bootup so that folks have a fighting chance
+	 * of noticing these things.
+	 */
+	TAINT_PERF_IF(LOCKDEP);
+	TAINT_PERF_IF(LOCK_STAT);
+	TAINT_PERF_IF(DEBUG_VM);
+	TAINT_PERF_IF(DEBUG_VM_VMACACHE);
+	TAINT_PERF_IF(DEBUG_VM_RB);
+	TAINT_PERF_IF(DEBUG_SLAB);
+	TAINT_PERF_IF(DEBUG_OBJECTS_FREE);
+	TAINT_PERF_IF(DEBUG_KMEMLEAK);
+	TAINT_PERF_IF(SCHEDSTATS);
+
+	if (!do_taint)
+		return 0;
+
+	pr_warn("Do not use this kernel for performance measurement.");
+	dump_stack();
+	add_taint(TAINT_PERFORMANCE, LOCKDEP_STILL_OK);
+	return 0;
+}
+late_initcall(performance_taint);
+#endif
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
