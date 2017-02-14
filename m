Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9E94B6B03C7
	for <linux-mm@kvack.org>; Tue, 14 Feb 2017 14:02:03 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id 203so39665959ith.3
        for <linux-mm@kvack.org>; Tue, 14 Feb 2017 11:02:03 -0800 (PST)
Received: from mail-it0-x235.google.com (mail-it0-x235.google.com. [2607:f8b0:4001:c0b::235])
        by mx.google.com with ESMTPS id i200si1732353ioi.119.2017.02.14.11.02.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Feb 2017 11:02:02 -0800 (PST)
Received: by mail-it0-x235.google.com with SMTP id c7so45698566itd.1
        for <linux-mm@kvack.org>; Tue, 14 Feb 2017 11:02:02 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170214194615.3feddd07@redhat.com>
References: <20170213195858.5215-1-edumazet@google.com> <20170213195858.5215-9-edumazet@google.com>
 <CAKgT0Ufx0Y=9kjLax36Gx4e7Y-A7sKZDNYxgJ9wbCT4_vxHhGA@mail.gmail.com>
 <CANn89iLkPB_Dx1L2dFfwOoeXOmPhu_C3OO2yqZi8+Rvjr=-EtA@mail.gmail.com>
 <CAKgT0UeB_e_Z7LM1_r=en8JJdgLhoYFstWpCDQN6iawLYZJKDA@mail.gmail.com>
 <20170214131206.44b644f6@redhat.com> <CANn89i+udp6Y42D9wqmz7U6LGn1mtDRXpQGHAOAeX25eD0dGnQ@mail.gmail.com>
 <cd4f3d91-252b-4796-2bd2-3030c18d9ee6@gmail.com> <CAKgT0UdRmpV_n1wstTHvqCgyRtze8z1rTJ5pKc_jdRttQCSySw@mail.gmail.com>
 <20170214194615.3feddd07@redhat.com>
From: Eric Dumazet <edumazet@google.com>
Date: Tue, 14 Feb 2017 11:02:01 -0800
Message-ID: <CANn89iK4fnsjsK+GHYdT7_F0f++sa+t2LqrZWftjEryhF=hX+w@mail.gmail.com>
Subject: Re: [PATCH v3 net-next 08/14] mlx4: use order-0 pages for RX
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Alexander Duyck <alexander.duyck@gmail.com>, Tariq Toukan <ttoukan.linux@gmail.com>, "David S . Miller" <davem@davemloft.net>, netdev <netdev@vger.kernel.org>, Tariq Toukan <tariqt@mellanox.com>, Martin KaFai Lau <kafai@fb.com>, Saeed Mahameed <saeedm@mellanox.com>, Willem de Bruijn <willemb@google.com>, Brenden Blanco <bblanco@plumgrid.com>, Alexei Starovoitov <ast@kernel.org>, Eric Dumazet <eric.dumazet@gmail.com>, linux-mm <linux-mm@kvack.org>

On Tue, Feb 14, 2017 at 10:46 AM, Jesper Dangaard Brouer
<brouer@redhat.com> wrote:
>

>
> With this Intel driver page count based recycle approach, the recycle
> size is tied to the size of the RX ring.  As Eric and Tariq discovered.
> And for other performance reasons (memory footprint of walking RX ring
> data-structures), don't want to increase the RX ring sizes.  Thus, it
> create two opposite performance needs.  That is why I think a more
> explicit approach with a pool is more attractive.
>
> How is this approach doing to work for XDP?
> (XDP doesn't "share" the page, and in-general we don't want the extra
> atomic.)
>
> We absolutely need recycling with XDP, when transmitting out another
> device, and the other devices DMA-TX completion need some way of
> returning this page.
> What is basically needed is a standardized callback to allow the remote
> driver to return the page to the originating driver.  As we don't have
> a NDP for XDP-forward/transmit yet, we could pass this callback as a
> parameter along with the packet-page to send?
>
>


mlx4 already has a cache for XDP.
I believe I did not change this part, it still should work.

commit d576acf0a22890cf3f8f7a9b035f1558077f6770
Author: Brenden Blanco <bblanco@plumgrid.com>
Date:   Tue Jul 19 12:16:52 2016 -0700

    net/mlx4_en: add page recycle to prepare rx ring for tx support

I have not checked if recent Tom work added core infra for this cache.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
