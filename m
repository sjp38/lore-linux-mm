Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 17BB96B0071
	for <linux-mm@kvack.org>; Mon, 22 Oct 2012 15:18:03 -0400 (EDT)
Date: Mon, 22 Oct 2012 15:17:58 -0400 (EDT)
Message-Id: <20121022.151758.1535731378259139241.davem@davemloft.net>
Subject: Re: [PATCH] net: fix secpath kmemleak
From: David Miller <davem@davemloft.net>
In-Reply-To: <1350932620.8609.1142.camel@edumazet-glaptop>
References: <20121022225918.32d86a5f@sacrilege>
	<1350926647.8609.1006.camel@edumazet-glaptop>
	<1350932620.8609.1142.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: eric.dumazet@gmail.com
Cc: mk.fraggod@gmail.com, paul@paul-moore.com, netdev@vger.kernel.org, linux-mm@kvack.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 22 Oct 2012 21:03:40 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> Mike Kazantsev found 3.5 kernels and beyond were leaking memory,
> and tracked the faulty commit to a1c7fff7e18f59e (net:
> netdev_alloc_skb() use build_skb()
> 
> While this commit seems fine, it uncovered a bug introduced
> in commit bad43ca8325 (net: introduce skb_try_coalesce()), in function
> kfree_skb_partial() :
> 
> If head is stolen, we free the sk_buff,
> without removing references on secpath (skb->sp).
> 
> So IPsec + IP defrag/reassembly (using skb coalescing), or
> TCP coalescing could leak secpath objects.
> 
> Fix this bug by calling skb_release_head_state(skb) to properly
> release all possible references to linked objects.
> 
> Reported-by: Mike Kazantsev <mk.fraggod@gmail.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Bisected-by: Mike Kazantsev <mk.fraggod@gmail.com>
> Tested-by: Mike Kazantsev <mk.fraggod@gmail.com>

Applied and queued up for -stable, thanks!

> It seems TCP stack could immediately release secpath references instead
> of waiting skb are eaten by consumer, thats will be a followup patch.

Indeed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
