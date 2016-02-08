Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f54.google.com (mail-qg0-f54.google.com [209.85.192.54])
	by kanga.kvack.org (Postfix) with ESMTP id BEE54828E1
	for <linux-mm@kvack.org>; Mon,  8 Feb 2016 07:15:07 -0500 (EST)
Received: by mail-qg0-f54.google.com with SMTP id y89so41541784qge.2
        for <linux-mm@kvack.org>; Mon, 08 Feb 2016 04:15:07 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 33si30164003qgj.71.2016.02.08.04.15.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Feb 2016 04:15:07 -0800 (PST)
Subject: [net-next PATCH V2 2/3] net: bulk free SKBs that were delay free'ed
 due to IRQ context
From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Mon, 08 Feb 2016 13:15:04 +0100
Message-ID: <20160208121504.8860.54430.stgit@localhost>
In-Reply-To: <20160208121328.8860.67014.stgit@localhost>
References: <20160208121328.8860.67014.stgit@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: netdev@vger.kernel.org, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, tom@herbertland.com, Alexander Duyck <alexander.duyck@gmail.com>, alexei.starovoitov@gmail.com, linux-mm@kvack.org, Jesper Dangaard Brouer <brouer@redhat.com>, Christoph Lameter <cl@linux.com>, "David S. Miller" <davem@davemloft.net>

The network stack defers SKBs free, in-case free happens in IRQ or
when IRQs are disabled. This happens in __dev_kfree_skb_irq() that
writes SKBs that were free'ed during IRQ to the softirq completion
queue (softnet_data.completion_queue).

These SKBs are naturally delayed, and cleaned up during NET_TX_SOFTIRQ
in function net_tx_action().  Take advantage of this a use the skb
defer and flush API, as we are already in softirq context.

For modern drivers this rarely happens. Although most drivers do call
dev_kfree_skb_any(), which detects the situation and calls
__dev_kfree_skb_irq() when needed.  This due to netpoll can call from
IRQ context.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 include/linux/skbuff.h |    1 +
 net/core/dev.c         |    8 +++++++-
 net/core/skbuff.c      |    8 ++++++--
 3 files changed, 14 insertions(+), 3 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 3c8d348223d7..b06ba2e07c89 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2402,6 +2402,7 @@ static inline struct sk_buff *napi_alloc_skb(struct napi_struct *napi,
 void napi_consume_skb(struct sk_buff *skb, int budget);
 
 void __kfree_skb_flush(void);
+void __kfree_skb_defer(struct sk_buff *skb);
 
 /**
  * __dev_alloc_pages - allocate page for network Rx
diff --git a/net/core/dev.c b/net/core/dev.c
index 44384a8c9613..b185d7eaa2e4 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3829,8 +3829,14 @@ static void net_tx_action(struct softirq_action *h)
 				trace_consume_skb(skb);
 			else
 				trace_kfree_skb(skb, net_tx_action);
-			__kfree_skb(skb);
+
+			if (skb->fclone != SKB_FCLONE_UNAVAILABLE)
+				__kfree_skb(skb);
+			else
+				__kfree_skb_defer(skb);
 		}
+
+		__kfree_skb_flush();
 	}
 
 	if (sd->output_queue) {
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index e26bb2b1dba4..d278e51789e9 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -767,7 +767,7 @@ void __kfree_skb_flush(void)
 	}
 }
 
-static void __kfree_skb_defer(struct sk_buff *skb)
+static inline void _kfree_skb_defer(struct sk_buff *skb)
 {
 	struct napi_alloc_cache *nc = this_cpu_ptr(&napi_alloc_cache);
 
@@ -789,6 +789,10 @@ static void __kfree_skb_defer(struct sk_buff *skb)
 		nc->skb_count = 0;
 	}
 }
+void __kfree_skb_defer(struct sk_buff *skb)
+{
+	_kfree_skb_defer(skb);
+}
 
 void napi_consume_skb(struct sk_buff *skb, int budget)
 {
@@ -814,7 +818,7 @@ void napi_consume_skb(struct sk_buff *skb, int budget)
 		return;
 	}
 
-	__kfree_skb_defer(skb);
+	_kfree_skb_defer(skb);
 }
 EXPORT_SYMBOL(napi_consume_skb);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
