Date: Wed, 09 Oct 2002 22:59:41 -0700 (PDT)
Message-Id: <20021009.225941.88169695.davem@redhat.com>
Subject: Re: 2.5.41-mm2
From: "David S. Miller" <davem@redhat.com>
In-Reply-To: <3DA512B1.63287C02@digeo.com>
References: <3DA512B1.63287C02@digeo.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@digeo.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

     but we're seeing a consistent few-percent regression in tests which perform
     networking to localhost.

There's debugging code in loopback that is helping us stress test
the TCP segmentation offload, you might want to disable that to
get more reliable numbers in 2.5.x.

Try this:

--- drivers/net/loopback.c.~1~	Wed Oct  9 23:01:16 2002
+++ drivers/net/loopback.c	Wed Oct  9 23:01:35 2002
@@ -190,12 +190,12 @@
 	dev->rebuild_header	= eth_rebuild_header;
 	dev->flags		= IFF_LOOPBACK;
 	dev->features		= NETIF_F_SG|NETIF_F_FRAGLIST|NETIF_F_NO_CSUM|NETIF_F_HIGHDMA;
-
+#if 0
 	/* Current netfilter will die with oom linearizing large skbs,
 	 * however this will be cured before 2.5.x is done.
 	 */
 	dev->features	       |= NETIF_F_TSO;
-
+#endif
 	dev->priv = kmalloc(sizeof(struct net_device_stats), GFP_KERNEL);
 	if (dev->priv == NULL)
 			return -ENOMEM;
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
