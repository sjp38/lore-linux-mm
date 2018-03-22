Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 662596B000C
	for <linux-mm@kvack.org>; Thu, 22 Mar 2018 11:32:14 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id 30-v6so814707ple.19
        for <linux-mm@kvack.org>; Thu, 22 Mar 2018 08:32:14 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id z85si5166728pfk.194.2018.03.22.08.32.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 22 Mar 2018 08:32:13 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v2 0/8] page_frag_cache improvements
Date: Thu, 22 Mar 2018 08:31:49 -0700
Message-Id: <20180322153157.10447-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, netdev@vger.kernel.org, linux-mm@kvack.org, Jesper Dangaard Brouer <brouer@redhat.com>, Eric Dumazet <eric.dumazet@gmail.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

Version 1 was completely wrong-headed and I have repented of the error
of my ways.  Thanks for educating me.

I still think it's possible to improve on the current state of the
page_frag allocator, and here are eight patches, each of which I think
represents an improvement.  They're not all that interlinked, although
there will be textual conflicts, so I'll be happy to revise and drop
any that are not actual improvements.

I have discovered (today), much to my chagrin, that testing using trinity
in KVM doesn't actually test the page_frag allocator.  I don't understand
why not.  So, this turns out to only be compile tested.  Sorry.

The net effect of all these patches is a reduction of four instructions
in the fastpath of the allocator on x86.  The page_frag_cache structure
also shrinks, to as small as 8 bytes on 32-bit with CONFIG_BASE_SMALL.

The last patch is probably wrong.  It'll definitely be inaccurate
because the call to page_frag_free() may not be the call which frees
a page; there's a really unlikely race where the page cache finds a
stale RCU pointer, bumps its refcount, discovers it's not the page it
was looking for and calls put_page(), which might end up being the last
reference count.  We can do something about that inaccuracy, but I don't
even know if this is the best approach to accounting these pages.

Matthew Wilcox (8):
  page_frag_cache: Remove pfmemalloc bool
  page_frag_cache: Move slowpath code from page_frag_alloc
  page_frag_cache: Rename 'nc' to 'pfc'
  page_frag_cache: Rename fragsz to size
  page_frag_cache: Save memory on small machines
  page_frag_cache: Use a mask instead of offset
  page_frag: Update documentation
  page_frag: Account allocations

 Documentation/vm/page_frags     |  42 -----------
 Documentation/vm/page_frags.rst |  24 +++++++
 include/linux/mm_types.h        |  20 ++++--
 include/linux/mmzone.h          |   3 +-
 mm/page_alloc.c                 | 155 ++++++++++++++++++++++++----------------
 net/core/skbuff.c               |   5 +-
 6 files changed, 135 insertions(+), 114 deletions(-)
 delete mode 100644 Documentation/vm/page_frags
 create mode 100644 Documentation/vm/page_frags.rst

-- 
2.16.2
