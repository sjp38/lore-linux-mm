Received: by nproxy.gmail.com with SMTP id l23so218022nfc
        for <linux-mm@kvack.org>; Thu, 08 Dec 2005 11:20:33 -0800 (PST)
Message-ID: <84144f020512081120u428ebd6eud0566a7d57a7726a@mail.gmail.com>
Date: Thu, 8 Dec 2005 21:20:33 +0200
From: Pekka Enberg <penberg@cs.helsinki.fi>
Subject: Re: allowed pages in the block later, was Re: [Ext2-devel] [PATCH] ext3: avoid sending down non-refcounted pages
In-Reply-To: <439879ED.5050706@cs.wisc.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
References: <20051208180900T.fujita.tomonori@lab.ntt.co.jp>
	 <20051208101833.GM14509@schatzie.adilger.int>
	 <20051208134239.GA13376@infradead.org> <439878E4.6060505@cs.wisc.edu>
	 <439879ED.5050706@cs.wisc.edu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Christie <michaelc@cs.wisc.edu>
Cc: open-iscsi@googlegroups.com, Christoph Hellwig <hch@infradead.org>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, linux-fsdevel@vger.kernel.org, ext2-devel@lists.sourceforge.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi,

On 12/8/05, Mike Christie <michaelc@cs.wisc.edu> wrote:
> Or there is not a way to do kmalloc(GFP_BLK) that gives us the right
> type of memory is there?

The slab allocator uses page->lru for special purposes. See
page_{set|get}_{cache|slab} in mm/slab.c. They are used by kfree(),
ksize() and slab debugging code to lookup the cache and slab an void
pointer belongs to.

But, if you just need put_page and get_page, couldn't you do something
like the following?

                                       Pekka

Index: 2.6/mm/swap.c
===================================================================
--- 2.6.orig/mm/swap.c
+++ 2.6/mm/swap.c
@@ -36,6 +36,9 @@ int page_cluster;

 void put_page(struct page *page)
 {
+	if (unlikely(PageSlab(page)))
+		return;
+
 	if (unlikely(PageCompound(page))) {
 		page = (struct page *)page_private(page);
 		if (put_page_testzero(page)) {
Index: 2.6/include/linux/mm.h
===================================================================
--- 2.6.orig/include/linux/mm.h
+++ 2.6/include/linux/mm.h
@@ -322,6 +322,9 @@ static inline int page_count(struct page

 static inline void get_page(struct page *page)
 {
+	if (unlikely(PageSlab(page)))
+		return;
+
 	if (unlikely(PageCompound(page)))
 		page = (struct page *)page_private(page);
 	atomic_inc(&page->_count);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
