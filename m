Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id F07A96B007E
	for <linux-mm@kvack.org>; Wed,  1 Jun 2016 20:35:45 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id g64so29800613pfb.2
        for <linux-mm@kvack.org>; Wed, 01 Jun 2016 17:35:45 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id b6si32592406pfk.87.2016.06.01.17.35.44
        for <linux-mm@kvack.org>;
        Wed, 01 Jun 2016 17:35:45 -0700 (PDT)
Date: Thu, 2 Jun 2016 09:36:27 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v7 00/12] Support non-lru page migration
Message-ID: <20160602003627.GC1736@bbox>
References: <1464736881-24886-1-git-send-email-minchan@kernel.org>
 <20160601144151.c9e5c560be29cae9a3ff1f1e@linux-foundation.org>
MIME-Version: 1.0
In-Reply-To: <20160601144151.c9e5c560be29cae9a3ff1f1e@linux-foundation.org>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, dri-devel@lists.freedesktop.org, Hugh Dickins <hughd@google.com>, John Einar Reitan <john.reitan@foss.arm.com>, Jonathan Corbet <corbet@lwn.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Mel Gorman <mgorman@suse.de>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Aquini <aquini@redhat.com>, Rik van Riel <riel@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, virtualization@lists.linux-foundation.org, Gioh Kim <gi-oh.kim@profitbricks.com>, Chan Gyun Jeong <chan.jeong@lge.com>, Sangseok Lee <sangseok.lee@lge.com>, Kyeongdon Kim <kyeongdon.kim@lge.com>, Chulmin Kim <cmlaika.kim@samsung.com>

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

For GPU driver, Gioh implemented but it was proprietary so couldn't
contribute.

For CMA, [zram: use __GFP_MOVABLE for memory allocation] added __GFP_MOVABLE
for zsmalloc page allocation so it can use CMA area automatically now.

> 
> What's the story there?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
