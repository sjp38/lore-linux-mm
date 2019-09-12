Return-Path: <SRS0=iDsh=XH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 35FA0C4CEC6
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 13:53:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 00D052084D
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 13:53:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 00D052084D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6E24B6B0005; Thu, 12 Sep 2019 09:53:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 692D86B0006; Thu, 12 Sep 2019 09:53:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5A7F76B0007; Thu, 12 Sep 2019 09:53:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0241.hostedemail.com [216.40.44.241])
	by kanga.kvack.org (Postfix) with ESMTP id 3A14F6B0005
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 09:53:53 -0400 (EDT)
Received: from smtpin03.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id AAFDF82437CF
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 13:53:52 +0000 (UTC)
X-FDA: 75926411904.03.honey84_3edd4eea15d2a
X-HE-Tag: honey84_3edd4eea15d2a
X-Filterd-Recvd-Size: 7909
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf50.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 13:53:51 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id AD654B7D4;
	Thu, 12 Sep 2019 13:53:49 +0000 (UTC)
Subject: Re: [PATCH v3] mm/kasan: dump alloc and free stack for page allocator
To: Qian Cai <cai@lca.pw>, Walter Wu <walter-zh.wu@mediatek.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>,
 Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>,
 Matthias Brugger <matthias.bgg@gmail.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 Martin Schwidefsky <schwidefsky@de.ibm.com>,
 Andrey Konovalov <andreyknvl@google.com>, Arnd Bergmann <arnd@arndb.de>,
 linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com,
 linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org,
 linux-mediatek@lists.infradead.org, wsd_upstream@mediatek.com
References: <20190911083921.4158-1-walter-zh.wu@mediatek.com>
 <5E358F4B-552C-4542-9655-E01C7B754F14@lca.pw>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <c4d2518f-4813-c941-6f47-73897f420517@suse.cz>
Date: Thu, 12 Sep 2019 15:53:48 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <5E358F4B-552C-4542-9655-E01C7B754F14@lca.pw>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 9/11/19 5:19 PM, Qian Cai wrote:
> 
> The new config looks redundant and confusing. It looks to me more of a document update
> in Documentation/dev-tools/kasan.txt to educate developers to select PAGE_OWNER and
> DEBUG_PAGEALLOC if needed.
 
Agreed. But if you want it fully automatic, how about something
like this (on top of mmotm/next)? If you agree I'll add changelog
and send properly.

----8<----

From a528d14c71d7fdf5872ca8ab3bd1b5bad26670c9 Mon Sep 17 00:00:00 2001
From: Vlastimil Babka <vbabka@suse.cz>
Date: Thu, 12 Sep 2019 15:51:23 +0200
Subject: [PATCH] make KASAN enable page_owner with free stack capture

---
 include/linux/page_owner.h |  1 +
 lib/Kconfig.kasan          |  4 ++++
 mm/Kconfig.debug           |  5 +++++
 mm/page_alloc.c            |  6 +++++-
 mm/page_owner.c            | 37 ++++++++++++++++++++++++-------------
 5 files changed, 39 insertions(+), 14 deletions(-)

diff --git a/include/linux/page_owner.h b/include/linux/page_owner.h
index 8679ccd722e8..6ffe8b81ba85 100644
--- a/include/linux/page_owner.h
+++ b/include/linux/page_owner.h
@@ -6,6 +6,7 @@
 
 #ifdef CONFIG_PAGE_OWNER
 extern struct static_key_false page_owner_inited;
+extern bool page_owner_free_stack_disabled;
 extern struct page_ext_operations page_owner_ops;
 
 extern void __reset_page_owner(struct page *page, unsigned int order);
diff --git a/lib/Kconfig.kasan b/lib/Kconfig.kasan
index 6c9682ce0254..dc560c7562e8 100644
--- a/lib/Kconfig.kasan
+++ b/lib/Kconfig.kasan
@@ -41,6 +41,8 @@ config KASAN_GENERIC
 	select SLUB_DEBUG if SLUB
 	select CONSTRUCTORS
 	select STACKDEPOT
+	select PAGE_OWNER
+	select PAGE_OWNER_FREE_STACK
 	help
 	  Enables generic KASAN mode.
 	  Supported in both GCC and Clang. With GCC it requires version 4.9.2
@@ -63,6 +65,8 @@ config KASAN_SW_TAGS
 	select SLUB_DEBUG if SLUB
 	select CONSTRUCTORS
 	select STACKDEPOT
+	select PAGE_OWNER
+	select PAGE_OWNER_FREE_STACK
 	help
 	  Enables software tag-based KASAN mode.
 	  This mode requires Top Byte Ignore support by the CPU and therefore
diff --git a/mm/Kconfig.debug b/mm/Kconfig.debug
index 327b3ebf23bf..a71d52636687 100644
--- a/mm/Kconfig.debug
+++ b/mm/Kconfig.debug
@@ -13,6 +13,7 @@ config DEBUG_PAGEALLOC
 	depends on DEBUG_KERNEL
 	depends on !HIBERNATION || ARCH_SUPPORTS_DEBUG_PAGEALLOC && !PPC && !SPARC
 	select PAGE_POISONING if !ARCH_SUPPORTS_DEBUG_PAGEALLOC
+	select PAGE_OWNER_FREE_STACK if PAGE_OWNER
 	---help---
 	  Unmap pages from the kernel linear mapping after free_pages().
 	  Depending on runtime enablement, this results in a small or large
@@ -62,6 +63,10 @@ config PAGE_OWNER
 
 	  If unsure, say N.
 
+config PAGE_OWNER_FREE_STACK
+	def_bool n
+	depends on PAGE_OWNER
+
 config PAGE_POISONING
 	bool "Poison pages after freeing"
 	select PAGE_POISONING_NO_SANITY if HIBERNATION
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index c5d62f1c2851..d9e44671af3f 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -710,8 +710,12 @@ static int __init early_debug_pagealloc(char *buf)
 	if (kstrtobool(buf, &enable))
 		return -EINVAL;
 
-	if (enable)
+	if (enable) {
 		static_branch_enable(&_debug_pagealloc_enabled);
+#ifdef CONFIG_PAGE_OWNER
+		page_owner_free_stack_disabled = false;
+#endif
+	}
 
 	return 0;
 }
diff --git a/mm/page_owner.c b/mm/page_owner.c
index dee931184788..d4551d7012d0 100644
--- a/mm/page_owner.c
+++ b/mm/page_owner.c
@@ -24,13 +24,15 @@ struct page_owner {
 	short last_migrate_reason;
 	gfp_t gfp_mask;
 	depot_stack_handle_t handle;
-#ifdef CONFIG_DEBUG_PAGEALLOC
+#ifdef CONFIG_PAGE_OWNER_FREE_STACK
 	depot_stack_handle_t free_handle;
 #endif
 };
 
 static bool page_owner_disabled = true;
+bool page_owner_free_stack_disabled = true;
 DEFINE_STATIC_KEY_FALSE(page_owner_inited);
+static DEFINE_STATIC_KEY_FALSE(page_owner_free_stack);
 
 static depot_stack_handle_t dummy_handle;
 static depot_stack_handle_t failure_handle;
@@ -46,6 +48,11 @@ static int __init early_page_owner_param(char *buf)
 	if (strcmp(buf, "on") == 0)
 		page_owner_disabled = false;
 
+	if (IS_ENABLED(CONFIG_KASAN)) {
+		page_owner_disabled = false;
+		page_owner_free_stack_disabled = false;
+	}
+
 	return 0;
 }
 early_param("page_owner", early_page_owner_param);
@@ -91,6 +98,8 @@ static void init_page_owner(void)
 	register_failure_stack();
 	register_early_stack();
 	static_branch_enable(&page_owner_inited);
+	if (!page_owner_free_stack_disabled)
+		static_branch_enable(&page_owner_free_stack);
 	init_early_allocated_pages();
 }
 
@@ -148,11 +157,11 @@ void __reset_page_owner(struct page *page, unsigned int order)
 {
 	int i;
 	struct page_ext *page_ext;
-#ifdef CONFIG_DEBUG_PAGEALLOC
+#ifdef CONFIG_PAGE_OWNER_FREE_STACK
 	depot_stack_handle_t handle = 0;
 	struct page_owner *page_owner;
 
-	if (debug_pagealloc_enabled())
+	if (static_branch_unlikely(&page_owner_free_stack))
 		handle = save_stack(GFP_NOWAIT | __GFP_NOWARN);
 #endif
 
@@ -161,8 +170,8 @@ void __reset_page_owner(struct page *page, unsigned int order)
 		if (unlikely(!page_ext))
 			continue;
 		__clear_bit(PAGE_EXT_OWNER_ACTIVE, &page_ext->flags);
-#ifdef CONFIG_DEBUG_PAGEALLOC
-		if (debug_pagealloc_enabled()) {
+#ifdef CONFIG_PAGE_OWNER_FREE_STACK
+		if (static_branch_unlikely(&page_owner_free_stack)) {
 			page_owner = get_page_owner(page_ext);
 			page_owner->free_handle = handle;
 		}
@@ -451,14 +460,16 @@ void __dump_page_owner(struct page *page)
 		stack_trace_print(entries, nr_entries, 0);
 	}
 
-#ifdef CONFIG_DEBUG_PAGEALLOC
-	handle = READ_ONCE(page_owner->free_handle);
-	if (!handle) {
-		pr_alert("page_owner free stack trace missing\n");
-	} else {
-		nr_entries = stack_depot_fetch(handle, &entries);
-		pr_alert("page last free stack trace:\n");
-		stack_trace_print(entries, nr_entries, 0);
+#ifdef CONFIG_PAGE_OWNER_FREE_STACK
+	if (static_branch_unlikely(&page_owner_free_stack)) {
+		handle = READ_ONCE(page_owner->free_handle);
+		if (!handle) {
+			pr_alert("page_owner free stack trace missing\n");
+		} else {
+			nr_entries = stack_depot_fetch(handle, &entries);
+			pr_alert("page last free stack trace:\n");
+			stack_trace_print(entries, nr_entries, 0);
+		}
 	}
 #endif
 
-- 
2.23.0


