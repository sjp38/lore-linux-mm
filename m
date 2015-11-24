Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9F5FA6B0253
	for <linux-mm@kvack.org>; Tue, 24 Nov 2015 18:02:30 -0500 (EST)
Received: by wmec201 with SMTP id c201so231774150wme.0
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 15:02:30 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id gh7si30192457wjb.118.2015.11.24.15.02.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Nov 2015 15:02:29 -0800 (PST)
Date: Tue, 24 Nov 2015 15:02:27 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] vmscan: fix slab vs lru balance
Message-Id: <20151124150227.78c9e39b789f593c5216471e@linux-foundation.org>
In-Reply-To: <1448369241-26593-1-git-send-email-vdavydov@virtuozzo.com>
References: <1448369241-26593-1-git-send-email-vdavydov@virtuozzo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 24 Nov 2015 15:47:21 +0300 Vladimir Davydov <vdavydov@virtuozzo.com> wrote:

> The comment to shrink_slab states that the portion of kmem objects
> scanned by it equals the portion of lru pages scanned by shrink_zone
> over shrinker->seeks.
> 
> shrinker->seeks is supposed to be equal to the number of disk seeks
> required to recreated an object. It is usually set to DEFAULT_SEEKS (2),
> which is quite logical, because most kmem objects (e.g. dentry or inode)
> require random IO to reread (seek to read and seek back).
> 
> That said, one would expect that dcache is scanned two times less
> intensively than page cache, which sounds sane as dentries are generally
> more costly to recreate.
> 
> However, the formula for distributing memory pressure between slab and
> lru actually looks as follows (see do_shrink_slab):
> 
>                               lru_scanned
> objs_to_scan = objs_total * --------------- * 4 / shrinker->seeks
>                             lru_reclaimable
> 
> That is dcache, as well as most of other slab caches, is scanned two
> times more aggressively than page cache.
> 
> Fix this by dropping '4' from the equation above.
> 

oh geeze.  Who wrote that crap?


commit c3f4656118a78c1c294e0b4d338ac946265a822b
Author: Andrew Morton <akpm@osdl.org>
Date:   Mon Dec 29 23:48:44 2003 -0800

    [PATCH] shrink_slab acounts for seeks incorrectly
    
    wli points out that shrink_slab inverts the sense of shrinker->seeks: those
    caches which require more seeks to reestablish an object are shrunk harder.
    That's wrong - they should be shrunk less.
    
    So fix that up, but scaling the result so that the patch is actually a no-op
    at this time, because all caches use DEFAULT_SEEKS (2).

diff --git a/mm/vmscan.c b/mm/vmscan.c
index b859482..f2da3c9 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -154,7 +154,7 @@ static int shrink_slab(long scanned, unsigned int gfp_mask)
 	list_for_each_entry(shrinker, &shrinker_list, list) {
 		unsigned long long delta;
 
-		delta = scanned * shrinker->seeks;
+		delta = 4 * (scanned / shrinker->seeks);
 		delta *= (*shrinker->shrinker)(0, gfp_mask);
 		do_div(delta, pages + 1);
 		shrinker->nr += delta;


What a pathetic changelog.

The current code may be good, it may be bad, but I'm reluctant to
change it without a solid demonstration that the result is overall
superior.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
