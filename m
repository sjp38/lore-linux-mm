Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 1C01E6B0031
	for <linux-mm@kvack.org>; Tue,  4 Feb 2014 18:14:30 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id kp14so9172858pab.37
        for <linux-mm@kvack.org>; Tue, 04 Feb 2014 15:14:29 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id sj5si26485387pab.23.2014.02.04.15.14.25
        for <linux-mm@kvack.org>;
        Tue, 04 Feb 2014 15:14:29 -0800 (PST)
Date: Tue, 4 Feb 2014 15:14:24 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 00/10] mm: thrash detection-based file cache sizing v9
Message-Id: <20140204151424.d08301233c1f1801f43498b1@linux-foundation.org>
In-Reply-To: <1391475222-1169-1-git-send-email-hannes@cmpxchg.org>
References: <1391475222-1169-1-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Bob Liu <bob.liu@oracle.com>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Luigi Semenzato <semenzato@google.com>, Mel Gorman <mgorman@suse.de>, Metin Doslu <metin@citusdata.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan.kim@gmail.com>, Ozgun Erdogan <ozgun@citusdata.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Roman Gushchin <klamm@yandex-team.ru>, Ryan Mallon <rmallon@gmail.com>, Tejun Heo <tj@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon,  3 Feb 2014 19:53:32 -0500 Johannes Weiner <hannes@cmpxchg.org> wrote:

> o Fix vmstat build problems on UP (Fengguang Wu's build bot)
> 
> o Clarify why optimistic radix_tree_node->private_list link checking
>   is safe without holding the list_lru lock (Dave Chinner)
> 
> o Assert locking balance when the list_lru isolator says it dropped
>   the list lock (Dave Chinner)
> 
> o Remove remnant of a manual reclaim counter in the shadow isolator,
>   the list_lru-provided accounting is accurate now that we added
>   LRU_REMOVED_RETRY (Dave Chinner)
> 
> o Set an object limit for the shadow shrinker instead of messing with
>   its seeks setting.  The configured seeks define how pressure applied
>   to pages translates to pressure on the object pool, in itself it is
>   not enough to replace proper object valuation to classify expired
>   and in-use objects.  Shadow nodes contain up to 64 shadow entries
>   from different/alternating zones that have their own atomic age
>   counter, so determining if a node is overall expired is crazy
>   expensive.  Instead, use an object limit above which nodes are very
>   likely to be expired.
> 
> o __pagevec_lookup and __find_get_pages kerneldoc fixes (Minchan Kim)
> 
> o radix_tree_node->count accessors for pages and shadows (Minchan Kim)
> 
> o Rebase to v3.14-rc1 and add review tags

An earlier version caused a 24-byte inode bloatage.  That appears to
have been reduced to 8 bytes, yes?  What was done there?

> 69 files changed, 1438 insertions(+), 462 deletions(-)

omigod

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
