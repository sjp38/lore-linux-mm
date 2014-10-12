Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 426DD6B0038
	for <linux-mm@kvack.org>; Sun, 12 Oct 2014 13:20:17 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id z10so4371544pdj.40
        for <linux-mm@kvack.org>; Sun, 12 Oct 2014 10:20:16 -0700 (PDT)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2001:4f8:3:36:211:85ff:fe63:a549])
        by mx.google.com with ESMTP id aj8si8436232pad.241.2014.10.12.10.20.15
        for <linux-mm@kvack.org>;
        Sun, 12 Oct 2014 10:20:16 -0700 (PDT)
Date: Sun, 12 Oct 2014 13:20:12 -0400 (EDT)
Message-Id: <20141012.132012.254712930139255731.davem@davemloft.net>
Subject: Re: unaligned accesses in SLAB etc.
From: David Miller <davem@davemloft.net>
In-Reply-To: <20141011.221510.1574777235900788349.davem@davemloft.net>
References: <20141011.221510.1574777235900788349.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-mm@kvack.org, mroos@linux.ee, sparclinux@vger.kernel.org

From: David Miller <davem@davemloft.net>
Date: Sat, 11 Oct 2014 22:15:10 -0400 (EDT)

> 
> I'm getting tons of the following on sparc64:
> 
> [603965.383447] Kernel unaligned access at TPC[546b58] free_block+0x98/0x1a0
> [603965.396987] Kernel unaligned access at TPC[546b60] free_block+0xa0/0x1a0
> [603965.410523] Kernel unaligned access at TPC[546b58] free_block+0x98/0x1a0

The unaligned accesses are happening in the SLAB_OBJ_PFMEMALLOC code,
which assumes that all object pointers are "unsigned long" aligned:

static inline void set_obj_pfmemalloc(void **objp)
{
        *objp = (void *)((unsigned long)*objp | SLAB_OBJ_PFMEMALLOC);
        return;
}

etc. etc.

But that code has been there working forever.  Something changed
recently such that this assumption no longer holds.

In all of the cases, the address is 4-byte aligned but not 8-byte
aligned.  And they are vmalloc addresses.

Which made me suspect the percpu commit:

====================
commit bf0dea23a9c094ae869a88bb694fbe966671bf6d
Author: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Date:   Thu Oct 9 15:26:27 2014 -0700

    mm/slab: use percpu allocator for cpu cache
====================

And indeed, reverting this commit fixes the problem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
