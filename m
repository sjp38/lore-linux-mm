Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 928866B0072
	for <linux-mm@kvack.org>; Mon, 22 Oct 2012 04:15:48 -0400 (EDT)
Received: by mail-bk0-f41.google.com with SMTP id jm1so806002bkc.14
        for <linux-mm@kvack.org>; Mon, 22 Oct 2012 01:15:46 -0700 (PDT)
Subject: Re: PROBLEM: Memory leak (at least with SLUB) from "secpath_dup"
 (xfrm) in 3.5+ kernels
From: Eric Dumazet <eric.dumazet@gmail.com>
In-Reply-To: <20121022045850.788df346@sacrilege>
References: <20121019205055.2b258d09@sacrilege>
	 <20121019233632.26cf96d8@sacrilege>
	 <CAHC9VhQ+gkAaRmwDWqzQd1U-hwH__5yxrxWa5_=koz_XTSXpjQ@mail.gmail.com>
	 <20121020204958.4bc8e293@sacrilege> <20121021044540.12e8f4b7@sacrilege>
	 <20121021062402.7c4c4cb8@sacrilege>
	 <1350826183.13333.2243.camel@edumazet-glaptop>
	 <20121021195701.7a5872e7@sacrilege> <20121022004332.7e3f3f29@sacrilege>
	 <20121022015134.4de457b9@sacrilege>
	 <1350856053.8609.217.camel@edumazet-glaptop>
	 <20121022045850.788df346@sacrilege>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 22 Oct 2012 10:15:43 +0200
Message-ID: <1350893743.8609.424.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kazantsev <mk.fraggod@gmail.com>
Cc: Paul Moore <paul@paul-moore.com>, netdev@vger.kernel.org, linux-mm@kvack.org

On Mon, 2012-10-22 at 04:58 +0600, Mike Kazantsev wrote:

> I've grepped for "/org/free" specifically and sure enough, same scraps
> of data seem to be in some of the (varied) dumps there.

Content is not meaningful, as we dont initialize it.
So you see previous content.

Could you try the following :

diff --git a/net/core/dev.c b/net/core/dev.c
index 09cb3f6..a903cca 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2977,6 +2977,9 @@ int netif_rx(struct sk_buff *skb)
 {
 	int ret;
 
+#ifdef CONFIG_XFRM
+	WARN_ON_ONCE(skb->sp);
+#endif
 	/* if netpoll wants it, pretend we never saw it */
 	if (netpoll_rx(skb))
 		return NET_RX_DROP;
@@ -3388,6 +3391,9 @@ out:
  */
 int netif_receive_skb(struct sk_buff *skb)
 {
+#ifdef CONFIG_XFRM
+	WARN_ON_ONCE(skb->sp);
+#endif
 	net_timestamp_check(netdev_tstamp_prequeue, skb);
 
 	if (skb_defer_rx_timestamp(skb))
diff --git a/net/xfrm/xfrm_input.c b/net/xfrm/xfrm_input.c
index ab2bb42..5930e91 100644
--- a/net/xfrm/xfrm_input.c
+++ b/net/xfrm/xfrm_input.c
@@ -29,11 +29,10 @@ struct sec_path *secpath_dup(struct sec_path *src)
 {
 	struct sec_path *sp;
 
-	sp = kmem_cache_alloc(secpath_cachep, GFP_ATOMIC);
+	sp = kmem_cache_zalloc(secpath_cachep, GFP_ATOMIC);
 	if (!sp)
 		return NULL;
 
-	sp->len = 0;
 	if (src) {
 		int i;
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
