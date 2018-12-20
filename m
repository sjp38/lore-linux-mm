Return-Path: <SRS0=PcJq=O5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D8EA2C43387
	for <linux-mm@archiver.kernel.org>; Thu, 20 Dec 2018 19:22:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8FF7B218FE
	for <linux-mm@archiver.kernel.org>; Thu, 20 Dec 2018 19:22:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="QlNAG2Db"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8FF7B218FE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5165C8E000F; Thu, 20 Dec 2018 14:22:00 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4C3CE8E0001; Thu, 20 Dec 2018 14:22:00 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 319AE8E000F; Thu, 20 Dec 2018 14:22:00 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 05B6B8E0001
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 14:22:00 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id k90so2981600qte.0
        for <linux-mm@kvack.org>; Thu, 20 Dec 2018 11:22:00 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:user-agent:date:from
         :to:cc:cc:cc:cc:cc:cc:cc:cc:cc:cc:cc:subject:references:mime-version
         :content-disposition:feedback-id;
        bh=ee1pZgnROCoNsOrAam7KrKG129xpjjIGO5hfhRbKwK0=;
        b=HVf6R2Fg8DzlD3BPkW4ktKgvFi3VCNG26uxLmuBXIKFyA2waZ22ffOiV4Y1E/CzaTo
         UBOed6/Mgi+N/cL9R3FzC2fRxLTDsibv8iOdlb3skwd/8vcCbERrfKkgzq3dMfzq8iby
         qp0SB6lJnTngmA5ZDATXXSOGZy3cFKwZoqGYcG1dwMwVO8CktyZzmd+jdbmJgSbYMADc
         4XJ4kvUBDL3bMYM47v3PGthJfXLnQq7yzFlhl4rIJaQRTBpMcI8xv57BBYXWRlNz8qpE
         8PLP1H3FRhfWxPNBzrfE5TsoDVH8FbBN5aOya8h5QIU2Wqx7gHLbZPSJ+YN+6vFj2nTc
         0geA==
X-Gm-Message-State: AA+aEWaR1+gd3L831oBpN07VEF9ZYSIPuiJ81/2NXbuKc1+9J7wQGLnH
	3ayx6j/TXap7SMfg0GvspEzCueJATPiOLclIHAKLflzVKKh+6/SbHKSSm6+2JmZibcnPtFdqhfl
	BzxfNKaEPuxIPx2Uz2A/mFZSyGwSFoqhKMOFwFSgpiGfZA9blar5wyYfjnAHOOS8=
X-Received: by 2002:a0c:e394:: with SMTP id a20mr26654212qvl.42.1545333719812;
        Thu, 20 Dec 2018 11:21:59 -0800 (PST)
X-Google-Smtp-Source: AFSGD/XZch4Hcz5r0QesBu8kkWEy4r2vWvbJ1E/Ygl/btKQLc6lNbN5C+PA4iMAQIv6okCZCOo8D
X-Received: by 2002:a0c:e394:: with SMTP id a20mr26654181qvl.42.1545333719396;
        Thu, 20 Dec 2018 11:21:59 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1545333719; cv=none;
        d=google.com; s=arc-20160816;
        b=lbyzUAiffQec4a2d8tV9OEu/oMH2Fip9qYj7eausO8tQqk452Jq+2sI4M3ExsEM1HG
         LpviYS+VKIHQqRuWYE5E+2Sbibq22xqiu8RVet1cJjn3ft6u5NZ+1e8dIgbOHi8fZchZ
         npqZkyeuXHTLMOsD9ExvpMBj86YkotYrKzVfDNcD5bsnzE8OQ1MmhBg9/nu3PiYic5an
         yNiJsW2CUGgmUXDp0giHiYVO8WoPhzamjrLsX6CKM772s5UT5A5tjcEegAhFI+qeR0uG
         q3gXyngbOXxu+Sne5BCcCYxIR1iXRcYc5CNgS7wZ8B5cJKun5H9Xbzh2AJq6QWa/wmrp
         pkSQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:content-disposition:mime-version:references:subject:cc
         :cc:cc:cc:cc:cc:cc:cc:cc:cc:cc:to:from:date:user-agent:message-id
         :dkim-signature;
        bh=ee1pZgnROCoNsOrAam7KrKG129xpjjIGO5hfhRbKwK0=;
        b=kiTemvmzGHiYeN5QJb2bdB27ORDQZCktANkeVE8DgKl9MKKqHyPhPr871TON1gyRzy
         nEM6PeVVsZmOTTAnT5gj0fMa3xSomCXFuZy8htAXMhyYUm4qBjykC/xul5N/MTi0Jwp2
         eTYyyafTi06wcWIvQlRV9xHPP5nm+0lFvMFK+7CplxqPNV/Ud/kZtxnugRsCVKSZz/aQ
         Sxx/KvLcn6yQ2lbAn3oHUsI/Xd9nbURqD1LPMD3/b7EkY4noNhMK/AZzMphiS87cGzRr
         rT3QilUe4fKRqUTQ2f83a5+bY8CSkqSmKWM0XcqTJbHByeH6HGgCwPdrioAiW53yTA3O
         SN8g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=fail header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=QlNAG2Db;
       spf=pass (google.com: domain of 01000167cd113f16-b5a2b2db-e75a-4bad-a47a-0a66fbf7fd8a-000000@amazonses.com designates 54.240.9.32 as permitted sender) smtp.mailfrom=01000167cd113f16-b5a2b2db-e75a-4bad-a47a-0a66fbf7fd8a-000000@amazonses.com
Received: from a9-32.smtp-out.amazonses.com (a9-32.smtp-out.amazonses.com. [54.240.9.32])
        by mx.google.com with ESMTPS id t7si3981848qvh.32.2018.12.20.11.21.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 20 Dec 2018 11:21:59 -0800 (PST)
Received-SPF: pass (google.com: domain of 01000167cd113f16-b5a2b2db-e75a-4bad-a47a-0a66fbf7fd8a-000000@amazonses.com designates 54.240.9.32 as permitted sender) client-ip=54.240.9.32;
Authentication-Results: mx.google.com;
       dkim=fail header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=QlNAG2Db;
       spf=pass (google.com: domain of 01000167cd113f16-b5a2b2db-e75a-4bad-a47a-0a66fbf7fd8a-000000@amazonses.com designates 54.240.9.32 as permitted sender) smtp.mailfrom=01000167cd113f16-b5a2b2db-e75a-4bad-a47a-0a66fbf7fd8a-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug; d=amazonses.com; t=1545333718;
	h=Message-Id:Date:From:To:Cc:Cc:Cc:CC:Cc:Cc:Cc:Cc:Cc:Cc:Cc:Subject:References:MIME-Version:Content-Type:Feedback-ID;
	bh=MEo1JnulmTAHG+WXA+afG0E08WmvUdsEOe37fi6PrrM=;
	b=QlNAG2DbLCddJR2rTzuDDeU5Bi4NhHZ686TqNEwNlRTD/c2MgN5RbdIK98ycS8Cu
	8Cb2xj8r43L7Rx9lSoR4+7luOLmsh4gqghmW/FkPslBSSU9RuEk5Zi45gxjTUtrsfqu
	5QH9n+9YHIP7rGhBd5cPpCWa/SItiQKh8huHJC7g=
Message-ID:
 <01000167cd113f16-b5a2b2db-e75a-4bad-a47a-0a66fbf7fd8a-000000@email.amazonses.com>
User-Agent: quilt/0.65
Date: Thu, 20 Dec 2018 19:21:58 +0000
From: Christoph Lameter <cl@linux.com>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
Cc: Pekka Enberg <penberg@cs.helsinki.fi>
CC: akpm@linux-foundation.org
Cc: Mel Gorman <mel@skynet.ie>
Cc: andi@firstfloor.org
Cc: Rik van Riel <riel@redhat.com>
Cc: Dave Chinner <dchinner@redhat.com>
Cc: Christoph Hellwig <hch@lst.de>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [RFC 3/7] slub: Add isolate() and migrate() methods
References: <20181220192145.023162076@linux.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline; filename=isolate_and_migrate_methods
X-SES-Outgoing: 2018.12.20-54.240.9.32
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20181220192158.4Dk_6uSsK2uNcfzZj0oVqjYlSRgE2eYaS_AVm6eCZH4@z>

Add the two methods needed for moving objects and enable the
display of the callbacks via the /sys/kernel/slab interface.

Add documentation explaining the use of these methods and the prototypes
for slab.h. Add functions to setup the callbacks method for a slab cache.

Add empty functions for SLAB/SLOB. The API is generic so it
could be theoretically implemented for these allocators as well.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 include/linux/slab.h     |   50 +++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/slub_def.h |    3 ++
 mm/slub.c                |   29 ++++++++++++++++++++++++++-
 3 files changed, 81 insertions(+), 1 deletion(-)

Index: linux/include/linux/slub_def.h
===================================================================
--- linux.orig/include/linux/slub_def.h
+++ linux/include/linux/slub_def.h
@@ -99,6 +99,9 @@ struct kmem_cache {
 	gfp_t allocflags;	/* gfp flags to use on each alloc */
 	int refcount;		/* Refcount for slab cache destroy */
 	void (*ctor)(void *);
+	kmem_isolate_func *isolate;
+	kmem_migrate_func *migrate;
+
 	unsigned int inuse;		/* Offset to metadata */
 	unsigned int align;		/* Alignment */
 	unsigned int red_left_pad;	/* Left redzone padding size */
Index: linux/mm/slub.c
===================================================================
--- linux.orig/mm/slub.c
+++ linux/mm/slub.c
@@ -3498,7 +3498,6 @@ static int calculate_sizes(struct kmem_c
 	else
 		s->flags &= ~__OBJECT_POISON;
 
-
 	/*
 	 * If we are Redzoning then check if there is some space between the
 	 * end of the object and the free pointer. If not then add an
@@ -4311,6 +4310,25 @@ int __kmem_cache_create(struct kmem_cach
 	return err;
 }
 
+void kmem_cache_setup_mobility(struct kmem_cache *s,
+	kmem_isolate_func isolate, kmem_migrate_func migrate)
+{
+	/*
+	 * Defragmentable slabs must have a ctor otherwise objects may be
+	 * in an undetermined state after they are allocated.
+	 */
+	BUG_ON(!s->ctor);
+	s->isolate = isolate;
+	s->migrate = migrate;
+	/*
+	 * Sadly serialization requirements currently mean that we have
+	 * to disable fast cmpxchg based processing.
+	 */
+	s->flags &= ~__CMPXCHG_DOUBLE;
+
+}
+EXPORT_SYMBOL(kmem_cache_setup_mobility);
+
 void *__kmalloc_track_caller(size_t size, gfp_t gfpflags, unsigned long caller)
 {
 	struct kmem_cache *s;
@@ -5004,6 +5022,20 @@ static ssize_t ops_show(struct kmem_cach
 
 	if (s->ctor)
 		x += sprintf(buf + x, "ctor : %pS\n", s->ctor);
+
+	if (s->isolate) {
+		x += sprintf(buf + x, "isolate : ");
+		x += sprint_symbol(buf + x,
+				(unsigned long)s->isolate);
+		x += sprintf(buf + x, "\n");
+	}
+
+	if (s->migrate) {
+		x += sprintf(buf + x, "migrate : ");
+		x += sprint_symbol(buf + x,
+				(unsigned long)s->migrate);
+		x += sprintf(buf + x, "\n");
+	}
 	return x;
 }
 SLAB_ATTR_RO(ops);
Index: linux/include/linux/slab.h
===================================================================
--- linux.orig/include/linux/slab.h
+++ linux/include/linux/slab.h
@@ -153,6 +153,68 @@ void memcg_deactivate_kmem_caches(struct
 void memcg_destroy_kmem_caches(struct mem_cgroup *);
 
 /*
+ * Function prototypes passed to kmem_cache_setup_mobility() to enable mobile
+ * objects and targeted reclaim in slab caches.
+ */
+
+/*
+ * kmem_cache_isolate_func() is called with locks held so that the slab
+ * objects cannot be freed. We are in an atomic context and no slab
+ * operations may be performed. The purpose of kmem_cache_isolate_func()
+ * is to pin the object so that it cannot be freed until
+ * kmem_cache_migrate_func() has processed them. This may be accomplished
+ * by increasing the refcount or setting a flag.
+ *
+ * Parameters passed are the number of objects to process and an array of
+ * pointers to objects which are intended to be moved.
+ *
+ * Returns a pointer that is passed to the migrate function. If any objects
+ * cannot be touched at this point then the pointer may indicate a
+ * failure and then the migration function can simply remove the references
+ * that were already obtained. The private data could be used to track
+ * the objects that were already pinned.
+ *
+ * The object pointer array passed is also passed to kmem_cache_migrate().
+ * The function may remove objects from the array by setting pointers to
+ * NULL. This is useful if we can determine that an object is being freed
+ * because kmem_cache_isolate_func() was called when the subsystem
+ * was calling kmem_cache_free().
+ * In that case it is not necessary to increase the refcount or
+ * specially mark the object because the release of the slab lock
+ * will lead to the immediate freeing of the object.
+ */
+typedef void *kmem_isolate_func(struct kmem_cache *, void **, int);
+
+/*
+ * kmem_cache_move_migrate_func is called with no locks held and interrupts
+ * enabled. Sleeping is possible. Any operation may be performed in
+ * migrate(). kmem_cache_migrate_func should allocate new objects and
+ * free all the objects.
+ **
+ * Parameters passed are the number of objects in the array, the array of
+ * pointers to the objects, the NUMA node where the object should be
+ * allocated and the pointer returned by kmem_cache_isolate_func().
+ *
+ * Success is checked by examining the number of remaining objects in
+ * the slab. If the number is zero then the objects will be freed.
+ */
+typedef void kmem_migrate_func(struct kmem_cache *, void **, int nr, int node, void *private);
+
+/*
+ * kmem_cache_setup_mobility() is used to setup callbacks for a slab cache.
+ */
+#ifdef CONFIG_SLUB
+void kmem_cache_setup_mobility(struct kmem_cache *, kmem_isolate_func,
+						kmem_migrate_func);
+#else
+static inline void kmem_cache_setup_mobility(struct kmem_cache *s,
+	kmem_isolate_func isolate, kmem_migrate_func migrate) {}
+#endif
+
+/*
+ * Allocator specific definitions. These are mainly used to establish optimized
+ * ways to convert kmalloc() calls to kmem_cache_alloc() invocations by
+ * selecting the appropriate general cache at compile time.
  * Please use this macro to create slab caches. Simply specify the
  * name of the structure and maybe some flags that are listed above.
  *
Index: linux/mm/slab_common.c
===================================================================
--- linux.orig/mm/slab_common.c
+++ linux/mm/slab_common.c
@@ -298,7 +298,7 @@ int slab_unmergeable(struct kmem_cache *
 	if (!is_root_cache(s))
 		return 1;
 
-	if (s->ctor)
+	if (s->ctor || s->isolate || s->migrate)
 		return 1;
 
 	if (s->usersize)

