Return-Path: <SRS0=TLXr=WI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 61CA4C433FF
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 16:07:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2FB71206A2
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 16:07:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2FB71206A2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 54A796B0008; Mon, 12 Aug 2019 12:07:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 522036B000A; Mon, 12 Aug 2019 12:07:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 45DD56B000C; Mon, 12 Aug 2019 12:07:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0232.hostedemail.com [216.40.44.232])
	by kanga.kvack.org (Postfix) with ESMTP id 1CE016B000A
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 12:07:19 -0400 (EDT)
Received: from smtpin14.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id BC52145D8
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 16:07:18 +0000 (UTC)
X-FDA: 75814255356.14.hill40_5951313cdf48
X-HE-Tag: hill40_5951313cdf48
X-Filterd-Recvd-Size: 4544
Received: from foss.arm.com (foss.arm.com [217.140.110.172])
	by imf39.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 16:07:18 +0000 (UTC)
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 6357E174E;
	Mon, 12 Aug 2019 09:06:49 -0700 (PDT)
Received: from arrakis.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.121.207.14])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id 6132C3F718;
	Mon, 12 Aug 2019 09:06:48 -0700 (PDT)
From: Catalin Marinas <catalin.marinas@arm.com>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@kernel.org>,
	Matthew Wilcox <willy@infradead.org>,
	Qian Cai <cai@lca.pw>
Subject: [PATCH v3 2/3] mm: kmemleak: Simple memory allocation pool for kmemleak objects
Date: Mon, 12 Aug 2019 17:06:41 +0100
Message-Id: <20190812160642.52134-3-catalin.marinas@arm.com>
X-Mailer: git-send-email 2.23.0.rc0
In-Reply-To: <20190812160642.52134-1-catalin.marinas@arm.com>
References: <20190812160642.52134-1-catalin.marinas@arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Add a memory pool for struct kmemleak_object in case the normal
kmem_cache_alloc() fails under the gfp constraints passed by the caller.
The mem_pool[] array size is currently fixed at 16000.

Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
---
 mm/kmemleak.c | 54 +++++++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 52 insertions(+), 2 deletions(-)

diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index 5ba7fad00fda..2fb86524d70b 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -180,11 +180,17 @@ struct kmemleak_object {
 #define HEX_ASCII		1
 /* max number of lines to be printed */
 #define HEX_MAX_LINES		2
+/* memory pool size */
+#define MEM_POOL_SIZE		16000
=20
 /* the list of all allocated objects */
 static LIST_HEAD(object_list);
 /* the list of gray-colored objects (see color_gray comment below) */
 static LIST_HEAD(gray_list);
+/* memory pool allocation */
+static struct kmemleak_object mem_pool[MEM_POOL_SIZE];
+static int mem_pool_free_count =3D ARRAY_SIZE(mem_pool);
+static LIST_HEAD(mem_pool_free_list);
 /* search tree for object boundaries */
 static struct rb_root object_tree_root =3D RB_ROOT;
 /* rw_lock protecting the access to object_list and object_tree_root */
@@ -451,6 +457,50 @@ static int get_object(struct kmemleak_object *object=
)
 	return atomic_inc_not_zero(&object->use_count);
 }
=20
+/*
+ * Memory pool allocation and freeing. kmemleak_lock must not be held.
+ */
+static struct kmemleak_object *mem_pool_alloc(gfp_t gfp)
+{
+	unsigned long flags;
+	struct kmemleak_object *object;
+
+	/* try the slab allocator first */
+	object =3D kmem_cache_alloc(object_cache, gfp_kmemleak_mask(gfp));
+	if (object)
+		return object;
+
+	/* slab allocation failed, try the memory pool */
+	write_lock_irqsave(&kmemleak_lock, flags);
+	object =3D list_first_entry_or_null(&mem_pool_free_list,
+					  typeof(*object), object_list);
+	if (object)
+		list_del(&object->object_list);
+	else if (mem_pool_free_count)
+		object =3D &mem_pool[--mem_pool_free_count];
+	write_unlock_irqrestore(&kmemleak_lock, flags);
+
+	return object;
+}
+
+/*
+ * Return the object to either the slab allocator or the memory pool.
+ */
+static void mem_pool_free(struct kmemleak_object *object)
+{
+	unsigned long flags;
+
+	if (object < mem_pool || object >=3D mem_pool + ARRAY_SIZE(mem_pool)) {
+		kmem_cache_free(object_cache, object);
+		return;
+	}
+
+	/* add the object to the memory pool free list */
+	write_lock_irqsave(&kmemleak_lock, flags);
+	list_add(&object->object_list, &mem_pool_free_list);
+	write_unlock_irqrestore(&kmemleak_lock, flags);
+}
+
 /*
  * RCU callback to free a kmemleak_object.
  */
@@ -469,7 +519,7 @@ static void free_object_rcu(struct rcu_head *rcu)
 		hlist_del(&area->node);
 		kmem_cache_free(scan_area_cache, area);
 	}
-	kmem_cache_free(object_cache, object);
+	mem_pool_free(object);
 }
=20
 /*
@@ -552,7 +602,7 @@ static struct kmemleak_object *create_object(unsigned=
 long ptr, size_t size,
 	struct rb_node **link, *rb_parent;
 	unsigned long untagged_ptr;
=20
-	object =3D kmem_cache_alloc(object_cache, gfp_kmemleak_mask(gfp));
+	object =3D mem_pool_alloc(gfp);
 	if (!object) {
 		pr_warn("Cannot allocate a kmemleak_object structure\n");
 		kmemleak_disable();

