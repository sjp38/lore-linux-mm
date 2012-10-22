Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id C550A6B0062
	for <linux-mm@kvack.org>; Mon, 22 Oct 2012 15:03:47 -0400 (EDT)
Received: by mail-ea0-f169.google.com with SMTP id k11so1118509eaa.14
        for <linux-mm@kvack.org>; Mon, 22 Oct 2012 12:03:46 -0700 (PDT)
Subject: [PATCH] net: fix secpath kmemleak
From: Eric Dumazet <eric.dumazet@gmail.com>
In-Reply-To: <1350926647.8609.1006.camel@edumazet-glaptop>
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
	 <1350893743.8609.424.camel@edumazet-glaptop>
	 <20121022180655.50a50401@sacrilege>
	 <1350918997.8609.858.camel@edumazet-glaptop>
	 <1350919337.8609.869.camel@edumazet-glaptop>
	 <1350919682.8609.877.camel@edumazet-glaptop>
	 <20121022225918.32d86a5f@sacrilege>
	 <1350926647.8609.1006.camel@edumazet-glaptop>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 22 Oct 2012 21:03:40 +0200
Message-ID: <1350932620.8609.1142.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kazantsev <mk.fraggod@gmail.com>, David Miller <davem@davemloft.net>
Cc: Paul Moore <paul@paul-moore.com>, netdev@vger.kernel.org, linux-mm@kvack.org

From: Eric Dumazet <edumazet@google.com>

Mike Kazantsev found 3.5 kernels and beyond were leaking memory,
and tracked the faulty commit to a1c7fff7e18f59e (net:
netdev_alloc_skb() use build_skb()

While this commit seems fine, it uncovered a bug introduced
in commit bad43ca8325 (net: introduce skb_try_coalesce()), in function
kfree_skb_partial() :

If head is stolen, we free the sk_buff,
without removing references on secpath (skb->sp).

So IPsec + IP defrag/reassembly (using skb coalescing), or
TCP coalescing could leak secpath objects.

Fix this bug by calling skb_release_head_state(skb) to properly
release all possible references to linked objects.

Reported-by: Mike Kazantsev <mk.fraggod@gmail.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Bisected-by: Mike Kazantsev <mk.fraggod@gmail.com>
Tested-by: Mike Kazantsev <mk.fraggod@gmail.com>
---
It seems TCP stack could immediately release secpath references instead
of waiting skb are eaten by consumer, thats will be a followup patch.

 net/core/skbuff.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 6e04b1f..4007c14 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3379,10 +3379,12 @@ EXPORT_SYMBOL(__skb_warn_lro_forwarding);
 
 void kfree_skb_partial(struct sk_buff *skb, bool head_stolen)
 {
-	if (head_stolen)
+	if (head_stolen) {
+		skb_release_head_state(skb);
 		kmem_cache_free(skbuff_head_cache, skb);
-	else
+	} else {
 		__kfree_skb(skb);
+	}
 }
 EXPORT_SYMBOL(kfree_skb_partial);
 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
