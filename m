Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f54.google.com (mail-yh0-f54.google.com [209.85.213.54])
	by kanga.kvack.org (Postfix) with ESMTP id D21D46B0035
	for <linux-mm@kvack.org>; Mon, 25 Nov 2013 20:56:34 -0500 (EST)
Received: by mail-yh0-f54.google.com with SMTP id z12so3504665yhz.13
        for <linux-mm@kvack.org>; Mon, 25 Nov 2013 17:56:34 -0800 (PST)
Received: from mail-pb0-x235.google.com (mail-pb0-x235.google.com [2607:f8b0:400e:c01::235])
        by mx.google.com with ESMTPS id z5si22403776yhd.249.2013.11.25.17.56.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 25 Nov 2013 17:56:34 -0800 (PST)
Received: by mail-pb0-f53.google.com with SMTP id ma3so6965927pbc.26
        for <linux-mm@kvack.org>; Mon, 25 Nov 2013 17:56:32 -0800 (PST)
Message-ID: <5293FFC7.5070907@gmail.com>
Date: Tue, 26 Nov 2013 12:56:23 +1100
From: Ryan Mallon <rmallon@gmail.com>
MIME-Version: 1.0
Subject: Re: [patch 7/9] mm: thrash detection-based file cache sizing
References: <1385336308-27121-1-git-send-email-hannes@cmpxchg.org> <1385336308-27121-8-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1385336308-27121-8-git-send-email-hannes@cmpxchg.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Chinner <david@fromorbit.com>, Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Tejun Heo <tj@kernel.org>, Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Greg Thelen <gthelen@google.com>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Michel Lespinasse <walken@google.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Roman Gushchin <klamm@yandex-team.ru>, Ozgun Erdogan <ozgun@citusdata.com>, Metin Doslu <metin@citusdata.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On 25/11/13 10:38, Johannes Weiner wrote:
> The VM maintains cached filesystem pages on two types of lists.  One
> list holds the pages recently faulted into the cache, the other list
> holds pages that have been referenced repeatedly on that first list.
> The idea is to prefer reclaiming young pages over those that have
> shown to benefit from caching in the past.  We call the recently used
> list "inactive list" and the frequently used list "active list".
> 
> Currently, the VM aims for a 1:1 ratio between the lists, which is the
> "perfect" trade-off between the ability to *protect* frequently used
> pages and the ability to *detect* frequently used pages.  This means
> that working set changes bigger than half of cache memory go
> undetected and thrash indefinitely, whereas working sets bigger than
> half of cache memory are unprotected against used-once streams that
> don't even need caching.
> 
> Historically, every reclaim scan of the inactive list also took a
> smaller number of pages from the tail of the active list and moved
> them to the head of the inactive list.  This model gave established
> working sets more gracetime in the face of temporary use-once streams,
> but ultimately was not significantly better than a FIFO policy and
> still thrashed cache based on eviction speed, rather than actual
> demand for cache.
> 
> This patch solves one half of the problem by decoupling the ability to
> detect working set changes from the inactive list size.  By
> maintaining a history of recently evicted file pages it can detect
> frequently used pages with an arbitrarily small inactive list size,
> and subsequently apply pressure on the active list based on actual
> demand for cache, not just overall eviction speed.
> 
> Every zone maintains a counter that tracks inactive list aging speed.
> When a page is evicted, a snapshot of this counter is stored in the
> now-empty page cache radix tree slot.  On refault, the minimum access
> distance of the page can be assesed, to evaluate whether the page
> should be part of the active list or not.
> 
> This fixes the VM's blindness towards working set changes in excess of
> the inactive list.  And it's the foundation to further improve the
> protection ability and reduce the minimum inactive list size of 50%.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---

<snip>

> + *   fault ------------------------+
> + *                                 |
> + *              +--------------+   |            +-------------+
> + *   reclaim <- |   inactive   | <-+-- demotion |    active   | <--+
> + *              +--------------+                +-------------+    |
> + *                     |                                           |
> + *                     +-------------- promotion ------------------+
> + *
> + *
> + *		Access frequency and refault distance
> + *
> + * A workload is trashing when its pages are frequently used but they

"thrashing".

~Ryan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
