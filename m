Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id E72B26B0390
	for <linux-mm@kvack.org>; Sun, 16 Apr 2017 21:48:00 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id o68so78976404pfj.20
        for <linux-mm@kvack.org>; Sun, 16 Apr 2017 18:48:00 -0700 (PDT)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id g26si9487288plj.197.2017.04.16.18.47.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 16 Apr 2017 18:47:59 -0700 (PDT)
Received: by mail-pg0-x242.google.com with SMTP id o123so24325453pga.1
        for <linux-mm@kvack.org>; Sun, 16 Apr 2017 18:47:59 -0700 (PDT)
Date: Mon, 17 Apr 2017 10:48:03 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: copy_page() on a kmalloc-ed page with DEBUG_SLAB enabled (was "zram:
 do not use copy_page with non-page alinged address")
Message-ID: <20170417014803.GC518@jagdpanzerIV.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@lge.com, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

Hello,

I'll fork it into a separate thread and Cc more MM people.
sorry for top-posting.

Minchan reported that doing copy_page() on a kmalloc(PAGE_SIZE) page
with DEBUG_SLAB enabled can cause a memory corruption (See below or
lkml.kernel.org/r/1492042622-12074-2-git-send-email-minchan@kernel.org )

that's an interesting problem. arm64 copy_page(), for instance, wants src
and dst to be page aligned, which is reasonable, while generic copy_page(),
on the contrary, simply does memcpy(). there are, probably, other callpaths
that do copy_page() on kmalloc-ed pages and I'm wondering if there is some
sort of a generic fix to the problem.

> > On (04/13/17 09:17), Minchan Kim wrote:
> > > The copy_page is optimized memcpy for page-alinged address.
> > > If it is used with non-page aligned address, it can corrupt memory which
> > > means system corruption. With zram, it can happen with
> > > 
> > > 1. 64K architecture
> > > 2. partial IO
> > > 3. slub debug
> > > 
> > > Partial IO need to allocate a page and zram allocates it via kmalloc.
> > > With slub debug, kmalloc(PAGE_SIZE) doesn't return page-size aligned
> > > address. And finally, copy_page(mem, cmem) corrupts memory.
> > 
> > which would be the case for many other copy_page() calls in the kernel.
> > right? if so - should the fix be in copy_page() then?
> 
> I thought about it but was not sure it's good idea by several reasons
> (but don't want to discuss it in this thread).
> 
> Anyway, it's stable stuff so I don't want to make the patch bloat.
> If you believe it is right direction and valuable, you could be
> a volunteer. :)

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
