Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 90D336B0388
	for <linux-mm@kvack.org>; Tue, 14 Mar 2017 08:52:40 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id b2so377047111pgc.6
        for <linux-mm@kvack.org>; Tue, 14 Mar 2017 05:52:40 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id y70si14733175pfk.182.2017.03.14.05.52.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Mar 2017 05:52:39 -0700 (PDT)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v2ECiCOZ128492
	for <linux-mm@kvack.org>; Tue, 14 Mar 2017 08:52:38 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2963vrtk3y-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 14 Mar 2017 08:52:38 -0400
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <heiko.carstens@de.ibm.com>;
	Tue, 14 Mar 2017 12:52:36 -0000
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: [PATCHv2 1/2] mm: add private lock to serialize memory hotplug operations
Date: Tue, 14 Mar 2017 13:52:25 +0100
In-Reply-To: <20170314125226.16779-1-heiko.carstens@de.ibm.com>
References: <20170314125226.16779-1-heiko.carstens@de.ibm.com>
Message-Id: <20170314125226.16779-2-heiko.carstens@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-s390@vger.kernel.org, Dan Williams <dan.j.williams@intel.com>, Michal Hocko <mhocko@suse.com>, "Rafael J . Wysocki" <rjw@rjwysocki.net>, Vladimir Davydov <vdavydov.dev@gmail.com>, Ben Hutchings <ben@decadent.org.uk>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Sebastian Ott <sebott@linux.vnet.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>

Commit bfc8c90139eb ("mem-hotplug: implement get/put_online_mems")
introduced new functions get/put_online_mems() and
mem_hotplug_begin/end() in order to allow similar semantics for memory
hotplug like for cpu hotplug.

The corresponding functions for cpu hotplug are get/put_online_cpus()
and cpu_hotplug_begin/done() for cpu hotplug.

The commit however missed to introduce functions that would serialize
memory hotplug operations like they are done for cpu hotplug with
cpu_maps_update_begin/done().

This basically leaves mem_hotplug.active_writer unprotected and allows
concurrent writers to modify it, which may lead to problems as
outlined by commit f931ab479dd2 ("mm: fix devm_memremap_pages crash,
use mem_hotplug_{begin, done}").

That commit was extended again with commit b5d24fda9c3d ("mm,
devm_memremap_pages: hold device_hotplug lock over mem_hotplug_{begin,
done}") which serializes memory hotplug operations for some call
sites by using the device_hotplug lock.

In addition with commit 3fc21924100b ("mm: validate device_hotplug is
held for memory hotplug") a sanity check was added to
mem_hotplug_begin() to verify that the device_hotplug lock is held.

This in turn triggers the following warning on s390:

WARNING: CPU: 6 PID: 1 at drivers/base/core.c:643 assert_held_device_hotplug+0x4a/0x58
 Call Trace:
  assert_held_device_hotplug+0x40/0x58)
  mem_hotplug_begin+0x34/0xc8
  add_memory_resource+0x7e/0x1f8
  add_memory+0xda/0x130
  add_memory_merged+0x15c/0x178
  sclp_detect_standby_memory+0x2ae/0x2f8
  do_one_initcall+0xa2/0x150
  kernel_init_freeable+0x228/0x2d8
  kernel_init+0x2a/0x140
  kernel_thread_starter+0x6/0xc

One possible fix would be to add more lock_device_hotplug() and
unlock_device_hotplug() calls around each call site of
mem_hotplug_begin/end(). But that would give the device_hotplug lock
additional semantics it better should not have (serialize memory
hotplug operations).

Instead add a new memory_add_remove_lock which has the similar
semantics like cpu_add_remove_lock for cpu hotplug.

To keep things hopefully a bit easier the lock will be locked and
unlocked within the mem_hotplug_begin/end() functions.

Acked-by: Dan Williams <dan.j.williams@intel.com>
Acked-by: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Ben Hutchings <ben@decadent.org.uk>
Cc: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Reported-by: Sebastian Ott <sebott@linux.vnet.ibm.com>
Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>
---
 kernel/memremap.c   | 4 ----
 mm/memory_hotplug.c | 6 +++++-
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/kernel/memremap.c b/kernel/memremap.c
index 06123234f118..07e85e5229da 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -247,11 +247,9 @@ static void devm_memremap_pages_release(struct device *dev, void *data)
 	align_start = res->start & ~(SECTION_SIZE - 1);
 	align_size = ALIGN(resource_size(res), SECTION_SIZE);
 
-	lock_device_hotplug();
 	mem_hotplug_begin();
 	arch_remove_memory(align_start, align_size);
 	mem_hotplug_done();
-	unlock_device_hotplug();
 
 	untrack_pfn(NULL, PHYS_PFN(align_start), align_size);
 	pgmap_radix_release(res);
@@ -364,11 +362,9 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
 	if (error)
 		goto err_pfn_remap;
 
-	lock_device_hotplug();
 	mem_hotplug_begin();
 	error = arch_add_memory(nid, align_start, align_size, true);
 	mem_hotplug_done();
-	unlock_device_hotplug();
 	if (error)
 		goto err_add_memory;
 
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 295479b792ec..6fa7208bcd56 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -125,9 +125,12 @@ void put_online_mems(void)
 
 }
 
+/* Serializes write accesses to mem_hotplug.active_writer. */
+static DEFINE_MUTEX(memory_add_remove_lock);
+
 void mem_hotplug_begin(void)
 {
-	assert_held_device_hotplug();
+	mutex_lock(&memory_add_remove_lock);
 
 	mem_hotplug.active_writer = current;
 
@@ -147,6 +150,7 @@ void mem_hotplug_done(void)
 	mem_hotplug.active_writer = NULL;
 	mutex_unlock(&mem_hotplug.lock);
 	memhp_lock_release();
+	mutex_unlock(&memory_add_remove_lock);
 }
 
 /* add this memory to iomem resource */
-- 
2.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
