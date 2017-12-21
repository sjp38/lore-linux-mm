Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3C5506B0038
	for <linux-mm@kvack.org>; Wed, 20 Dec 2017 19:01:47 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id f64so17270853pfd.6
        for <linux-mm@kvack.org>; Wed, 20 Dec 2017 16:01:47 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id a64si13949456pfc.349.2017.12.20.16.01.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 20 Dec 2017 16:01:45 -0800 (PST)
Date: Wed, 20 Dec 2017 16:01:44 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v2 6/8] mm: Store compound_dtor / compound_order as bytes
Message-ID: <20171221000144.GB2980@bombadil.infradead.org>
References: <20171220155552.15884-1-willy@infradead.org>
 <20171220155552.15884-7-willy@infradead.org>
 <20171220153907.7f3994967cba32c6f654982c@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171220153907.7f3994967cba32c6f654982c@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>

On Wed, Dec 20, 2017 at 03:39:07PM -0800, Andrew Morton wrote:
> On Wed, 20 Dec 2017 07:55:50 -0800 Matthew Wilcox <willy@infradead.org> wrote:
> 
> > From: Matthew Wilcox <mawilcox@microsoft.com>
> > 
> > Neither of these values get even close to 256; compound_dtor is
> > currently at a maximum of 3, and compound_order can't be over 64.
> > No machine has inefficient access to bytes since EV5, and while
> > those are still supported, we don't optimise for them any more.
> 
> So we couild fit compound_dtor and compound_order into a single byte if
> desperate?

Yes ... unless we find another kind of destructor we need for compound pages.

> > This does not shrink struct page, but it removes an ifdef and
> > frees up 2-6 bytes for future use.
> 
> Can we add a little comment telling readers "hey there's a gap here!"?

I think they should have to work to find it!

Here's a replacement patch:

From: Matthew Wilcox <mawilcox@microsoft.com>
Date: Fri, 15 Dec 2017 23:29:11 -0500
Subject: [PATCH] mm: Store compound_dtor / compound_order as bytes

Neither of these values get even close to 256; compound_dtor is
currently at a maximum of 3, and compound_order can't be over 64.
No machine has inefficient access to bytes since EV5, and while
those are still supported, we don't optimise for them any more.
This does not shrink struct page, but it removes an ifdef and
frees up 2-6 bytes for future use.

diff of pahole output:

@@ -34,8 +34,8 @@
 		struct callback_head callback_head;      /*    32    16 */
 		struct {
 			long unsigned int compound_head; /*    32     8 */
-			unsigned int compound_dtor;      /*    40     4 */
-			unsigned int compound_order;     /*    44     4 */
+			unsigned char compound_dtor;     /*    40     1 */
+			unsigned char compound_order;    /*    41     1 */
 		};                                       /*    32    16 */
 	};                                               /*    32    16 */
 	union {

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Acked-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/mm_types.h | 16 +++-------------
 1 file changed, 3 insertions(+), 13 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 5521c9799c50..3e7e99784656 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -136,19 +136,9 @@ struct page {
 			unsigned long compound_head; /* If bit zero is set */
 
 			/* First tail page only */
-#ifdef CONFIG_64BIT
-			/*
-			 * On 64 bit system we have enough space in struct page
-			 * to encode compound_dtor and compound_order with
-			 * unsigned int. It can help compiler generate better or
-			 * smaller code on some archtectures.
-			 */
-			unsigned int compound_dtor;
-			unsigned int compound_order;
-#else
-			unsigned short int compound_dtor;
-			unsigned short int compound_order;
-#endif
+			unsigned char compound_dtor;
+			unsigned char compound_order;
+			/* two/six bytes available here */
 		};
 
 #if defined(CONFIG_TRANSPARENT_HUGEPAGE) && USE_SPLIT_PMD_PTLOCKS
-- 
2.15.1

Seriously, this is only available in the first tail page of a compound
page, so they'll have to go through Kirill to have it assigned to them
... I don't want to pretend like it's available for general use.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
