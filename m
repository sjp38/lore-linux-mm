Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 049C428024D
	for <linux-mm@kvack.org>; Tue, 14 Jul 2015 17:07:11 -0400 (EDT)
Received: by pdbqm3 with SMTP id qm3so11862875pdb.0
        for <linux-mm@kvack.org>; Tue, 14 Jul 2015 14:07:10 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id rx6si3668666pab.219.2015.07.14.14.07.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Jul 2015 14:07:10 -0700 (PDT)
Date: Tue, 14 Jul 2015 14:07:08 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] mm: show proportional swap share of the mapping
Message-Id: <20150714140708.c7a406aa2bf43ecf73844e96@linux-foundation.org>
In-Reply-To: <1434373614-1041-1-git-send-email-minchan@kernel.org>
References: <1434373614-1041-1-git-send-email-minchan@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Bongkyu Kim <bongkyu.kim@lge.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Jonathan Corbet <corbet@lwn.net>

On Mon, 15 Jun 2015 22:06:54 +0900 Minchan Kim <minchan@kernel.org> wrote:

> We want to know per-process workingset size for smart memory management
> on userland and we use swap(ex, zram) heavily to maximize memory efficiency
> so workingset includes swap as well as RSS.
> 
> On such system, if there are lots of shared anonymous pages, it's
> really hard to figure out exactly how many each process consumes
> memory(ie, rss + wap) if the system has lots of shared anonymous
> memory(e.g, android).
> 
> This patch introduces SwapPss field on /proc/<pid>/smaps so we can get
> more exact workingset size per process.
> 
> ...
>
> +int swp_swapcount(swp_entry_t entry)
> +{
> +	int count, tmp_count, n;
> +	struct swap_info_struct *p;
> +	struct page *page;
> +	pgoff_t offset;
> +	unsigned char *map;
> +
> +	p = swap_info_get(entry);
> +	if (!p)
> +		return 0;
> +
> +	count = swap_count(p->swap_map[swp_offset(entry)]);
> +	if (!(count & COUNT_CONTINUED))
> +		goto out;
> +
> +	count &= ~COUNT_CONTINUED;
> +	n = SWAP_MAP_MAX + 1;
> +
> +	offset = swp_offset(entry);
> +	page = vmalloc_to_page(p->swap_map + offset);
> +	offset &= ~PAGE_MASK;
> +	VM_BUG_ON(page_private(page) != SWP_CONTINUED);
> +
> +	do {
> +		page = list_entry(page->lru.next, struct page, lru);
> +		map = kmap_atomic(page) + offset;
> +		tmp_count = *map;
> +		kunmap_atomic(map);

A little thing: I've never liked the way that kunmap_atomic() accepts
any address within the page.  It's weird, and it makes the reviewer
have to scramble around to make sure the offset can never be >=
PAGE_SIZE.

We can easily avoid doing it here:

--- a/mm/swapfile.c~mm-show-proportional-swap-share-of-the-mapping-fix
+++ a/mm/swapfile.c
@@ -904,8 +904,8 @@ int swp_swapcount(swp_entry_t entry)
 
 	do {
 		page = list_entry(page->lru.next, struct page, lru);
-		map = kmap_atomic(page) + offset;
-		tmp_count = *map;
+		map = kmap_atomic(page);
+		tmp_count = map[offset];
 		kunmap_atomic(map);
 
 		count += (tmp_count & ~COUNT_CONTINUED) * n;

> +		count += (tmp_count & ~COUNT_CONTINUED) * n;
> +		n *= (SWAP_CONT_MAX + 1);
> +	} while (tmp_count & COUNT_CONTINUED);
> +out:
> +	spin_unlock(&p->lock);
> +	return count;
> +}
>
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
