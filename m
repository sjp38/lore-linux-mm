Return-Path: <SRS0=L4L0=TB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0476FC43219
	for <linux-mm@archiver.kernel.org>; Wed,  1 May 2019 14:03:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A2A8621670
	for <linux-mm@archiver.kernel.org>; Wed,  1 May 2019 14:03:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A2A8621670
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 68A666B000C; Wed,  1 May 2019 10:03:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 63E486B000D; Wed,  1 May 2019 10:03:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4DBD16B000E; Wed,  1 May 2019 10:03:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 13CE06B000C
	for <linux-mm@kvack.org>; Wed,  1 May 2019 10:03:07 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id d1so10929590pgk.21
        for <linux-mm@kvack.org>; Wed, 01 May 2019 07:03:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=A7SFuJbJ0Uz+80lz/JGgS9jWr30zBIqu8J3bqFaW1VQ=;
        b=Rp6itI97yvFtc5xayfXv7n4nOPJsutx4U+rVu52slqnpE5FYUPBvPedChhRNUn5GlQ
         jyy2Z+yawIjKNlFXiD3ENyNdAlu2cKhGvDptqiE9lNMwLmKDry89DbB3PsMUreIJQnV5
         pFQJxqTj1g9cuwo1Ep/sxdAn7qxyMVvYQbmFt5gGCGtyEWnakBAeYsfEdZGeqCHB4qMK
         h3NHHnae1s7RFs7vSj5R8ZKQPddlcLA9vLSo2do4G61UHr+22UY2XTkLwfzbPu4B303i
         vuw7HPUJCzA8rEWQvJi7GCw/LjBfZdxrbNijY/CSwZjAzKQNRqwHOSOUWbA3HcCy5IPC
         GoAg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of brian.welty@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=brian.welty@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAV5Ykiac6QsJ/81YsK32YClkkixg39kiHa5KS1f0DHsvjgN9oXG
	0VBFW0RklDzMHi/B9YqvwOYuBc4gH3NQbHEJqJ7/Ab/7UAISJndTUdZPDdcRnt1oeWUZ+vflfMr
	Ozygzicj+KtpdogWBXFUC9f+o0TDj5tlF4UHH5afkGa6NFD5j91cxgKhL0JMWXldpbg==
X-Received: by 2002:a17:902:4101:: with SMTP id e1mr79389527pld.25.1556719386667;
        Wed, 01 May 2019 07:03:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzsV3MP65nzKxToax1oFV4Ytd5XP+9AuC2WOQ0B3+IWY1clVtyUMq8otdanxqAXIPAz2Ozx
X-Received: by 2002:a17:902:4101:: with SMTP id e1mr79389304pld.25.1556719384902;
        Wed, 01 May 2019 07:03:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556719384; cv=none;
        d=google.com; s=arc-20160816;
        b=CK8y8Zx6UPaPdMQ5tU+tcMTsGQ/YTohbVAh2084MhUjXkkLnpY2acHHRF9zZwa0EEQ
         yE0Wlve77UQ8TkTwuqyENuJZwaiufBIaXbEd6sDqezUx2D+OWgE4behy8Hdy76Oug9IX
         22CPV2IotbxE9n59UyJvwwUp24SX1R3VQnXxaca0kCn04rOwN2PoB9kO5/X2Wpje4Mf9
         JezFk8kqoH1svKw1UOGaFr0VmF5lf+B4ilasXDSe+JzVBf05akfegtpHqxzRPXba+Tdg
         IMTKgW6c+a40Sx4CLRQLKh8jq4YCSBuMS3jC3GQMbsdal2uGnGd9ytmREiSY4HNC9iPV
         emMA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:to:from;
        bh=A7SFuJbJ0Uz+80lz/JGgS9jWr30zBIqu8J3bqFaW1VQ=;
        b=l6w4PU8dCb/pvUVbBJ+iop4LmyCrAzUA/Ca9Oj7MZ/z8GTkdDRu3SrsyywaL4rL4yC
         Qq7gDtrmqYa48DWWe9r7hRLtEDU4QDPFwA1QoTfe4XWKyei/itMS130Ia+/fw9hhcJl/
         ccMcnuPH3/znjFg3cD/2u7JMu0kmzy6XgjDXhqmBHkcQLV27AChTSvWqH9YN8yb1tTQU
         UCUvI+YUOQiOe3J6Mfxft36bGcsO8pxhVJFDDFbDt+KcToJsOVDUOdmKmGfsDmwwCIUc
         dSt/ppdXGyPaMKR7auXCm9810G73HYMTTxiXuHZD9FR5M47PVJSI2Ahpm26034BjD0En
         Nksg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of brian.welty@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=brian.welty@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id q25si38000486pgv.534.2019.05.01.07.03.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 May 2019 07:03:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of brian.welty@intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of brian.welty@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=brian.welty@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga008.fm.intel.com ([10.253.24.58])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 01 May 2019 07:03:04 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,417,1549958400"; 
   d="scan'208";a="145141406"
Received: from nperf12.hd.intel.com ([10.127.88.161])
  by fmsmga008.fm.intel.com with ESMTP; 01 May 2019 07:03:03 -0700
From: Brian Welty <brian.welty@intel.com>
To: cgroups@vger.kernel.org,
	Tejun Heo <tj@kernel.org>,
	Li Zefan <lizefan@huawei.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	linux-mm@kvack.org,
	Michal Hocko <mhocko@kernel.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	dri-devel@lists.freedesktop.org,
	David Airlie <airlied@linux.ie>,
	Daniel Vetter <daniel@ffwll.ch>,
	intel-gfx@lists.freedesktop.org,
	Jani Nikula <jani.nikula@linux.intel.com>,
	Joonas Lahtinen <joonas.lahtinen@linux.intel.com>,
	Rodrigo Vivi <rodrigo.vivi@intel.com>,
	=?UTF-8?q?Christian=20K=C3=B6nig?= <christian.koenig@amd.com>,
	Alex Deucher <alexander.deucher@amd.com>,
	ChunMing Zhou <David1.Zhou@amd.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [RFC PATCH 3/5] memcg: Add per-device support to memory cgroup subsystem
Date: Wed,  1 May 2019 10:04:36 -0400
Message-Id: <20190501140438.9506-4-brian.welty@intel.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190501140438.9506-1-brian.welty@intel.com>
References: <20190501140438.9506-1-brian.welty@intel.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Here we update memory cgroup to enable the newly introduced per-device
framework.  As mentioned in the prior patch, the intent here is to allow
drivers to have their own private cgroup controls (such as memory limit)
to be applied to device resources instead of host system resources.

In summary, to enable device registration for memory cgroup subsystem:
  *  set .allow_devices to true
  *  add new exported device register and device unregister functions
     to register a device with the cgroup subsystem
  *  implement the .device_css_alloc callback to create device
     specific cgroups_subsys_state within a cgroup

As cgroup is created and for current registered devices, one will see in
the cgroup filesystem these additional files:
  mount/<cgroup_name>/memory.devices/<dev_name>/<mem_cgrp attributes>

Registration of a new device is performed in device drivers using new
mem_cgroup_device_register(). This will create above files in existing
cgroups.

And for runtime charging to the cgroup, we add the following:
  *  add new routine to lookup the device-specific cgroup_subsys_state
     which is within the task's cgroup (mem_cgroup_device_from_task)
  *  add new functions for device specific 'direct' charging

The last point above involves adding new mem_cgroup_try_charge_direct
and mem_cgroup_uncharge_direct functions.  The 'direct' name is to say
that we are charging the specified cgroup state directly and not using
any associated page or mm_struct.  We are called within device specific
memory management routines, where the device driver will track which
cgroup to charge within its own private data structures.

With this initial submission, support for memory accounting and charging
is functional.  Nested cgroups will correctly maintain the parent for
device-specific state as well, such that hierarchial charging to device
files is supported.

Cc: cgroups@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: dri-devel@lists.freedesktop.org
Cc: Matt Roper <matthew.d.roper@intel.com>
Signed-off-by: Brian Welty <brian.welty@intel.com>
---
 include/linux/memcontrol.h |  10 ++
 mm/memcontrol.c            | 183 ++++++++++++++++++++++++++++++++++---
 2 files changed, 178 insertions(+), 15 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index dbb6118370c1..711669b613dc 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -348,6 +348,11 @@ void mem_cgroup_cancel_charge(struct page *page, struct mem_cgroup *memcg,
 		bool compound);
 void mem_cgroup_uncharge(struct page *page);
 void mem_cgroup_uncharge_list(struct list_head *page_list);
+/* direct charging to mem_cgroup is primarily for device driver usage */
+int mem_cgroup_try_charge_direct(struct mem_cgroup *memcg,
+				 unsigned long nr_pages);
+void mem_cgroup_uncharge_direct(struct mem_cgroup *memcg,
+				unsigned long nr_pages);
 
 void mem_cgroup_migrate(struct page *oldpage, struct page *newpage);
 
@@ -395,6 +400,11 @@ struct lruvec *mem_cgroup_page_lruvec(struct page *, struct pglist_data *);
 bool task_in_mem_cgroup(struct task_struct *task, struct mem_cgroup *memcg);
 struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p);
 
+struct mem_cgroup *mem_cgroup_device_from_task(unsigned long id,
+					       struct task_struct *p);
+int mem_cgroup_device_register(struct device *dev, unsigned long *dev_id);
+void mem_cgroup_device_unregister(unsigned long dev_id);
+
 struct mem_cgroup *get_mem_cgroup_from_mm(struct mm_struct *mm);
 
 struct mem_cgroup *get_mem_cgroup_from_page(struct page *page);
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 81a0d3914ec9..2c8407aed0f5 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -823,6 +823,47 @@ struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p)
 }
 EXPORT_SYMBOL(mem_cgroup_from_task);
 
+int mem_cgroup_device_register(struct device *dev, unsigned long *dev_id)
+{
+	return cgroup_device_register(&memory_cgrp_subsys, dev, dev_id);
+}
+EXPORT_SYMBOL(mem_cgroup_device_register);
+
+void mem_cgroup_device_unregister(unsigned long dev_id)
+{
+	cgroup_device_unregister(&memory_cgrp_subsys, dev_id);
+}
+EXPORT_SYMBOL(mem_cgroup_device_unregister);
+
+/**
+ * mem_cgroup_device_from_task: Lookup device-specific memcg
+ * @id: device-specific id returned from mem_cgroup_device_register
+ * @p: task to lookup the memcg
+ *
+ * First use mem_cgroup_from_task to lookup and obtain a reference on
+ * the memcg associated with this task @p.  Within this memcg, find the
+ * device-specific one associated with @id.
+ * However if mem_cgroup is disabled, NULL is returned.
+ */
+struct mem_cgroup *mem_cgroup_device_from_task(unsigned long id,
+					       struct task_struct *p)
+{
+	struct mem_cgroup *memcg;
+	struct mem_cgroup *dev_memcg = NULL;
+
+	if (mem_cgroup_disabled())
+		return NULL;
+
+	rcu_read_lock();
+	memcg  = mem_cgroup_from_task(p);
+	if (memcg)
+		dev_memcg = idr_find(&memcg->css.device_css_idr, id);
+	rcu_read_unlock();
+
+	return dev_memcg;
+}
+EXPORT_SYMBOL(mem_cgroup_device_from_task);
+
 /**
  * get_mem_cgroup_from_mm: Obtain a reference on given mm_struct's memcg.
  * @mm: mm from which memcg should be extracted. It can be NULL.
@@ -2179,13 +2220,31 @@ void mem_cgroup_handle_over_high(void)
 	current->memcg_nr_pages_over_high = 0;
 }
 
+static bool __try_charge(struct mem_cgroup *memcg, unsigned int nr_pages,
+			 struct mem_cgroup **mem_over_limit)
+{
+	struct page_counter *counter;
+
+	if (!do_memsw_account() ||
+	    page_counter_try_charge(&memcg->memsw, nr_pages, &counter)) {
+		if (page_counter_try_charge(&memcg->memory, nr_pages, &counter))
+			return true;
+		if (do_memsw_account())
+			page_counter_uncharge(&memcg->memsw, nr_pages);
+		*mem_over_limit = mem_cgroup_from_counter(counter, memory);
+	} else {
+		*mem_over_limit = mem_cgroup_from_counter(counter, memsw);
+	}
+
+	return false;
+}
+
 static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
 		      unsigned int nr_pages)
 {
 	unsigned int batch = max(MEMCG_CHARGE_BATCH, nr_pages);
 	int nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
 	struct mem_cgroup *mem_over_limit;
-	struct page_counter *counter;
 	unsigned long nr_reclaimed;
 	bool may_swap = true;
 	bool drained = false;
@@ -2198,17 +2257,10 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	if (consume_stock(memcg, nr_pages))
 		return 0;
 
-	if (!do_memsw_account() ||
-	    page_counter_try_charge(&memcg->memsw, batch, &counter)) {
-		if (page_counter_try_charge(&memcg->memory, batch, &counter))
-			goto done_restock;
-		if (do_memsw_account())
-			page_counter_uncharge(&memcg->memsw, batch);
-		mem_over_limit = mem_cgroup_from_counter(counter, memory);
-	} else {
-		mem_over_limit = mem_cgroup_from_counter(counter, memsw);
-		may_swap = false;
-	}
+	if (__try_charge(memcg, batch, &mem_over_limit))
+		goto done_restock;
+	else
+		may_swap = !do_memsw_account();
 
 	if (batch > nr_pages) {
 		batch = nr_pages;
@@ -2892,6 +2944,9 @@ static int mem_cgroup_force_empty(struct mem_cgroup *memcg)
 {
 	int nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
 
+	if (memcg->css.device)
+		return 0;
+
 	/* we call try-to-free pages for make this cgroup empty */
 	lru_add_drain_all();
 
@@ -4496,7 +4551,7 @@ static struct mem_cgroup *mem_cgroup_alloc(void)
 }
 
 static struct cgroup_subsys_state * __ref
-mem_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
+__mem_cgroup_css_alloc(struct cgroup_subsys_state *parent_css, bool is_device)
 {
 	struct mem_cgroup *parent = mem_cgroup_from_css(parent_css);
 	struct mem_cgroup *memcg;
@@ -4530,11 +4585,13 @@ mem_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
 		 * much sense so let cgroup subsystem know about this
 		 * unfortunate state in our controller.
 		 */
-		if (parent != root_mem_cgroup)
+		if (!is_device && parent != root_mem_cgroup)
 			memory_cgrp_subsys.broken_hierarchy = true;
 	}
 
-	/* The following stuff does not apply to the root */
+	/* The following stuff does not apply to devices or the root */
+	if (is_device)
+		return &memcg->css;
 	if (!parent) {
 		root_mem_cgroup = memcg;
 		return &memcg->css;
@@ -4554,6 +4611,34 @@ mem_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
 	return ERR_PTR(-ENOMEM);
 }
 
+static struct cgroup_subsys_state * __ref
+mem_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
+{
+	return __mem_cgroup_css_alloc(parent_css, false);
+}
+
+/*
+ * For given @cgroup_css, we create and return new device-specific css.
+ *
+ * @device and @cgroup_css are unused here, but they are provided as other
+ * cgroup subsystems might require them.
+ */
+static struct cgroup_subsys_state * __ref
+mem_cgroup_device_css_alloc(struct device *device,
+			    struct cgroup_subsys_state *cgroup_css,
+			    struct cgroup_subsys_state *parent_device_css)
+{
+	/*
+	 * For hierarchial page counters to work correctly, we specify
+	 * parent here as the device-specific css from our parent css
+	 * (@parent_device_css).  In other words, for nested cgroups,
+	 * the device-specific charging structures are also nested.
+	 * Note, caller will itself set .device and .parent in returned
+	 * structure.
+	 */
+	return __mem_cgroup_css_alloc(parent_device_css, true);
+}
+
 static int mem_cgroup_css_online(struct cgroup_subsys_state *css)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
@@ -4613,6 +4698,9 @@ static void mem_cgroup_css_free(struct cgroup_subsys_state *css)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
 
+	if (css->device)
+		goto free_cgrp;
+
 	if (cgroup_subsys_on_dfl(memory_cgrp_subsys) && !cgroup_memory_nosocket)
 		static_branch_dec(&memcg_sockets_enabled_key);
 
@@ -4624,6 +4712,7 @@ static void mem_cgroup_css_free(struct cgroup_subsys_state *css)
 	mem_cgroup_remove_from_trees(memcg);
 	memcg_free_shrinker_maps(memcg);
 	memcg_free_kmem(memcg);
+free_cgrp:
 	mem_cgroup_free(memcg);
 }
 
@@ -5720,6 +5809,7 @@ static struct cftype memory_files[] = {
 
 struct cgroup_subsys memory_cgrp_subsys = {
 	.css_alloc = mem_cgroup_css_alloc,
+	.device_css_alloc = mem_cgroup_device_css_alloc,
 	.css_online = mem_cgroup_css_online,
 	.css_offline = mem_cgroup_css_offline,
 	.css_released = mem_cgroup_css_released,
@@ -5732,6 +5822,7 @@ struct cgroup_subsys memory_cgrp_subsys = {
 	.dfl_cftypes = memory_files,
 	.legacy_cftypes = mem_cgroup_legacy_files,
 	.early_init = 0,
+	.allow_devices = true,
 };
 
 /**
@@ -6031,6 +6122,68 @@ void mem_cgroup_cancel_charge(struct page *page, struct mem_cgroup *memcg,
 	cancel_charge(memcg, nr_pages);
 }
 
+/**
+ * mem_cgroup_try_charge_direct - try charging nr_pages to memcg
+ * @memcg: memcgto charge
+ * @nr_pages: number of pages to charge
+ *
+ * Try to charge @nr_pages to specified @memcg. This variant is intended
+ * where the memcg is known and can be directly charged, with the primary
+ * use case being in device drivers that have registered with the subsys.
+ * Device drivers that implement their own device-specific memory manager
+ * will use these direct charging functions to make charges against their
+ * device-private state (@memcg) within the cgroup.
+ *
+ * There is no separate mem_cgroup_commit_charge() in this use case, as the
+ * device driver is not using page structs. Reclaim is not needed internally
+ * here, as the caller can decide to attempt memory reclaim on error.
+ *
+ * Returns 0 on success.  Otherwise, an error code is returned.
+ *
+ * To uncharge (or cancel charge), call mem_cgroup_uncharge_direct().
+ */
+int mem_cgroup_try_charge_direct(struct mem_cgroup *memcg,
+				 unsigned long nr_pages)
+{
+	struct mem_cgroup *mem_over_limit;
+	int ret = 0;
+
+	if (!memcg || mem_cgroup_disabled() || mem_cgroup_is_root(memcg))
+		return 0;
+
+	if (__try_charge(memcg, nr_pages, &mem_over_limit)) {
+		css_get_many(&memcg->css, nr_pages);
+	} else {
+		memcg_memory_event(mem_over_limit, MEMCG_MAX);
+		ret = -ENOMEM;
+	}
+	return ret;
+}
+EXPORT_SYMBOL(mem_cgroup_try_charge_direct);
+
+/**
+ * mem_cgroup_uncharge_direct - uncharge nr_pages to memcg
+ * @memcg: memcg to charge
+ * @nr_pages: number of pages to charge
+ *
+ * Uncharge @nr_pages to specified @memcg. This variant is intended
+ * where the memcg is known and can directly uncharge, with the primary
+ * use case being in device drivers that have registered with the subsys.
+ * Device drivers use these direct charging functions to make charges
+ * against their device-private state (@memcg) within the cgroup.
+ *
+ * Returns 0 on success.  Otherwise, an error code is returned.
+ */
+void mem_cgroup_uncharge_direct(struct mem_cgroup *memcg,
+				unsigned long nr_pages)
+{
+	if (!memcg || mem_cgroup_disabled())
+		return;
+
+	cancel_charge(memcg, nr_pages);
+}
+EXPORT_SYMBOL(mem_cgroup_uncharge_direct);
+
 struct uncharge_gather {
 	struct mem_cgroup *memcg;
 	unsigned long pgpgout;
-- 
2.21.0

