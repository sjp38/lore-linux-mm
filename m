Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id DA2026B0038
	for <linux-mm@kvack.org>; Sat, 22 Aug 2015 06:45:31 -0400 (EDT)
Received: by widdq5 with SMTP id dq5so33786566wid.0
        for <linux-mm@kvack.org>; Sat, 22 Aug 2015 03:45:31 -0700 (PDT)
Received: from mail-wi0-x229.google.com (mail-wi0-x229.google.com. [2a00:1450:400c:c05::229])
        by mx.google.com with ESMTPS id fp5si10252356wib.85.2015.08.22.03.45.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 22 Aug 2015 03:45:30 -0700 (PDT)
Received: by widdq5 with SMTP id dq5so10522889wid.1
        for <linux-mm@kvack.org>; Sat, 22 Aug 2015 03:45:29 -0700 (PDT)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 0/3] mm/vmalloc: Cache the /proc/meminfo vmalloc statistics
Date: Sat, 22 Aug 2015 12:44:57 +0200
Message-Id: <1440240300-6206-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Dave Hansen <dave@sr71.net>, Peter Zijlstra <peterz@infradead.org>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Rasmus Villemoes <linux@rasmusvillemoes.dk>, Linus Torvalds <torvalds@linux-foundation.org>

This series is a variant of Linus's jiffies based caching approach in the:

   "get_vmalloc_info() and /proc/meminfo insanely expensive"

thread on lkml.

The idea is to track modifications to the vmalloc list by wrapping the
lock/unlock primitives, and to put a flag next to the spinlock. If the
spinlock is taken then it's cheap to modify this flag, and if it has
not been taken (the cached case) it will be a read-mostly variable
for every CPU in essence.

It seems to work for me, but it's only very (very!) lightly tested.

Would something like this be acceptable (and is it correct)?

Thanks,

    Ingo

Ingo Molnar (3):
  mm/vmalloc: Abstract out vmap_area_lock lock/unlock operations
  mm/vmalloc: Track vmalloc info changes
  mm/vmalloc: Cache the vmalloc memory info

 mm/vmalloc.c | 82 +++++++++++++++++++++++++++++++++++++++++++++++++++++++-------------------------
 1 file changed, 57 insertions(+), 25 deletions(-)

-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
