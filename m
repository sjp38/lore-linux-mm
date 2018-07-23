Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 225116B000A
	for <linux-mm@kvack.org>; Mon, 23 Jul 2018 18:55:00 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id g5-v6so1164161pgv.12
        for <linux-mm@kvack.org>; Mon, 23 Jul 2018 15:55:00 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 64-v6si10024702pgd.509.2018.07.23.15.54.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 23 Jul 2018 15:54:58 -0700 (PDT)
Date: Mon, 23 Jul 2018 15:54:54 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: kernel BUG at mm/shmem.c:LINE!
Message-ID: <20180723225454.GC18236@bombadil.infradead.org>
References: <000000000000d624c605705e9010@google.com>
 <20180709143610.GD2662@bombadil.infradead.org>
 <alpine.LSU.2.11.1807221856350.5536@eggly.anvils>
 <20180723140150.GA31843@bombadil.infradead.org>
 <alpine.LSU.2.11.1807231111310.1698@eggly.anvils>
 <20180723203628.GA18236@bombadil.infradead.org>
 <alpine.LSU.2.11.1807231531240.2545@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1807231531240.2545@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: syzbot <syzbot+b8e0dfee3fd8c9012771@syzkaller.appspotmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, syzkaller-bugs@googlegroups.com

On Mon, Jul 23, 2018 at 03:42:22PM -0700, Hugh Dickins wrote:
> On Mon, 23 Jul 2018, Matthew Wilcox wrote:
> > I figured out a fix and pushed it to the 'ida' branch in
> > git://git.infradead.org/users/willy/linux-dax.git
> 
> Great, thanks a lot for sorting that out so quickly. But I've cloned
> the tree and don't see today's patch, so assume you've folded the fix
> into an existing commit? If possible, please append the diff of today's
> fix to this thread so that we can try it out. Or if that's difficult,
> please at least tell which files were modified, then I can probably
> work it out from the diff of those files against mmotm.

Sure!  It's just this:

diff --git a/lib/xarray.c b/lib/xarray.c
index 32a9c2a6a9e9..383c410997eb 100644
--- a/lib/xarray.c
+++ b/lib/xarray.c
@@ -660,6 +660,8 @@ void xas_create_range(struct xa_state *xas)
 	unsigned char sibs = xas->xa_sibs;
 
 	xas->xa_index |= ((sibs + 1) << shift) - 1;
+	if (!xas_top(xas->xa_node) && xas->xa_node->shift == xas->xa_shift)
+		xas->xa_offset |= sibs;
 	xas->xa_shift = 0;
 	xas->xa_sibs = 0;
 

The only other things changed are the test suite, and removing an
unnecessary change, so they can be ignored:

diff --git a/lib/test_xarray.c b/lib/test_xarray.c
index 8a67d4bb1788..ec06c3ca19e9 100644
--- a/lib/test_xarray.c
+++ b/lib/test_xarray.c
@@ -695,19 +695,20 @@ static noinline void check_move(struct xarray *xa)
 		check_move_small(xa, (1UL << i) - 1);
 }
 
-static noinline void check_create_range_1(struct xarray *xa,
+static noinline void xa_store_many_order(struct xarray *xa,
 		unsigned long index, unsigned order)
 {
 	XA_STATE_ORDER(xas, xa, index, order);
-	unsigned int i;
+	unsigned int i = 0;
 
 	do {
 		xas_lock(&xas);
+		XA_BUG_ON(xa, xas_find_conflict(&xas));
 		xas_create_range(&xas);
 		if (xas_error(&xas))
 			goto unlock;
 		for (i = 0; i < (1U << order); i++) {
-			xas_store(&xas, xa + i);
+			XA_BUG_ON(xa, xas_store(&xas, xa_mk_value(index + i)));
 			xas_next(&xas);
 		}
 unlock:
@@ -715,7 +716,29 @@ static noinline void check_create_range_1(struct xarray *xa,
 	} while (xas_nomem(&xas, GFP_KERNEL));
 
 	XA_BUG_ON(xa, xas_error(&xas));
-	xa_destroy(xa);
+}
+
+static noinline void check_create_range_1(struct xarray *xa,
+		unsigned long index, unsigned order)
+{
+	unsigned long i;
+
+	xa_store_many_order(xa, index, order);
+	for (i = index; i < index + (1UL << order); i++)
+		xa_erase_value(xa, i);
+	XA_BUG_ON(xa, !xa_empty(xa));
+}
+
+static noinline void check_create_range_2(struct xarray *xa, unsigned order)
+{
+	unsigned long i;
+	unsigned long nr = 1UL << order;
+
+	for (i = 0; i < nr * nr; i += nr)
+		xa_store_many_order(xa, i, order);
+	for (i = 0; i < nr * nr; i++)
+		xa_erase_value(xa, i);
+	XA_BUG_ON(xa, !xa_empty(xa));
 }
 
 static noinline void check_create_range(struct xarray *xa)
@@ -729,6 +752,8 @@ static noinline void check_create_range(struct xarray *xa)
 		check_create_range_1(xa, 2U << order, order);
 		check_create_range_1(xa, 3U << order, order);
 		check_create_range_1(xa, 1U << 24, order);
+		if (order < 10)
+			check_create_range_2(xa, order);
 	}
 }
 
diff --git a/mm/shmem.c b/mm/shmem.c
index af2d7fa05af7..3ac507803787 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -589,8 +589,8 @@ static int shmem_add_to_page_cache(struct page *page,
 	VM_BUG_ON(expected && PageTransHuge(page));
 
 	page_ref_add(page, nr);
-	page->index = index;
 	page->mapping = mapping;
+	page->index = index;
 
 	do {
 		void *entry;
