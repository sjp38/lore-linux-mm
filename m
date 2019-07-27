Return-Path: <SRS0=PO26=VY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 89C1EC7618B
	for <linux-mm@archiver.kernel.org>; Sat, 27 Jul 2019 13:23:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 474912075C
	for <linux-mm@archiver.kernel.org>; Sat, 27 Jul 2019 13:23:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 474912075C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 97BF88E0003; Sat, 27 Jul 2019 09:23:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 904CB8E0002; Sat, 27 Jul 2019 09:23:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7CDB98E0003; Sat, 27 Jul 2019 09:23:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2DFBB8E0002
	for <linux-mm@kvack.org>; Sat, 27 Jul 2019 09:23:44 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id y3so35608562edm.21
        for <linux-mm@kvack.org>; Sat, 27 Jul 2019 06:23:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=0zm3XZWTb3AoYkf0dPkG/cF2oas/d2FZ4xqO29EaCJ4=;
        b=h/RjAbi+pQbPYEObKllOrdz6WEKZoZEaLLlb4eamxa2SceZRJrj8TtMH1YAJtZZXzF
         l6M1WknHmklvokzI3sZ9sSJPJ4GuwgA+VxS5isk/rldRtmFCWD39TQNUCRht0Rr5wI4Z
         UYeL2JOwpF/zH4MMSbupMJBi3UlOsqJoRFD6Xnqv2x1uSbTsVMocPpMvWiZRgqVTGcB2
         CKCROQ32EAVRObDcqZ/f6A2N7b+l+k+rJKPt/9iuNgnCGUbS8gTeoyDiUIzTYOxJJpGj
         NebrxtT0QjGcdNFAA7MdWoFTuKqaur1XCosf+jKv9olH9VJ/4fA4SzM+ja0hosSIUOqO
         0x+Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAV//hH7xwpbKh2saC1VUkqC1n1A/uRIouPTA02RpIM4RVpqd79j
	abV9fymutDDm+/dfTT/8SzVTBqzOSW0JaoOKLkdZ9fZCOFyolIYicp/eQpiHyMBWP2MFpWLQfPU
	1XF4YdmP8tf7jRLOrrydTPrOaAD4xz2yf3l5unElvO63wqO9VV/ozz88oQ3943/9b8w==
X-Received: by 2002:a17:906:8317:: with SMTP id j23mr64385957ejx.51.1564233823745;
        Sat, 27 Jul 2019 06:23:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxWiua+eX/gy9JlLA28Sjdt8lwBVJ++iUg/cmGBXJItWwIY2uE/RpmlEhonE64GtQ7P89GS
X-Received: by 2002:a17:906:8317:: with SMTP id j23mr64385917ejx.51.1564233822832;
        Sat, 27 Jul 2019 06:23:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564233822; cv=none;
        d=google.com; s=arc-20160816;
        b=nwnhAZaFELOF0NXZ/WF5MBpNGKwdfm/A2w12H2bif8hVQUlW0lDltUzB9309g4mtx3
         akLTZUCyFJozcb8dPXiKCMMCXs+V0jM1bThzG8Bex6mzvpvdGko9nRFcxKgeV3PTEyU6
         QFSMr8q0hg6T3v9NJDGUrk9tk6J21UXT+4ZcYaXvCSKybEUSYy4/cvn1dn6LwELb7xR2
         OxXy9p1D7UTuXakZkYBIUTpbHLB/ZaPGPd+/mBB/sAfGLRaqnzd2RoynXCWtfdDginlp
         BOMhpL8FP0FEB5tzuhPOEpscmC12ZoBLrXbyfr+BrxmelNvOvhFZ21uqoJTzn8/rFlEK
         HtQQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=0zm3XZWTb3AoYkf0dPkG/cF2oas/d2FZ4xqO29EaCJ4=;
        b=Lw/x8/k+UO1RpSsdFRaddLUF0rCHuUG7asENjE8WWxwCQ8BovD0v8CcV8SmRxzGKlC
         igcsSnmwCHFkZ/sHAovhdL8u1gkEWvQBUQdOD8KrxghguontfagllaX91l2DE/3LvfMI
         koEmYRV0PNeKQ6aPKuC3F0A9/gWMtOaJ5CwiXtaXtvnOoCROYa9mZQ4VM+Y/J4/gp0oI
         u0PoivA20RWzJSzCgls91PcmcA2fOV04t3VgubXEbjwV0S2k/bO2TaEHAMZUEcXn0uDL
         LG/VjuxeVQhYXE6do3vf1uoSuMXGJoF7eivLV7zrlDmkSV3iWLeJLIJijBvBpOjW4LYy
         vQZg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id ss18si12240033ejb.84.2019.07.27.06.23.42
        for <linux-mm@kvack.org>;
        Sat, 27 Jul 2019 06:23:42 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id A143C28;
	Sat, 27 Jul 2019 06:23:41 -0700 (PDT)
Received: from arrakis.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.121.207.14])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id 9D8453F71F;
	Sat, 27 Jul 2019 06:23:40 -0700 (PDT)
From: Catalin Marinas <catalin.marinas@arm.com>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@kernel.org>,
	Matthew Wilcox <willy@infradead.org>,
	Qian Cai <cai@lca.pw>
Subject: [PATCH v2] mm: kmemleak: Use mempool allocations for kmemleak objects
Date: Sat, 27 Jul 2019 14:23:33 +0100
Message-Id: <20190727132334.9184-1-catalin.marinas@arm.com>
X-Mailer: git-send-email 2.22.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Add mempool allocations for struct kmemleak_object and
kmemleak_scan_area as slightly more resilient than kmem_cache_alloc()
under memory pressure. Additionally, mask out all the gfp flags passed
to kmemleak other than GFP_KERNEL|GFP_ATOMIC.

A boot-time tuning parameter (kmemleak.mempool) is added to allow a
different minimum pool size (defaulting to NR_CPUS * 4).

Cc: Michal Hocko <mhocko@kernel.org>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Qian Cai <cai@lca.pw>
Suggested-by: Michal Hocko <mhocko@kernel.org>
Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
---

v1 posted here:

http://lkml.kernel.org/r/20190328145917.GC10283@arrakis.emea.arm.com

Changes in v2:

- kmemleak.mempool cmdline parameter to configure the minimum pool size
- rebased against -next (on top of the __GFP_NOFAIL revert)

 .../admin-guide/kernel-parameters.txt         |  6 ++
 mm/kmemleak.c                                 | 58 +++++++++++++++----
 2 files changed, 54 insertions(+), 10 deletions(-)

diff --git a/Documentation/admin-guide/kernel-parameters.txt b/Documentation/admin-guide/kernel-parameters.txt
index 46b826fcb5ad..11c413e3c42b 100644
--- a/Documentation/admin-guide/kernel-parameters.txt
+++ b/Documentation/admin-guide/kernel-parameters.txt
@@ -2011,6 +2011,12 @@
 			Built with CONFIG_DEBUG_KMEMLEAK_DEFAULT_OFF=y,
 			the default is off.
 
+	kmemleak.mempool=
+			[KNL] Boot-time tuning of the minimum kmemleak
+			metadata pool size.
+			Format: <int>
+			Default: NR_CPUS * 4
+
 	kprobe_event=[probe-list]
 			[FTRACE] Add kprobe events and enable at boot time.
 			The probe-list is a semicolon delimited list of probe
diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index 6e9e8cca663e..a31eab79bcf5 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -69,6 +69,7 @@
 #include <linux/kthread.h>
 #include <linux/rbtree.h>
 #include <linux/fs.h>
+#include <linux/mempool.h>
 #include <linux/debugfs.h>
 #include <linux/seq_file.h>
 #include <linux/cpumask.h>
@@ -112,9 +113,7 @@
 #define BYTES_PER_POINTER	sizeof(void *)
 
 /* GFP bitmask for kmemleak internal allocations */
-#define gfp_kmemleak_mask(gfp)	(((gfp) & (GFP_KERNEL | GFP_ATOMIC)) | \
-				 __GFP_NORETRY | __GFP_NOMEMALLOC | \
-				 __GFP_NOWARN)
+#define gfp_kmemleak_mask(gfp)	((gfp) & (GFP_KERNEL | GFP_ATOMIC))
 
 /* scanning area inside a memory block */
 struct kmemleak_scan_area {
@@ -190,7 +189,13 @@ static DEFINE_RWLOCK(kmemleak_lock);
 
 /* allocation caches for kmemleak internal data */
 static struct kmem_cache *object_cache;
+static mempool_t *object_mempool;
 static struct kmem_cache *scan_area_cache;
+static mempool_t *scan_area_mempool;
+
+/* default minimum memory pool sizes */
+static int min_object_pool = NR_CPUS * 4;
+static int min_scan_area_pool = NR_CPUS * 1;
 
 /* set if tracing memory operations is enabled */
 static int kmemleak_enabled;
@@ -465,9 +470,9 @@ static void free_object_rcu(struct rcu_head *rcu)
 	 */
 	hlist_for_each_entry_safe(area, tmp, &object->area_list, node) {
 		hlist_del(&area->node);
-		kmem_cache_free(scan_area_cache, area);
+		mempool_free(area, scan_area_mempool);
 	}
-	kmem_cache_free(object_cache, object);
+	mempool_free(object, object_mempool);
 }
 
 /*
@@ -550,7 +555,7 @@ static struct kmemleak_object *create_object(unsigned long ptr, size_t size,
 	struct rb_node **link, *rb_parent;
 	unsigned long untagged_ptr;
 
-	object = kmem_cache_alloc(object_cache, gfp_kmemleak_mask(gfp));
+	object = mempool_alloc(object_mempool, gfp_kmemleak_mask(gfp));
 	if (!object) {
 		pr_warn("Cannot allocate a kmemleak_object structure\n");
 		kmemleak_disable();
@@ -614,7 +619,7 @@ static struct kmemleak_object *create_object(unsigned long ptr, size_t size,
 			 * be freed while the kmemleak_lock is held.
 			 */
 			dump_object_info(parent);
-			kmem_cache_free(object_cache, object);
+			mempool_free(object, object_mempool);
 			object = NULL;
 			goto out;
 		}
@@ -772,7 +777,7 @@ static void add_scan_area(unsigned long ptr, size_t size, gfp_t gfp)
 		return;
 	}
 
-	area = kmem_cache_alloc(scan_area_cache, gfp_kmemleak_mask(gfp));
+	area = mempool_alloc(scan_area_mempool, gfp_kmemleak_mask(gfp));
 	if (!area) {
 		pr_warn("Cannot allocate a scan area\n");
 		goto out;
@@ -784,7 +789,7 @@ static void add_scan_area(unsigned long ptr, size_t size, gfp_t gfp)
 	} else if (ptr + size > object->pointer + object->size) {
 		kmemleak_warn("Scan area larger than object 0x%08lx\n", ptr);
 		dump_object_info(object);
-		kmem_cache_free(scan_area_cache, area);
+		mempool_free(area, scan_area_mempool);
 		goto out_unlock;
 	}
 
@@ -1993,6 +1998,27 @@ static int __init kmemleak_boot_config(char *str)
 }
 early_param("kmemleak", kmemleak_boot_config);
 
+/*
+ * Allow boot-time tuning of the kmemleak mempool size.
+ */
+static int __init kmemleak_mempool_config(char *str)
+{
+	int size, ret;
+
+	if (!str)
+		return -EINVAL;
+
+	ret = kstrtoint(str, 0, &size);
+	if (ret)
+		return ret;
+
+	min_object_pool = size;
+	min_scan_area_pool = size / 4;
+
+	return 0;
+}
+early_param("kmemleak.mempool", kmemleak_mempool_config);
+
 static void __init print_log_trace(struct early_log *log)
 {
 	pr_notice("Early log backtrace:\n");
@@ -2020,6 +2046,18 @@ void __init kmemleak_init(void)
 
 	object_cache = KMEM_CACHE(kmemleak_object, SLAB_NOLEAKTRACE);
 	scan_area_cache = KMEM_CACHE(kmemleak_scan_area, SLAB_NOLEAKTRACE);
+	if (!object_cache || !scan_area_cache) {
+		kmemleak_disable();
+		return;
+	}
+	object_mempool = mempool_create_slab_pool(min_object_pool,
+						  object_cache);
+	scan_area_mempool = mempool_create_slab_pool(min_scan_area_pool,
+						     scan_area_cache);
+	if (!object_mempool || !scan_area_mempool) {
+		kmemleak_disable();
+		return;
+	}
 
 	if (crt_early_log > ARRAY_SIZE(early_log))
 		pr_warn("Early log buffer exceeded (%d), please increase DEBUG_KMEMLEAK_EARLY_LOG_SIZE\n",
@@ -2126,7 +2164,7 @@ static int __init kmemleak_late_init(void)
 		mutex_unlock(&scan_mutex);
 	}
 
-	pr_info("Kernel memory leak detector initialized\n");
+	pr_info("Kernel memory leak detector initialized (mempool size: %d)\n", min_object_pool);
 
 	return 0;
 }

