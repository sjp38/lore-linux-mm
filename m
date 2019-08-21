Return-Path: <SRS0=I31T=WR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BA5B0C3A5A1
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 18:03:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 42A77214DA
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 18:03:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 42A77214DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EBD2E6B0336; Wed, 21 Aug 2019 14:03:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E6E516B0337; Wed, 21 Aug 2019 14:03:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D5DA76B0339; Wed, 21 Aug 2019 14:03:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0027.hostedemail.com [216.40.44.27])
	by kanga.kvack.org (Postfix) with ESMTP id B6E806B0336
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 14:03:32 -0400 (EDT)
Received: from smtpin22.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 332378248AC6
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 18:03:32 +0000 (UTC)
X-FDA: 75847207464.22.dolls91_58fdc626f102a
X-HE-Tag: dolls91_58fdc626f102a
X-Filterd-Recvd-Size: 10624
Received: from relay.sw.ru (relay.sw.ru [185.231.240.75])
	by imf49.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 18:03:31 +0000 (UTC)
Received: from [172.16.25.5] (helo=i7.sw.ru)
	by relay.sw.ru with esmtp (Exim 4.92)
	(envelope-from <aryabinin@virtuozzo.com>)
	id 1i0UxB-0003dx-8Y; Wed, 21 Aug 2019 21:03:25 +0300
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dmitry Vyukov <dvyukov@google.com>,
	Alexander Potapenko <glider@google.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	kasan-dev@googlegroups.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Walter Wu <walter-zh.wu@mediatek.com>,
	Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: [PATCH v5] kasan: add memory corruption identification for software tag-based mode
Date: Wed, 21 Aug 2019 21:03:32 +0300
Message-Id: <20190821180332.11450-1-aryabinin@virtuozzo.com>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Walter Wu <walter-zh.wu@mediatek.com>

This patch adds memory corruption identification at bug report for
software tag-based mode, the report show whether it is "use-after-free"
or "out-of-bound" error instead of "invalid-access" error. This will make
it easier for programmers to see the memory corruption problem.

We extend the slab to store five old free pointer tag and free backtrace,
we can check if the tagged address is in the slab record and make a
good guess if the object is more like "use-after-free" or "out-of-bound".
therefore every slab memory corruption can be identified whether it's
"use-after-free" or "out-of-bound".

[aryabinin@virtuozzo.com: simplify & clenup code:
  https://lkml.kernel.org/r/3318f9d7-a760-3cc8-b700-f06108ae745f@virtuozz=
o.com]
Signed-off-by: Walter Wu <walter-zh.wu@mediatek.com>
Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
---

=3D=3D=3D=3D=3D=3D Changes
Change since v1:
- add feature option CONFIG_KASAN_SW_TAGS_IDENTIFY.
- change QUARANTINE_FRACTION to reduce quarantine size.
- change the qlist order in order to find the newest object in quarantine
- reduce the number of calling kmalloc() from 2 to 1 time.
- remove global variable to use argument to pass it.
- correct the amount of qobject cache->size into the byes of qlist_head.
- only use kasan_cache_shrink() to shink memory.

Change since v2:
- remove the shinking memory function kasan_cache_shrink()
- modify the description of the CONFIG_KASAN_SW_TAGS_IDENTIFY
- optimize the quarantine_find_object() and qobject_free()
- fix the duplicating function name 3 times in the header.
- modify the function name set_track() to kasan_set_track()

Change since v3:
- change tag-based quarantine to extend slab to identify memory corruptio=
n

Changes since v4:
 - Simplify and cleanup code.

 lib/Kconfig.kasan      |  8 ++++++++
 mm/kasan/common.c      | 22 +++++++++++++++++++--
 mm/kasan/kasan.h       | 14 +++++++++++++-
 mm/kasan/report.c      | 44 ++++++++++++++++++++++++++++++++----------
 mm/kasan/tags_report.c | 24 +++++++++++++++++++++++
 5 files changed, 99 insertions(+), 13 deletions(-)

diff --git a/lib/Kconfig.kasan b/lib/Kconfig.kasan
index 7fa97a8b5717..6c9682ce0254 100644
--- a/lib/Kconfig.kasan
+++ b/lib/Kconfig.kasan
@@ -134,6 +134,14 @@ config KASAN_S390_4_LEVEL_PAGING
 	  to 3TB of RAM with KASan enabled). This options allows to force
 	  4-level paging instead.
=20
+config KASAN_SW_TAGS_IDENTIFY
+	bool "Enable memory corruption identification"
+	depends on KASAN_SW_TAGS
+	help
+	  This option enables best-effort identification of bug type
+	  (use-after-free or out-of-bounds) at the cost of increased
+	  memory consumption.
+
 config TEST_KASAN
 	tristate "Module for testing KASAN for bug detection"
 	depends on m && KASAN
diff --git a/mm/kasan/common.c b/mm/kasan/common.c
index 3b8cde0cb5b2..6814d6d6a023 100644
--- a/mm/kasan/common.c
+++ b/mm/kasan/common.c
@@ -304,7 +304,6 @@ size_t kasan_metadata_size(struct kmem_cache *cache)
 struct kasan_alloc_meta *get_alloc_info(struct kmem_cache *cache,
 					const void *object)
 {
-	BUILD_BUG_ON(sizeof(struct kasan_alloc_meta) > 32);
 	return (void *)object + cache->kasan_info.alloc_meta_offset;
 }
=20
@@ -315,6 +314,24 @@ struct kasan_free_meta *get_free_info(struct kmem_ca=
che *cache,
 	return (void *)object + cache->kasan_info.free_meta_offset;
 }
=20
+
+static void kasan_set_free_info(struct kmem_cache *cache,
+		void *object, u8 tag)
+{
+	struct kasan_alloc_meta *alloc_meta;
+	u8 idx =3D 0;
+
+	alloc_meta =3D get_alloc_info(cache, object);
+
+#ifdef CONFIG_KASAN_SW_TAGS_IDENTIFY
+	idx =3D alloc_meta->free_track_idx;
+	alloc_meta->free_pointer_tag[idx] =3D tag;
+	alloc_meta->free_track_idx =3D (idx + 1) % KASAN_NR_FREE_STACKS;
+#endif
+
+	set_track(&alloc_meta->free_track[idx], GFP_NOWAIT);
+}
+
 void kasan_poison_slab(struct page *page)
 {
 	unsigned long i;
@@ -451,7 +468,8 @@ static bool __kasan_slab_free(struct kmem_cache *cach=
e, void *object,
 			unlikely(!(cache->flags & SLAB_KASAN)))
 		return false;
=20
-	set_track(&get_alloc_info(cache, object)->free_track, GFP_NOWAIT);
+	kasan_set_free_info(cache, object, tag);
+
 	quarantine_put(get_free_info(cache, object), cache);
=20
 	return IS_ENABLED(CONFIG_KASAN_GENERIC);
diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
index 014f19e76247..35cff6bbb716 100644
--- a/mm/kasan/kasan.h
+++ b/mm/kasan/kasan.h
@@ -95,9 +95,19 @@ struct kasan_track {
 	depot_stack_handle_t stack;
 };
=20
+#ifdef CONFIG_KASAN_SW_TAGS_IDENTIFY
+#define KASAN_NR_FREE_STACKS 5
+#else
+#define KASAN_NR_FREE_STACKS 1
+#endif
+
 struct kasan_alloc_meta {
 	struct kasan_track alloc_track;
-	struct kasan_track free_track;
+	struct kasan_track free_track[KASAN_NR_FREE_STACKS];
+#ifdef CONFIG_KASAN_SW_TAGS_IDENTIFY
+	u8 free_pointer_tag[KASAN_NR_FREE_STACKS];
+	u8 free_track_idx;
+#endif
 };
=20
 struct qlist_node {
@@ -146,6 +156,8 @@ void kasan_report(unsigned long addr, size_t size,
 		bool is_write, unsigned long ip);
 void kasan_report_invalid_free(void *object, unsigned long ip);
=20
+struct page *kasan_addr_to_page(const void *addr);
+
 #if defined(CONFIG_KASAN_GENERIC) && \
 	(defined(CONFIG_SLAB) || defined(CONFIG_SLUB))
 void quarantine_put(struct kasan_free_meta *info, struct kmem_cache *cac=
he);
diff --git a/mm/kasan/report.c b/mm/kasan/report.c
index 0e5f965f1882..621782100eaa 100644
--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -111,7 +111,7 @@ static void print_track(struct kasan_track *track, co=
nst char *prefix)
 	}
 }
=20
-static struct page *addr_to_page(const void *addr)
+struct page *kasan_addr_to_page(const void *addr)
 {
 	if ((addr >=3D (void *)PAGE_OFFSET) &&
 			(addr < high_memory))
@@ -151,15 +151,38 @@ static void describe_object_addr(struct kmem_cache =
*cache, void *object,
 		(void *)(object_addr + cache->object_size));
 }
=20
+static struct kasan_track *kasan_get_free_track(struct kmem_cache *cache=
,
+		void *object, u8 tag)
+{
+	struct kasan_alloc_meta *alloc_meta;
+	int i =3D 0;
+
+	alloc_meta =3D get_alloc_info(cache, object);
+
+#ifdef CONFIG_KASAN_SW_TAGS_IDENTIFY
+	for (i =3D 0; i < KASAN_NR_FREE_STACKS; i++) {
+		if (alloc_meta->free_pointer_tag[i] =3D=3D tag)
+			break;
+	}
+	if (i =3D=3D KASAN_NR_FREE_STACKS)
+		i =3D alloc_meta->free_track_idx;
+#endif
+
+	return &alloc_meta->free_track[i];
+}
+
 static void describe_object(struct kmem_cache *cache, void *object,
-				const void *addr)
+				const void *addr, u8 tag)
 {
 	struct kasan_alloc_meta *alloc_info =3D get_alloc_info(cache, object);
=20
 	if (cache->flags & SLAB_KASAN) {
+		struct kasan_track *free_track;
+
 		print_track(&alloc_info->alloc_track, "Allocated");
 		pr_err("\n");
-		print_track(&alloc_info->free_track, "Freed");
+		free_track =3D kasan_get_free_track(cache, object, tag);
+		print_track(free_track, "Freed");
 		pr_err("\n");
 	}
=20
@@ -344,9 +367,9 @@ static void print_address_stack_frame(const void *add=
r)
 	print_decoded_frame_descr(frame_descr);
 }
=20
-static void print_address_description(void *addr)
+static void print_address_description(void *addr, u8 tag)
 {
-	struct page *page =3D addr_to_page(addr);
+	struct page *page =3D kasan_addr_to_page(addr);
=20
 	dump_stack();
 	pr_err("\n");
@@ -355,7 +378,7 @@ static void print_address_description(void *addr)
 		struct kmem_cache *cache =3D page->slab_cache;
 		void *object =3D nearest_obj(cache, page,	addr);
=20
-		describe_object(cache, object, addr);
+		describe_object(cache, object, addr, tag);
 	}
=20
 	if (kernel_or_module_addr(addr) && !init_task_stack_addr(addr)) {
@@ -435,13 +458,14 @@ static bool report_enabled(void)
 void kasan_report_invalid_free(void *object, unsigned long ip)
 {
 	unsigned long flags;
+	u8 tag =3D get_tag(object);
=20
+	object =3D reset_tag(object);
 	start_report(&flags);
 	pr_err("BUG: KASAN: double-free or invalid-free in %pS\n", (void *)ip);
-	print_tags(get_tag(object), reset_tag(object));
-	object =3D reset_tag(object);
+	print_tags(tag, object);
 	pr_err("\n");
-	print_address_description(object);
+	print_address_description(object, tag);
 	pr_err("\n");
 	print_shadow_for_address(object);
 	end_report(&flags);
@@ -479,7 +503,7 @@ void __kasan_report(unsigned long addr, size_t size, =
bool is_write, unsigned lon
 	pr_err("\n");
=20
 	if (addr_has_shadow(untagged_addr)) {
-		print_address_description(untagged_addr);
+		print_address_description(untagged_addr, get_tag(tagged_addr));
 		pr_err("\n");
 		print_shadow_for_address(info.first_bad_addr);
 	} else {
diff --git a/mm/kasan/tags_report.c b/mm/kasan/tags_report.c
index 8eaf5f722271..969ae08f59d7 100644
--- a/mm/kasan/tags_report.c
+++ b/mm/kasan/tags_report.c
@@ -36,6 +36,30 @@
=20
 const char *get_bug_type(struct kasan_access_info *info)
 {
+#ifdef CONFIG_KASAN_SW_TAGS_IDENTIFY
+	struct kasan_alloc_meta *alloc_meta;
+	struct kmem_cache *cache;
+	struct page *page;
+	const void *addr;
+	void *object;
+	u8 tag;
+	int i;
+
+	tag =3D get_tag(info->access_addr);
+	addr =3D reset_tag(info->access_addr);
+	page =3D kasan_addr_to_page(addr);
+	if (page && PageSlab(page)) {
+		cache =3D page->slab_cache;
+		object =3D nearest_obj(cache, page, (void *)addr);
+		alloc_meta =3D get_alloc_info(cache, object);
+
+		for (i =3D 0; i < KASAN_NR_FREE_STACKS; i++)
+			if (alloc_meta->free_pointer_tag[i] =3D=3D tag)
+				return "use-after-free";
+		return "out-of-bounds";
+	}
+
+#endif
 	return "invalid-access";
 }
=20
--=20
2.21.0


