Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f174.google.com (mail-io0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id A66036B0256
	for <linux-mm@kvack.org>; Fri,  4 Sep 2015 13:01:09 -0400 (EDT)
Received: by iofb144 with SMTP id b144so30846311iof.1
        for <linux-mm@kvack.org>; Fri, 04 Sep 2015 10:01:09 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id na7si456183pdb.93.2015.09.04.10.01.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Sep 2015 10:01:09 -0700 (PDT)
Subject: [RFC PATCH 2/3] net: NIC helper API for building array of skbs to
 free
From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Fri, 04 Sep 2015 19:01:06 +0200
Message-ID: <20150904170104.4312.47707.stgit@devil>
In-Reply-To: <20150904165944.4312.32435.stgit@devil>
References: <20150904165944.4312.32435.stgit@devil>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: netdev@vger.kernel.org, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Jesper Dangaard Brouer <brouer@redhat.com>, aravinda@linux.vnet.ibm.com, Christoph Lameter <cl@linux.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, iamjoonsoo.kim@lge.com

The NIC device drivers are expected to use this small helper API, when
building up an array of objects/skbs to bulk free, while (loop)
processing objects to free.  Objects to be free'ed later is added
(dev_free_waitlist_add) to an array and flushed if the array runs
full.  After processing the array is flushed (dev_free_waitlist_flush).
The array should be stored on the local stack.

Usage e.g. during TX completion loop the NIC driver can replace
dev_consume_skb_any() with an "add" and after the loop a "flush".

For performance reasons the compiler should inline most of these
functions.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 include/linux/netdevice.h |   62 +++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 62 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 05b9a694e213..d0133e778314 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2935,6 +2935,68 @@ static inline void dev_consume_skb_any(struct sk_buff *skb)
 	__dev_kfree_skb_any(skb, SKB_REASON_CONSUMED);
 }
 
+/* The NIC device drivers are expected to use this small helper API,
+ * when building up an array of objects/skbs to bulk free, while
+ * (loop) processing objects to free.  Objects to be free'ed later is
+ * added (dev_free_waitlist_add) to an array and flushed if the array
+ * runs full.  After processing the array is flushed (dev_free_waitlist_flush).
+ * The array should be stored on the local stack.
+ *
+ * Usage e.g. during TX completion loop the NIC driver can replace
+ * dev_consume_skb_any() with an "add" and after the loop a "flush".
+ *
+ * For performance reasons the compiler should inline most of these
+ * functions.
+ */
+struct dev_free_waitlist {
+	struct sk_buff **skbs;
+	unsigned int skb_cnt;
+};
+
+static void __dev_free_waitlist_bulkfree(struct dev_free_waitlist *wl)
+{
+	/* Cannot bulk free from interrupt context or with IRQs
+	 * disabled, due to how SLAB bulk API works (and gain it's
+	 * speedup).  This can e.g. happen due to invocation from
+	 * netconsole/netpoll.
+	 */
+	if (unlikely(in_irq() || irqs_disabled())) {
+		int i;
+
+		for (i = 0; i < wl->skb_cnt; i++)
+			dev_consume_skb_irq(wl->skbs[i]);
+	} else {
+		/* Likely fastpath, don't call with cnt == 0 */
+		kfree_skb_bulk(wl->skbs, wl->skb_cnt);
+	}
+}
+
+static inline void dev_free_waitlist_flush(struct dev_free_waitlist *wl)
+{
+	/* Flush the waitlist, but only if any objects remain, as bulk
+	 * freeing "zero" objects is not supported and plus it avoids
+	 * pointless function calls.
+	 */
+	if (likely(wl->skb_cnt))
+		__dev_free_waitlist_bulkfree(wl);
+}
+
+static __always_inline void dev_free_waitlist_add(struct dev_free_waitlist *wl,
+						  struct sk_buff *skb,
+						  unsigned int max)
+{
+	/* It is recommended that max is a builtin constant, as this
+	 * saves one register when inlined. Catch offenders with:
+	 * BUILD_BUG_ON(!__builtin_constant_p(max));
+	 */
+	wl->skbs[wl->skb_cnt++] = skb;
+	if (wl->skb_cnt == max) {
+		/* Detect when waitlist array is full, then flush and reset */
+		__dev_free_waitlist_bulkfree(wl);
+		wl->skb_cnt = 0;
+	}
+}
+
 int netif_rx(struct sk_buff *skb);
 int netif_rx_ni(struct sk_buff *skb);
 int netif_receive_skb_sk(struct sock *sk, struct sk_buff *skb);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
