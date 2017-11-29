Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5EA086B0253
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 01:26:10 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id d4so1527683pgv.4
        for <linux-mm@kvack.org>; Tue, 28 Nov 2017 22:26:10 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id 5si790122plx.33.2017.11.28.22.26.08
        for <linux-mm@kvack.org>;
        Tue, 28 Nov 2017 22:26:09 -0800 (PST)
Date: Wed, 29 Nov 2017 15:32:08 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH] mm, compaction: direct freepage allocation for async
 direct compaction
Message-ID: <20171129063208.GC8125@js1304-P5Q-DELUXE>
References: <20171122143321.29501-1-hannes@cmpxchg.org>
 <20171123140843.is7cqatrdijkjqql@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171123140843.is7cqatrdijkjqql@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Thu, Nov 23, 2017 at 02:08:43PM +0000, Mel Gorman wrote:

> 3. Another reason a linear scanner was used was because we wanted to
>    clear entire pageblocks we were migrating from and pack the target
>    pageblocks as much as possible. This was to reduce the amount of
>    migration required overall even though the scanning hurts. This patch
>    takes MIGRATE_MOVABLE pages from anywhere that is "not this pageblock".
>    Those potentially have to be moved again and again trying to randomly
>    fill a MIGRATE_MOVABLE block. Have you considered using the freelists
>    as a hint? i.e. take a page from the freelist, then isolate all free
>    pages in the same pageblock as migration targets? That would preserve
>    the "packing property" of the linear scanner.
> 
>    This would increase the amount of scanning but that *might* be offset by
>    the number of migrations the workload does overall. Note that migrations
>    potentially are minor faults so if we do too many migrations, your
>    workload may suffer.
> 
> 4. One problem the linear scanner avoids is that a migration target is
>    subsequently used as a migration source and leads to a ping-pong effect.
>    I don't know how bad this is in practice or even if it's a problem at
>    all but it was a concern at the time

IIUC, this potential advantage for a linear scanner would not be the
actual advantage in the *running* system.

Consider about following worst case scenario for "direct freepage
allocation" that "moved again" happens.

__M1___F1_________________F2__F3___

M: migration source page (the number denotes the ID of the page)
F: freepage (the number denotes the sequence in the freelist of the buddy)
_: other pages
migration scanner: move from left to right.

If migration happens with "direct freepage allocation", memory state
will be changed to:

__F?___M1_________________F2__F3___

And then, please assume that there is an another movable allocation
before another migration. It's reasonable assumption since there are
really many movable allocations in the *running* system.

__F?___M1_________________M2__F3___

If migration happens again, memory state will be:

__F?___F?_________________M2__M1___

M1 is moved twice and overall number of migration is two.

Now, think about a linear scanner. With the same scenario,
memory state will be as following.

__M1___F1_________________F2__F3___
__F?___F1_________________F2__M1___
__F?___M2_________________F2__M1___
__F?___F?_________________M2__M1___

Although "move again" doesn't happen in a linear scanner, final memory
state is the same and the same number of migration happens.

So, I think that "direct freepage allocation" doesn't suffer from such
a ping-poing effect. Am I missing something?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
