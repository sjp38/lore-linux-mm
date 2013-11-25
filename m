Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 6C3AF6B0037
	for <linux-mm@kvack.org>; Mon, 25 Nov 2013 18:50:15 -0500 (EST)
Received: by mail-pd0-f180.google.com with SMTP id q10so6533977pdj.39
        for <linux-mm@kvack.org>; Mon, 25 Nov 2013 15:50:14 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id hk1si29069913pbb.251.2013.11.25.15.50.13
        for <linux-mm@kvack.org>;
        Mon, 25 Nov 2013 15:50:13 -0800 (PST)
Date: Mon, 25 Nov 2013 15:50:11 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 7/9] mm: thrash detection-based file cache sizing
Message-Id: <20131125155011.2f1320ab422436b1204bd15e@linux-foundation.org>
In-Reply-To: <1385336308-27121-8-git-send-email-hannes@cmpxchg.org>
References: <1385336308-27121-1-git-send-email-hannes@cmpxchg.org>
	<1385336308-27121-8-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Dave Chinner <david@fromorbit.com>, Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Tejun Heo <tj@kernel.org>, Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Greg Thelen <gthelen@google.com>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Michel Lespinasse <walken@google.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Roman Gushchin <klamm@yandex-team.ru>, Ozgun Erdogan <ozgun@citusdata.com>, Metin Doslu <metin@citusdata.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Sun, 24 Nov 2013 18:38:26 -0500 Johannes Weiner <hannes@cmpxchg.org> wrote:

> ...
>
> + *		Access frequency and refault distance
> + *
> + * A workload is trashing when its pages are frequently used but they
> + * are evicted from the inactive list every time before another access
> + * would have promoted them to the active list.
> + *
> + * In cases where the average access distance between thrashing pages
> + * is bigger than the size of memory there is nothing that can be
> + * done - the thrashing set could never fit into memory under any
> + * circumstance.
> + *
> + * However, the average access distance could be bigger than the
> + * inactive list, yet smaller than the size of memory.  In this case,
> + * the set could fit into memory if it weren't for the currently
> + * active pages - which may be used more, hopefully less frequently:
> + *
> + *      +-memory available to cache-+
> + *      |                           |
> + *      +-inactive------+-active----+
> + *  a b | c d e f g h i | J K L M N |
> + *      +---------------+-----------+

So making the inactive list smaller will worsen this problem?

If so, don't we have a conflict with this objective:

> Right now we have a fixed ratio (50:50) between inactive and active
> list but we already have complaints about working sets exceeding half
> of memory being pushed out of the cache by simple streaming in the
> background.  Ultimately, we want to adjust this ratio and allow for a
> much smaller inactive list.

?

> + * It is prohibitively expensive to accurately track access frequency
> + * of pages.  But a reasonable approximation can be made to measure
> + * thrashing on the inactive list, after which refaulting pages can be
> + * activated optimistically to compete with the existing active pages.
> + *
> + * Approximating inactive page access frequency - Observations:
> + *
> + * 1. When a page is accesed for the first time, it is added to the

"accessed"

> + *    head of the inactive list, slides every existing inactive page
> + *    towards the tail by one slot, and pushes the current tail page
> + *    out of memory.
> + *
>
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
