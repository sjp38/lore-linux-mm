Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 772576B0027
	for <linux-mm@kvack.org>; Thu, 22 Mar 2018 15:58:27 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id s6so4682749pgn.3
        for <linux-mm@kvack.org>; Thu, 22 Mar 2018 12:58:27 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id b123si5442895pfb.406.2018.03.22.12.58.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 22 Mar 2018 12:58:25 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH 0/4] Add free() function
Date: Thu, 22 Mar 2018 12:58:15 -0700
Message-Id: <20180322195819.24271-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Kirill Tkhai <ktkhai@virtuozzo.com>, Matthew Wilcox <mawilcox@microsoft.com>, linux-kernel@vger.kernel.org, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

Today, kfree_rcu() can only free objects allocated using kmalloc().
There have been attempts to extend that to kvfree(), but I think we
should take it even further and allow freeing as many different objects
as possible.

It turns out many different kinds of memory allocations can be detected
from the address.  vmalloc() and percpu_alloc() can be detected by being
in a particular range.  kmalloc() and kmem_cache_alloc() can be detected
from the struct page.  __get_free_pages() and page_frag_alloc() are both
freeable just by decrementing the refcount on the page.

This allows us to delete many dozens of tiny rcu callbacks throughout
the kernel, much as was done when kfree_rcu was added.

Matthew Wilcox (4):
  decompression: Rename malloc and free
  Rename 'free' functions
  mm: Add free()
  rcu: Switch to using free() instead of kfree()

 crypto/lrw.c                  |  4 ++--
 crypto/xts.c                  |  4 ++--
 include/linux/decompress/mm.h | 10 ++++++----
 include/linux/kernel.h        |  2 ++
 include/linux/rcupdate.h      | 40 +++++++++++++++++++---------------------
 include/linux/rcutiny.h       |  2 +-
 include/linux/rcutree.h       |  2 +-
 include/trace/events/rcu.h    |  8 ++++----
 kernel/rcu/rcu.h              |  8 +++-----
 kernel/rcu/tree.c             | 11 +++++------
 mm/util.c                     | 39 +++++++++++++++++++++++++++++++++++++++
 11 files changed, 84 insertions(+), 46 deletions(-)

-- 
2.16.2
