Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id A889C6B0261
	for <linux-mm@kvack.org>; Sat, 26 Nov 2016 18:14:29 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id o3so14659134wjo.1
        for <linux-mm@kvack.org>; Sat, 26 Nov 2016 15:14:29 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id 137si20091882wmb.66.2016.11.26.15.14.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Sat, 26 Nov 2016 15:14:28 -0800 (PST)
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [PATCH 11/22] mm/zswap: Convert dst-mem to hotplug state machine
Date: Sun, 27 Nov 2016 00:13:39 +0100
Message-Id: <20161126231350.10321-12-bigeasy@linutronix.de>
In-Reply-To: <20161126231350.10321-1-bigeasy@linutronix.de>
References: <20161126231350.10321-1-bigeasy@linutronix.de>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: rt@linutronix.de, tglx@linutronix.de, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Seth Jennings <sjenning@redhat.com>, linux-mm@kvack.org

Install the callbacks via the state machine and let the core invoke
the callbacks on the already online CPUs.

Cc: Seth Jennings <sjenning@redhat.com>
Cc: linux-mm@kvack.org
Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 include/linux/cpuhotplug.h |  1 +
 mm/zswap.c                 | 75 +++++++++++-------------------------------=
----
 2 files changed, 19 insertions(+), 57 deletions(-)

diff --git a/include/linux/cpuhotplug.h b/include/linux/cpuhotplug.h
index 9f29dd996088..62f51a4e8676 100644
--- a/include/linux/cpuhotplug.h
+++ b/include/linux/cpuhotplug.h
@@ -65,6 +65,7 @@ enum cpuhp_state {
 	CPUHP_ARM_BL_PREPARE,
 	CPUHP_TRACE_RB_PREPARE,
 	CPUHP_MM_ZS_PREPARE,
+	CPUHP_MM_ZSWP_MEM_PREPARE,
 	CPUHP_TIMERS_DEAD,
 	CPUHP_NOTF_ERR_INJ_PREPARE,
 	CPUHP_MIPS_SOC_PREPARE,
diff --git a/mm/zswap.c b/mm/zswap.c
index 275b22cc8df4..b13aa5706348 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -352,70 +352,28 @@ static struct zswap_entry *zswap_entry_find_get(struc=
t rb_root *root,
 **********************************/
 static DEFINE_PER_CPU(u8 *, zswap_dstmem);
=20
-static int __zswap_cpu_dstmem_notifier(unsigned long action, unsigned long=
 cpu)
+static int zswap_dstmem_prepare(unsigned int cpu)
 {
 	u8 *dst;
=20
-	switch (action) {
-	case CPU_UP_PREPARE:
-		dst =3D kmalloc_node(PAGE_SIZE * 2, GFP_KERNEL, cpu_to_node(cpu));
-		if (!dst) {
-			pr_err("can't allocate compressor buffer\n");
-			return NOTIFY_BAD;
-		}
-		per_cpu(zswap_dstmem, cpu) =3D dst;
-		break;
-	case CPU_DEAD:
-	case CPU_UP_CANCELED:
-		dst =3D per_cpu(zswap_dstmem, cpu);
-		kfree(dst);
-		per_cpu(zswap_dstmem, cpu) =3D NULL;
-		break;
-	default:
-		break;
+	dst =3D kmalloc_node(PAGE_SIZE * 2, GFP_KERNEL, cpu_to_node(cpu));
+	if (!dst) {
+		pr_err("can't allocate compressor buffer\n");
+		return -ENOMEM;
 	}
-	return NOTIFY_OK;
-}
-
-static int zswap_cpu_dstmem_notifier(struct notifier_block *nb,
-				     unsigned long action, void *pcpu)
-{
-	return __zswap_cpu_dstmem_notifier(action, (unsigned long)pcpu);
-}
-
-static struct notifier_block zswap_dstmem_notifier =3D {
-	.notifier_call =3D	zswap_cpu_dstmem_notifier,
-};
-
-static int __init zswap_cpu_dstmem_init(void)
-{
-	unsigned long cpu;
-
-	cpu_notifier_register_begin();
-	for_each_online_cpu(cpu)
-		if (__zswap_cpu_dstmem_notifier(CPU_UP_PREPARE, cpu) =3D=3D
-		    NOTIFY_BAD)
-			goto cleanup;
-	__register_cpu_notifier(&zswap_dstmem_notifier);
-	cpu_notifier_register_done();
+	per_cpu(zswap_dstmem, cpu) =3D dst;
 	return 0;
-
-cleanup:
-	for_each_online_cpu(cpu)
-		__zswap_cpu_dstmem_notifier(CPU_UP_CANCELED, cpu);
-	cpu_notifier_register_done();
-	return -ENOMEM;
 }
=20
-static void zswap_cpu_dstmem_destroy(void)
+static int zswap_dstmem_dead(unsigned int cpu)
 {
-	unsigned long cpu;
+	u8 *dst;
=20
-	cpu_notifier_register_begin();
-	for_each_online_cpu(cpu)
-		__zswap_cpu_dstmem_notifier(CPU_UP_CANCELED, cpu);
-	__unregister_cpu_notifier(&zswap_dstmem_notifier);
-	cpu_notifier_register_done();
+	dst =3D per_cpu(zswap_dstmem, cpu);
+	kfree(dst);
+	per_cpu(zswap_dstmem, cpu) =3D NULL;
+
+	return 0;
 }
=20
 static int __zswap_cpu_comp_notifier(struct zswap_pool *pool,
@@ -1238,6 +1196,7 @@ static void __exit zswap_debugfs_exit(void) { }
 static int __init init_zswap(void)
 {
 	struct zswap_pool *pool;
+	int ret;
=20
 	zswap_init_started =3D true;
=20
@@ -1246,7 +1205,9 @@ static int __init init_zswap(void)
 		goto cache_fail;
 	}
=20
-	if (zswap_cpu_dstmem_init()) {
+	ret =3D cpuhp_setup_state(CPUHP_MM_ZSWP_MEM_PREPARE, "mm/zswap:prepare",
+				zswap_dstmem_prepare, zswap_dstmem_dead);
+	if (ret) {
 		pr_err("dstmem alloc failed\n");
 		goto dstmem_fail;
 	}
@@ -1267,7 +1228,7 @@ static int __init init_zswap(void)
 	return 0;
=20
 pool_fail:
-	zswap_cpu_dstmem_destroy();
+	cpuhp_remove_state(CPUHP_MM_ZSWP_MEM_PREPARE);
 dstmem_fail:
 	zswap_entry_cache_destroy();
 cache_fail:
--=20
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
