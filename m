Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id BA6B28299B
	for <linux-mm@kvack.org>; Fri, 13 Mar 2015 08:13:27 -0400 (EDT)
Received: by pdbfp1 with SMTP id fp1so28489614pdb.7
        for <linux-mm@kvack.org>; Fri, 13 Mar 2015 05:13:27 -0700 (PDT)
Received: from mail-pa0-x236.google.com (mail-pa0-x236.google.com. [2607:f8b0:400e:c03::236])
        by mx.google.com with ESMTPS id pb7si2182631pdb.193.2015.03.13.05.13.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Mar 2015 05:13:26 -0700 (PDT)
Received: by padbj1 with SMTP id bj1so29051454pad.12
        for <linux-mm@kvack.org>; Fri, 13 Mar 2015 05:13:26 -0700 (PDT)
From: Roman Pen <r.peniaev@gmail.com>
Subject: [PATCH 0/3] [RFC] mm/vmalloc: fix possible exhaustion of vmalloc space
Date: Fri, 13 Mar 2015 21:12:54 +0900
Message-Id: <1426248777-19768-1-git-send-email-r.peniaev@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: Roman Pen <r.peniaev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@kernel.dk>, Eric Dumazet <edumazet@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, WANG Chao <chaowang@redhat.com>, Fabian Frederick <fabf@skynet.be>, Christoph Lameter <cl@linux.com>, Gioh Kim <gioh.kim@lge.com>, Rob Jones <rob.jones@codethink.co.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org

Hello all.

Recently I came across high fragmentation of vm_map_ram allocator: vmap_block
has free space, but still new blocks continue to appear.  Further investigation
showed that certain mapping/unmapping sequence can exhaust vmalloc space.  On
small 32bit systems that's not a big problem, cause purging will be called soon
on a first allocation failure (alloc_vmap_area), but on 64bit machines, e.g.
x86_64 has 45 bits of vmalloc space, that can be a disaster.

Fixing this I also did some tweaks in allocation logic of a new vmap block and
replaced dirty bitmap with min/max dirty range values to make the logic simpler.

I would like to receive comments on the following three patches.

Thanks.

Roman Pen (3):
  mm/vmalloc: fix possible exhaustion of vmalloc space caused by
    vm_map_ram allocator
  mm/vmalloc: occupy newly allocated vmap block just after allocation
  mm/vmalloc: get rid of dirty bitmap inside vmap_block structure

 mm/vmalloc.c | 94 ++++++++++++++++++++++++++++++++++--------------------------
 1 file changed, 54 insertions(+), 40 deletions(-)

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Nick Piggin <npiggin@kernel.dk>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: David Rientjes <rientjes@google.com>
Cc: WANG Chao <chaowang@redhat.com>
Cc: Fabian Frederick <fabf@skynet.be>
Cc: Christoph Lameter <cl@linux.com>
Cc: Gioh Kim <gioh.kim@lge.com>
Cc: Rob Jones <rob.jones@codethink.co.uk>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
Cc: stable@vger.kernel.org
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
