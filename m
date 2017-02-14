Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id CB0386B0396
	for <linux-mm@kvack.org>; Tue, 14 Feb 2017 09:56:53 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id c4so6119271wrd.1
        for <linux-mm@kvack.org>; Tue, 14 Feb 2017 06:56:53 -0800 (PST)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id 1si1033461wrq.77.2017.02.14.06.56.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Feb 2017 06:56:52 -0800 (PST)
Received: by mail-wm0-x244.google.com with SMTP id r18so3949058wmd.3
        for <linux-mm@kvack.org>; Tue, 14 Feb 2017 06:56:52 -0800 (PST)
Subject: Re: [PATCH v3 net-next 08/14] mlx4: use order-0 pages for RX
References: <20170213195858.5215-1-edumazet@google.com>
 <20170213195858.5215-9-edumazet@google.com>
 <CAKgT0Ufx0Y=9kjLax36Gx4e7Y-A7sKZDNYxgJ9wbCT4_vxHhGA@mail.gmail.com>
 <CANn89iLkPB_Dx1L2dFfwOoeXOmPhu_C3OO2yqZi8+Rvjr=-EtA@mail.gmail.com>
 <CAKgT0UeB_e_Z7LM1_r=en8JJdgLhoYFstWpCDQN6iawLYZJKDA@mail.gmail.com>
 <20170214131206.44b644f6@redhat.com>
 <CANn89i+udp6Y42D9wqmz7U6LGn1mtDRXpQGHAOAeX25eD0dGnQ@mail.gmail.com>
From: Tariq Toukan <ttoukan.linux@gmail.com>
Message-ID: <cd4f3d91-252b-4796-2bd2-3030c18d9ee6@gmail.com>
Date: Tue, 14 Feb 2017 16:56:49 +0200
MIME-Version: 1.0
In-Reply-To: <CANn89i+udp6Y42D9wqmz7U6LGn1mtDRXpQGHAOAeX25eD0dGnQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <edumazet@google.com>, Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Alexander Duyck <alexander.duyck@gmail.com>, "David S . Miller" <davem@davemloft.net>, netdev <netdev@vger.kernel.org>, Tariq Toukan <tariqt@mellanox.com>, Martin KaFai Lau <kafai@fb.com>, Saeed Mahameed <saeedm@mellanox.com>, Willem de Bruijn <willemb@google.com>, Brenden Blanco <bblanco@plumgrid.com>, Alexei Starovoitov <ast@kernel.org>, Eric Dumazet <eric.dumazet@gmail.com>, linux-mm <linux-mm@kvack.org>



On 14/02/2017 3:45 PM, Eric Dumazet wrote:
> On Tue, Feb 14, 2017 at 4:12 AM, Jesper Dangaard Brouer
> <brouer@redhat.com> wrote:
>
>> It is important to understand that there are two cases for the cost of
>> an atomic op, which depend on the cache-coherency state of the
>> cacheline.
>>
>> Measured on Skylake CPU i7-6700K CPU @ 4.00GHz
>>
>> (1) Local CPU atomic op :  27 cycles(tsc)  6.776 ns
>> (2) Remote CPU atomic op: 260 cycles(tsc) 64.964 ns
>>
> Okay, it seems you guys really want a patch that I said was not giving
> good results
>
> Let me publish the numbers I get , adding or not the last (and not
> official) patch.
>
> If I _force_ the user space process to run on the other node,
> then the results are not the ones Alex or you are expecting.
>
> I have with this patch about 2.7 Mpps of this silly single TCP flow,
> and 3.5 Mpps without it.
>
> lpaa24:~# sar -n DEV 1 10 | grep eth0 | grep Ave
> Average:         eth0 2699243.20  16663.70 1354783.36   1079.95
> 0.00      0.00      4.50
>
> Profile of the cpu on NUMA node 1 ( netserver consuming data ) :
>
>      54.73%  [kernel]      [k] copy_user_enhanced_fast_string
>      31.07%  [kernel]      [k] skb_release_data
>       4.24%  [kernel]      [k] skb_copy_datagram_iter
>       1.35%  [kernel]      [k] copy_page_to_iter
>       0.98%  [kernel]      [k] _raw_spin_lock
>       0.90%  [kernel]      [k] skb_release_head_state
>       0.60%  [kernel]      [k] tcp_transmit_skb
>       0.51%  [kernel]      [k] mlx4_en_xmit
>       0.33%  [kernel]      [k] ___cache_free
>       0.28%  [kernel]      [k] tcp_rcv_established
>
> Profile of cpu handling mlx4 softirqs (NUMA node 0)
>
>
>      48.00%  [kernel]          [k] mlx4_en_process_rx_cq
>      12.92%  [kernel]          [k] napi_gro_frags
>       7.28%  [kernel]          [k] inet_gro_receive
>       7.17%  [kernel]          [k] tcp_gro_receive
>       5.10%  [kernel]          [k] dev_gro_receive
>       4.87%  [kernel]          [k] skb_gro_receive
>       2.45%  [kernel]          [k] mlx4_en_prepare_rx_desc
>       2.04%  [kernel]          [k] __build_skb
>       1.02%  [kernel]          [k] napi_reuse_skb.isra.95
>       1.01%  [kernel]          [k] tcp4_gro_receive
>       0.65%  [kernel]          [k] kmem_cache_alloc
>       0.45%  [kernel]          [k] _raw_spin_lock
>
> Without the latest  patch (the exact patch series v3 I submitted),
> thus with this atomic_inc() in mlx4_en_process_rx_cq  instead of only reads.
>
> lpaa24:~# sar -n DEV 1 10|grep eth0|grep Ave
> Average:         eth0 3566768.50  25638.60 1790345.69   1663.51
> 0.00      0.00      4.50
>
> Profiles of the two cpus :
>
>      74.85%  [kernel]      [k] copy_user_enhanced_fast_string
>       6.42%  [kernel]      [k] skb_release_data
>       5.65%  [kernel]      [k] skb_copy_datagram_iter
>       1.83%  [kernel]      [k] copy_page_to_iter
>       1.59%  [kernel]      [k] _raw_spin_lock
>       1.48%  [kernel]      [k] skb_release_head_state
>       0.72%  [kernel]      [k] tcp_transmit_skb
>       0.68%  [kernel]      [k] mlx4_en_xmit
>       0.43%  [kernel]      [k] page_frag_free
>       0.38%  [kernel]      [k] ___cache_free
>       0.37%  [kernel]      [k] tcp_established_options
>       0.37%  [kernel]      [k] __ip_local_out
>
>
>     37.98%  [kernel]          [k] mlx4_en_process_rx_cq
>      26.47%  [kernel]          [k] napi_gro_frags
>       7.02%  [kernel]          [k] inet_gro_receive
>       5.89%  [kernel]          [k] tcp_gro_receive
>       5.17%  [kernel]          [k] dev_gro_receive
>       4.80%  [kernel]          [k] skb_gro_receive
>       2.61%  [kernel]          [k] __build_skb
>       2.45%  [kernel]          [k] mlx4_en_prepare_rx_desc
>       1.59%  [kernel]          [k] napi_reuse_skb.isra.95
>       0.95%  [kernel]          [k] tcp4_gro_receive
>       0.51%  [kernel]          [k] kmem_cache_alloc
>       0.42%  [kernel]          [k] __inet_lookup_established
>       0.34%  [kernel]          [k] swiotlb_sync_single_for_cpu
>
>
> So probably this will need further analysis, outside of the scope of
> this patch series.
>
> Could we now please Ack this v3 and merge it ?
>
> Thanks.
Thanks Eric.

As the previous series caused hangs, we must run functional regression 
tests over this series as well.
Run has already started, and results will be available tomorrow morning.

In general, I really like this series. The re-factorization looks more 
elegant and more correct, functionally.

However, performance wise: we fear that the numbers will be drastically 
lower with this transition to order-0 pages,
because of the (becoming critical) page allocator and dma operations 
bottlenecks, especially on systems with costly
dma operations, such as ARM, iommu=on, etc...

We already have this exact issue in mlx5, where we moved to order-0 
allocations with a fixed size cache, but that was not enough.
Customers of mlx5 have already complained about the performance 
degradation, and currently this is hurting our business.
We get a clear nack from our performance regression team regarding doing 
the same in mlx4.
So, the question is, can we live with this degradation until those 
bottleneck challenges are addressed?
Following our perf experts feedback, I cannot just simply Ack. We need 
to have a clear plan to close the perf gap or reduce the impact.

Internally, I already implemented "dynamic page-cache" and "page-reuse" 
mechanisms in the driver,
and together they totally bridge the performance gap.
That's why I would like to hear from Jesper what is the status of his 
page_pool API, it is promising and could totally solve these issues.

Regards,
Tariq

>
>
>
>> Notice the huge difference. And in case 2, it is enough that the remote
>> CPU reads the cacheline and brings it into "Shared" (MESI) state, and
>> the local CPU then does the atomic op.
>>
>> One key ideas behind the page_pool, is that remote CPUs read/detect
>> refcnt==1 (Shared-state), and store the page in a small per-CPU array.
>> When array is full, it gets bulk returned to the shared-ptr-ring pool.
>> When "local" CPU need new pages, from the shared-ptr-ring it prefetchw
>> during it's bulk refill, to latency-hide the MESI transitions needed.
>>
>> --
>> Best regards,
>>    Jesper Dangaard Brouer
>>    MSc.CS, Principal Kernel Engineer at Red Hat
>>    LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
