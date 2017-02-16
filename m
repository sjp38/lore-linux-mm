Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id B00DA680FFB
	for <linux-mm@kvack.org>; Thu, 16 Feb 2017 10:47:07 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id c73so26911695pfb.7
        for <linux-mm@kvack.org>; Thu, 16 Feb 2017 07:47:07 -0800 (PST)
Received: from mail-pg0-x244.google.com (mail-pg0-x244.google.com. [2607:f8b0:400e:c05::244])
        by mx.google.com with ESMTPS id c5si7280167pgj.310.2017.02.16.07.47.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Feb 2017 07:47:06 -0800 (PST)
Received: by mail-pg0-x244.google.com with SMTP id 5so2296093pgj.0
        for <linux-mm@kvack.org>; Thu, 16 Feb 2017 07:47:06 -0800 (PST)
Message-ID: <1487260025.1311.50.camel@edumazet-glaptop3.roam.corp.google.com>
Subject: Re: [PATCH v3 net-next 08/14] mlx4: use order-0 pages for RX
From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 16 Feb 2017 07:47:05 -0800
In-Reply-To: <37bc04eb-71c9-0433-304d-87fcf8b06be3@mellanox.com>
References: <20170213195858.5215-1-edumazet@google.com>
	 <20170213195858.5215-9-edumazet@google.com>
	 <CAKgT0Ufx0Y=9kjLax36Gx4e7Y-A7sKZDNYxgJ9wbCT4_vxHhGA@mail.gmail.com>
	 <CANn89iLkPB_Dx1L2dFfwOoeXOmPhu_C3OO2yqZi8+Rvjr=-EtA@mail.gmail.com>
	 <CAKgT0UeB_e_Z7LM1_r=en8JJdgLhoYFstWpCDQN6iawLYZJKDA@mail.gmail.com>
	 <20170214131206.44b644f6@redhat.com>
	 <CANn89i+udp6Y42D9wqmz7U6LGn1mtDRXpQGHAOAeX25eD0dGnQ@mail.gmail.com>
	 <cd4f3d91-252b-4796-2bd2-3030c18d9ee6@gmail.com>
	 <1487087488.8227.53.camel@edumazet-glaptop3.roam.corp.google.com>
	 <CALx6S3530_2DYU-3VRmvRYZ3n05OqJZpJ3x02vXQd6Q7FUJQvw@mail.gmail.com>
	 <ccc4cb9e-9863-02e1-2789-4869aea3c661@mellanox.com>
	 <CANn89iJip45peBQB9Tn1mWVg+1QYZH+01CqkAUctd3xqwPw8Zg@mail.gmail.com>
	 <37bc04eb-71c9-0433-304d-87fcf8b06be3@mellanox.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tariq Toukan <tariqt@mellanox.com>
Cc: Eric Dumazet <edumazet@google.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Tom Herbert <tom@herbertland.com>, Alexander Duyck <alexander.duyck@gmail.com>, "David S . Miller" <davem@davemloft.net>, netdev <netdev@vger.kernel.org>, Martin KaFai Lau <kafai@fb.com>, Saeed Mahameed <saeedm@mellanox.com>, Willem de Bruijn <willemb@google.com>, Brenden Blanco <bblanco@plumgrid.com>, Alexei Starovoitov <ast@kernel.org>, linux-mm <linux-mm@kvack.org>

On Thu, 2017-02-16 at 15:08 +0200, Tariq Toukan wrote:
> On 15/02/2017 6:57 PM, Eric Dumazet wrote:
> > On Wed, Feb 15, 2017 at 8:42 AM, Tariq Toukan <tariqt@mellanox.com> wrote:
> >> Isn't it the same principle in page_frag_alloc() ?
> >> It is called form __netdev_alloc_skb()/__napi_alloc_skb().
> >>
> >> Why is it ok to have order-3 pages (PAGE_FRAG_CACHE_MAX_ORDER) there?
> > This is not ok.
> >
> > This is a very well known problem, we already mentioned that here in the past,
> > but at least core networking stack uses  order-0 pages on PowerPC.
> You're right, we should have done this as well in mlx4 on PPC.
> > mlx4 driver suffers from this problem 100% more than other drivers ;)
> >
> > One problem at a time Tariq. Right now, only mlx4 has this big problem
> > compared to other NIC.
> We _do_ agree that the series improves the driver's quality, stability,
> and performance in a fragmented system.
> 
> But due to the late rc we're in, and the fact that we know what benchmarks
> our customers are going to run, we cannot Ack the series and get it
> as is inside kernel 4.11.
> 
> We are interested to get your series merged along another perf improvement
> we are preparing for next rc1. This way we will earn the desired stability
> without breaking existing benchmarks.
> I think this is the right thing to do at this point of time.
> 
> 
> The idea behind the perf improvement, suggested by Jesper, is to split
> the napi_poll call mlx4_en_process_rx_cq() loop into two.
> The first loop extracts completed CQEs and starts prefetching on data
> and RX descriptors. The second loop process the real packets.

Make sure to resubmit my patches before anything new.

We need to backport them to stable versions, without XDP, without
anything fancy.

And submit what is needed for 4.11, since current mlx4 driver in
net-next is broken, in case you missed it.

Thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
