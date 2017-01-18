Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id A413D6B026D
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 09:23:51 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id y143so18506662pfb.6
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 06:23:51 -0800 (PST)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id l17si386318pgj.44.2017.01.18.06.23.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jan 2017 06:23:50 -0800 (PST)
Received: by mail-pg0-x242.google.com with SMTP id t6so1534739pgt.1
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 06:23:50 -0800 (PST)
Message-ID: <1484749428.13165.100.camel@edumazet-glaptop3.roam.corp.google.com>
Subject: Re: [PATCH net-next] mlx4: support __GFP_MEMALLOC for rx
From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 18 Jan 2017 06:23:48 -0800
In-Reply-To: <2696ea05-bb39-787b-2029-33b729fd88e0@yandex-team.ru>
References: 
	<1484712850.13165.86.camel@edumazet-glaptop3.roam.corp.google.com>
	 <2696ea05-bb39-787b-2029-33b729fd88e0@yandex-team.ru>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>, Tariq Toukan <tariqt@mellanox.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Wed, 2017-01-18 at 12:31 +0300, Konstantin Khlebnikov wrote:
> On 18.01.2017 07:14, Eric Dumazet wrote:
> > From: Eric Dumazet <edumazet@google.com>
> >
> > Commit 04aeb56a1732 ("net/mlx4_en: allocate non 0-order pages for RX
> > ring with __GFP_NOMEMALLOC") added code that appears to be not needed at
> > that time, since mlx4 never used __GFP_MEMALLOC allocations anyway.
> >
> > As using memory reserves is a must in some situations (swap over NFS or
> > iSCSI), this patch adds this flag.
> 
> AFAIK __GFP_MEMALLOC is used for TX, not for RX: for allocations which
> are required by memory reclaimer to free some pages.
> 
> Allocation RX buffers with __GFP_MEMALLOC is a straight way to
> depleting all reserves by flood from network.

You are mistaken.

How do you think a TCP flow can make progress sending data if no ACK
packet can go back in RX ?

Take a look at sk_filter_trim_cap(), where the RX packets received on a
socket which does not have SOCK_MEMALLOC is dropped.

        /*
         * If the skb was allocated from pfmemalloc reserves, only
         * allow SOCK_MEMALLOC sockets to use it as this socket is
         * helping free memory
         */
        if (skb_pfmemalloc(skb) && !sock_flag(sk, SOCK_MEMALLOC))
                return -ENOMEM;

Also take a look at __dev_alloc_pages()

static inline struct page *__dev_alloc_pages(gfp_t gfp_mask,
                                             unsigned int order)
{
        /* This piece of code contains several assumptions.
         * 1.  This is for device Rx, therefor a cold page is preferred.
         * 2.  The expectation is the user wants a compound page.
         * 3.  If requesting a order 0 page it will not be compound
         *     due to the check to see if order has a value in prep_new_page
         * 4.  __GFP_MEMALLOC is ignored if __GFP_NOMEMALLOC is set due to
         *     code in gfp_to_alloc_flags that should be enforcing this.
         */
        gfp_mask |= __GFP_COLD | __GFP_COMP | __GFP_MEMALLOC;

        return alloc_pages_node(NUMA_NO_NODE, gfp_mask, order);
}


So __GFP_MEMALLOC in RX is absolutely supported.

But drivers have to opt-in, either using __dev_alloc_pages() or
dev_alloc_pages, or explicitely ORing __GFP_MEMALLOC when using
alloc_page[s]()



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
