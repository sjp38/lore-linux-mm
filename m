Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4842E6B000D
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 04:55:36 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id s19so20430357qke.20
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 01:55:36 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k185-v6si3922767qkf.21.2018.11.05.01.55.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Nov 2018 01:55:35 -0800 (PST)
Date: Mon, 5 Nov 2018 10:55:25 +0100
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH 1/2] mm/page_alloc: free order-0 pages through PCP in
 page_frag_free()
Message-ID: <20181105105525.1f78c661@redhat.com>
In-Reply-To: <20181105085820.6341-1-aaron.lu@intel.com>
References: <20181105085820.6341-1-aaron.lu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaron Lu <aaron.lu@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, =?UTF-8?B?UGF3ZcWC?= Staszewski <pstaszewski@itcare.pl>, Eric Dumazet <eric.dumazet@gmail.com>, Tariq Toukan <tariqt@mellanox.com>, Ilias Apalodimas <ilias.apalodimas@linaro.org>, Yoel Caspersen <yoel@kviknet.dk>, Mel Gorman <mgorman@techsingularity.net>, Saeed Mahameed <saeedm@mellanox.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Dave Hansen <dave.hansen@linux.intel.com>, brouer@redhat.com

On Mon,  5 Nov 2018 16:58:19 +0800
Aaron Lu <aaron.lu@intel.com> wrote:

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
>     -> skb_free_frag()

Nitpick: you added skb_free_frag() two times, else correct.
(All this stuff gets inlined by the compiler, which makes it hard to
spot with perf report).

>       -> page_frag_free() =20
> And the pages being freed on this path are order-0 pages.
>=20
> Fix this by doing similar things as in __page_frag_cache_drain() -
> send the being freed page to PCP if it's an order-0 page, or
> directly to Buddy if it is a high order page.
>=20
> With this change, Pawe=C5=82 hasn't noticed lock contention yet in
> his workload and Jesper has noticed a 7% performance improvement
> using a micro benchmark and lock contention is gone.
>=20
> [1]: https://www.spinics.net/lists/netdev/msg531362.html
> [2]: https://www.spinics.net/lists/netdev/msg531421.html
> [3]: https://www.spinics.net/lists/netdev/msg531556.html
> Reported-by: Pawe=C5=82 Staszewski <pstaszewski@itcare.pl>
> Analysed-by: Jesper Dangaard Brouer <brouer@redhat.com>
> Signed-off-by: Aaron Lu <aaron.lu@intel.com>
> ---

It is REALLY great that Aaron spotted this! (based on my analysis).
This have likely been causing scalability issues on real-life network
traffic, but have been hiding behind the driver level recycle tricks
for micro-benchmarking.

Acked-by: Jesper Dangaard Brouer <brouer@redhat.com>

>  mm/page_alloc.c | 10 ++++++++--
>  1 file changed, 8 insertions(+), 2 deletions(-)
>=20
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index ae31839874b8..91a9a6af41a2 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -4555,8 +4555,14 @@ void page_frag_free(void *addr)
>  {
>  	struct page *page =3D virt_to_head_page(addr);
> =20
> -	if (unlikely(put_page_testzero(page)))
> -		__free_pages_ok(page, compound_order(page));
> +	if (unlikely(put_page_testzero(page))) {
> +		unsigned int order =3D compound_order(page);
> +
> +		if (order =3D=3D 0)
> +			free_unref_page(page);
> +		else
> +			__free_pages_ok(page, order);
> +	}
>  }
>  EXPORT_SYMBOL(page_frag_free);
> =20

--=20
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
