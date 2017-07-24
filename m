Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id DA3796B02C3
	for <linux-mm@kvack.org>; Mon, 24 Jul 2017 09:06:24 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id v102so24666920wrb.2
        for <linux-mm@kvack.org>; Mon, 24 Jul 2017 06:06:24 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c6si12001219wrb.310.2017.07.24.06.06.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 24 Jul 2017 06:06:23 -0700 (PDT)
Date: Mon, 24 Jul 2017 15:06:13 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 4/4] mm, page_ext: move page_ext_init() after
 page_alloc_init_late()
Message-ID: <20170724130613.GK25221@dhcp22.suse.cz>
References: <20170720134029.25268-1-vbabka@suse.cz>
 <20170720134029.25268-5-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170720134029.25268-5-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Yang Shi <yang.shi@linaro.org>, Laura Abbott <labbott@redhat.com>, Vinayak Menon <vinmenon@codeaurora.org>, zhong jiang <zhongjiang@huawei.com>

On Thu 20-07-17 15:40:29, Vlastimil Babka wrote:
> Commit b8f1a75d61d8 ("mm: call page_ext_init() after all struct pages are
> initialized") has avoided a a NULL pointer dereference due to
> DEFERRED_STRUCT_PAGE_INIT clashing with page_ext, by calling page_ext_init()
> only after the deferred struct page init has finished. Later commit
> fe53ca54270a ("mm: use early_pfn_to_nid in page_ext_init") avoided the
> underlying issue differently and moved the page_ext_init() call back to where
> it was before.
> 
> However, there are two problems with the current code:
> - on very large machines, page_ext_init() may fail to allocate the page_ext
> structures, because deferred struct page init hasn't yet started, and the
> pre-inited part might be too small.
> This has been observed with a 3TB machine with page_owner=on. Although it
> was an older kernel where page_owner hasn't yet been converted to stack depot,
> thus page_ext was larger, the fundamental problem is still in mainline.

I was about to suggest using memblock/bootmem allocator but it seems
that page_ext_init is called passed mm_init. Is there any specific
reason why we cannot do the per-section initialization along with the
rest of the memory section init code which should have an early
allocator available?

> - page_owner's init_pages_in_zone() is called before deferred struct page init
> has started, so it will encounter unitialized struct pages. This currently
> happens to cause no harm, because the memmap array is are pre-zeroed on
> allocation and thus the "if (page_zone(page) != zone)" check is negative, but
> that pre-zeroing guarantee might change soon.

Yes this is annoying and the bug IMHO. We shouldn't consider spanned
pages but rather the maximum valid pfn for the zone. The rest simply
cannot by used by anybody so there shouldn't be any page_ext work due.
Or am I missing something?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
