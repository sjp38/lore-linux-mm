Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id B43836B0038
	for <linux-mm@kvack.org>; Sat,  4 Feb 2017 09:52:09 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id q3so55505672qtf.4
        for <linux-mm@kvack.org>; Sat, 04 Feb 2017 06:52:09 -0800 (PST)
Received: from mail-qk0-x243.google.com (mail-qk0-x243.google.com. [2607:f8b0:400d:c09::243])
        by mx.google.com with ESMTPS id q69si21484261qki.161.2017.02.04.06.52.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 04 Feb 2017 06:52:08 -0800 (PST)
Received: by mail-qk0-x243.google.com with SMTP id 11so2646721qkl.0
        for <linux-mm@kvack.org>; Sat, 04 Feb 2017 06:52:08 -0800 (PST)
Date: Sat, 4 Feb 2017 09:52:03 -0500
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH] slub: make sysfs directories for memcg sub-caches optional
Message-ID: <20170204145203.GB26958@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, Michal Hocko <mhocko@kernel.org>, kernel-team@fb.com

SLUB creates a per-cache directory under /sys/kernel/slab which hosts
a bunch of debug files.  Usually, there aren't that many caches on a
system and this doesn't really matter; however, if memcg is in use,
each cache can have per-cgroup sub-caches.  SLUB creates the same
directories for these sub-caches under /sys/kernel/slab/$CACHE/cgroup.

Unfortunately, because there can be a lot of cgroups, active or
draining, the product of the numbers of caches, cgroups and files in
each directory can reach a very high number - hundreds of thousands is
commonplace.  Millions and beyond aren't difficult to reach either.

What's under /sys/kernel/slab is primarily for debugging and the
information and control on the a root cache already cover its
sub-caches.  While having a separate directory for each sub-cache can
be helpful for development, it doesn't make much sense to pay this
amount of overhead by default.

This patch introduces a boot parameter slub_memcg_sysfs which
determines whether to create sysfs directories for per-memcg
sub-caches.  It also adds CONFIG_SLUB_MEMCG_SYSFS_ON which determines
the boot parameter's default value and defaults to 0.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
---
 Documentation/kernel-parameters.txt |    8 ++++++++
 init/Kconfig                        |   14 ++++++++++++++
 mm/slub.c                           |   29 ++++++++++++++++++++++++++---
 3 files changed, 48 insertions(+), 3 deletions(-)

--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -3517,6 +3517,14 @@ bytes respectively. Such letter suffixes
 			last alloc / free. For more information see
 			Documentation/vm/slub.txt.
 
+	slub_memcg_sysfs=	[MM, SLUB]
+			Determines whether to enable sysfs directories for
+			memory cgroup sub-caches. 1 to enable, 0 to disable.
+			The default is determined by CONFIG_SLUB_MEMCG_SYSFS_ON.
+			Enabling this can lead to a very high number of	debug
+			directories and files being created under
+			/sys/kernel/slub.
+
 	slub_max_order= [MM, SLUB]
 			Determines the maximum allowed order for slabs.
 			A high setting may cause OOMs due to memory
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -1786,6 +1786,20 @@ config SLUB_DEBUG
 	  SLUB sysfs support. /sys/slab will not exist and there will be
 	  no support for cache validation etc.
 
+config SLUB_MEMCG_SYSFS_ON
+	default n
+	bool "Enable memcg SLUB sysfs support by default" if EXPERT
+	depends on SLUB && SYSFS && MEMCG
+	help
+	  SLUB creates a directory under /sys/kernel/slab for each
+	  allocation cache to host info and debug files. If memory
+	  cgroup is enabled, each cache can have per memory cgroup
+	  caches. SLUB can create the same sysfs directories for these
+	  caches under /sys/kernel/slab/CACHE/cgroup but it can lead
+	  to a very high number of debug files being created. This is
+	  controlled by slub_memcg_sysfs boot parameter and this
+	  config option determines the parameter's default value.
+
 config COMPAT_BRK
 	bool "Disable heap randomization"
 	default y
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -4700,6 +4700,22 @@ enum slab_stat_type {
 #define SO_OBJECTS	(1 << SL_OBJECTS)
 #define SO_TOTAL	(1 << SL_TOTAL)
 
+#ifdef CONFIG_MEMCG
+static bool memcg_sysfs_enabled = IS_ENABLED(CONFIG_SLUB_MEMCG_SYSFS_ON);
+
+static int __init setup_slub_memcg_sysfs(char *str)
+{
+	int v;
+
+	if (get_option(&str, &v) > 0)
+		memcg_sysfs_enabled = v;
+
+	return 1;
+}
+
+__setup("slub_memcg_sysfs=", setup_slub_memcg_sysfs);
+#endif
+
 static ssize_t show_slab_objects(struct kmem_cache *s,
 			    char *buf, unsigned long flags)
 {
@@ -5603,8 +5619,14 @@ static int sysfs_slab_add(struct kmem_ca
 {
 	int err;
 	const char *name;
+	struct kset *kset = cache_kset(s);
 	int unmergeable = slab_unmergeable(s);
 
+	if (!kset) {
+		kobject_init(&s->kobj, &slab_ktype);
+		return 0;
+	}
+
 	if (unmergeable) {
 		/*
 		 * Slabcache can never be merged so we can use the name proper.
@@ -5621,7 +5643,7 @@ static int sysfs_slab_add(struct kmem_ca
 		name = create_unique_id(s);
 	}
 
-	s->kobj.kset = cache_kset(s);
+	s->kobj.kset = kset;
 	err = kobject_init_and_add(&s->kobj, &slab_ktype, NULL, "%s", name);
 	if (err)
 		goto out;
@@ -5631,7 +5653,7 @@ static int sysfs_slab_add(struct kmem_ca
 		goto out_del_kobj;
 
 #ifdef CONFIG_MEMCG
-	if (is_root_cache(s)) {
+	if (is_root_cache(s) && memcg_sysfs_enabled) {
 		s->memcg_kset = kset_create_and_add("cgroup", NULL, &s->kobj);
 		if (!s->memcg_kset) {
 			err = -ENOMEM;
@@ -5673,7 +5695,8 @@ static void sysfs_slab_remove(struct kme
 		return;
 
 #ifdef CONFIG_MEMCG
-	kset_unregister(s->memcg_kset);
+	if (s->memcg_kset)
+		kset_unregister(s->memcg_kset);
 #endif
 	kobject_uevent(&s->kobj, KOBJ_REMOVE);
 	kobject_del(&s->kobj);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
