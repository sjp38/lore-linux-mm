Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f174.google.com (mail-ie0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id 49B0A6B0032
	for <linux-mm@kvack.org>; Fri,  9 Jan 2015 19:24:22 -0500 (EST)
Received: by mail-ie0-f174.google.com with SMTP id at20so17885891iec.5
        for <linux-mm@kvack.org>; Fri, 09 Jan 2015 16:24:22 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id ag10si7856683icc.28.2015.01.09.16.24.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Jan 2015 16:24:21 -0800 (PST)
Date: Fri, 9 Jan 2015 16:24:19 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/page_alloc.c: drop dead destroy_compound_page()
Message-Id: <20150109162419.b52796aee45d6747399d2ebb@linux-foundation.org>
In-Reply-To: <20150108141004.AB3461A2@black.fi.intel.com>
References: <1420458382-161038-1-git-send-email-kirill.shutemov@linux.intel.com>
	<20150107134039.25d4edfad92b62f3eee8b570@linux-foundation.org>
	<20150108141004.AB3461A2@black.fi.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: aarcange@redhat.com, linux-mm@kvack.org

On Thu,  8 Jan 2015 16:10:04 +0200 (EET) "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:

> Something like this?
> 
> >From 5fd481c1c521112e9cea407f5a2644c9f93d0e14 Mon Sep 17 00:00:00 2001
> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Date: Thu, 8 Jan 2015 15:59:23 +0200
> Subject: [PATCH] mm: more checks on free_pages_prepare() for tail pages
> 
> Apart form being dead, destroy_compound_page() did some potentially
> useful checks. Let's re-introduce them in free_pages_prepare(), where
> they can be acctually triggered.
> 
> compound_order() assert is already in free_pages_prepare(). We have few
> checks for tail pages left.
> 

I'm thinking we avoid the overhead unless CONFIG_DEBUG_VM?


From: Andrew Morton <akpm@linux-foundation.org>
Subject: mm-more-checks-on-free_pages_prepare-for-tail-pages-fix

Make it conditional on CONFIG_DEBUG_VM, make free_tail_pages_check()
return void.

Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/page_alloc.c |   16 +++++++++++-----
 1 file changed, 11 insertions(+), 5 deletions(-)

diff -puN mm/page_alloc.c~mm-more-checks-on-free_pages_prepare-for-tail-pages-fix mm/page_alloc.c
--- a/mm/page_alloc.c~mm-more-checks-on-free_pages_prepare-for-tail-pages-fix
+++ a/mm/page_alloc.c
@@ -764,20 +764,26 @@ static void free_one_page(struct zone *z
 	spin_unlock(&zone->lock);
 }
 
-static int free_tail_pages_check(struct page *head_page, struct page *page)
+#ifdef CONFIG_DEBUG_VM
+static void free_tail_pages_check(struct page *head_page, struct page *page)
 {
 	if (!IS_ENABLED(CONFIG_DEBUG_VM))
-		return 0;
+		return;
 	if (unlikely(!PageTail(page))) {
 		bad_page(page, "PageTail not set", 0);
-		return 1;
+		return;
 	}
 	if (unlikely(page->first_page != head_page)) {
 		bad_page(page, "first_page not consistent", 0);
-		return 1;
+		return;
 	}
-	return 0;
 }
+#else
+static inline void free_tail_pages_check(struct page *head_page,
+					 struct page *page)
+{
+}
+#endif
 
 static bool free_pages_prepare(struct page *page, unsigned int order)
 {
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
