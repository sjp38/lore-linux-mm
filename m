Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id F423E6B0309
	for <linux-mm@kvack.org>; Tue, 20 Dec 2016 08:28:10 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id w39so127206554qtw.0
        for <linux-mm@kvack.org>; Tue, 20 Dec 2016 05:28:10 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x66si2647320qkd.227.2016.12.20.05.28.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Dec 2016 05:28:10 -0800 (PST)
Subject: [RFC PATCH 0/4] page_pool proof-of-concept early code
From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Tue, 20 Dec 2016 14:28:07 +0100
Message-ID: <20161220132444.18788.50875.stgit@firesoul>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Alexander Duyck <alexander.duyck@gmail.com>
Cc: willemdebruijn.kernel@gmail.com, netdev@vger.kernel.org, john.fastabend@gmail.com, Saeed Mahameed <saeedm@mellanox.com>, Jesper Dangaard Brouer <brouer@redhat.com>, bjorn.topel@intel.com, Alexei Starovoitov <alexei.starovoitov@gmail.com>, Tariq Toukan <tariqt@mellanox.com>

This is an RFC patchset of my *work-in-progress* page_pool implemenation.
This is NOT ready for inclusion.  People asked to see the code, so here we go.

This patchset is focused providing a generic replacement for the
driver page recycle caches. Where mlx5 is the first user in patch-3.

Notice that patch-2 is more "MM-invasive" (modifies put_page) than
patch-4 which is less MM-agressive (scaled back based on input from
Mel Gorman).

I do know that all page-flags are used (for 32bit), thus I'm open to
suggestions/ideas on howto work-around this (need some way to identify
a page belongs to a page pool).


This patchset is the bare-minimum PoC that allows me to benchmarks
these ideas and see if performance is going in the right direction.
It is not safe, e.g. unloading the driver can crash the kernel.

---

Jesper Dangaard Brouer (4):
      doc: page_pool introduction documentation
      page_pool: basic implementation of page_pool
      mlx5: use page_pool
      page_pool: change refcnt model


 Documentation/vm/page_pool/introduction.rst       |   71 ++++
 drivers/net/ethernet/mellanox/mlx5/core/en.h      |    1 
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c |   28 +
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c   |   47 ++
 include/linux/mm.h                                |    1 
 include/linux/mm_types.h                          |   11 +
 include/linux/page-flags.h                        |   13 +
 include/linux/page_pool.h                         |  168 +++++++++
 include/linux/skbuff.h                            |    2 
 include/trace/events/mmflags.h                    |    3 
 mm/Makefile                                       |    3 
 mm/page_alloc.c                                   |    6 
 mm/page_pool.c                                    |  402 +++++++++++++++++++++
 mm/slub.c                                         |    4 
 mm/swap.c                                         |    3 
 15 files changed, 741 insertions(+), 22 deletions(-)
 create mode 100644 Documentation/vm/page_pool/introduction.rst
 create mode 100644 include/linux/page_pool.h
 create mode 100644 mm/page_pool.c

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
