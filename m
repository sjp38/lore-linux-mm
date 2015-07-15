Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 9D2D52802C4
	for <linux-mm@kvack.org>; Wed, 15 Jul 2015 19:49:51 -0400 (EDT)
Received: by pdbep18 with SMTP id ep18so34308894pdb.1
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 16:49:51 -0700 (PDT)
Received: from mail-pa0-x233.google.com (mail-pa0-x233.google.com. [2607:f8b0:400e:c03::233])
        by mx.google.com with ESMTPS id w10si9846890pdo.223.2015.07.15.16.49.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Jul 2015 16:49:50 -0700 (PDT)
Received: by pachj5 with SMTP id hj5so32076103pac.3
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 16:49:50 -0700 (PDT)
Date: Thu, 16 Jul 2015 08:49:55 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v2] mm: show proportional swap share of the mapping
Message-ID: <20150715234955.GB988@bgram>
References: <1434373614-1041-1-git-send-email-minchan@kernel.org>
 <20150714140708.c7a406aa2bf43ecf73844e96@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150714140708.c7a406aa2bf43ecf73844e96@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Bongkyu Kim <bongkyu.kim@lge.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Jonathan Corbet <corbet@lwn.net>

On Tue, Jul 14, 2015 at 02:07:08PM -0700, Andrew Morton wrote:
> On Mon, 15 Jun 2015 22:06:54 +0900 Minchan Kim <minchan@kernel.org> wrote:
> 
> > We want to know per-process workingset size for smart memory management
> > on userland and we use swap(ex, zram) heavily to maximize memory efficiency
> > so workingset includes swap as well as RSS.
> > 
> > On such system, if there are lots of shared anonymous pages, it's
> > really hard to figure out exactly how many each process consumes
> > memory(ie, rss + wap) if the system has lots of shared anonymous
> > memory(e.g, android).
> > 
> > This patch introduces SwapPss field on /proc/<pid>/smaps so we can get
> > more exact workingset size per process.
> > 
> > ...
> >
> > +int swp_swapcount(swp_entry_t entry)
> > +{
> > +	int count, tmp_count, n;
> > +	struct swap_info_struct *p;
> > +	struct page *page;
> > +	pgoff_t offset;
> > +	unsigned char *map;
> > +
> > +	p = swap_info_get(entry);
> > +	if (!p)
> > +		return 0;
> > +
> > +	count = swap_count(p->swap_map[swp_offset(entry)]);
> > +	if (!(count & COUNT_CONTINUED))
> > +		goto out;
> > +
> > +	count &= ~COUNT_CONTINUED;
> > +	n = SWAP_MAP_MAX + 1;
> > +
> > +	offset = swp_offset(entry);
> > +	page = vmalloc_to_page(p->swap_map + offset);
> > +	offset &= ~PAGE_MASK;
> > +	VM_BUG_ON(page_private(page) != SWP_CONTINUED);
> > +
> > +	do {
> > +		page = list_entry(page->lru.next, struct page, lru);
> > +		map = kmap_atomic(page) + offset;
> > +		tmp_count = *map;
> > +		kunmap_atomic(map);
> 
> A little thing: I've never liked the way that kunmap_atomic() accepts
> any address within the page.  It's weird, and it makes the reviewer
> have to scramble around to make sure the offset can never be >=
> PAGE_SIZE.

Very ture. I was bitten by that.
Thanks for the clean up.

> 
> We can easily avoid doing it here:
> 
> --- a/mm/swapfile.c~mm-show-proportional-swap-share-of-the-mapping-fix
> +++ a/mm/swapfile.c
> @@ -904,8 +904,8 @@ int swp_swapcount(swp_entry_t entry)
>  
>  	do {
>  		page = list_entry(page->lru.next, struct page, lru);
> -		map = kmap_atomic(page) + offset;
> -		tmp_count = *map;
> +		map = kmap_atomic(page);
> +		tmp_count = map[offset];
>  		kunmap_atomic(map);
>  
>  		count += (tmp_count & ~COUNT_CONTINUED) * n;
> 
> > +		count += (tmp_count & ~COUNT_CONTINUED) * n;
> > +		n *= (SWAP_CONT_MAX + 1);
> > +	} while (tmp_count & COUNT_CONTINUED);
> > +out:
> > +	spin_unlock(&p->lock);
> > +	return count;
> > +}
> >

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
