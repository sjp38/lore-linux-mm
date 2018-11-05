Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0ACA96B000A
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 10:44:14 -0500 (EST)
Received: by mail-io1-f69.google.com with SMTP id k9-v6so10533988ioj.18
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 07:44:14 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u81-v6sor12187584iod.73.2018.11.05.07.44.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Nov 2018 07:44:12 -0800 (PST)
MIME-Version: 1.0
References: <20181105085820.6341-1-aaron.lu@intel.com>
In-Reply-To: <20181105085820.6341-1-aaron.lu@intel.com>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Mon, 5 Nov 2018 07:44:00 -0800
Message-ID: <CAKgT0UdvYVTA8OjgLhXo9tRUOGikrCi3zJXSrqM0ZmeHb5P2mA@mail.gmail.com>
Subject: Re: [PATCH 1/2] mm/page_alloc: free order-0 pages through PCP in page_frag_free()
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: aaron.lu@intel.com
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Netdev <netdev@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, =?UTF-8?Q?Pawe=C5=82_Staszewski?= <pstaszewski@itcare.pl>, Jesper Dangaard Brouer <brouer@redhat.com>, Eric Dumazet <eric.dumazet@gmail.com>, Tariq Toukan <tariqt@mellanox.com>, ilias.apalodimas@linaro.org, yoel@kviknet.dk, Mel Gorman <mgorman@techsingularity.net>, Saeed Mahameed <saeedm@mellanox.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, dave.hansen@linux.intel.com

On Mon, Nov 5, 2018 at 12:58 AM Aaron Lu <aaron.lu@intel.com> wrote:
>
> page_frag_free() calls __free_pages_ok() to free the page back to
> Buddy. This is OK for high order page, but for order-0 pages, it
> misses the optimization opportunity of using Per-Cpu-Pages and can
> cause zone lock contention when called frequently.
>
> Pawe=C5=82 Staszewski recently shared his result of 'how Linux kernel
> handles normal traffic'[1] and from perf data, Jesper Dangaard Brouer
> found the lock contention comes from page allocator:
>
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
>
> Jesper explained how it happened: mlx5 driver RX-page recycle
> mechanism is not effective in this workload and pages have to go
> through the page allocator. The lock contention happens during
> mlx5 DMA TX completion cycle. And the page allocator cannot keep
> up at these speeds.[2]
>
> I thought that __free_pages_ok() are mostly freeing high order
> pages and thought this is an lock contention for high order pages
> but Jesper explained in detail that __free_pages_ok() here are
> actually freeing order-0 pages because mlx5 is using order-0 pages
> to satisfy its page pool allocation request.[3]
>
> The free path as pointed out by Jesper is:
> skb_free_head()
>   -> skb_free_frag()
>     -> skb_free_frag()
>       -> page_frag_free()
> And the pages being freed on this path are order-0 pages.
>
> Fix this by doing similar things as in __page_frag_cache_drain() -
> send the being freed page to PCP if it's an order-0 page, or
> directly to Buddy if it is a high order page.
>
> With this change, Pawe=C5=82 hasn't noticed lock contention yet in
> his workload and Jesper has noticed a 7% performance improvement
> using a micro benchmark and lock contention is gone.
>
> [1]: https://www.spinics.net/lists/netdev/msg531362.html
> [2]: https://www.spinics.net/lists/netdev/msg531421.html
> [3]: https://www.spinics.net/lists/netdev/msg531556.html
> Reported-by: Pawe=C5=82 Staszewski <pstaszewski@itcare.pl>
> Analysed-by: Jesper Dangaard Brouer <brouer@redhat.com>
> Signed-off-by: Aaron Lu <aaron.lu@intel.com>
> ---
>  mm/page_alloc.c | 10 ++++++++--
>  1 file changed, 8 insertions(+), 2 deletions(-)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index ae31839874b8..91a9a6af41a2 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -4555,8 +4555,14 @@ void page_frag_free(void *addr)
>  {
>         struct page *page =3D virt_to_head_page(addr);
>
> -       if (unlikely(put_page_testzero(page)))
> -               __free_pages_ok(page, compound_order(page));
> +       if (unlikely(put_page_testzero(page))) {
> +               unsigned int order =3D compound_order(page);
> +
> +               if (order =3D=3D 0)
> +                       free_unref_page(page);
> +               else
> +                       __free_pages_ok(page, order);
> +       }
>  }
>  EXPORT_SYMBOL(page_frag_free);
>

One thing I would suggest for Pawel to try would be to reduce the Tx
qdisc size on his transmitting interfaces, Reduce the Tx ring size,
and possibly increase the Tx interrupt rate. Ideally we shouldn't have
too many packets in-flight and I suspect that is the issue that Pawel
is seeing that is leading to the page pool allocator freeing up the
memory. I know we like to try to batch things but the issue is
processing too many Tx buffers in one batch leads to us eating up too
much memory and causing evictions from the cache. Ideally the Rx and
Tx rings and queues should be sized as small as possible while still
allowing us to process up to our NAPI budget. Usually I run things
with a 128 Rx / 128 Tx setup and then reduce the Tx queue length so we
don't have more buffers stored there than we can place in the Tx ring.
Then we can avoid the extra thrash of having to pull/push memory into
and out of the freelists. Essentially the issue here ends up being
another form of buffer bloat.

With that said this change should be mostly harmless and does address
the fact that we can have both regular order 0 pages and page frags
used for skb->head.

Acked-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
