Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 10A196B0289
	for <linux-mm@kvack.org>; Sat, 10 Nov 2018 18:54:30 -0500 (EST)
Received: by mail-lj1-f198.google.com with SMTP id q185-v6so1588630ljb.14
        for <linux-mm@kvack.org>; Sat, 10 Nov 2018 15:54:30 -0800 (PST)
Received: from smtp7.iq.pl (smtp7.iq.pl. [86.111.240.244])
        by mx.google.com with ESMTPS id d2-v6si10653604lfh.31.2018.11.10.15.54.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 10 Nov 2018 15:54:28 -0800 (PST)
Subject: Re: [PATCH 1/2] mm/page_alloc: free order-0 pages through PCP in
 page_frag_free()
References: <20181105085820.6341-1-aaron.lu@intel.com>
 <CAKgT0UdvYVTA8OjgLhXo9tRUOGikrCi3zJXSrqM0ZmeHb5P2mA@mail.gmail.com>
From: =?UTF-8?Q?Pawe=c5=82_Staszewski?= <pstaszewski@itcare.pl>
Message-ID: <b8b1fbb7-9139-9455-69b8-8c1bed4f7c74@itcare.pl>
Date: Sun, 11 Nov 2018 00:54:27 +0100
MIME-Version: 1.0
In-Reply-To: <CAKgT0UdvYVTA8OjgLhXo9tRUOGikrCi3zJXSrqM0ZmeHb5P2mA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: pl
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.duyck@gmail.com>, aaron.lu@intel.com
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Netdev <netdev@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jesper Dangaard Brouer <brouer@redhat.com>, Eric Dumazet <eric.dumazet@gmail.com>, Tariq Toukan <tariqt@mellanox.com>, ilias.apalodimas@linaro.org, yoel@kviknet.dk, Mel Gorman <mgorman@techsingularity.net>, Saeed Mahameed <saeedm@mellanox.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, dave.hansen@linux.intel.com



W dniu 05.11.2018 oA 16:44, Alexander Duyck pisze:
> On Mon, Nov 5, 2018 at 12:58 AM Aaron Lu <aaron.lu@intel.com> wrote:
>> page_frag_free() calls __free_pages_ok() to free the page back to
>> Buddy. This is OK for high order page, but for order-0 pages, it
>> misses the optimization opportunity of using Per-Cpu-Pages and can
>> cause zone lock contention when called frequently.
>>
>> PaweA? Staszewski recently shared his result of 'how Linux kernel
>> handles normal traffic'[1] and from perf data, Jesper Dangaard Brouer
>> found the lock contention comes from page allocator:
>>
>>    mlx5e_poll_tx_cq
>>    |
>>     --16.34%--napi_consume_skb
>>               |
>>               |--12.65%--__free_pages_ok
>>               |          |
>>               |           --11.86%--free_one_page
>>               |                     |
>>               |                     |--10.10%--queued_spin_lock_slowpath
>>               |                     |
>>               |                      --0.65%--_raw_spin_lock
>>               |
>>               |--1.55%--page_frag_free
>>               |
>>                --1.44%--skb_release_data
>>
>> Jesper explained how it happened: mlx5 driver RX-page recycle
>> mechanism is not effective in this workload and pages have to go
>> through the page allocator. The lock contention happens during
>> mlx5 DMA TX completion cycle. And the page allocator cannot keep
>> up at these speeds.[2]
>>
>> I thought that __free_pages_ok() are mostly freeing high order
>> pages and thought this is an lock contention for high order pages
>> but Jesper explained in detail that __free_pages_ok() here are
>> actually freeing order-0 pages because mlx5 is using order-0 pages
>> to satisfy its page pool allocation request.[3]
>>
>> The free path as pointed out by Jesper is:
>> skb_free_head()
>>    -> skb_free_frag()
>>      -> skb_free_frag()
>>        -> page_frag_free()
>> And the pages being freed on this path are order-0 pages.
>>
>> Fix this by doing similar things as in __page_frag_cache_drain() -
>> send the being freed page to PCP if it's an order-0 page, or
>> directly to Buddy if it is a high order page.
>>
>> With this change, PaweA? hasn't noticed lock contention yet in
>> his workload and Jesper has noticed a 7% performance improvement
>> using a micro benchmark and lock contention is gone.
>>
>> [1]: https://www.spinics.net/lists/netdev/msg531362.html
>> [2]: https://www.spinics.net/lists/netdev/msg531421.html
>> [3]: https://www.spinics.net/lists/netdev/msg531556.html
>> Reported-by: PaweA? Staszewski <pstaszewski@itcare.pl>
>> Analysed-by: Jesper Dangaard Brouer <brouer@redhat.com>
>> Signed-off-by: Aaron Lu <aaron.lu@intel.com>
>> ---
>>   mm/page_alloc.c | 10 ++++++++--
>>   1 file changed, 8 insertions(+), 2 deletions(-)
>>
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index ae31839874b8..91a9a6af41a2 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -4555,8 +4555,14 @@ void page_frag_free(void *addr)
>>   {
>>          struct page *page = virt_to_head_page(addr);
>>
>> -       if (unlikely(put_page_testzero(page)))
>> -               __free_pages_ok(page, compound_order(page));
>> +       if (unlikely(put_page_testzero(page))) {
>> +               unsigned int order = compound_order(page);
>> +
>> +               if (order == 0)
>> +                       free_unref_page(page);
>> +               else
>> +                       __free_pages_ok(page, order);
>> +       }
>>   }
>>   EXPORT_SYMBOL(page_frag_free);
>>
> One thing I would suggest for Pawel to try would be to reduce the Tx
> qdisc size on his transmitting interfaces, Reduce the Tx ring size,
> and possibly increase the Tx interrupt rate. Ideally we shouldn't have
> too many packets in-flight and I suspect that is the issue that Pawel
> is seeing that is leading to the page pool allocator freeing up the
> memory. I know we like to try to batch things but the issue is
> processing too many Tx buffers in one batch leads to us eating up too
> much memory and causing evictions from the cache. Ideally the Rx and
> Tx rings and queues should be sized as small as possible while still
> allowing us to process up to our NAPI budget. Usually I run things
> with a 128 Rx / 128 Tx setup and then reduce the Tx queue length so we
> don't have more buffers stored there than we can place in the Tx ring.
> Then we can avoid the extra thrash of having to pull/push memory into
> and out of the freelists. Essentially the issue here ends up being
> another form of buffer bloat.
Thanks Aleksandar - yes it can be - but in my scenario setting RX buffer 
<4096 producing more interface rx drops - and no_rx_buffer on network 
controller that is receiving more packets
So i need to stick with 3000-4000 on RX - and yes i was trying to lower 
the TX buff on connectx4 - but that changed nothing before Aaron patch

After Aaron patch - decreasing TX buffer influencing total bandwidth 
that can be handled by the router/server
Dono why before this patch there was no difference there no matter what 
i set there there was always page_alloc/slowpath on top in perf


Currently testing RX4096/TX256 - this helps with bandwidth like +10% 
more bandwidth with less interrupts...


>
> With that said this change should be mostly harmless and does address
> the fact that we can have both regular order 0 pages and page frags
> used for skb->head.
>
> Acked-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
>
