Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f180.google.com (mail-qk0-f180.google.com [209.85.220.180])
	by kanga.kvack.org (Postfix) with ESMTP id AF5036B007E
	for <linux-mm@kvack.org>; Sat,  9 Apr 2016 08:34:42 -0400 (EDT)
Received: by mail-qk0-f180.google.com with SMTP id o6so54127212qkc.2
        for <linux-mm@kvack.org>; Sat, 09 Apr 2016 05:34:42 -0700 (PDT)
Received: from mail-qg0-x230.google.com (mail-qg0-x230.google.com. [2607:f8b0:400d:c04::230])
        by mx.google.com with ESMTPS id t26si13547126qki.113.2016.04.09.05.34.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 09 Apr 2016 05:34:41 -0700 (PDT)
Received: by mail-qg0-x230.google.com with SMTP id j35so111199521qge.0
        for <linux-mm@kvack.org>; Sat, 09 Apr 2016 05:34:41 -0700 (PDT)
Message-ID: <1460205278.6473.486.camel@edumazet-glaptop3.roam.corp.google.com>
Subject: Re: [Lsf] [LSF/MM TOPIC] Generic page-pool recycle facility?
From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 09 Apr 2016 05:34:38 -0700
In-Reply-To: <20160409111132.781a11b6@redhat.com>
References: <1460034425.20949.7.camel@HansenPartnership.com>
	 <20160407161715.52635cac@redhat.com>
	 <1460042309.6473.414.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160409111132.781a11b6@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: James Bottomley <James.Bottomley@HansenPartnership.com>, Tom Herbert <tom@herbertland.com>, Brenden Blanco <bblanco@plumgrid.com>, lsf@lists.linux-foundation.org, linux-mm <linux-mm@kvack.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, lsf-pc@lists.linux-foundation.org, Alexei Starovoitov <alexei.starovoitov@gmail.com>

On Sat, 2016-04-09 at 11:11 +0200, Jesper Dangaard Brouer wrote:
> Hi Eric,


> Above code is okay.  But do you think we also can get away with the same
> trick we do with the SKB refcnf?  Where we avoid an atomic operation if
> refcnt==1.
> 
> void kfree_skb(struct sk_buff *skb)
> {
> 	if (unlikely(!skb))
> 		return;
> 	if (likely(atomic_read(&skb->users) == 1))
> 		smp_rmb();
> 	else if (likely(!atomic_dec_and_test(&skb->users)))
> 		return;
> 	trace_kfree_skb(skb, __builtin_return_address(0));
> 	__kfree_skb(skb);
> }
> EXPORT_SYMBOL(kfree_skb);

No we can not use this trick this for pages :

https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=ec91698360b3818ff426488a1529811f7a7ab87f






--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
