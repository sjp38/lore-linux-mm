Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f176.google.com (mail-ob0-f176.google.com [209.85.214.176])
	by kanga.kvack.org (Postfix) with ESMTP id 4582E6B006C
	for <linux-mm@kvack.org>; Wed, 18 Mar 2015 01:52:06 -0400 (EDT)
Received: by obcxo2 with SMTP id xo2so24607400obc.0
        for <linux-mm@kvack.org>; Tue, 17 Mar 2015 22:52:06 -0700 (PDT)
Received: from mail-ob0-x22d.google.com (mail-ob0-x22d.google.com. [2607:f8b0:4003:c01::22d])
        by mx.google.com with ESMTPS id s4si2387286oia.108.2015.03.17.22.52.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Mar 2015 22:52:05 -0700 (PDT)
Received: by obcxo2 with SMTP id xo2so24606978obc.0
        for <linux-mm@kvack.org>; Tue, 17 Mar 2015 22:52:04 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1426248777-19768-4-git-send-email-r.peniaev@gmail.com>
References: <1426248777-19768-1-git-send-email-r.peniaev@gmail.com>
	<1426248777-19768-4-git-send-email-r.peniaev@gmail.com>
Date: Wed, 18 Mar 2015 14:52:03 +0900
Message-ID: <CAAmzW4MPkFzV0kuQy=nE9nWqFRWCq3S00_DgGiYtPtf2Lzp7_A@mail.gmail.com>
Subject: Re: [PATCH 3/3] mm/vmalloc: get rid of dirty bitmap inside vmap_block structure
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Pen <r.peniaev@gmail.com>
Cc: Nick Piggin <npiggin@kernel.dk>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Eric Dumazet <edumazet@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, WANG Chao <chaowang@redhat.com>, Fabian Frederick <fabf@skynet.be>, Christoph Lameter <cl@linux.com>, Gioh Kim <gioh.kim@lge.com>, Rob Jones <rob.jones@codethink.co.uk>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

2015-03-13 21:12 GMT+09:00 Roman Pen <r.peniaev@gmail.com>:
> In original implementation of vm_map_ram made by Nick Piggin there were two
> bitmaps:  alloc_map and dirty_map.  None of them were used as supposed to be:
> finding a suitable free hole for next allocation in block. vm_map_ram allocates
> space sequentially in block and on free call marks pages as dirty, so freed
> space can't be reused anymore.
>
> Actually would be very interesting to know the real meaning of those bitmaps,
> maybe implementation was incomplete, etc.
>
> But long time ago Zhang Yanfei removed alloc_map by these two commits:
>
>   mm/vmalloc.c: remove dead code in vb_alloc
>      3fcd76e8028e0be37b02a2002b4f56755daeda06
>   mm/vmalloc.c: remove alloc_map from vmap_block
>      b8e748b6c32999f221ea4786557b8e7e6c4e4e7a
>
> In current patch I replaced dirty_map with two range variables: dirty min and
> max.  These variables store minimum and maximum position of dirty space in a
> block, since we need only to know the dirty range, not exact position of dirty
> pages.
>
> Why it was made? Several reasons: at first glance it seems that vm_map_ram
> allocator concerns about fragmentation thus it uses bitmaps for finding free
> hole, but it is not true.  To avoid complexity seems it is better to use
> something simple, like min or max range values.  Secondly, code also becomes
> simpler, without iteration over bitmap, just comparing values in min and max
> macros.  Thirdly, bitmap occupies up to 1024 bits (4MB is a max size of a
> block).  Here I replaced the whole bitmap with two longs.
>
> Finally vm_unmap_aliases should be slightly faster and the whole vmap_block
> structure occupies less memory.
>
> Signed-off-by: Roman Pen <r.peniaev@gmail.com>
> Cc: Nick Piggin <npiggin@kernel.dk>
> Cc: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: David Rientjes <rientjes@google.com>
> Cc: WANG Chao <chaowang@redhat.com>
> Cc: Fabian Frederick <fabf@skynet.be>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Gioh Kim <gioh.kim@lge.com>
> Cc: Rob Jones <rob.jones@codethink.co.uk>
> Cc: linux-mm@kvack.org
> Cc: linux-kernel@vger.kernel.org

Acked-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
