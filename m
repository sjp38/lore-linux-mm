Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0C5F06B0253
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 10:24:35 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id f144so20562265pfa.3
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 07:24:35 -0800 (PST)
Received: from mail-pg0-x241.google.com (mail-pg0-x241.google.com. [2607:f8b0:400e:c05::241])
        by mx.google.com with ESMTPS id v190si533760pgb.58.2017.01.18.07.24.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jan 2017 07:24:34 -0800 (PST)
Received: by mail-pg0-x241.google.com with SMTP id 75so1634972pgf.3
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 07:24:34 -0800 (PST)
Message-ID: <1484753071.13165.106.camel@edumazet-glaptop3.roam.corp.google.com>
Subject: Re: [PATCH net-next] mlx4: support __GFP_MEMALLOC for rx
From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 18 Jan 2017 07:24:31 -0800
In-Reply-To: <ed9a6b2a-428e-ac78-bba8-742f5e7c1eed@yandex-team.ru>
References: 
	<1484712850.13165.86.camel@edumazet-glaptop3.roam.corp.google.com>
	 <2696ea05-bb39-787b-2029-33b729fd88e0@yandex-team.ru>
	 <1484749428.13165.100.camel@edumazet-glaptop3.roam.corp.google.com>
	 <ed9a6b2a-428e-ac78-bba8-742f5e7c1eed@yandex-team.ru>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>, Tariq Toukan <tariqt@mellanox.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Wed, 2017-01-18 at 18:11 +0300, Konstantin Khlebnikov wrote:
> On 18.01.2017 17:23, Eric Dumazet wrote:

> >
> > Take a look at sk_filter_trim_cap(), where the RX packets received on a
> > socket which does not have SOCK_MEMALLOC is dropped.
> >
> >         /*
> >          * If the skb was allocated from pfmemalloc reserves, only
> >          * allow SOCK_MEMALLOC sockets to use it as this socket is
> >          * helping free memory
> >          */
> >         if (skb_pfmemalloc(skb) && !sock_flag(sk, SOCK_MEMALLOC))
> >                 return -ENOMEM;
> 
> I suppose this happens in BH context right after receiving packet?
> 
> Potentially any ACK could free memory in TCP send queue,
> so using reserves here makes sense.

Yes, but only sockets with SOCK_MEMALLOC have this contract with the mm
layer.

For 'other' sockets, one possible trick would be that if only the page
fragment attached to skb had the pfmemalloc bit, and not the sk_buff
itself, we could attempt a skb_condense() operation [1], but it is not
really easy to properly recompute skb->pfmemalloc.

Pure TCP ACK packets can usually be trimmed by skb_condense().
Since they have no payload, we have a guarantee they wont sit in a queue
and hold memory.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
