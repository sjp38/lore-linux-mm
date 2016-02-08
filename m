Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f47.google.com (mail-qg0-f47.google.com [209.85.192.47])
	by kanga.kvack.org (Postfix) with ESMTP id 89C2C828E1
	for <linux-mm@kvack.org>; Mon,  8 Feb 2016 07:14:58 -0500 (EST)
Received: by mail-qg0-f47.google.com with SMTP id y9so111364086qgd.3
        for <linux-mm@kvack.org>; Mon, 08 Feb 2016 04:14:58 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g60si25568190qgf.118.2016.02.08.04.14.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Feb 2016 04:14:57 -0800 (PST)
Subject: [net-next PATCH V2 0/3] net: mitigating kmem_cache free slowpath
From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Mon, 08 Feb 2016 13:14:54 +0100
Message-ID: <20160208121328.8860.67014.stgit@localhost>
In-Reply-To: <20160207.142526.1252110536030712971.davem@davemloft.net>
References: <20160207.142526.1252110536030712971.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: netdev@vger.kernel.org, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, tom@herbertland.com, Alexander Duyck <alexander.duyck@gmail.com>, alexei.starovoitov@gmail.com, linux-mm@kvack.org, Jesper Dangaard Brouer <brouer@redhat.com>, Christoph Lameter <cl@linux.com>, "David S. Miller" <davem@davemloft.net>

This patchset is the first real use-case for kmem_cache bulk _free_.
The use of bulk _alloc_ is NOT included in this patchset. The full use
have previously been posted here [1].

The bulk free side have the largest benefit for the network stack
use-case, because network stack is hitting the kmem_cache/SLUB
slowpath when freeing SKBs, due to the amount of outstanding SKBs.
This is solved by using the new API kmem_cache_free_bulk().

Introduce new API napi_consume_skb(), that hides/handles bulk freeing
for the caller.  The drivers simply need to use this call when freeing
SKBs in NAPI context, e.g. replacing their calles to dev_kfree_skb() /
dev_consume_skb_any().

Driver ixgbe is the first user of this new API.

[1] http://thread.gmane.org/gmane.linux.network/384302/focus=397373

---

Jesper Dangaard Brouer (3):
      net: bulk free infrastructure for NAPI context, use napi_consume_skb
      net: bulk free SKBs that were delay free'ed due to IRQ context
      ixgbe: bulk free SKBs during TX completion cleanup cycle


 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    6 +-
 include/linux/skbuff.h                        |    4 +
 net/core/dev.c                                |    9 ++-
 net/core/skbuff.c                             |   87 +++++++++++++++++++++++--
 4 files changed, 96 insertions(+), 10 deletions(-)

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
