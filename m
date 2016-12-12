Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id F29C16B0260
	for <linux-mm@kvack.org>; Mon, 12 Dec 2016 10:56:01 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id i131so14831423wmf.3
        for <linux-mm@kvack.org>; Mon, 12 Dec 2016 07:56:01 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id kb9si44872599wjc.139.2016.12.12.07.55.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Dec 2016 07:56:00 -0800 (PST)
Date: Mon, 12 Dec 2016 10:55:52 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: fadvise: avoid expensive remote LRU cache draining
 after FADV_DONTNEED
Message-ID: <20161212155552.GA7148@cmpxchg.org>
References: <20161210172658.5182-1-hannes@cmpxchg.org>
 <5cc0eb6f-bede-a34a-522b-e30d06723ffa@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5cc0eb6f-bede-a34a-522b-e30d06723ffa@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Mon, Dec 12, 2016 at 10:21:24AM +0100, Vlastimil Babka wrote:
> On 12/10/2016 06:26 PM, Johannes Weiner wrote:
> > When FADV_DONTNEED cannot drop all pages in the range, it observes
> > that some pages might still be on per-cpu LRU caches after recent
> > instantiation and so initiates remote calls to all CPUs to flush their
> > local caches. However, in most cases, the fadvise happens from the
> > same context that instantiated the pages, and any pre-LRU pages in the
> > specified range are most likely sitting on the local CPU's LRU cache,
> > and so in many cases this results in unnecessary remote calls, which,
> > in a loaded system, can hold up the fadvise() call significantly.
> 
> Got any numbers for this part?

I didn't record it in the extreme case we observed, unfortunately. We
had a slow-to-respond system and noticed it spending seconds in
lru_add_drain_all() after fadvise calls, and this patch came out of
thinking about the code and how we commonly call FADV_DONTNEED.

FWIW, I wrote a silly directory tree walker/searcher that recurses
through /usr to read and FADV_DONTNEED each file it finds. On a 2
socket 40 ht machine, over 1% is spent in lru_add_drain_all(). With
the patch, that cost is gone; the local drain cost shows at 0.09%.

> > Try to avoid the remote call by flushing the local LRU cache before
> > even attempting to invalidate anything. It's a cheap operation, and
> > the local LRU cache is the most likely to hold any pre-LRU pages in
> > the specified fadvise range.
> 
> Anyway it looks like things can't be worse after this patch, so...
> 
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> 
> Acked-by: Vlastimil Babka <vbabka@suse.cz>

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
