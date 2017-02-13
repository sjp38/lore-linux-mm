Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 027166B0038
	for <linux-mm@kvack.org>; Mon, 13 Feb 2017 05:51:21 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id h7so41546166wjy.6
        for <linux-mm@kvack.org>; Mon, 13 Feb 2017 02:51:20 -0800 (PST)
Received: from outbound-smtp10.blacknight.com (outbound-smtp10.blacknight.com. [46.22.139.15])
        by mx.google.com with ESMTPS id d28si5015149wma.147.2017.02.13.02.51.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Feb 2017 02:51:19 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp10.blacknight.com (Postfix) with ESMTPS id 601161C1500
	for <linux-mm@kvack.org>; Mon, 13 Feb 2017 10:51:19 +0000 (GMT)
Date: Mon, 13 Feb 2017 10:51:18 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH v2 03/10] mm, page_alloc: split smallest stolen page in
 fallback
Message-ID: <20170213105118.f3y5y2xaf2kdnxv7@techsingularity.net>
References: <20170210172343.30283-1-vbabka@suse.cz>
 <20170210172343.30283-4-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170210172343.30283-4-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Fri, Feb 10, 2017 at 06:23:36PM +0100, Vlastimil Babka wrote:
> The __rmqueue_fallback() function is called when there's no free page of
> requested migratetype, and we need to steal from a different one. There are
> various heuristics to make this event infrequent and reduce permanent
> fragmentation. The main one is to try stealing from a pageblock that has the
> most free pages, and possibly steal them all at once and convert the whole
> pageblock. Precise searching for such pageblock would be expensive, so instead
> the heuristics walks the free lists from MAX_ORDER down to requested order and
> assumes that the block with highest-order free page is likely to also have the
> most free pages in total.
> 
> Chances are that together with the highest-order page, we steal also pages of
> lower orders from the same block. But then we still split the highest order
> page. This is wasteful and can contribute to fragmentation instead of avoiding
> it.
> 

The original intent was that if an allocation request was stealing a
pageblock that taking the largest one would reduce the likelihood of a
steal in the near future by the same type.

> This patch thus changes __rmqueue_fallback() to just steal the page(s) and put
> them on the freelist of the requested migratetype, and only report whether it
> was successful. Then we pick (and eventually split) the smallest page with
> __rmqueue_smallest().  This all happens under zone lock, so nobody can steal it
> from us in the process. This should reduce fragmentation due to fallbacks. At
> worst we are only stealing a single highest-order page and waste some cycles by
> moving it between lists and then removing it, but fallback is not exactly hot
> path so that should not be a concern. As a side benefit the patch removes some
> duplicate code by reusing __rmqueue_smallest().
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>

But conceptually this is better so

Acked-by: Mel Gorman <mgorman@techsingularity.net>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
