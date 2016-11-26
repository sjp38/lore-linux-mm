Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 434656B025E
	for <linux-mm@kvack.org>; Sat, 26 Nov 2016 18:14:29 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id i131so29401473wmf.3
        for <linux-mm@kvack.org>; Sat, 26 Nov 2016 15:14:29 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id l6si48168730wje.169.2016.11.26.15.14.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Sat, 26 Nov 2016 15:14:28 -0800 (PST)
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [PATCH 10/22] mm/zsmalloc: Convert to hotplug state machine
Date: Sun, 27 Nov 2016 00:13:38 +0100
Message-Id: <20161126231350.10321-11-bigeasy@linutronix.de>
In-Reply-To: <20161126231350.10321-1-bigeasy@linutronix.de>
References: <20161126231350.10321-1-bigeasy@linutronix.de>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: rt@linutronix.de, tglx@linutronix.de, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, linux-mm@kvack.org

Install the callbacks via the state machine and let the core invoke
the callbacks on the already online CPUs.

Cc: Minchan Kim <minchan@kernel.org>
Cc: Nitin Gupta <ngupta@vflare.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
CC: linux-mm@kvack.org
Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 include/linux/cpuhotplug.h |  1 +
 mm/zsmalloc.c              | 67 +++++++++---------------------------------=
----
 2 files changed, 14 insertions(+), 54 deletions(-)

diff --git a/include/linux/cpuhotplug.h b/include/linux/cpuhotplug.h
index 4ebd1bc27f8d..9f29dd996088 100644
--- a/include/linux/cpuhotplug.h
+++ b/include/linux/cpuhotplug.h
@@ -64,6 +64,7 @@ enum cpuhp_state {
 	CPUHP_NET_IUCV_PREPARE,
 	CPUHP_ARM_BL_PREPARE,
 	CPUHP_TRACE_RB_PREPARE,
+	CPUHP_MM_ZS_PREPARE,
 	CPUHP_TIMERS_DEAD,
 	CPUHP_NOTF_ERR_INJ_PREPARE,
 	CPUHP_MIPS_SOC_PREPARE,
diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index b0bc023d25c5..9cc3c0b2c2c1 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -1284,61 +1284,21 @@ static void __zs_unmap_object(struct mapping_area *=
area,
=20
 #endif /* CONFIG_PGTABLE_MAPPING */
=20
-static int zs_cpu_notifier(struct notifier_block *nb, unsigned long action,
-				void *pcpu)
+static int zs_cpu_prepare(unsigned int cpu)
 {
-	int ret, cpu =3D (long)pcpu;
 	struct mapping_area *area;
=20
-	switch (action) {
-	case CPU_UP_PREPARE:
-		area =3D &per_cpu(zs_map_area, cpu);
-		ret =3D __zs_cpu_up(area);
-		if (ret)
-			return notifier_from_errno(ret);
-		break;
-	case CPU_DEAD:
-	case CPU_UP_CANCELED:
-		area =3D &per_cpu(zs_map_area, cpu);
-		__zs_cpu_down(area);
-		break;
-	}
-
-	return NOTIFY_OK;
+	area =3D &per_cpu(zs_map_area, cpu);
+	return __zs_cpu_up(area);
 }
=20
-static struct notifier_block zs_cpu_nb =3D {
-	.notifier_call =3D zs_cpu_notifier
-};
-
-static int zs_register_cpu_notifier(void)
+static int zs_cpu_dead(unsigned int cpu)
 {
-	int cpu, uninitialized_var(ret);
+	struct mapping_area *area;
=20
-	cpu_notifier_register_begin();
-
-	__register_cpu_notifier(&zs_cpu_nb);
-	for_each_online_cpu(cpu) {
-		ret =3D zs_cpu_notifier(NULL, CPU_UP_PREPARE, (void *)(long)cpu);
-		if (notifier_to_errno(ret))
-			break;
-	}
-
-	cpu_notifier_register_done();
-	return notifier_to_errno(ret);
-}
-
-static void zs_unregister_cpu_notifier(void)
-{
-	int cpu;
-
-	cpu_notifier_register_begin();
-
-	for_each_online_cpu(cpu)
-		zs_cpu_notifier(NULL, CPU_DEAD, (void *)(long)cpu);
-	__unregister_cpu_notifier(&zs_cpu_nb);
-
-	cpu_notifier_register_done();
+	area =3D &per_cpu(zs_map_area, cpu);
+	__zs_cpu_down(area);
+	return 0;
 }
=20
 static void __init init_zs_size_classes(void)
@@ -2534,10 +2494,10 @@ static int __init zs_init(void)
 	if (ret)
 		goto out;
=20
-	ret =3D zs_register_cpu_notifier();
-
+	ret =3D cpuhp_setup_state(CPUHP_MM_ZS_PREPARE, "mm/zsmalloc:prepare",
+				zs_cpu_prepare, zs_cpu_dead);
 	if (ret)
-		goto notifier_fail;
+		goto hp_setup_fail;
=20
 	init_zs_size_classes();
=20
@@ -2549,8 +2509,7 @@ static int __init zs_init(void)
=20
 	return 0;
=20
-notifier_fail:
-	zs_unregister_cpu_notifier();
+hp_setup_fail:
 	zsmalloc_unmount();
 out:
 	return ret;
@@ -2562,7 +2521,7 @@ static void __exit zs_exit(void)
 	zpool_unregister_driver(&zs_zpool_driver);
 #endif
 	zsmalloc_unmount();
-	zs_unregister_cpu_notifier();
+	cpuhp_remove_state(CPUHP_MM_ZS_PREPARE);
=20
 	zs_stat_exit();
 }
--=20
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
