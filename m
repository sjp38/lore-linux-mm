Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f197.google.com (mail-lb0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id D3B726B007E
	for <linux-mm@kvack.org>; Wed,  1 Jun 2016 18:40:16 -0400 (EDT)
Received: by mail-lb0-f197.google.com with SMTP id rs7so15961243lbb.2
        for <linux-mm@kvack.org>; Wed, 01 Jun 2016 15:40:16 -0700 (PDT)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id t5si2135618wje.124.2016.06.01.15.40.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Jun 2016 15:40:15 -0700 (PDT)
Received: by mail-wm0-x244.google.com with SMTP id a136so10832400wme.0
        for <linux-mm@kvack.org>; Wed, 01 Jun 2016 15:40:15 -0700 (PDT)
Date: Thu, 2 Jun 2016 00:40:11 +0200
From: Daniel Vetter <daniel@ffwll.ch>
Subject: Re: [PATCH v7 00/12] Support non-lru page migration
Message-ID: <20160601224011.GC7231@phenom.ffwll.local>
References: <1464736881-24886-1-git-send-email-minchan@kernel.org>
 <20160601144151.c9e5c560be29cae9a3ff1f1e@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160601144151.c9e5c560be29cae9a3ff1f1e@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, dri-devel@lists.freedesktop.org, Hugh Dickins <hughd@google.com>, John Einar Reitan <john.reitan@foss.arm.com>, Jonathan Corbet <corbet@lwn.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Mel Gorman <mgorman@suse.de>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Aquini <aquini@redhat.com>, Rik van Riel <riel@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, virtualization@lists.linux-foundation.org, Gioh Kim <gi-oh.kim@profitbricks.com>, Chan Gyun Jeong <chan.jeong@lge.com>, Sangseok Lee <sangseok.lee@lge.com>, Kyeongdon Kim <kyeongdon.kim@lge.com>, Chulmin Kim <cmlaika.kim@samsung.com>

On Wed, Jun 01, 2016 at 02:41:51PM -0700, Andrew Morton wrote:
> On Wed,  1 Jun 2016 08:21:09 +0900 Minchan Kim <minchan@kernel.org> wrote:
> 
> > Recently, I got many reports about perfermance degradation in embedded
> > system(Android mobile phone, webOS TV and so on) and easy fork fail.
> > 
> > The problem was fragmentation caused by zram and GPU driver mainly.
> > With memory pressure, their pages were spread out all of pageblock and
> > it cannot be migrated with current compaction algorithm which supports
> > only LRU pages. In the end, compaction cannot work well so reclaimer
> > shrinks all of working set pages. It made system very slow and even to
> > fail to fork easily which requires order-[2 or 3] allocations.
> > 
> > Other pain point is that they cannot use CMA memory space so when OOM
> > kill happens, I can see many free pages in CMA area, which is not
> > memory efficient. In our product which has big CMA memory, it reclaims
> > zones too exccessively to allocate GPU and zram page although there are
> > lots of free space in CMA so system becomes very slow easily.
> 
> But this isn't presently implemented for GPU drivers or for CMA, yes?
> 
> What's the story there?

Broken (out-of-tree) drivers that don't allocate their gpu stuff
correctly.  There's piles of drivers that get_user_page all over the place
but then fail to timely get off these pages again. The fix is to get off
those pages again (either by unpinning timely, or registering an
mmu_notifier if the driver wants to keep the pages pinned indefinitely, as
a caching optimization).

At least that's my guess, and iirc it was confirmed first time around this
series showed up.
-Daniel
-- 
Daniel Vetter
Software Engineer, Intel Corporation
http://blog.ffwll.ch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
