Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id A1BF36810C8
	for <linux-mm@kvack.org>; Fri, 25 Aug 2017 16:55:24 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id b8so5549738pgn.3
        for <linux-mm@kvack.org>; Fri, 25 Aug 2017 13:55:24 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0121.outbound.protection.outlook.com. [104.47.0.121])
        by mx.google.com with ESMTPS id y67si1916656plh.477.2017.08.25.13.55.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 25 Aug 2017 13:55:23 -0700 (PDT)
Subject: Re: [PATCH][v2] mm: use sc->priority for slab shrink targets
References: <1503589176-1823-1-git-send-email-jbacik@fb.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <d2f483b6-670a-54ef-e997-96777163241f@virtuozzo.com>
Date: Fri, 25 Aug 2017 23:54:56 +0300
MIME-Version: 1.0
In-Reply-To: <1503589176-1823-1-git-send-email-jbacik@fb.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: josef@toxicpanda.com, minchan@kernel.org, linux-mm@kvack.org, hannes@cmpxchg.org, riel@redhat.com, akpm@linux-foundation.org, david@fromorbit.com, kernel-team@fb.com
Cc: Josef Bacik <jbacik@fb.com>

On 08/24/2017 06:39 PM, josef@toxicpanda.com wrote:
> From: Josef Bacik <jbacik@fb.com>
> 
> Previously we were using the ratio of the number of lru pages scanned to
> the number of eligible lru pages to determine the number of slab objects
> to scan.  The problem with this is that these two things have nothing to
> do with each other, so in slab heavy work loads where there is little to
> no page cache we can end up with the pages scanned being a very low
> number.  This means that we reclaim next to no slab pages and waste a
> lot of time reclaiming small amounts of space.
> 
> Consider the following scenario, where we have the following values and
> the rest of the memory usage is in slab
> 
> Active:            58840 kB
> Inactive:          46860 kB
> 
> Every time we do a get_scan_count() we do this
> 
> scan = size >> sc->priority
> 
> where sc->priority starts at DEF_PRIORITY, which is 12.  The first loop
> through reclaim would result in a scan target of 2 pages to 11715 total
> inactive pages, and 3 pages to 14710 total active pages.  This is a
> really really small target for a system that is entirely slab pages.
> And this is super optimistic, this assumes we even get to scan these
> pages.  We don't increment sc->nr_scanned unless we 1) isolate the page,
> which assumes it's not in use, and 2) can lock the page.  Under
> pressure these numbers could probably go down, I'm sure there's some
> random pages from daemons that aren't actually in use, so the targets
> get even smaller.
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
> 

Acked-by: Andrey Ryabinin <aryabinin@virtuozzo.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
