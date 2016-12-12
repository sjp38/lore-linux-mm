Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 716886B0261
	for <linux-mm@kvack.org>; Mon, 12 Dec 2016 04:51:27 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id w13so11406249wmw.0
        for <linux-mm@kvack.org>; Mon, 12 Dec 2016 01:51:27 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id qa4si43632319wjc.238.2016.12.12.01.51.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 12 Dec 2016 01:51:26 -0800 (PST)
Date: Mon, 12 Dec 2016 09:51:24 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: fadvise: avoid expensive remote LRU cache draining
 after FADV_DONTNEED
Message-ID: <20161212095124.zz6yiork6uezsczb@suse.de>
References: <20161210172658.5182-1-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20161210172658.5182-1-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Sat, Dec 10, 2016 at 12:26:58PM -0500, Johannes Weiner wrote:
> When FADV_DONTNEED cannot drop all pages in the range, it observes
> that some pages might still be on per-cpu LRU caches after recent
> instantiation and so initiates remote calls to all CPUs to flush their
> local caches. However, in most cases, the fadvise happens from the
> same context that instantiated the pages, and any pre-LRU pages in the
> specified range are most likely sitting on the local CPU's LRU cache,
> and so in many cases this results in unnecessary remote calls, which,
> in a loaded system, can hold up the fadvise() call significantly.
> 
> Try to avoid the remote call by flushing the local LRU cache before
> even attempting to invalidate anything. It's a cheap operation, and
> the local LRU cache is the most likely to hold any pre-LRU pages in
> the specified fadvise range.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
