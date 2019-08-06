Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AB222C433FF
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 05:43:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 32475206A2
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 05:43:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 32475206A2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mediatek.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CE59A6B0006; Tue,  6 Aug 2019 01:43:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C96556B0008; Tue,  6 Aug 2019 01:43:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B84D76B000A; Tue,  6 Aug 2019 01:43:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7DAC06B0006
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 01:43:49 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id s21so47601262plr.2
        for <linux-mm@kvack.org>; Mon, 05 Aug 2019 22:43:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version;
        bh=OBiOHBJNA0EwPzUOLk1WXfMlqfDylmUiZp52wqeeYGk=;
        b=Zmz+iZXFlaOVhsNnye32xYq/4SoszEg0ImJowPX5mrHSpJrVphRyIRiKVG/JvdrKpX
         Wbf2Z3gGANUNmh/Cpq8MEmEJ1g06umM2/uDwpCpZC5zRhUf5MRUBgt5hexUyRVfAkwCY
         C+WpvNzKixYEmTMx94VHiEa/hce3K6UqA2AVxU7DPKLnVnwv2d3gTnUgoCq/f4bpm8ju
         zX8jYW1j8q8nkZOKyWSZ+wBYMzR6QvLmsTSondCXOQAdzhgGnQn2DeYtIaMf0lNENyJy
         HMpE7KV5Eir+6HHghU62OSh9MfMjXNpuFSFpOv8l7zGgdfwOHZIVqRgapVQYyNJ6YbK2
         3mZw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of walter-zh.wu@mediatek.com designates 210.61.82.184 as permitted sender) smtp.mailfrom=walter-zh.wu@mediatek.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mediatek.com
X-Gm-Message-State: APjAAAXpmo7xDWWTt/PwoQSBT5Fah9xXsNMo5PHvnlYeM1+4fnfe1lO8
	5JFPDw2sEUtPYeKuHBrLu25nidn50XIdGQzQqv9UsYFhd6hiFGhbY7MBPG3fgrxks39kENB+o2B
	XBli1ffHsXDmhcmuittX+/9sRolwn0om7yUBRQ+RhGQtsV9M/1ERslxaerRNLWbGV7A==
X-Received: by 2002:a17:902:7612:: with SMTP id k18mr1436130pll.48.1565070229084;
        Mon, 05 Aug 2019 22:43:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzEiYtsHxDwo9QcC3FhVkVXLQhuWBL7eRIOz7FBwazVS26soqpvjak93q4V4h9bcsEe9oCe
X-Received: by 2002:a17:902:7612:: with SMTP id k18mr1436040pll.48.1565070227375;
        Mon, 05 Aug 2019 22:43:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565070227; cv=none;
        d=google.com; s=arc-20160816;
        b=YyVvUFL31PlXjCjs+ezqQKnpLAQWSIYn+31N2TKypXSAAAAv/ePe9EEX3msfB0HziN
         tY0Be1HN9GLcLFeWl0TfIgqwsT22losFXZTHqmkETmfQmTOueGsLfxnsaExD4A4J6mTr
         2Qegpc9qs/JZFVIDEsaPKoLWNkygJ2rBj//YRPcG+eTC6SrDhuXUgJ948z6wpHi5gL2S
         k6PG5K/IH0Tv6tTIW22eV/SvU6wwKZctblWySjFfD8okNJRqKzd57NGWTZh0CwmMYJKw
         M7q0Qy4vNZugEKlOEItygf4TaGD1XOrzaKHZKjqb1Es7e/2LJDVCmU6sfg5lQGMyUEmE
         B6GQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:subject:cc:to:from;
        bh=OBiOHBJNA0EwPzUOLk1WXfMlqfDylmUiZp52wqeeYGk=;
        b=BBi7XU5iqLP/soB+GDVqolW6dbDwokdn/yJ2T57odiAyb0Bf1nJ2Lu7e18vtLr0807
         0FBotGlm4a6KmcqqGb/2Jwv5f/FjBpQvDB2ta6qScEZVpsnEfzT8vtWDLHSHjBbEqh1S
         DTbvrWg3ofyYhq/YREjvUNosy1/4IRg2SJZXRspCbcXRCyZljdek8fbYx5I56zn4mE9L
         wvpfls8fmTwzukRtlvrjST9VDJU0IecHEPgguYv6uzuJsZs6DyPDWuyMD2qdUoy2Rx/0
         Kf6iasyL64NpcnvmZePecDrX3i03UObZIgXqvhKeBEfHG8pl9uva5MMePF7noFCJ2rqu
         6Onw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of walter-zh.wu@mediatek.com designates 210.61.82.184 as permitted sender) smtp.mailfrom=walter-zh.wu@mediatek.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mediatek.com
Received: from mailgw02.mediatek.com ([210.61.82.184])
        by mx.google.com with ESMTP id r11si13900413pjq.108.2019.08.05.22.43.46
        for <linux-mm@kvack.org>;
        Mon, 05 Aug 2019 22:43:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of walter-zh.wu@mediatek.com designates 210.61.82.184 as permitted sender) client-ip=210.61.82.184;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of walter-zh.wu@mediatek.com designates 210.61.82.184 as permitted sender) smtp.mailfrom=walter-zh.wu@mediatek.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mediatek.com
X-UUID: 7723729e524f4c1085823b1379389ab4-20190806
X-UUID: 7723729e524f4c1085823b1379389ab4-20190806
Received: from mtkmrs01.mediatek.inc [(172.21.131.159)] by mailgw02.mediatek.com
	(envelope-from <walter-zh.wu@mediatek.com>)
	(Cellopoint E-mail Firewall v4.1.10 Build 0707 with TLS)
	with ESMTP id 1263771809; Tue, 06 Aug 2019 13:43:43 +0800
Received: from mtkcas07.mediatek.inc (172.21.101.84) by
 mtkmbs07n2.mediatek.inc (172.21.101.141) with Microsoft SMTP Server (TLS) id
 15.0.1395.4; Tue, 6 Aug 2019 13:43:42 +0800
Received: from mtksdccf07.mediatek.inc (172.21.84.99) by mtkcas07.mediatek.inc
 (172.21.101.73) with Microsoft SMTP Server id 15.0.1395.4 via Frontend
 Transport; Tue, 6 Aug 2019 13:43:42 +0800
From: Walter Wu <walter-zh.wu@mediatek.com>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko
	<glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Matthias Brugger
	<matthias.bgg@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Martin
 Schwidefsky <schwidefsky@de.ibm.com>, Arnd Bergmann <arnd@arndb.de>, Thomas
 Gleixner <tglx@linutronix.de>, Vasily Gorbik <gor@linux.ibm.com>, Andrey
 Konovalov <andreyknvl@google.com>, Miles Chen <miles.chen@mediatek.com>,
	Walter Wu <walter-zh.wu@mediatek.com>
CC: <linux-kernel@vger.kernel.org>, <kasan-dev@googlegroups.com>,
	<linux-mm@kvack.org>, <linux-arm-kernel@lists.infradead.org>,
	<linux-mediatek@lists.infradead.org>, <wsd_upstream@mediatek.com>
Subject: [PATCH v4] kasan: add memory corruption identification for software tag-based mode
Date: Tue, 6 Aug 2019 13:43:40 +0800
Message-ID: <20190806054340.16305-1-walter-zh.wu@mediatek.com>
X-Mailer: git-send-email 2.18.0
MIME-Version: 1.0
Content-Type: text/plain
X-MTK: N
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch adds memory corruption identification at bug report for
software tag-based mode, the report show whether it is "use-after-free"
or "out-of-bound" error instead of "invalid-access" error. This will make
it easier for programmers to see the memory corruption problem.

We extend the slab to store five old free pointer tag and free backtrace,
we can check if the tagged address is in the slab record and make a
good guess if the object is more like "use-after-free" or "out-of-bound".
therefore every slab memory corruption can be identified whether it's
"use-after-free" or "out-of-bound".

====== Changes
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
- change tag-based quarantine to extend slab to identify memory corruption

Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Dmitry Vyukov <dvyukov@google.com>
Signed-off-by: Walter Wu <walter-zh.wu@mediatek.com>
---
 lib/Kconfig.kasan      |  8 ++++
 mm/kasan/common.c      | 14 +++++--
 mm/kasan/kasan.h       | 37 ++++++++++++++++++
 mm/kasan/report.c      | 53 +++++++++++++++-----------
 mm/kasan/tags.c        | 86 ++++++++++++++++++++++++++++++++++++++++++
 mm/kasan/tags_report.c |  5 ++-
 6 files changed, 177 insertions(+), 26 deletions(-)

diff --git a/lib/Kconfig.kasan b/lib/Kconfig.kasan
index 4fafba1a923b..70b55e1c4834 100644
--- a/lib/Kconfig.kasan
+++ b/lib/Kconfig.kasan
@@ -135,6 +135,14 @@ config KASAN_S390_4_LEVEL_PAGING
 	  to 3TB of RAM with KASan enabled). This options allows to force
 	  4-level paging instead.
 
+config KASAN_SW_TAGS_IDENTIFY
+	bool "Enable memory corruption identification"
+	depends on KASAN_SW_TAGS
+	help
+	  This option enables best-effort identification of bug type
+	  (use-after-free or out-of-bounds) at the cost of increased
+	  memory consumption for slab extending.
+
 config TEST_KASAN
 	tristate "Module for testing KASAN for bug detection"
 	depends on m && KASAN
diff --git a/mm/kasan/common.c b/mm/kasan/common.c
index 2277b82902d8..6bbb044708e6 100644
--- a/mm/kasan/common.c
+++ b/mm/kasan/common.c
@@ -71,7 +71,7 @@ static inline depot_stack_handle_t save_stack(gfp_t flags)
 	return stack_depot_save(entries, nr_entries, flags);
 }
 
-static inline void set_track(struct kasan_track *track, gfp_t flags)
+void kasan_set_track(struct kasan_track *track, gfp_t flags)
 {
 	track->pid = current->pid;
 	track->stack = save_stack(flags);
@@ -304,7 +304,8 @@ size_t kasan_metadata_size(struct kmem_cache *cache)
 struct kasan_alloc_meta *get_alloc_info(struct kmem_cache *cache,
 					const void *object)
 {
-	BUILD_BUG_ON(sizeof(struct kasan_alloc_meta) > 32);
+	if (!IS_ENABLED(CONFIG_KASAN_SW_TAGS_IDENTIFY))
+		BUILD_BUG_ON(sizeof(struct kasan_alloc_meta) > 32);
 	return (void *)object + cache->kasan_info.alloc_meta_offset;
 }
 
@@ -446,7 +447,11 @@ static bool __kasan_slab_free(struct kmem_cache *cache, void *object,
 			unlikely(!(cache->flags & SLAB_KASAN)))
 		return false;
 
-	set_track(&get_alloc_info(cache, object)->free_track, GFP_NOWAIT);
+	if (IS_ENABLED(CONFIG_KASAN_SW_TAGS_IDENTIFY))
+		kasan_set_free_info(cache, object, tag);
+	else
+		kasan_set_track(&get_alloc_info(cache, object)->free_track,
+						GFP_NOWAIT);
 	quarantine_put(get_free_info(cache, object), cache);
 
 	return IS_ENABLED(CONFIG_KASAN_GENERIC);
@@ -484,7 +489,8 @@ static void *__kasan_kmalloc(struct kmem_cache *cache, const void *object,
 		KASAN_KMALLOC_REDZONE);
 
 	if (cache->flags & SLAB_KASAN)
-		set_track(&get_alloc_info(cache, object)->alloc_track, flags);
+		kasan_set_track(&get_alloc_info(cache, object)->alloc_track,
+						flags);
 
 	return set_tag(object, tag);
 }
diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
index 014f19e76247..531a5823e8c6 100644
--- a/mm/kasan/kasan.h
+++ b/mm/kasan/kasan.h
@@ -95,9 +95,23 @@ struct kasan_track {
 	depot_stack_handle_t stack;
 };
 
+#ifdef CONFIG_KASAN_SW_TAGS_IDENTIFY
+#define KASAN_EXTRA_FREE_INFO_COUNT 4
+#define KASAN_TOTAL_FREE_INFO_COUNT  (KASAN_EXTRA_FREE_INFO_COUNT + 1)
+struct extra_free_info {
+	/* Round-robin FIFO array. */
+	struct kasan_track free_track[KASAN_EXTRA_FREE_INFO_COUNT];
+	u8 free_pointer_tag[KASAN_TOTAL_FREE_INFO_COUNT];
+	u8 free_track_tail;
+};
+#endif
+
 struct kasan_alloc_meta {
 	struct kasan_track alloc_track;
 	struct kasan_track free_track;
+#ifdef CONFIG_KASAN_SW_TAGS_IDENTIFY
+	struct extra_free_info free_info;
+#endif
 };
 
 struct qlist_node {
@@ -146,6 +160,29 @@ void kasan_report(unsigned long addr, size_t size,
 		bool is_write, unsigned long ip);
 void kasan_report_invalid_free(void *object, unsigned long ip);
 
+struct page *addr_to_page(const void *addr);
+
+void kasan_set_track(struct kasan_track *track, gfp_t flags);
+
+#ifdef CONFIG_KASAN_SW_TAGS_IDENTIFY
+void kasan_set_free_info(struct kmem_cache *cache, void *object, u8 tag);
+struct kasan_track *kasan_get_free_track(struct kmem_cache *cache,
+		void *object, u8 tag);
+char *kasan_get_corruption_type(void *addr);
+#else
+static inline void kasan_set_free_info(struct kmem_cache *cache,
+		void *object, u8 tag) { }
+static inline struct kasan_track *kasan_get_free_track(
+		struct kmem_cache *cache, void *object, u8 tag)
+{
+	return NULL;
+}
+static inline char *kasan_get_corruption_type(void *addr)
+{
+	return NULL;
+}
+#endif
+
 #if defined(CONFIG_KASAN_GENERIC) && \
 	(defined(CONFIG_SLAB) || defined(CONFIG_SLUB))
 void quarantine_put(struct kasan_free_meta *info, struct kmem_cache *cache);
diff --git a/mm/kasan/report.c b/mm/kasan/report.c
index 0e5f965f1882..9ea7a4265b42 100644
--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -111,14 +111,6 @@ static void print_track(struct kasan_track *track, const char *prefix)
 	}
 }
 
-static struct page *addr_to_page(const void *addr)
-{
-	if ((addr >= (void *)PAGE_OFFSET) &&
-			(addr < high_memory))
-		return virt_to_head_page(addr);
-	return NULL;
-}
-
 static void describe_object_addr(struct kmem_cache *cache, void *object,
 				const void *addr)
 {
@@ -152,18 +144,27 @@ static void describe_object_addr(struct kmem_cache *cache, void *object,
 }
 
 static void describe_object(struct kmem_cache *cache, void *object,
-				const void *addr)
+				const void *tagged_addr)
 {
+	void *untagged_addr = reset_tag(tagged_addr);
 	struct kasan_alloc_meta *alloc_info = get_alloc_info(cache, object);
 
 	if (cache->flags & SLAB_KASAN) {
 		print_track(&alloc_info->alloc_track, "Allocated");
 		pr_err("\n");
-		print_track(&alloc_info->free_track, "Freed");
-		pr_err("\n");
+		if (IS_ENABLED(CONFIG_KASAN_SW_TAGS_IDENTIFY)) {
+			struct kasan_track *free_track;
+			u8 tag = get_tag(tagged_addr);
+
+			free_track = kasan_get_free_track(cache, object, tag);
+			print_track(free_track, "Freed");
+		} else {
+			print_track(&alloc_info->free_track, "Freed");
+			pr_err("\n");
+		}
 	}
 
-	describe_object_addr(cache, object, addr);
+	describe_object_addr(cache, object, untagged_addr);
 }
 
 static inline bool kernel_or_module_addr(const void *addr)
@@ -344,23 +345,25 @@ static void print_address_stack_frame(const void *addr)
 	print_decoded_frame_descr(frame_descr);
 }
 
-static void print_address_description(void *addr)
+static void print_address_description(void *tagged_addr)
 {
-	struct page *page = addr_to_page(addr);
+	void *untagged_addr = reset_tag(tagged_addr);
+	struct page *page = addr_to_page(untagged_addr);
 
 	dump_stack();
 	pr_err("\n");
 
 	if (page && PageSlab(page)) {
 		struct kmem_cache *cache = page->slab_cache;
-		void *object = nearest_obj(cache, page,	addr);
+		void *object = nearest_obj(cache, page,	untagged_addr);
 
-		describe_object(cache, object, addr);
+		describe_object(cache, object, tagged_addr);
 	}
 
-	if (kernel_or_module_addr(addr) && !init_task_stack_addr(addr)) {
+	if (kernel_or_module_addr(untagged_addr) &&
+			!init_task_stack_addr(untagged_addr)) {
 		pr_err("The buggy address belongs to the variable:\n");
-		pr_err(" %pS\n", addr);
+		pr_err(" %pS\n", tagged_addr);
 	}
 
 	if (page) {
@@ -368,7 +371,7 @@ static void print_address_description(void *addr)
 		dump_page(page, "kasan: bad access detected");
 	}
 
-	print_address_stack_frame(addr);
+	print_address_stack_frame(untagged_addr);
 }
 
 static bool row_is_guilty(const void *row, const void *guilty)
@@ -432,6 +435,14 @@ static bool report_enabled(void)
 	return !test_and_set_bit(KASAN_BIT_REPORTED, &kasan_flags);
 }
 
+struct page *addr_to_page(const void *addr)
+{
+	if ((addr >= (void *)PAGE_OFFSET) &&
+			(addr < high_memory))
+		return virt_to_head_page(addr);
+	return NULL;
+}
+
 void kasan_report_invalid_free(void *object, unsigned long ip)
 {
 	unsigned long flags;
@@ -439,10 +450,10 @@ void kasan_report_invalid_free(void *object, unsigned long ip)
 	start_report(&flags);
 	pr_err("BUG: KASAN: double-free or invalid-free in %pS\n", (void *)ip);
 	print_tags(get_tag(object), reset_tag(object));
-	object = reset_tag(object);
 	pr_err("\n");
 	print_address_description(object);
 	pr_err("\n");
+	object = reset_tag(object);
 	print_shadow_for_address(object);
 	end_report(&flags);
 }
@@ -479,7 +490,7 @@ void __kasan_report(unsigned long addr, size_t size, bool is_write, unsigned lon
 	pr_err("\n");
 
 	if (addr_has_shadow(untagged_addr)) {
-		print_address_description(untagged_addr);
+		print_address_description(tagged_addr);
 		pr_err("\n");
 		print_shadow_for_address(info.first_bad_addr);
 	} else {
diff --git a/mm/kasan/tags.c b/mm/kasan/tags.c
index 0e987c9ca052..05a11f1cfff7 100644
--- a/mm/kasan/tags.c
+++ b/mm/kasan/tags.c
@@ -161,3 +161,89 @@ void __hwasan_tag_memory(unsigned long addr, u8 tag, unsigned long size)
 	kasan_poison_shadow((void *)addr, size, tag);
 }
 EXPORT_SYMBOL(__hwasan_tag_memory);
+
+#ifdef CONFIG_KASAN_SW_TAGS_IDENTIFY
+void kasan_set_free_info(struct kmem_cache *cache,
+		void *object, u8 tag)
+{
+	struct kasan_alloc_meta *alloc_meta;
+	struct extra_free_info *free_info;
+	u8 idx;
+
+	alloc_meta = get_alloc_info(cache, object);
+	free_info = &alloc_meta->free_info;
+
+	if (free_info->free_track_tail == 0)
+		free_info->free_track_tail = KASAN_EXTRA_FREE_INFO_COUNT;
+	else
+		free_info->free_track_tail -= 1;
+
+	idx = free_info->free_track_tail;
+	free_info->free_pointer_tag[idx] = tag;
+
+	if (idx == KASAN_EXTRA_FREE_INFO_COUNT)
+		kasan_set_track(&alloc_meta->free_track, GFP_NOWAIT);
+	else
+		kasan_set_track(&free_info->free_track[idx], GFP_NOWAIT);
+}
+
+struct kasan_track *kasan_get_free_track(struct kmem_cache *cache,
+		void *object, u8 tag)
+{
+	struct kasan_alloc_meta *alloc_meta;
+	struct extra_free_info *free_info;
+	int idx, i;
+
+	alloc_meta = get_alloc_info(cache, object);
+	free_info = &alloc_meta->free_info;
+
+	for (i = 0; i < KASAN_TOTAL_FREE_INFO_COUNT; i++) {
+		idx = free_info->free_track_tail + i;
+		if (idx >= KASAN_TOTAL_FREE_INFO_COUNT)
+			idx -= KASAN_TOTAL_FREE_INFO_COUNT;
+
+		if (free_info->free_pointer_tag[idx] == tag) {
+			if (idx == KASAN_EXTRA_FREE_INFO_COUNT)
+				return &alloc_meta->free_track;
+			else
+				return &free_info->free_track[idx];
+		}
+	}
+	if (free_info->free_track_tail == KASAN_EXTRA_FREE_INFO_COUNT)
+		return &alloc_meta->free_track;
+	else
+		return &free_info->free_track[free_info->free_track_tail];
+}
+
+char *kasan_get_corruption_type(void *addr)
+{
+	struct kasan_alloc_meta *alloc_meta;
+	struct extra_free_info *free_info;
+	struct page *page;
+	struct kmem_cache *cache;
+	void *object;
+	u8 tag;
+	int idx, i;
+
+	tag = get_tag(addr);
+	addr = reset_tag(addr);
+	page = addr_to_page(addr);
+	if (page && PageSlab(page)) {
+		cache = page->slab_cache;
+		object = nearest_obj(cache, page, addr);
+		alloc_meta = get_alloc_info(cache, object);
+		free_info = &alloc_meta->free_info;
+
+		for (i = 0; i < KASAN_TOTAL_FREE_INFO_COUNT; i++) {
+			idx = free_info->free_track_tail + i;
+			if (idx >= KASAN_TOTAL_FREE_INFO_COUNT)
+				idx -= KASAN_TOTAL_FREE_INFO_COUNT;
+
+			if (free_info->free_pointer_tag[idx] == tag)
+				return "use-after-free";
+		}
+		return "out-of-bounds";
+	}
+	return "invalid-access";
+}
+#endif
diff --git a/mm/kasan/tags_report.c b/mm/kasan/tags_report.c
index 8eaf5f722271..6d8cdb91c4b6 100644
--- a/mm/kasan/tags_report.c
+++ b/mm/kasan/tags_report.c
@@ -36,7 +36,10 @@
 
 const char *get_bug_type(struct kasan_access_info *info)
 {
-	return "invalid-access";
+	if (IS_ENABLED(CONFIG_KASAN_SW_TAGS_IDENTIFY))
+		return(kasan_get_corruption_type((void *)info->access_addr));
+	else
+		return "invalid-access";
 }
 
 void *find_first_bad_addr(void *addr, size_t size)
-- 
2.18.0

