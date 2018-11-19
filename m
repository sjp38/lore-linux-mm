Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 18C3A6B1A39
	for <linux-mm@kvack.org>; Mon, 19 Nov 2018 08:48:43 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id h86-v6so21473843pfd.2
        for <linux-mm@kvack.org>; Mon, 19 Nov 2018 05:48:43 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id v189si38253742pgb.398.2018.11.19.05.48.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Nov 2018 05:48:41 -0800 (PST)
From: Aaron Lu <aaron.lu@intel.com>
Subject: [PATCH v2 RESEND 1/2] mm/page_alloc: free order-0 pages through PCP in page_frag_free()
Date: Mon, 19 Nov 2018 21:48:33 +0800
Message-Id: <20181119134834.17765-2-aaron.lu@intel.com>
In-Reply-To: <20181119134834.17765-1-aaron.lu@intel.com>
References: <20181119134834.17765-1-aaron.lu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, =?UTF-8?q?Pawe=C5=82=20Staszewski?= <pstaszewski@itcare.pl>, Jesper Dangaard Brouer <brouer@redhat.com>, Eric Dumazet <eric.dumazet@gmail.com>, Tariq Toukan <tariqt@mellanox.com>, Ilias Apalodimas <ilias.apalodimas@linaro.org>, Yoel Caspersen <yoel@kviknet.dk>, Mel Gorman <mgorman@techsingularity.net>, Saeed Mahameed <saeedm@mellanox.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Dave Hansen <dave.hansen@linux.intel.com>, Alexander Duyck <alexander.h.duyck@linux.intel.com>, Ian Kumlien <ian.kumlien@gmail.com>

page_frag_free() calls __free_pages_ok() to free the page back to
Buddy. This is OK for high order page, but for order-0 pages, it
misses the optimization opportunity of using Per-Cpu-Pages and can
cause zone lock contention when called frequently.

PaweA? Staszewski recently shared his result of 'how Linux kernel
handles normal traffic'[1] and from perf data, Jesper Dangaard Brouer
found the lock contention comes from page allocator:

  mlx5e_poll_tx_cq
  |
   --16.34%--napi_consume_skb
             |
             |--12.65%--__free_pages_ok
             |          |
             |           --11.86%--free_one_page
             |                     |
             |                     |--10.10%--queued_spin_lock_slowpath
             |                     |
             |                      --0.65%--_raw_spin_lock
             |
             |--1.55%--page_frag_free
             |
              --1.44%--skb_release_data

Jesper explained how it happened: mlx5 driver RX-page recycle
mechanism is not effective in this workload and pages have to go
through the page allocator. The lock contention happens during
mlx5 DMA TX completion cycle. And the page allocator cannot keep
up at these speeds.[2]

I thought that __free_pages_ok() are mostly freeing high order
pages and thought this is an lock contention for high order pages
but Jesper explained in detail that __free_pages_ok() here are
actually freeing order-0 pages because mlx5 is using order-0 pages
to satisfy its page pool allocation request.[3]

The free path as pointed out by Jesper is:
skb_free_head()
  -> skb_free_frag()
    -> page_frag_free()
And the pages being freed on this path are order-0 pages.

Fix this by doing similar things as in __page_frag_cache_drain() -
send the being freed page to PCP if it's an order-0 page, or
directly to Buddy if it is a high order page.

With this change, PaweA? hasn't noticed lock contention yet in
his workload and Jesper has noticed a 7% performance improvement
using a micro benchmark and lock contention is gone. Ilias' test
on a 'low' speed 1Gbit interface on an cortex-a53 shows ~11%
performance boost testing with 64byte packets and __free_pages_ok()
disappeared from perf top.

[1]: https://www.spinics.net/lists/netdev/msg531362.html
[2]: https://www.spinics.net/lists/netdev/msg531421.html
[3]: https://www.spinics.net/lists/netdev/msg531556.html

Reported-by: PaweA? Staszewski <pstaszewski@itcare.pl>
Analysed-by: Jesper Dangaard Brouer <brouer@redhat.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Acked-by: Mel Gorman <mgorman@techsingularity.net>
Acked-by: Jesper Dangaard Brouer <brouer@redhat.com>
Acked-by: Ilias Apalodimas <ilias.apalodimas@linaro.org>
Tested-by: Ilias Apalodimas <ilias.apalodimas@linaro.org>
Acked-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Acked-by: Tariq Toukan <tariqt@mellanox.com
Signed-off-by: Aaron Lu <aaron.lu@intel.com>
---
 mm/page_alloc.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 421c5b652708..8f8c6b33b637 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4677,8 +4677,14 @@ void page_frag_free(void *addr)
 {
 	struct page *page = virt_to_head_page(addr);
 
-	if (unlikely(put_page_testzero(page)))
-		__free_pages_ok(page, compound_order(page));
+	if (unlikely(put_page_testzero(page))) {
+		unsigned int order = compound_order(page);
+
+		if (order == 0)
+			free_unref_page(page);
+		else
+			__free_pages_ok(page, order);
+	}
 }
 EXPORT_SYMBOL(page_frag_free);
 
-- 
2.17.2
