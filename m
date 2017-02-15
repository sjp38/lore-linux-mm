Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id C35554405B1
	for <linux-mm@kvack.org>; Wed, 15 Feb 2017 11:57:58 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id e137so74814077itc.0
        for <linux-mm@kvack.org>; Wed, 15 Feb 2017 08:57:58 -0800 (PST)
Received: from mail-it0-x22b.google.com (mail-it0-x22b.google.com. [2607:f8b0:4001:c0b::22b])
        by mx.google.com with ESMTPS id w19si4576633ioi.6.2017.02.15.08.57.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Feb 2017 08:57:57 -0800 (PST)
Received: by mail-it0-x22b.google.com with SMTP id 203so69023602ith.0
        for <linux-mm@kvack.org>; Wed, 15 Feb 2017 08:57:57 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <ccc4cb9e-9863-02e1-2789-4869aea3c661@mellanox.com>
References: <20170213195858.5215-1-edumazet@google.com> <20170213195858.5215-9-edumazet@google.com>
 <CAKgT0Ufx0Y=9kjLax36Gx4e7Y-A7sKZDNYxgJ9wbCT4_vxHhGA@mail.gmail.com>
 <CANn89iLkPB_Dx1L2dFfwOoeXOmPhu_C3OO2yqZi8+Rvjr=-EtA@mail.gmail.com>
 <CAKgT0UeB_e_Z7LM1_r=en8JJdgLhoYFstWpCDQN6iawLYZJKDA@mail.gmail.com>
 <20170214131206.44b644f6@redhat.com> <CANn89i+udp6Y42D9wqmz7U6LGn1mtDRXpQGHAOAeX25eD0dGnQ@mail.gmail.com>
 <cd4f3d91-252b-4796-2bd2-3030c18d9ee6@gmail.com> <1487087488.8227.53.camel@edumazet-glaptop3.roam.corp.google.com>
 <CALx6S3530_2DYU-3VRmvRYZ3n05OqJZpJ3x02vXQd6Q7FUJQvw@mail.gmail.com> <ccc4cb9e-9863-02e1-2789-4869aea3c661@mellanox.com>
From: Eric Dumazet <edumazet@google.com>
Date: Wed, 15 Feb 2017 08:57:56 -0800
Message-ID: <CANn89iJip45peBQB9Tn1mWVg+1QYZH+01CqkAUctd3xqwPw8Zg@mail.gmail.com>
Subject: Re: [PATCH v3 net-next 08/14] mlx4: use order-0 pages for RX
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tariq Toukan <tariqt@mellanox.com>
Cc: Tom Herbert <tom@herbertland.com>, Eric Dumazet <eric.dumazet@gmail.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Alexander Duyck <alexander.duyck@gmail.com>, "David S . Miller" <davem@davemloft.net>, netdev <netdev@vger.kernel.org>, Martin KaFai Lau <kafai@fb.com>, Saeed Mahameed <saeedm@mellanox.com>, Willem de Bruijn <willemb@google.com>, Brenden Blanco <bblanco@plumgrid.com>, Alexei Starovoitov <ast@kernel.org>, linux-mm <linux-mm@kvack.org>

On Wed, Feb 15, 2017 at 8:42 AM, Tariq Toukan <tariqt@mellanox.com> wrote:
>

>
> Isn't it the same principle in page_frag_alloc() ?
> It is called form __netdev_alloc_skb()/__napi_alloc_skb().
>
> Why is it ok to have order-3 pages (PAGE_FRAG_CACHE_MAX_ORDER) there?

This is not ok.

This is a very well known problem, we already mentioned that here in the past,
but at least core networking stack uses  order-0 pages on PowerPC.

mlx4 driver suffers from this problem 100% more than other drivers ;)

One problem at a time Tariq. Right now, only mlx4 has this big problem
compared to other NIC.

Then, if we _still_ hit major issues, we might also need to force
napi_get_frags()
to allocate skb->head using kmalloc() instead of a page frag.

That is a very simple fix.

Remember that we have skb->truesize that is an approximation, it will
never be completely accurate,
but we need to make it better.

mlx4 driver pretends to have a frag truesize of 1536 bytes, but this
is obviously wrong when host is under memory pressure
(2 frags per page -> truesize should be 2048)


> By using netdev/napi_alloc_skb, you'll get that the SKB's linear data is a
> frag of a huge page,
> and it is not going to be freed before the other non-linear frags.
> Cannot this cause the same threats (memory pinning and so...)?
>
> Currently, mlx4 doesn't use this generic API, while most other drivers do.
>
> Similar claims are true for TX:
> https://github.com/torvalds/linux/commit/5640f7685831e088fe6c2e1f863a6805962f8e81

We do not have such problem on TX. GFP_KERNEL allocations do not have
the same issues.

Tasks are usually not malicious in our DC, and most serious
applications use memcg or such memory control.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
