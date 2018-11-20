Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8D0076B1F92
	for <linux-mm@kvack.org>; Tue, 20 Nov 2018 04:42:13 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id g22so2439898qke.15
        for <linux-mm@kvack.org>; Tue, 20 Nov 2018 01:42:13 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x31si2391286qvc.205.2018.11.20.01.42.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Nov 2018 01:42:12 -0800 (PST)
Date: Tue, 20 Nov 2018 04:42:09 -0500 (EST)
From: Pankaj Gupta <pagupta@redhat.com>
Message-ID: <683236105.35259866.1542706929529.JavaMail.zimbra@redhat.com>
In-Reply-To: <20181120014544.GB10657@intel.com>
References: <20181119134834.17765-1-aaron.lu@intel.com> <20181119134834.17765-2-aaron.lu@intel.com> <20181120014544.GB10657@intel.com>
Subject: Re: [PATCH v2 RESEND update 1/2] mm/page_alloc: free order-0 pages
 through PCP in page_frag_free()
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaron Lu <aaron.lu@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, =?utf-8?Q?Pawe=C5=82?= Staszewski <pstaszewski@itcare.pl>, Jesper Dangaard Brouer <brouer@redhat.com>, Eric Dumazet <eric.dumazet@gmail.com>, Tariq Toukan <tariqt@mellanox.com>, Ilias Apalodimas <ilias.apalodimas@linaro.org>, Yoel Caspersen <yoel@kviknet.dk>, Mel Gorman <mgorman@techsingularity.net>, Saeed Mahameed <saeedm@mellanox.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Dave Hansen <dave.hansen@linux.intel.com>, Alexander Duyck <alexander.h.duyck@linux.intel.com>, Ian Kumlien <ian.kumlien@gmail.com>


>=20
> page_frag_free() calls __free_pages_ok() to free the page back to
> Buddy. This is OK for high order page, but for order-0 pages, it
> misses the optimization opportunity of using Per-Cpu-Pages and can
> cause zone lock contention when called frequently.
>=20
> Pawe=C5=82 Staszewski recently shared his result of 'how Linux kernel
> handles normal traffic'[1] and from perf data, Jesper Dangaard Brouer
> found the lock contention comes from page allocator:
>=20
>   mlx5e_poll_tx_cq
>   |
>    --16.34%--napi_consume_skb
>              |
>              |--12.65%--__free_pages_ok
>              |          |
>              |           --11.86%--free_one_page
>              |                     |
>              |                     |--10.10%--queued_spin_lock_slowpath
>              |                     |
>              |                      --0.65%--_raw_spin_lock
>              |
>              |--1.55%--page_frag_free
>              |
>               --1.44%--skb_release_data
>=20
> Jesper explained how it happened: mlx5 driver RX-page recycle
> mechanism is not effective in this workload and pages have to go
> through the page allocator. The lock contention happens during
> mlx5 DMA TX completion cycle. And the page allocator cannot keep
> up at these speeds.[2]
>=20
> I thought that __free_pages_ok() are mostly freeing high order
> pages and thought this is an lock contention for high order pages
> but Jesper explained in detail that __free_pages_ok() here are
> actually freeing order-0 pages because mlx5 is using order-0 pages
> to satisfy its page pool allocation request.[3]
>=20
> The free path as pointed out by Jesper is:
> skb_free_head()
>   -> skb_free_frag()
>     -> page_frag_free()
> And the pages being freed on this path are order-0 pages.
>=20
> Fix this by doing similar things as in __page_frag_cache_drain() -
> send the being freed page to PCP if it's an order-0 page, or
> directly to Buddy if it is a high order page.
>=20
> With this change, Pawe=C5=82 hasn't noticed lock contention yet in
> his workload and Jesper has noticed a 7% performance improvement
> using a micro benchmark and lock contention is gone. Ilias' test
> on a 'low' speed 1Gbit interface on an cortex-a53 shows ~11%
> performance boost testing with 64byte packets and __free_pages_ok()
> disappeared from perf top.
>=20
> [1]: https://www.spinics.net/lists/netdev/msg531362.html
> [2]: https://www.spinics.net/lists/netdev/msg531421.html
> [3]: https://www.spinics.net/lists/netdev/msg531556.html
>=20
> Reported-by: Pawe=C5=82 Staszewski <pstaszewski@itcare.pl>
> Analysed-by: Jesper Dangaard Brouer <brouer@redhat.com>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> Acked-by: Mel Gorman <mgorman@techsingularity.net>
> Acked-by: Jesper Dangaard Brouer <brouer@redhat.com>
> Acked-by: Ilias Apalodimas <ilias.apalodimas@linaro.org>
> Tested-by: Ilias Apalodimas <ilias.apalodimas@linaro.org>
> Acked-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> Acked-by: Tariq Toukan <tariqt@mellanox.com>
> Signed-off-by: Aaron Lu <aaron.lu@intel.com>
> ---
> update: fix Tariq's email tag.
>=20
>  mm/page_alloc.c | 10 ++++++++--
>  1 file changed, 8 insertions(+), 2 deletions(-)
>=20
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 421c5b652708..8f8c6b33b637 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -4677,8 +4677,14 @@ void page_frag_free(void *addr)
>  {
>  =09struct page *page =3D virt_to_head_page(addr);
> =20
> -=09if (unlikely(put_page_testzero(page)))
> -=09=09__free_pages_ok(page, compound_order(page));
> +=09if (unlikely(put_page_testzero(page))) {
> +=09=09unsigned int order =3D compound_order(page);
> +
> +=09=09if (order =3D=3D 0)
> +=09=09=09free_unref_page(page);
> +=09=09else
> +=09=09=09__free_pages_ok(page, order);
> +=09}
>  }
>  EXPORT_SYMBOL(page_frag_free);
> =20
> --
> 2.17.2

A good optimization for zero order allocations. =20
Acked-by: Pankaj gupta <pagupta@redhat.com>
=20
Thanks,
Pankaj
