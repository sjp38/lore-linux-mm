Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f44.google.com (mail-qg0-f44.google.com [209.85.192.44])
	by kanga.kvack.org (Postfix) with ESMTP id 07BBA6B0070
	for <linux-mm@kvack.org>; Thu,  7 May 2015 00:11:49 -0400 (EDT)
Received: by qgfi89 with SMTP id i89so15380298qgf.1
        for <linux-mm@kvack.org>; Wed, 06 May 2015 21:11:48 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u5si856148qgu.115.2015.05.06.21.11.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 May 2015 21:11:48 -0700 (PDT)
Subject: [PATCH 02/10] igb: Don't use NETDEV_FRAG_PAGE_MAX_SIZE in
 descriptor calculation
From: Alexander Duyck <alexander.h.duyck@redhat.com>
Date: Wed, 06 May 2015 21:11:45 -0700
Message-ID: <20150507041145.1873.66455.stgit@ahduyck-vm-fedora22>
In-Reply-To: <20150507035558.1873.52664.stgit@ahduyck-vm-fedora22>
References: <20150507035558.1873.52664.stgit@ahduyck-vm-fedora22>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: netdev@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, davem@davemloft.net, eric.dumazet@gmail.com

This change updates igb so that it will correctly perform the descriptor
count calculation.  Previously it was taking NETDEV_FRAG_PAGE_MAX_SIZE
into account with isn't really correct since a different value is used to
determine the size of the pages used for TCP.  That is actually determined
by SKB_FRAG_PAGE_ORDER.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c |   11 +++--------
 1 file changed, 3 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index d3b4098fce48..1394642e4859 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -4974,6 +4974,7 @@ netdev_tx_t igb_xmit_frame_ring(struct sk_buff *skb,
 	struct igb_tx_buffer *first;
 	int tso;
 	u32 tx_flags = 0;
+	unsigned short f;
 	u16 count = TXD_USE_COUNT(skb_headlen(skb));
 	__be16 protocol = vlan_get_protocol(skb);
 	u8 hdr_len = 0;
@@ -4984,14 +4985,8 @@ netdev_tx_t igb_xmit_frame_ring(struct sk_buff *skb,
 	 *       + 1 desc for context descriptor,
 	 * otherwise try next time
 	 */
-	if (NETDEV_FRAG_PAGE_MAX_SIZE > IGB_MAX_DATA_PER_TXD) {
-		unsigned short f;
-
-		for (f = 0; f < skb_shinfo(skb)->nr_frags; f++)
-			count += TXD_USE_COUNT(skb_shinfo(skb)->frags[f].size);
-	} else {
-		count += skb_shinfo(skb)->nr_frags;
-	}
+	for (f = 0; f < skb_shinfo(skb)->nr_frags; f++)
+		count += TXD_USE_COUNT(skb_shinfo(skb)->frags[f].size);
 
 	if (igb_maybe_stop_tx(tx_ring, count + 3)) {
 		/* this is a hard error */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
