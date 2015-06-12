Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f170.google.com (mail-qk0-f170.google.com [209.85.220.170])
	by kanga.kvack.org (Postfix) with ESMTP id DED3C6B0032
	for <linux-mm@kvack.org>; Thu, 11 Jun 2015 20:34:22 -0400 (EDT)
Received: by qkhq76 with SMTP id q76so10289225qkh.2
        for <linux-mm@kvack.org>; Thu, 11 Jun 2015 17:34:22 -0700 (PDT)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2001:4f8:3:36:211:85ff:fe63:a549])
        by mx.google.com with ESMTP id v108si2272193qge.0.2015.06.11.17.34.21
        for <linux-mm@kvack.org>;
        Thu, 11 Jun 2015 17:34:21 -0700 (PDT)
Date: Thu, 11 Jun 2015 17:34:19 -0700 (PDT)
Message-Id: <20150611.173419.1266197335293542334.davem@davemloft.net>
Subject: Re: [RFC V3] net: don't wait for order-3 page allocation
From: David Miller <davem@davemloft.net>
In-Reply-To: <0099265406c32b9b9057de100404a4148d602cdd.1434066549.git.shli@fb.com>
References: <0099265406c32b9b9057de100404a4148d602cdd.1434066549.git.shli@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: shli@fb.com
Cc: netdev@vger.kernel.org, Kernel-team@fb.com, clm@fb.com, linux-mm@kvack.org, dbavatar@gmail.com, edumazet@google.com

From: Shaohua Li <shli@fb.com>
Date: Thu, 11 Jun 2015 16:50:48 -0700

> We saw excessive direct memory compaction triggered by skb_page_frag_refill.
> This causes performance issues and add latency. Commit 5640f7685831e0
> introduces the order-3 allocation. According to the changelog, the order-3
> allocation isn't a must-have but to improve performance. But direct memory
> compaction has high overhead. The benefit of order-3 allocation can't
> compensate the overhead of direct memory compaction.
> 
> This patch makes the order-3 page allocation atomic. If there is no memory
> pressure and memory isn't fragmented, the alloction will still success, so we
> don't sacrifice the order-3 benefit here. If the atomic allocation fails,
> direct memory compaction will not be triggered, skb_page_frag_refill will
> fallback to order-0 immediately, hence the direct memory compaction overhead is
> avoided. In the allocation failure case, kswapd is waken up and doing
> compaction, so chances are allocation could success next time.
> 
> alloc_skb_with_frags is the same.
> 
> The mellanox driver does similar thing, if this is accepted, we must fix
> the driver too.
> 
> V3: fix the same issue in alloc_skb_with_frags as pointed out by Eric
> V2: make the changelog clearer
> 
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Chris Mason <clm@fb.com>
> Cc: Debabrata Banerjee <dbavatar@gmail.com>
> Signed-off-by: Shaohua Li <shli@fb.com>

Applied and queued up for -stable, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
