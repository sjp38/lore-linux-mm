Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5BD8B6B016B
	for <linux-mm@kvack.org>; Thu, 25 Aug 2011 20:03:05 -0400 (EDT)
Date: Thu, 25 Aug 2011 17:03:02 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -v2] debug-pagealloc: add support for highmem pages
Message-Id: <20110825170302.81ed210c.akpm@linux-foundation.org>
In-Reply-To: <1314281649-21508-1-git-send-email-akinobu.mita@gmail.com>
References: <1314281649-21508-1-git-send-email-akinobu.mita@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Akinobu Mita <akinobu.mita@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 25 Aug 2011 23:14:09 +0900
Akinobu Mita <akinobu.mita@gmail.com> wrote:

> This adds support for highmem pages poisoning and verification to the
> debug-pagealloc feature for no-architecture support.
> 

Sorry, I had a brainfart.  kmap_atomic() internally does the
preempt_disable() (actually pagefault_disable()).

--- a/mm/debug-pagealloc.c~debug-pagealloc-add-support-for-highmem-pages-fix
+++ a/mm/debug-pagealloc.c
@@ -23,14 +23,11 @@ static inline bool page_poison(struct pa
 
 static void poison_page(struct page *page)
 {
-	void *addr;
+	void *addr = kmap_atomic(page);
 
-	preempt_disable();
-	addr = kmap_atomic(page);
 	set_page_poison(page);
 	memset(addr, PAGE_POISON, PAGE_SIZE);
 	kunmap_atomic(addr);
-	preempt_enable();
 }
 
 static void poison_pages(struct page *page, int n)
@@ -82,12 +79,10 @@ static void unpoison_page(struct page *p
 	if (!page_poison(page))
 		return;
 
-	preempt_disable();
 	addr = kmap_atomic(page);
 	check_poison_mem(addr, PAGE_SIZE);
 	clear_page_poison(page);
 	kunmap_atomic(addr);
-	preempt_enable();
 }
 
 static void unpoison_pages(struct page *page, int n)
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
