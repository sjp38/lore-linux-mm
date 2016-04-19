Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id A2C1F6B007E
	for <linux-mm@kvack.org>; Tue, 19 Apr 2016 13:39:40 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id w143so20718474wmw.2
        for <linux-mm@kvack.org>; Tue, 19 Apr 2016 10:39:40 -0700 (PDT)
Received: from outbound-smtp11.blacknight.com (outbound-smtp11.blacknight.com. [46.22.139.16])
        by mx.google.com with ESMTPS id ur8si1346383wjc.174.2016.04.19.10.39.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Apr 2016 10:39:39 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp11.blacknight.com (Postfix) with ESMTPS id 922C61C2080
	for <linux-mm@kvack.org>; Tue, 19 Apr 2016 18:39:38 +0100 (IST)
Date: Tue, 19 Apr 2016 18:39:26 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH net-next V2 05/11] net/mlx5e: Support RX multi-packet WQE
 (Striding RQ)
Message-ID: <20160419173833.GB15167@techsingularity.net>
References: <1460928725-18741-1-git-send-email-saeedm@mellanox.com>
 <1460928725-18741-6-git-send-email-saeedm@mellanox.com>
 <1460939371.10638.97.camel@edumazet-glaptop3.roam.corp.google.com>
 <1460983695.10638.113.camel@edumazet-glaptop3.roam.corp.google.com>
 <CALzJLG_W9SkgMBQp86P0WDknw4Kc=DCBrvpPemAUbRX=r4r8Yg@mail.gmail.com>
 <1460989033.10638.120.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160419182532.423d3c05@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160419182532.423d3c05@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Saeed Mahameed <saeedm@dev.mellanox.co.il>, Saeed Mahameed <saeedm@mellanox.com>, "David S. Miller" <davem@davemloft.net>, Linux Netdev List <netdev@vger.kernel.org>, Or Gerlitz <ogerlitz@mellanox.com>, Tal Alon <talal@mellanox.com>, Tariq Toukan <tariqt@mellanox.com>, Eran Ben Elisha <eranbe@mellanox.com>, Achiad Shochat <achiad@mellanox.com>, linux-mm <linux-mm@kvack.org>

On Tue, Apr 19, 2016 at 06:25:32PM +0200, Jesper Dangaard Brouer wrote:
> On Mon, 18 Apr 2016 07:17:13 -0700
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> 
> > On Mon, 2016-04-18 at 16:05 +0300, Saeed Mahameed wrote:
> > > On Mon, Apr 18, 2016 at 3:48 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:  
> > > > On Sun, 2016-04-17 at 17:29 -0700, Eric Dumazet wrote:
> > > >  
> > > >>
> > > >> If really you need to allocate physically contiguous memory, have you
> > > >> considered converting the order-5 pages into 32 order-0 ones ?  
> > > >
> > > > Search for split_page() call sites for examples.
> > > >
> > > >  
> > > 
> > > Thanks Eric, we are already evaluating split_page as we speak.
> > > 
> > > We did look but could not find any specific alloc_pages API that

alloc_pages_exact()

> > > allocates many physically contiguous pages with order0 ! so we assume
> > > it is ok to use split_page.  
> > 
> > Note: I have no idea of split_page() performance :
> 
> Maybe Mel knows?

Irrelevant in comparison to the cost of allocating an order-5 pages if
one is not already available.

> And maybe Mel have an opinion about if this is a good
> or bad approach, e.g. will this approach stress the page allocator in a
> bad way?
> 

It'll contend on the zone lock minimally but again, irrelevant in
comparison to having to reclaim/compact an order-5 page if one is not
already free.

It'll appear to work well in benchmarks and then fall apart when the
system is running for long enough.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
