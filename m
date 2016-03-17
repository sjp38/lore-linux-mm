Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f175.google.com (mail-ig0-f175.google.com [209.85.213.175])
	by kanga.kvack.org (Postfix) with ESMTP id C8FF06B007E
	for <linux-mm@kvack.org>; Thu, 17 Mar 2016 18:16:33 -0400 (EDT)
Received: by mail-ig0-f175.google.com with SMTP id kc10so8156818igb.0
        for <linux-mm@kvack.org>; Thu, 17 Mar 2016 15:16:33 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id f5si12716483ioj.36.2016.03.17.15.16.32
        for <linux-mm@kvack.org>;
        Thu, 17 Mar 2016 15:16:33 -0700 (PDT)
Date: Fri, 18 Mar 2016 07:17:31 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v1 11/19] zsmalloc: squeeze freelist into page->mapping
Message-ID: <20160317221731.GA2154@bbox>
References: <1457681423-26664-1-git-send-email-minchan@kernel.org>
 <1457681423-26664-12-git-send-email-minchan@kernel.org>
 <20160315064053.GF1464@swordfish>
 <20160315065126.GA3039@bbox>
 <56EA9E8E.5040206@hisilicon.com>
MIME-Version: 1.0
In-Reply-To: <56EA9E8E.5040206@hisilicon.com>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: YiPing Xu <xuyiping@hisilicon.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jlayton@poochiereds.net, bfields@fieldses.org, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, koct9i@gmail.com, aquini@redhat.com, virtualization@lists.linux-foundation.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, rknize@motorola.com, Rik van Riel <riel@redhat.com>, Gioh Kim <gurugio@hanmail.net>

On Thu, Mar 17, 2016 at 08:09:50PM +0800, YiPing Xu wrote:
> 
> 
> On 2016/3/15 14:51, Minchan Kim wrote:
> >On Tue, Mar 15, 2016 at 03:40:53PM +0900, Sergey Senozhatsky wrote:
> >>On (03/11/16 16:30), Minchan Kim wrote:
> >>>-static void *location_to_obj(struct page *page, unsigned long obj_idx)
> >>>+static void objidx_to_page_and_ofs(struct size_class *class,
> >>>+				struct page *first_page,
> >>>+				unsigned long obj_idx,
> >>>+				struct page **obj_page,
> >>>+				unsigned long *ofs_in_page)
> >>
> >>this looks big; 5 params, function "returning" both page and offset...
> >>any chance to split it in two steps, perhaps?
> >
> >Yes, it's rather ugly but I don't have a good idea.
> >Feel free to suggest if you have a better idea.
> >
> >>
> >>besides, it is more intuitive (at least to me) when 'offset'
> >>shortened to 'offt', not 'ofs'.
> 
> 	the purpose to get 'obj_page' and 'ofs_in_page' is to map the page
> and get the meta-data pointer in the page, so, we can finish this in
> a single function.
> 
> 	just like this, and maybe we could have a better function name
> 
> static unsigned long *map_handle(struct size_class *class,
> 	struct page *first_page, unsigned long obj_idx)
> {
> 	struct page *cursor = first_page;
> 	unsigned long offset = obj_idx * class->size;
> 	int nr_page = offset >> PAGE_SHIFT;
> 	unsigned long offset_in_page = offset & ~PAGE_MASK;
> 	void *addr;
> 	int i;
> 
> 	if (class->huge) {
> 		VM_BUG_ON_PAGE(!is_first_page(page), page);
> 		return &page_private(page);
> 	}
> 
> 	for (i = 0; i < nr_page; i++)
> 		cursor = get_next_page(cursor);
> 
> 	addr = kmap_atomic(cursor);
> 	
> 	return addr + offset_in_page;
> }
> 
> static void unmap_handle(unsigned long *addr)
> {
> 	if (class->huge) {
> 		return;
> 	}
> 
> 	kunmap_atomic(addr & ~PAGE_MASK);
> }
> 
> 	all functions called "objidx_to_page_and_ofs" could use it like
> this, for example:
> 
> static unsigned long handle_from_obj(struct size_class *class,
> 				struct page *first_page, int obj_idx)
> {
> 	unsigned long *head = map_handle(class, first_page, obj_idx);
> 
> 	if (*head & OBJ_ALLOCATED_TAG)
> 		handle = *head & ~OBJ_ALLOCATED_TAG;
> 
> 	unmap_handle(*head);
> 
> 	return handle;
> }
> 
> 	'freeze_zspage', u'nfreeze_zspage' use it in the same way.
> 
> 	but in 'obj_malloc', we still have to get the page to get obj.
> 
> 	obj = location_to_obj(m_page, obj);

Yes, That's why I didn't use such pattern. I didn't want to
add unnecessary overhead in that hot path.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
