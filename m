Return-Path: <SRS0=haCV=WW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EF083C3A5A4
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 06:59:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 902732190F
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 06:59:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="a2U8wbAF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 902732190F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 004776B0528; Mon, 26 Aug 2019 02:59:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EF77F6B0529; Mon, 26 Aug 2019 02:59:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E0C936B052A; Mon, 26 Aug 2019 02:59:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0204.hostedemail.com [216.40.44.204])
	by kanga.kvack.org (Postfix) with ESMTP id BFB276B0528
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 02:59:57 -0400 (EDT)
Received: from smtpin03.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 5B384180AD7C1
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 06:59:57 +0000 (UTC)
X-FDA: 75863679234.03.flock83_73f923b130f5a
X-HE-Tag: flock83_73f923b130f5a
X-Filterd-Recvd-Size: 5996
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by imf19.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 06:59:56 +0000 (UTC)
Received: from guoren-Inspiron-7460.lan (unknown [223.93.147.148])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id D782C217F4;
	Mon, 26 Aug 2019 06:59:52 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1566802795;
	bh=a5Ew7eb6cqPDgQY6v0geKQo8QWx+WuyGsAB/zRhoQ/I=;
	h=From:To:Cc:Subject:Date:From;
	b=a2U8wbAFJLIR89Zxq31tq9JRzjmOOjQJHb7wO5PTtR/bOZKg+M/C6mhPXZDDh007f
	 r8q1YkZE0lzMS1O8W5bStqwkfe3mXUzmWAbDTUr2qH96+VAsPzDuWkPioZu+WjAdhs
	 kri6KgWXXub6+7p2hRaG7E2NsdgXBq+M+xgvOta8=
From: guoren@kernel.org
To: arnd@arndb.de,
	hch@infradead.org
Cc: linux-kernel@vger.kernel.org,
	linux-arch@vger.kernel.org,
	linux-csky@vger.kernel.org,
	linux-mm@kvack.org,
	Guo Ren <ren_guo@c-sky.com>
Subject: [RESEND PATCH V2] csky: Fixup 610 vipt cache flush mechanism
Date: Mon, 26 Aug 2019 14:59:33 +0800
Message-Id: <1566802773-24707-1-git-send-email-guoren@kernel.org>
X-Mailer: git-send-email 2.7.4
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Guo Ren <ren_guo@c-sky.com>

610 has vipt aliasing issue, so we need to finish the cache flush
apis mentioned in cachetlb.rst to avoid data corruption.

Here is the list of modified apis in the patch:

 - flush_kernel_dcache_page      (new add)
 - flush_dcache_mmap_lock        (new add)
 - flush_dcache_mmap_unlock      (new add)
 - flush_kernel_vmap_range       (new add)
 - invalidate_kernel_vmap_range  (new add)
 - flush_anon_page               (new add)
 - flush_cache_range             (new add)
 - flush_cache_vmap              (flush all)
 - flush_cache_vunmap            (flush all)
 - flush_cache_mm                (only dcache flush)
 - flush_icache_page             (just nop)
 - copy_from_user_page           (remove no need flush)
 - copy_to_user_page             (remove no need flush)

Change to V2:
 - Fixup compile error with xa_lock*(&mapping->i_pages)

Signed-off-by: Guo Ren <ren_guo@c-sky.com>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: Christoph Hellwig <hch@infradead.org>
---
 arch/csky/abiv1/cacheflush.c         | 20 ++++++++++++++++++
 arch/csky/abiv1/inc/abi/cacheflush.h | 41 +++++++++++++++++++++++++-----------
 2 files changed, 49 insertions(+), 12 deletions(-)

diff --git a/arch/csky/abiv1/cacheflush.c b/arch/csky/abiv1/cacheflush.c
index fee99fc..9f1fe80 100644
--- a/arch/csky/abiv1/cacheflush.c
+++ b/arch/csky/abiv1/cacheflush.c
@@ -54,3 +54,23 @@ void update_mmu_cache(struct vm_area_struct *vma, unsigned long addr,
 			icache_inv_all();
 	}
 }
+
+void flush_kernel_dcache_page(struct page *page)
+{
+	struct address_space *mapping;
+
+	mapping = page_mapping_file(page);
+
+	if (!mapping || mapping_mapped(mapping))
+		dcache_wbinv_all();
+}
+EXPORT_SYMBOL(flush_kernel_dcache_page);
+
+void flush_cache_range(struct vm_area_struct *vma, unsigned long start,
+	unsigned long end)
+{
+	dcache_wbinv_all();
+
+	if (vma->vm_flags & VM_EXEC)
+		icache_inv_all();
+}
diff --git a/arch/csky/abiv1/inc/abi/cacheflush.h b/arch/csky/abiv1/inc/abi/cacheflush.h
index fce5604..79ef9e8 100644
--- a/arch/csky/abiv1/inc/abi/cacheflush.h
+++ b/arch/csky/abiv1/inc/abi/cacheflush.h
@@ -4,26 +4,49 @@
 #ifndef __ABI_CSKY_CACHEFLUSH_H
 #define __ABI_CSKY_CACHEFLUSH_H
 
-#include <linux/compiler.h>
+#include <linux/mm.h>
 #include <asm/string.h>
 #include <asm/cache.h>
 
 #define ARCH_IMPLEMENTS_FLUSH_DCACHE_PAGE 1
 extern void flush_dcache_page(struct page *);
 
-#define flush_cache_mm(mm)			cache_wbinv_all()
+#define flush_cache_mm(mm)			dcache_wbinv_all()
 #define flush_cache_page(vma, page, pfn)	cache_wbinv_all()
 #define flush_cache_dup_mm(mm)			cache_wbinv_all()
 
+#define ARCH_HAS_FLUSH_KERNEL_DCACHE_PAGE
+extern void flush_kernel_dcache_page(struct page *);
+
+#define flush_dcache_mmap_lock(mapping)		xa_lock_irq(&mapping->i_pages)
+#define flush_dcache_mmap_unlock(mapping)	xa_unlock_irq(&mapping->i_pages)
+
+static inline void flush_kernel_vmap_range(void *addr, int size)
+{
+	dcache_wbinv_all();
+}
+static inline void invalidate_kernel_vmap_range(void *addr, int size)
+{
+	dcache_wbinv_all();
+}
+
+#define ARCH_HAS_FLUSH_ANON_PAGE
+static inline void flush_anon_page(struct vm_area_struct *vma,
+			 struct page *page, unsigned long vmaddr)
+{
+	if (PageAnon(page))
+		cache_wbinv_all();
+}
+
 /*
  * if (current_mm != vma->mm) cache_wbinv_range(start, end) will be broken.
  * Use cache_wbinv_all() here and need to be improved in future.
  */
-#define flush_cache_range(vma, start, end)	cache_wbinv_all()
-#define flush_cache_vmap(start, end)		cache_wbinv_range(start, end)
-#define flush_cache_vunmap(start, end)		cache_wbinv_range(start, end)
+extern void flush_cache_range(struct vm_area_struct *vma, unsigned long start, unsigned long end);
+#define flush_cache_vmap(start, end)		cache_wbinv_all()
+#define flush_cache_vunmap(start, end)		cache_wbinv_all()
 
-#define flush_icache_page(vma, page)		cache_wbinv_all()
+#define flush_icache_page(vma, page)		do {} while (0);
 #define flush_icache_range(start, end)		cache_wbinv_range(start, end)
 
 #define flush_icache_user_range(vma,page,addr,len) \
@@ -31,19 +54,13 @@ extern void flush_dcache_page(struct page *);
 
 #define copy_from_user_page(vma, page, vaddr, dst, src, len) \
 do { \
-	cache_wbinv_all(); \
 	memcpy(dst, src, len); \
-	cache_wbinv_all(); \
 } while (0)
 
 #define copy_to_user_page(vma, page, vaddr, dst, src, len) \
 do { \
-	cache_wbinv_all(); \
 	memcpy(dst, src, len); \
 	cache_wbinv_all(); \
 } while (0)
 
-#define flush_dcache_mmap_lock(mapping)		do {} while (0)
-#define flush_dcache_mmap_unlock(mapping)	do {} while (0)
-
 #endif /* __ABI_CSKY_CACHEFLUSH_H */
-- 
2.7.4


