Return-Path: <SRS0=DRoR=SM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A32E5C10F14
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 19:14:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 518F42184B
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 19:14:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 518F42184B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E47C16B0005; Wed, 10 Apr 2019 15:13:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DC93E6B0006; Wed, 10 Apr 2019 15:13:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CC2386B0008; Wed, 10 Apr 2019 15:13:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id A34306B0005
	for <linux-mm@kvack.org>; Wed, 10 Apr 2019 15:13:59 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id d49so3230402qtk.8
        for <linux-mm@kvack.org>; Wed, 10 Apr 2019 12:13:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=sHnXzx23mKGzmM1k+o+LppmvQ/fIeqpa9wtD2H40pVQ=;
        b=ge04IbRBRi7BWkdefJhL+gVLaI/s28KmgPRcLRIk6N+bPCufWYp1DcN8JjXj1aHzua
         HkcdyDeHlSW3QJolrWrbQWLiLX6zxJebgSduwuIYHljZk0qWb4pYeqxRlT2Qvs/2QMeG
         Lhk8U/TsUSz8Yf8BKm0JpwfY99ceg31n54DCg4N9m4ogsyOFQtRXoV1mURFvC3ClGcQ6
         UWiqe76sbo5fzWYi4KfhN8SpRxeLeL8uNujG6HJ+4dayraVNOkhhgvu7bvehwbM+oUpt
         F+EeVrb5b1So7Cp9TSOl7Fu4QPMax8D+IEXd5rSERLzClKorVzs9lfvixlXdG9Pf2mK5
         kB8g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUksZthVA58yx9tTficVRjzVllokk+9XZsr3EVT3ui/GOtlr8sa
	IDrZ/3xvUFkoXJUW+DZ7xNiCOtKAQ5ti1IZN9+F4jrD6u8oxbwTw0Eo9qpR2hDq+AGxVMUHBCfl
	kCLbPb1t/r30NpymdqdlMLx5taqpOEyvkBQ5IFavIRkAR00ynNfZIgZbHMHxD/rJX7g==
X-Received: by 2002:a37:8843:: with SMTP id k64mr14096891qkd.8.1554923639380;
        Wed, 10 Apr 2019 12:13:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz2FbyhlBgaDoNg9eWwGZRJT8vI+vDB/jSvN8PQlhZ9JemIHJRPmceIBVWL6HW/ZelL7Ye2
X-Received: by 2002:a37:8843:: with SMTP id k64mr14096806qkd.8.1554923638259;
        Wed, 10 Apr 2019 12:13:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554923638; cv=none;
        d=google.com; s=arc-20160816;
        b=uOuz4G8GXl4RE93lvXhHEfyuG2B+xnLU4+BLQhvt801jJqg+U4uuflW3Hp5kdgF6s9
         L0Ow+A3KmFEeKdHC5Aj2eCG0GE30ZQL2uJX54ELkqKIoXQPJbNadBjkqDH/64XcD4I1I
         g4jf2FbWYRN2R/Ho/SXezNuDb2aIMNIOg5lh1eOES4aGCMKm3P8xEie2VSEAr9Gi8IJ/
         ZLz70gieZVEV2AOB6GlSKe/LTu1l/ccSRraAMl/baFuJLCt2BYL6Vh8/arEYIGIOKB5Y
         lWQoIjvLS3VDBWq5z8ftIXdeiGbD8euS3Hsd5p5+pL1WnTch5HW0PVqF15MkB/c8wRAu
         cyNw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=sHnXzx23mKGzmM1k+o+LppmvQ/fIeqpa9wtD2H40pVQ=;
        b=Rhr07HgoxeXOvEONT/RX6K6prvtFqq+LNKOXEqgQWYC7ujhU3WMpd4QbmJmt+51dlf
         28+FmAVfvfYtk4lQIWTQk7L7v2uB0hWrJ9f0wSQwPrqLoC8UIJRk23iFcaOxy1GERAie
         M6bDz9/hiizGaaMSZhBFofP6z8bLz3sCITr97dlvQA8bOPai3sO/Hsj8TzbncFLxyZiZ
         6sAwnl2ihjKX436aAQj3/5HDsJCaTy4jNjpJUeT4/Pq215q7PZZFsNWUggWlKJZMyDe4
         HNdfWsF9HoCW5lu0XxsFrO6dsCsYLPG8HzN8eVsNQQ1k8oS+JgQcTTBdnPkJE885j2zT
         SDhA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k16si6878888qtf.2.2019.04.10.12.13.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Apr 2019 12:13:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 6476680B2C;
	Wed, 10 Apr 2019 19:13:57 +0000 (UTC)
Received: from llong.com (ovpn-120-189.rdu2.redhat.com [10.10.120.189])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 786C46013A;
	Wed, 10 Apr 2019 19:13:54 +0000 (UTC)
From: Waiman Long <longman@redhat.com>
To: Tejun Heo <tj@kernel.org>,
	Li Zefan <lizefan@huawei.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Jonathan Corbet <corbet@lwn.net>,
	Michal Hocko <mhocko@kernel.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: linux-kernel@vger.kernel.org,
	cgroups@vger.kernel.org,
	linux-doc@vger.kernel.org,
	linux-mm@kvack.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Roman Gushchin <guro@fb.com>,
	Shakeel Butt <shakeelb@google.com>,
	Kirill Tkhai <ktkhai@virtuozzo.com>,
	Aaron Lu <aaron.lu@intel.com>,
	Waiman Long <longman@redhat.com>
Subject: [RFC PATCH 1/2] mm/memcontrol: Finer-grained control for subset of allocated memory
Date: Wed, 10 Apr 2019 15:13:20 -0400
Message-Id: <20190410191321.9527-2-longman@redhat.com>
In-Reply-To: <20190410191321.9527-1-longman@redhat.com>
References: <20190410191321.9527-1-longman@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.28]); Wed, 10 Apr 2019 19:13:57 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The current control mechanism for memory cgroup v2 lumps all the memory
together irrespective of the type of memory objects. However, there
are cases where users may have more concern about one type of memory
usage than the others.

In order to support finer-grained control of memory usage, the following
two new cgroup v2 control files are added:

 - memory.subset.list
   Either "" (default), "anon" (anonymous memory) or "file" (file
   cache). It specifies the type of memory objects we want to monitor.
 - memory.subset.high
   The high memory limit for the memory type specified in
   "memory.subset.list".

For simplicity, the limit is for memory usage by all the tasks within
the current memory cgroup only. It doesn't include memory usage by
other tasks in child memory cgroups. Hence, we can just check the
corresponding stat[] array entry of the selected memory type to see if
it is above the limit.

We currently don't have the capability to specify the type of memory
objects to reclaim. When memory reclaim is triggered after reaching
the "memory.subset.high" limit, other type of memory objects will also
be reclaimed.

In the future, we may extend this capability to allow even more
fine-grained selection of memory types as well as a combination of them
if the need arises.

A test program was written to allocate 1 Gbytes of memory and then
touch every pages of them. This program was then run in a memory cgroup:

 # echo anon > memory.subset.list
 # echo 10485760 > memory.subset.high
 # echo $$ > cgroup.procs
 # ~/touch-1gb

While the test program was running:

 # grep -w anon memory.stat
 anon 10817536

It was a bit higher than the limit, but that should be OK.

Without setting the limit, the output would be

 # grep -w anon memory.stat
 anon 1074335744

Signed-off-by: Waiman Long <longman@redhat.com>
---
 Documentation/admin-guide/cgroup-v2.rst | 35 +++++++++
 include/linux/memcontrol.h              |  7 ++
 mm/memcontrol.c                         | 96 ++++++++++++++++++++++++-
 3 files changed, 137 insertions(+), 1 deletion(-)

diff --git a/Documentation/admin-guide/cgroup-v2.rst b/Documentation/admin-guide/cgroup-v2.rst
index 20f92c16ffbf..0d5b7c77897d 100644
--- a/Documentation/admin-guide/cgroup-v2.rst
+++ b/Documentation/admin-guide/cgroup-v2.rst
@@ -1080,6 +1080,41 @@ PAGE_SIZE multiple when read back.
 	high limit is used and monitored properly, this limit's
 	utility is limited to providing the final safety net.
 
+  memory.subset.high
+	A read-write single value file which exists on non-root cgroups.
+	The default is "max".
+
+	Memory usage throttle limit for a subset of memory objects with
+	types specified in "memory.subset.list".  If a cgroup's usage for
+	those memory objects goes over the high boundary, the processes
+	of the cgroup are throttled and put under heavy reclaim pressure.
+
+	This throttle limit is not allowed to go higher than
+	"memory.high" and will be adjusted accordingly when "memory.high"
+	is changed.  Because of that, "memory.subset.list" should always
+	be set first before assigning a limit to this file.
+
+	Unlike "memory.high", "memory.subset.high" does not count memory
+	objects usage in child cgroups.
+
+	Going over the high limit never invokes the OOM killer and
+	under extreme conditions the limit may be breached.
+
+  memory.subset.list
+	A read-write single value file which exists on non-root cgroups.
+	The default is "" which means no separate memory subcomponent
+	tracking and throttling.
+
+	Currently, only the following two primary subcompoent types are
+	supported:
+
+	 - anon (anonymous memory)
+	 - file (filesystem cache, including tmpfs and shared memory)
+
+	The value of this file should either be "", "anon" or "file".
+	Changing its value resets "memory.subset.high" to be the same
+	as "memory.high".
+
   memory.oom.group
 	A read-write single value file which exists on non-root
 	cgroups.  The default value is "0".
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 1f3d880b7ca1..1baf3e4a9eeb 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -212,6 +212,13 @@ struct mem_cgroup {
 	/* Upper bound of normal memory consumption range */
 	unsigned long high;
 
+	/*
+	 * Upper memory consumption bound for a subset of memory object type
+	 * specified in subset_list for the current cgroup only.
+	 */
+	unsigned long subset_high;
+	unsigned long subset_list;
+
 	/* Range enforcement for interrupt charges */
 	struct work_struct high_work;
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 532e0e2a4817..7e52adea60d9 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2145,6 +2145,14 @@ static void reclaim_high(struct mem_cgroup *memcg,
 			 unsigned int nr_pages,
 			 gfp_t gfp_mask)
 {
+	int mtype = READ_ONCE(memcg->subset_list);
+
+	/*
+	 * Try memory reclaim if subset_high is exceeded.
+	 */
+	if (mtype && (memcg_page_state(memcg, mtype) > memcg->subset_high))
+		try_to_free_mem_cgroup_pages(memcg, nr_pages, gfp_mask, true);
+
 	do {
 		if (page_counter_read(&memcg->memory) <= memcg->high)
 			continue;
@@ -2190,6 +2198,7 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	bool may_swap = true;
 	bool drained = false;
 	bool oomed = false;
+	bool over_subset_high = false;
 	enum oom_status oom_status;
 
 	if (mem_cgroup_is_root(memcg))
@@ -2323,6 +2332,10 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	if (batch > nr_pages)
 		refill_stock(memcg, batch - nr_pages);
 
+	if (memcg->subset_list &&
+	   (memcg_page_state(memcg, memcg->subset_list) > memcg->subset_high))
+		over_subset_high = true;
+
 	/*
 	 * If the hierarchy is above the normal consumption range, schedule
 	 * reclaim on returning to userland.  We can perform reclaim here
@@ -2333,7 +2346,8 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	 * reclaim, the cost of mismatch is negligible.
 	 */
 	do {
-		if (page_counter_read(&memcg->memory) > memcg->high) {
+		if (page_counter_read(&memcg->memory) > memcg->high ||
+		    over_subset_high) {
 			/* Don't bother a random interrupted task */
 			if (in_interrupt()) {
 				schedule_work(&memcg->high_work);
@@ -2343,6 +2357,7 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
 			set_notify_resume(current);
 			break;
 		}
+		over_subset_high = false;
 	} while ((memcg = parent_mem_cgroup(memcg)));
 
 	return 0;
@@ -4491,6 +4506,7 @@ mem_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
 		return ERR_PTR(error);
 
 	memcg->high = PAGE_COUNTER_MAX;
+	memcg->subset_high = PAGE_COUNTER_MAX;
 	memcg->soft_limit = PAGE_COUNTER_MAX;
 	if (parent) {
 		memcg->swappiness = mem_cgroup_swappiness(parent);
@@ -5447,6 +5463,13 @@ static ssize_t memory_high_write(struct kernfs_open_file *of,
 
 	memcg->high = high;
 
+	/*
+	 * Synchronize subset_high if subset_list not set and lower
+	 * subset_high, if necessary.
+	 */
+	if (!memcg->subset_list || (high < memcg->subset_high))
+		memcg->subset_high = high;
+
 	nr_pages = page_counter_read(&memcg->memory);
 	if (nr_pages > high)
 		try_to_free_mem_cgroup_pages(memcg, nr_pages - high,
@@ -5511,6 +5534,65 @@ static ssize_t memory_max_write(struct kernfs_open_file *of,
 	return nbytes;
 }
 
+static int memory_subset_high_show(struct seq_file *m, void *v)
+{
+	return seq_puts_memcg_tunable(m,
+			READ_ONCE(mem_cgroup_from_seq(m)->subset_high));
+}
+
+static ssize_t memory_subset_high_write(struct kernfs_open_file *of,
+					char *buf, size_t nbytes, loff_t off)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_css(of_css(of));
+	unsigned long high;
+	int err;
+
+	buf = strstrip(buf);
+	err = page_counter_memparse(buf, "max", &high);
+	if (err)
+		return err;
+
+	if (high > memcg->high)
+		return -EINVAL;
+
+	memcg->subset_high = high;
+	return nbytes;
+}
+
+static int memory_subset_list_show(struct seq_file *m, void *v)
+{
+	unsigned long mtype = READ_ONCE(mem_cgroup_from_seq(m)->subset_list);
+
+	seq_puts(m, (mtype == MEMCG_RSS)   ? "anon\n" :
+		    (mtype == MEMCG_CACHE) ? "file\n" : "\n");
+	return 0;
+}
+
+static ssize_t memory_subset_list_write(struct kernfs_open_file *of,
+					char *buf, size_t nbytes, loff_t off)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_css(of_css(of));
+	unsigned long mtype;
+
+	buf = strstrip(buf);
+	if (!strcmp(buf, "anon"))
+		mtype = MEMCG_RSS;
+	else if (!strcmp(buf, "file"))
+		mtype = MEMCG_CACHE;
+	else if (buf[0] == '\0')
+		mtype = 0;
+	else
+		return -EINVAL;
+
+	if (mtype == memcg->subset_list)
+		return nbytes;
+
+	memcg->subset_list = mtype;
+	/* Reset subset_high */
+	memcg->subset_high = memcg->high;
+	return nbytes;
+}
+
 static int memory_events_show(struct seq_file *m, void *v)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_seq(m);
@@ -5699,6 +5781,18 @@ static struct cftype memory_files[] = {
 		.seq_show = memory_oom_group_show,
 		.write = memory_oom_group_write,
 	},
+	{
+		.name = "subset.high",
+		.flags = CFTYPE_NOT_ON_ROOT,
+		.seq_show = memory_subset_high_show,
+		.write = memory_subset_high_write,
+	},
+	{
+		.name = "subset.list",
+		.flags = CFTYPE_NOT_ON_ROOT,
+		.seq_show = memory_subset_list_show,
+		.write = memory_subset_list_write,
+	},
 	{ }	/* terminate */
 };
 
-- 
2.18.1

