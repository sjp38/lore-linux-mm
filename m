Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 74480280704
	for <linux-mm@kvack.org>; Thu, 24 Aug 2017 03:08:14 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id m133so32962649pga.2
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 00:08:14 -0700 (PDT)
Received: from mail-pg0-x243.google.com (mail-pg0-x243.google.com. [2607:f8b0:400e:c05::243])
        by mx.google.com with ESMTPS id a41si106919pli.340.2017.08.24.00.08.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Aug 2017 00:08:13 -0700 (PDT)
Received: by mail-pg0-x243.google.com with SMTP id p14so2686472pgd.1
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 00:08:13 -0700 (PDT)
Date: Thu, 24 Aug 2017 16:08:01 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 1/2] mm: use sc->priority for slab shrink targets
Message-ID: <20170824070801.GA20463@bgram>
References: <1503430539-2878-1-git-send-email-jbacik@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1503430539-2878-1-git-send-email-jbacik@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: josef@toxicpanda.com
Cc: linux-mm@kvack.org, hannes@cmpxchg.org, riel@redhat.com, akpm@linux-foundation.org, david@fromorbit.com, kernel-team@fb.com, aryabinin@virtuozzo.com, Josef Bacik <jbacik@fb.com>

On Tue, Aug 22, 2017 at 03:35:38PM -0400, josef@toxicpanda.com wrote:
> From: Josef Bacik <jbacik@fb.com>
> 
> Previously we were using the ratio of the number of lru pages scanned to
> the number of eligible lru pages to determine the number of slab objects
> to scan.  The problem with this is that these two things have nothing to
> do with each other, so in slab heavy work loads where there is little to
> no page cache we can end up with the pages scanned being a very low
> number.  This means that we reclaim next to no slab pages and waste a
> lot of time reclaiming small amounts of space.

Your answer on the question I asked will help to parse this paragraph.

Quote from previous discussion:
"
where sc->priority starts at DEF_PRIORITY, which is 12.  The first loop through
reclaim would result in a scan target of 2 pages to 11715 total inactive pages,
and 3 pages to 14710 total active pages.  This is a really really small target
for a system that is entirely slab pages.  And this is super optimistic, this
assumes we even get to scan these pages.  We don't increment sc->nr_scanned
unless we 1) isolate the page, which assumes it's not in use, and 2) can lock
the page.  Under pressure these numbers could probably go down, I'm sure there's
some random pages from daemons that aren't actually in use, so the targets get
even smaller.
"

Please add it to the description.

> 
> Instead use sc->priority in the same way we use it to determine scan
> amounts for the lru's.  This generally equates to pages.  Consider the
> following
> 
> slab_pages = (nr_objects * object_size) / PAGE_SIZE
> 
> What we would like to do is
> 
> scan = slab_pages >> sc->priority
> 
> but we don't know the number of slab pages each shrinker controls, only
> the objects.  However say that theoretically we knew how many pages a
> shrinker controlled, we'd still have to convert this to objects, which
> would look like the following
> 
> scan = shrinker_pages >> sc->priority
> scan_objects = (PAGE_SIZE / object_size) * scan
> 
> or written another way
> 
> scan_objects = (shrinker_pages >> sc->priority) *
> 		(PAGE_SIZE / object_size)
> 
> which can thus be written
> 
> scan_objects = ((shrinker_pages * PAGE_SIZE) / object_size) >>
> 		sc->priority
> 
> which is just
> 
> scan_objects = nr_objects >> sc->priority
> 
> We don't need to know exactly how many pages each shrinker represents,
> it's objects are all the information we need.  Making this change allows
> us to place an appropriate amount of pressure on the shrinker pools for
> their relative size.
> 
> Signed-off-by: Josef Bacik <jbacik@fb.com>

Acked-by: Minchan Kim <minchan@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
