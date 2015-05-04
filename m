Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 3663F6B0038
	for <linux-mm@kvack.org>; Mon,  4 May 2015 19:14:49 -0400 (EDT)
Received: by wgso17 with SMTP id o17so165497482wgs.1
        for <linux-mm@kvack.org>; Mon, 04 May 2015 16:14:48 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id cu4si24904202wjb.191.2015.05.04.16.14.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 May 2015 16:14:47 -0700 (PDT)
Subject: [net-next PATCH 0/6] Add skb_free_frag to replace
 put_page(virt_to_head_page(ptr))
From: Alexander Duyck <alexander.h.duyck@redhat.com>
Date: Mon, 04 May 2015 16:14:42 -0700
Message-ID: <20150504231000.1538.70520.stgit@ahduyck-vm-fedora22>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, netdev@vger.kernel.org
Cc: akpm@linux-foundation.org, davem@davemloft.net

This patch set cleans up some of the handling of page frags used in the skb
allocation.  The issue was we were having to use a number of calls to
virt_to_head_page in a number of places and then following that up with
put_page.  Both calls end up being expensive, the first due to size, and
the second due to the fact that we end up having to call a number of other
functions before we finally see the page freed in the case of compound
pages.

The skb_free_frag function is meant to resolve that by providing a
centralized location for the virt_to_head_page call and by coalesing
several checks such as the check for PageHead into a single check so that
we can keep the instruction cound minimal when freeing the page frag.

With this change I am seeing an improvement of about 5% in a simple
receive/drop test.

---

Alexander Duyck (6):
      net: Add skb_free_frag to replace use of put_page in freeing skb->head
      netcp: Replace put_page(virt_to_head_page(ptr)) w/ skb_free_frag
      mvneta: Replace put_page(virt_to_head_page(ptr)) w/ skb_free_frag
      e1000: Replace e1000_free_frag with skb_free_frag
      hisilicon: Replace put_page(virt_to_head_page()) with skb_free_frag()
      bnx2x, tg3: Replace put_page(virt_to_head_page()) with skb_free_frag()


 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c |    2 +-
 drivers/net/ethernet/broadcom/tg3.c             |    2 +-
 drivers/net/ethernet/hisilicon/hip04_eth.c      |    2 +-
 drivers/net/ethernet/intel/e1000/e1000_main.c   |   19 ++++++---------
 drivers/net/ethernet/marvell/mvneta.c           |    2 +-
 drivers/net/ethernet/ti/netcp_core.c            |    2 +-
 include/linux/gfp.h                             |    1 +
 include/linux/skbuff.h                          |    1 +
 mm/page_alloc.c                                 |    4 +--
 net/core/skbuff.c                               |   29 +++++++++++++++++++++--
 10 files changed, 41 insertions(+), 23 deletions(-)

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
