Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2692A6B0261
	for <linux-mm@kvack.org>; Sat, 26 Nov 2016 18:14:31 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id xy5so14656304wjc.0
        for <linux-mm@kvack.org>; Sat, 26 Nov 2016 15:14:31 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id to13si44584585wjb.192.2016.11.26.15.14.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Sat, 26 Nov 2016 15:14:29 -0800 (PST)
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [PATCH 12/22] mm/zswap: Convert pool to hotplug state machine
Date: Sun, 27 Nov 2016 00:13:40 +0100
Message-Id: <20161126231350.10321-13-bigeasy@linutronix.de>
In-Reply-To: <20161126231350.10321-1-bigeasy@linutronix.de>
References: <20161126231350.10321-1-bigeasy@linutronix.de>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: rt@linutronix.de, tglx@linutronix.de, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Seth Jennings <sjenning@redhat.com>, linux-mm@kvack.org

Install the callbacks via the state machine. Multi state is used to address=
 the
per-pool notifier. Uppon adding of the intance the callback is invoked for =
all
online CPUs so the manual init can go.

Cc: Seth Jennings <sjenning@redhat.com>
Cc: linux-mm@kvack.org
Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 include/linux/cpuhotplug.h |  1 +
 mm/zswap.c                 | 99 ++++++++++++++++--------------------------=
----
 2 files changed, 35 insertions(+), 65 deletions(-)

diff --git a/include/linux/cpuhotplug.h b/include/linux/cpuhotplug.h
index 62f51a4e8676..c7d0d76ef0ee 100644
--- a/include/linux/cpuhotplug.h
+++ b/include/linux/cpuhotplug.h
@@ -66,6 +66,7 @@ enum cpuhp_state {
 	CPUHP_TRACE_RB_PREPARE,
 	CPUHP_MM_ZS_PREPARE,
 	CPUHP_MM_ZSWP_MEM_PREPARE,
+	CPUHP_MM_ZSWP_POOL_PREPARE,
 	CPUHP_TIMERS_DEAD,
 	CPUHP_NOTF_ERR_INJ_PREPARE,
 	CPUHP_MIPS_SOC_PREPARE,
diff --git a/mm/zswap.c b/mm/zswap.c
index b13aa5706348..067a0d62f318 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -118,7 +118,7 @@ struct zswap_pool {
 	struct kref kref;
 	struct list_head list;
 	struct work_struct work;
-	struct notifier_block notifier;
+	struct hlist_node node;
 	char tfm_name[CRYPTO_MAX_ALG_NAME];
 };
=20
@@ -376,77 +376,34 @@ static int zswap_dstmem_dead(unsigned int cpu)
 	return 0;
 }
=20
-static int __zswap_cpu_comp_notifier(struct zswap_pool *pool,
-				     unsigned long action, unsigned long cpu)
+static int zswap_cpu_comp_prepare(unsigned int cpu, struct hlist_node *nod=
e)
 {
+	struct zswap_pool *pool =3D hlist_entry(node, struct zswap_pool, node);
 	struct crypto_comp *tfm;
=20
-	switch (action) {
-	case CPU_UP_PREPARE:
-		if (WARN_ON(*per_cpu_ptr(pool->tfm, cpu)))
-			break;
-		tfm =3D crypto_alloc_comp(pool->tfm_name, 0, 0);
-		if (IS_ERR_OR_NULL(tfm)) {
-			pr_err("could not alloc crypto comp %s : %ld\n",
-			       pool->tfm_name, PTR_ERR(tfm));
-			return NOTIFY_BAD;
-		}
-		*per_cpu_ptr(pool->tfm, cpu) =3D tfm;
-		break;
-	case CPU_DEAD:
-	case CPU_UP_CANCELED:
-		tfm =3D *per_cpu_ptr(pool->tfm, cpu);
-		if (!IS_ERR_OR_NULL(tfm))
-			crypto_free_comp(tfm);
-		*per_cpu_ptr(pool->tfm, cpu) =3D NULL;
-		break;
-	default:
-		break;
+	if (WARN_ON(*per_cpu_ptr(pool->tfm, cpu)))
+		return 0;
+
+	tfm =3D crypto_alloc_comp(pool->tfm_name, 0, 0);
+	if (IS_ERR_OR_NULL(tfm)) {
+		pr_err("could not alloc crypto comp %s : %ld\n",
+		       pool->tfm_name, PTR_ERR(tfm));
+		return -ENOMEM;
 	}
-	return NOTIFY_OK;
-}
-
-static int zswap_cpu_comp_notifier(struct notifier_block *nb,
-				   unsigned long action, void *pcpu)
-{
-	unsigned long cpu =3D (unsigned long)pcpu;
-	struct zswap_pool *pool =3D container_of(nb, typeof(*pool), notifier);
-
-	return __zswap_cpu_comp_notifier(pool, action, cpu);
-}
-
-static int zswap_cpu_comp_init(struct zswap_pool *pool)
-{
-	unsigned long cpu;
-
-	memset(&pool->notifier, 0, sizeof(pool->notifier));
-	pool->notifier.notifier_call =3D zswap_cpu_comp_notifier;
-
-	cpu_notifier_register_begin();
-	for_each_online_cpu(cpu)
-		if (__zswap_cpu_comp_notifier(pool, CPU_UP_PREPARE, cpu) =3D=3D
-		    NOTIFY_BAD)
-			goto cleanup;
-	__register_cpu_notifier(&pool->notifier);
-	cpu_notifier_register_done();
+	*per_cpu_ptr(pool->tfm, cpu) =3D tfm;
 	return 0;
-
-cleanup:
-	for_each_online_cpu(cpu)
-		__zswap_cpu_comp_notifier(pool, CPU_UP_CANCELED, cpu);
-	cpu_notifier_register_done();
-	return -ENOMEM;
 }
=20
-static void zswap_cpu_comp_destroy(struct zswap_pool *pool)
+static int zswap_cpu_comp_dead(unsigned int cpu, struct hlist_node *node)
 {
-	unsigned long cpu;
+	struct zswap_pool *pool =3D hlist_entry(node, struct zswap_pool, node);
+	struct crypto_comp *tfm;
=20
-	cpu_notifier_register_begin();
-	for_each_online_cpu(cpu)
-		__zswap_cpu_comp_notifier(pool, CPU_UP_CANCELED, cpu);
-	__unregister_cpu_notifier(&pool->notifier);
-	cpu_notifier_register_done();
+	tfm =3D *per_cpu_ptr(pool->tfm, cpu);
+	if (!IS_ERR_OR_NULL(tfm))
+		crypto_free_comp(tfm);
+	*per_cpu_ptr(pool->tfm, cpu) =3D NULL;
+	return 0;
 }
=20
 /*********************************
@@ -527,6 +484,7 @@ static struct zswap_pool *zswap_pool_create(char *type,=
 char *compressor)
 	struct zswap_pool *pool;
 	char name[38]; /* 'zswap' + 32 char (max) num + \0 */
 	gfp_t gfp =3D __GFP_NORETRY | __GFP_NOWARN | __GFP_KSWAPD_RECLAIM;
+	int ret;
=20
 	pool =3D kzalloc(sizeof(*pool), GFP_KERNEL);
 	if (!pool) {
@@ -551,7 +509,9 @@ static struct zswap_pool *zswap_pool_create(char *type,=
 char *compressor)
 		goto error;
 	}
=20
-	if (zswap_cpu_comp_init(pool))
+	ret =3D cpuhp_state_add_instance(CPUHP_MM_ZSWP_POOL_PREPARE,
+				       &pool->node);
+	if (ret)
 		goto error;
 	pr_debug("using %s compressor\n", pool->tfm_name);
=20
@@ -605,7 +565,7 @@ static void zswap_pool_destroy(struct zswap_pool *pool)
 {
 	zswap_pool_debug("destroying", pool);
=20
-	zswap_cpu_comp_destroy(pool);
+	cpuhp_state_remove_instance(CPUHP_MM_ZSWP_POOL_PREPARE, &pool->node);
 	free_percpu(pool->tfm);
 	zpool_destroy_pool(pool->zpool);
 	kfree(pool);
@@ -1212,6 +1172,13 @@ static int __init init_zswap(void)
 		goto dstmem_fail;
 	}
=20
+	ret =3D cpuhp_setup_state_multi(CPUHP_MM_ZSWP_POOL_PREPARE,
+				      "mm/zswap_pool:prepare",
+				      zswap_cpu_comp_prepare,
+				      zswap_cpu_comp_dead);
+	if (ret)
+		goto hp_fail;
+
 	pool =3D __zswap_pool_create_fallback();
 	if (!pool) {
 		pr_err("pool creation failed\n");
@@ -1228,6 +1195,8 @@ static int __init init_zswap(void)
 	return 0;
=20
 pool_fail:
+	cpuhp_remove_state_nocalls(CPUHP_MM_ZSWP_POOL_PREPARE);
+hp_fail:
 	cpuhp_remove_state(CPUHP_MM_ZSWP_MEM_PREPARE);
 dstmem_fail:
 	zswap_entry_cache_destroy();
--=20
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
