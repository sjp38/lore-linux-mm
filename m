Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 04CEF6B0253
	for <linux-mm@kvack.org>; Tue, 15 Sep 2015 00:21:33 -0400 (EDT)
Received: by padhy16 with SMTP id hy16so163704283pad.1
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 21:21:32 -0700 (PDT)
Received: from mail-pa0-x233.google.com (mail-pa0-x233.google.com. [2607:f8b0:400e:c03::233])
        by mx.google.com with ESMTPS id zm2si2010994pbc.165.2015.09.14.21.21.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Sep 2015 21:21:32 -0700 (PDT)
Received: by padhy16 with SMTP id hy16so163703995pad.1
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 21:21:31 -0700 (PDT)
Date: Tue, 15 Sep 2015 13:22:16 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH 0/3] allow zram to use zbud as underlying allocator
Message-ID: <20150915042216.GE1860@swordfish>
References: <20150914154901.92c5b7b24e15f04d8204de18@gmail.com>
 <55F6D356.5000106@suse.cz>
 <CAMJBoFMD8jj372sXfb5NkT2MBzBUQp232U7XxO9QHKco+mHUYQ@mail.gmail.com>
 <55F6D641.6010209@suse.cz>
 <CALZtONCKCTRP5r0u5iXYHsQ=uxA-B+1M=4=RPGtFiwo4EOpzeg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALZtONCKCTRP5r0u5iXYHsQ=uxA-B+1M=4=RPGtFiwo4EOpzeg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Vitaly Wool <vitalywool@gmail.com>, Minchan Kim <minchan@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On (09/15/15 00:08), Dan Streetman wrote:
[..]
> 
> it doesn't.  but it has a complex (compared to zbud) way of storing
> pages - many different classes, which each are made up of zspages,
> which contain multiple actual pages to store some number of
> specifically sized objects.  So it can get fragmented, with lots of
> zspages with empty spaces for objects.  That's what the recently added
> zsmalloc compaction addresses, by scanning all the zspages in all the
> classes and compacting zspages within each class.
> 

correct. a bit of internals: we don't scan all the zspages every
time. each class has stats for allocated used objects, allocated
used objects, etc. so we 'compact' only classes that can be
compacted:

 static unsigned long zs_can_compact(struct size_class *class)
 {
         unsigned long obj_wasted;
 
         obj_wasted = zs_stat_get(class, OBJ_ALLOCATED) -
                 zs_stat_get(class, OBJ_USED);
 
         obj_wasted /= get_maxobj_per_zspage(class->size,
                         class->pages_per_zspage);
 
         return obj_wasted * class->pages_per_zspage;
 }

if we can free any zspages (which is at least one page), then we
attempt to do so.

is compaction the root cause of the symptoms Vitaly observe?


Vitaly, if you disable compaction:

---

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 14fc466..d9b5427 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -1944,8 +1944,9 @@ struct zs_pool *zs_create_pool(char *name, gfp_t flags)
         * Not critical, we still can use the pool
         * and user can trigger compaction manually.
         */
-       if (zs_register_shrinker(pool) == 0)
+/*     if (zs_register_shrinker(pool) == 0)
                pool->shrinker_enabled = true;
+*/
        return pool;
 
 err:


---

does the 'problem' go away?


> but I haven't followed most of the recent zsmalloc updates too
> closely, so I may be totally wrong :-)
> 
> zbud is much simpler; since it just uses buddied pairs, it simply
> keeps a list of zbud page with only 1 compressed page stored in it.
> There is still the possibility of fragmentation, but since it's
> simple, it's much smaller.  And there is no compaction implemented in
> it, currently.  The downside, as we all know, is worse efficiency in
> storing compressed pages - it can't do better than 2:1.
> 

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
