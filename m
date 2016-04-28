Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 96E826B0005
	for <linux-mm@kvack.org>; Thu, 28 Apr 2016 17:20:26 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 203so165529534pfy.2
        for <linux-mm@kvack.org>; Thu, 28 Apr 2016 14:20:26 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id ah8si13593724pad.148.2016.04.28.14.20.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Apr 2016 14:20:25 -0700 (PDT)
Date: Thu, 28 Apr 2016 14:20:24 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [mmotm:master 190/376] mm/page_alloc.c:995: warning:
 'free_pages_prepare' declared inline after being called
Message-Id: <20160428142024.f8cde9819e9cd75cc6f1a670@linux-foundation.org>
In-Reply-To: <201604281203.VLTNjuRT%fengguang.wu@intel.com>
References: <201604281203.VLTNjuRT%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: kbuild-all@01.org, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Linux Memory Management List <linux-mm@kvack.org>

On Thu, 28 Apr 2016 12:22:04 +0800 kbuild test robot <fengguang.wu@intel.com> wrote:

> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   3eb62ac3b0fd7cf3656c0e2a4ed3b0833bb2e952
> commit: 2eb5dfe5f118fae2f81ddb971edb5280e1ce3e5e [190/376] mm-page_alloc-dont-duplicate-code-in-free_pcp_prepare-fix
> config: avr32-atngw100_defconfig (attached as .config)
> compiler: 
> reproduce:
>         wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         git checkout 2eb5dfe5f118fae2f81ddb971edb5280e1ce3e5e
>         # save the attached .config to linux build tree
>         make.cross ARCH=avr32 
> 
> All warnings (new ones prefixed by >>):
> 
> >> mm/page_alloc.c:995: warning: 'free_pages_prepare' declared inline after being called
>    mm/page_alloc.c:995: warning: previous declaration of 'free_pages_prepare' was here

grumble.  I'm not really sure what went wrong here.  Let's do it more
properlier.

--- a/mm/page_alloc.c~mm-page_alloc-dont-duplicate-code-in-free_pcp_prepare-fix-fix
+++ a/mm/page_alloc.c
@@ -991,8 +991,60 @@ out:
 	return ret;
 }
 
-static bool free_pages_prepare(struct page *page, unsigned int order,
-			       bool check_free);
+static __always_inline bool free_pages_prepare(struct page *page,
+					unsigned int order, bool check_free)
+{
+	int bad = 0;
+
+	VM_BUG_ON_PAGE(PageTail(page), page);
+
+	trace_mm_page_free(page, order);
+	kmemcheck_free_shadow(page, order);
+	kasan_free_pages(page, order);
+
+	/*
+	 * Check tail pages before head page information is cleared to
+	 * avoid checking PageCompound for order-0 pages.
+	 */
+	if (unlikely(order)) {
+		bool compound = PageCompound(page);
+		int i;
+
+		VM_BUG_ON_PAGE(compound && compound_order(page) != order, page);
+
+		for (i = 1; i < (1 << order); i++) {
+			if (compound)
+				bad += free_tail_pages_check(page, page + i);
+			if (unlikely(free_pages_check(page + i))) {
+				bad++;
+				continue;
+			}
+			(page + i)->flags &= ~PAGE_FLAGS_CHECK_AT_PREP;
+		}
+	}
+	if (PageAnonHead(page))
+		page->mapping = NULL;
+	if (check_free)
+		bad += free_pages_check(page);
+	if (bad)
+		return false;
+
+	page_cpupid_reset_last(page);
+	page->flags &= ~PAGE_FLAGS_CHECK_AT_PREP;
+	reset_page_owner(page, order);
+
+	if (!PageHighMem(page)) {
+		debug_check_no_locks_freed(page_address(page),
+					   PAGE_SIZE << order);
+		debug_check_no_obj_freed(page_address(page),
+					   PAGE_SIZE << order);
+	}
+	arch_free_page(page, order);
+	kernel_poison_pages(page, 1 << order, 0);
+	kernel_map_pages(page, 1 << order, 0);
+
+	return true;
+}
 
 #ifdef CONFIG_DEBUG_VM
 static inline bool free_pcp_prepare(struct page *page)
@@ -1179,61 +1231,6 @@ void __meminit reserve_bootmem_region(un
 	}
 }
 
-static __always_inline bool free_pages_prepare(struct page *page,
-					unsigned int order, bool check_free)
-{
-	int bad = 0;
-
-	VM_BUG_ON_PAGE(PageTail(page), page);
-
-	trace_mm_page_free(page, order);
-	kmemcheck_free_shadow(page, order);
-	kasan_free_pages(page, order);
-
-	/*
-	 * Check tail pages before head page information is cleared to
-	 * avoid checking PageCompound for order-0 pages.
-	 */
-	if (unlikely(order)) {
-		bool compound = PageCompound(page);
-		int i;
-
-		VM_BUG_ON_PAGE(compound && compound_order(page) != order, page);
-
-		for (i = 1; i < (1 << order); i++) {
-			if (compound)
-				bad += free_tail_pages_check(page, page + i);
-			if (unlikely(free_pages_check(page + i))) {
-				bad++;
-				continue;
-			}
-			(page + i)->flags &= ~PAGE_FLAGS_CHECK_AT_PREP;
-		}
-	}
-	if (PageAnonHead(page))
-		page->mapping = NULL;
-	if (check_free)
-		bad += free_pages_check(page);
-	if (bad)
-		return false;
-
-	page_cpupid_reset_last(page);
-	page->flags &= ~PAGE_FLAGS_CHECK_AT_PREP;
-	reset_page_owner(page, order);
-
-	if (!PageHighMem(page)) {
-		debug_check_no_locks_freed(page_address(page),
-					   PAGE_SIZE << order);
-		debug_check_no_obj_freed(page_address(page),
-					   PAGE_SIZE << order);
-	}
-	arch_free_page(page, order);
-	kernel_poison_pages(page, 1 << order, 0);
-	kernel_map_pages(page, 1 << order, 0);
-
-	return true;
-}
-
 static void __free_pages_ok(struct page *page, unsigned int order)
 {
 	unsigned long flags;
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
