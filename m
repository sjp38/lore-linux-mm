Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf1-f72.google.com (mail-lf1-f72.google.com [209.85.167.72])
	by kanga.kvack.org (Postfix) with ESMTP id BA2556B02B2
	for <linux-mm@kvack.org>; Mon, 12 Nov 2018 12:01:10 -0500 (EST)
Received: by mail-lf1-f72.google.com with SMTP id z10so973577lfe.21
        for <linux-mm@kvack.org>; Mon, 12 Nov 2018 09:01:10 -0800 (PST)
Received: from smtp7.iq.pl (smtp7.iq.pl. [86.111.240.244])
        by mx.google.com with ESMTPS id y130si9750171lff.43.2018.11.12.09.01.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Nov 2018 09:01:07 -0800 (PST)
Subject: Re: [PATCH 1/2] mm/page_alloc: free order-0 pages through PCP in
 page_frag_free()
References: <20181105085820.6341-1-aaron.lu@intel.com>
 <CAKgT0UdvYVTA8OjgLhXo9tRUOGikrCi3zJXSrqM0ZmeHb5P2mA@mail.gmail.com>
 <b8b1fbb7-9139-9455-69b8-8c1bed4f7c74@itcare.pl>
 <CAKgT0UdhcXF-ohPHPbg8onRjFabEMnbpXGmLm-27skCNzGKOgw@mail.gmail.com>
 <bd33633b-2f6c-0034-a130-38a8468531db@itcare.pl>
 <CAKgT0UeOBF0yPJLOTBBb3m7nTkmSDxzkCur+iGzJ++Y-jWaw9g@mail.gmail.com>
From: =?UTF-8?Q?Pawe=c5=82_Staszewski?= <pstaszewski@itcare.pl>
Message-ID: <b8cb68d5-06c0-5e85-ec44-270ec92d1b8b@itcare.pl>
Date: Mon, 12 Nov 2018 18:01:09 +0100
MIME-Version: 1.0
In-Reply-To: <CAKgT0UeOBF0yPJLOTBBb3m7nTkmSDxzkCur+iGzJ++Y-jWaw9g@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: pl
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: aaron.lu@intel.com, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Netdev <netdev@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jesper Dangaard Brouer <brouer@redhat.com>, Eric Dumazet <eric.dumazet@gmail.com>, Tariq Toukan <tariqt@mellanox.com>, ilias.apalodimas@linaro.org, yoel@kviknet.dk, Mel Gorman <mgorman@techsingularity.net>, Saeed Mahameed <saeedm@mellanox.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, dave.hansen@linux.intel.com


W dniu 12.11.2018 oA 16:30, Alexander Duyck pisze:
> On Sun, Nov 11, 2018 at 4:39 PM PaweA? Staszewski <pstaszewski@itcare.pl> wrote:
>>
>> W dniu 12.11.2018 o 00:05, Alexander Duyck pisze:
>>> On Sat, Nov 10, 2018 at 3:54 PM PaweA? Staszewski <pstaszewski@itcare.pl> wrote:
>>>>
>>>> W dniu 05.11.2018 o 16:44, Alexander Duyck pisze:
>>>>> On Mon, Nov 5, 2018 at 12:58 AM Aaron Lu <aaron.lu@intel.com> wrote:
>>>>>> page_frag_free() calls __free_pages_ok() to free the page back to
>>>>>> Buddy. This is OK for high order page, but for order-0 pages, it
>>>>>> misses the optimization opportunity of using Per-Cpu-Pages and can
>>>>>> cause zone lock contention when called frequently.
>>>>>>
>>>>>> PaweA? Staszewski recently shared his result of 'how Linux kernel
>>>>>> handles normal traffic'[1] and from perf data, Jesper Dangaard Brouer
>>>>>> found the lock contention comes from page allocator:
>>>>>>
>>>>>>      mlx5e_poll_tx_cq
>>>>>>      |
>>>>>>       --16.34%--napi_consume_skb
>>>>>>                 |
>>>>>>                 |--12.65%--__free_pages_ok
>>>>>>                 |          |
>>>>>>                 |           --11.86%--free_one_page
>>>>>>                 |                     |
>>>>>>                 |                     |--10.10%--queued_spin_lock_slowpath
>>>>>>                 |                     |
>>>>>>                 |                      --0.65%--_raw_spin_lock
>>>>>>                 |
>>>>>>                 |--1.55%--page_frag_free
>>>>>>                 |
>>>>>>                  --1.44%--skb_release_data
>>>>>>
>>>>>> Jesper explained how it happened: mlx5 driver RX-page recycle
>>>>>> mechanism is not effective in this workload and pages have to go
>>>>>> through the page allocator. The lock contention happens during
>>>>>> mlx5 DMA TX completion cycle. And the page allocator cannot keep
>>>>>> up at these speeds.[2]
>>>>>>
>>>>>> I thought that __free_pages_ok() are mostly freeing high order
>>>>>> pages and thought this is an lock contention for high order pages
>>>>>> but Jesper explained in detail that __free_pages_ok() here are
>>>>>> actually freeing order-0 pages because mlx5 is using order-0 pages
>>>>>> to satisfy its page pool allocation request.[3]
>>>>>>
>>>>>> The free path as pointed out by Jesper is:
>>>>>> skb_free_head()
>>>>>>      -> skb_free_frag()
>>>>>>        -> skb_free_frag()
>>>>>>          -> page_frag_free()
>>>>>> And the pages being freed on this path are order-0 pages.
>>>>>>
>>>>>> Fix this by doing similar things as in __page_frag_cache_drain() -
>>>>>> send the being freed page to PCP if it's an order-0 page, or
>>>>>> directly to Buddy if it is a high order page.
>>>>>>
>>>>>> With this change, PaweA? hasn't noticed lock contention yet in
>>>>>> his workload and Jesper has noticed a 7% performance improvement
>>>>>> using a micro benchmark and lock contention is gone.
>>>>>>
>>>>>> [1]: https://www.spinics.net/lists/netdev/msg531362.html
>>>>>> [2]: https://www.spinics.net/lists/netdev/msg531421.html
>>>>>> [3]: https://www.spinics.net/lists/netdev/msg531556.html
>>>>>> Reported-by: PaweA? Staszewski <pstaszewski@itcare.pl>
>>>>>> Analysed-by: Jesper Dangaard Brouer <brouer@redhat.com>
>>>>>> Signed-off-by: Aaron Lu <aaron.lu@intel.com>
>>>>>> ---
>>>>>>     mm/page_alloc.c | 10 ++++++++--
>>>>>>     1 file changed, 8 insertions(+), 2 deletions(-)
>>>>>>
>>>>>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>>>>>> index ae31839874b8..91a9a6af41a2 100644
>>>>>> --- a/mm/page_alloc.c
>>>>>> +++ b/mm/page_alloc.c
>>>>>> @@ -4555,8 +4555,14 @@ void page_frag_free(void *addr)
>>>>>>     {
>>>>>>            struct page *page = virt_to_head_page(addr);
>>>>>>
>>>>>> -       if (unlikely(put_page_testzero(page)))
>>>>>> -               __free_pages_ok(page, compound_order(page));
>>>>>> +       if (unlikely(put_page_testzero(page))) {
>>>>>> +               unsigned int order = compound_order(page);
>>>>>> +
>>>>>> +               if (order == 0)
>>>>>> +                       free_unref_page(page);
>>>>>> +               else
>>>>>> +                       __free_pages_ok(page, order);
>>>>>> +       }
>>>>>>     }
>>>>>>     EXPORT_SYMBOL(page_frag_free);
>>>>>>
>>>>> One thing I would suggest for Pawel to try would be to reduce the Tx
>>>>> qdisc size on his transmitting interfaces, Reduce the Tx ring size,
>>>>> and possibly increase the Tx interrupt rate. Ideally we shouldn't have
>>>>> too many packets in-flight and I suspect that is the issue that Pawel
>>>>> is seeing that is leading to the page pool allocator freeing up the
>>>>> memory. I know we like to try to batch things but the issue is
>>>>> processing too many Tx buffers in one batch leads to us eating up too
>>>>> much memory and causing evictions from the cache. Ideally the Rx and
>>>>> Tx rings and queues should be sized as small as possible while still
>>>>> allowing us to process up to our NAPI budget. Usually I run things
>>>>> with a 128 Rx / 128 Tx setup and then reduce the Tx queue length so we
>>>>> don't have more buffers stored there than we can place in the Tx ring.
>>>>> Then we can avoid the extra thrash of having to pull/push memory into
>>>>> and out of the freelists. Essentially the issue here ends up being
>>>>> another form of buffer bloat.
>>>> Thanks Aleksandar - yes it can be - but in my scenario setting RX buffer
>>>> <4096 producing more interface rx drops - and no_rx_buffer on network
>>>> controller that is receiving more packets
>>>> So i need to stick with 3000-4000 on RX - and yes i was trying to lower
>>>> the TX buff on connectx4 - but that changed nothing before Aaron patch
>>>>
>>>> After Aaron patch - decreasing TX buffer influencing total bandwidth
>>>> that can be handled by the router/server
>>>> Dono why before this patch there was no difference there no matter what
>>>> i set there there was always page_alloc/slowpath on top in perf
>>>>
>>>>
>>>> Currently testing RX4096/TX256 - this helps with bandwidth like +10%
>>>> more bandwidth with less interrupts...
>>> The problem is if you are going for less interrupts you are setting
>>> yourself up for buffer bloat. Basically you are going to use much more
>>> cache and much more memory then you actually need and if things are
>>> properly configured NAPI should take care of the interrupts anyway
>>> since under maximum load you shouldn't stop polling normally.
>> Im trying to balance here - there is problem cause server is forwarding
>> all kingd of protocols packets/different size etc
>>
>> The problem is im trying to go in high interrupt rate - but
>>
>> Setting coalescence to adaptative for rx killing cpu's at 22Gbit/s RX
>> and 22Gbit with rly high interrupt rate
> I wouldn't recommend adaptive just because the behavior would be hard
> to predict.
>
>> So adding a little more latency i can turn off adaptative rx and setup
>> rx-usecs from range 16-64 - and this gives me more or less interrupts -
>> but the problem is - always same bandwidth as maximum
> What about the tx-usecs, is that a functional thing for the adapter
> you are using?

Yes tx-usecs is not used now cause of adaptative mode on tx side:

ethtool -c enp175s0
Coalesce parameters for enp175s0:
Adaptive RX: offA  TX: on
stats-block-usecs: 0
sample-interval: 0
pkt-rate-low: 0
pkt-rate-high: 0
dmac: 32551

rx-usecs: 64
rx-frames: 128
rx-usecs-irq: 0
rx-frames-irq: 0

tx-usecs: 8
tx-frames: 64
tx-usecs-irq: 0
tx-frames-irq: 0

rx-usecs-low: 0
rx-frame-low: 0
tx-usecs-low: 0
tx-frame-low: 0

rx-usecs-high: 0
rx-frame-high: 0
tx-usecs-high: 0
tx-frame-high: 0

>
> The Rx side logic should be pretty easy to figure out. Essentially you
> want to keep the Rx ring size as small as possible while at the same
> time avoiding storming the system with interrupts. I know for 10Gb/s I
> have used a value of 25us in the past. What you want to watch for is
> if you are dropping packets on the Rx side or not. Ideally you want
> enough buffers that you can capture any burst while you wait for the
> interrupt routine to catch up.
>
>>> One issue I have seen is people delay interrupts for as long as
>>> possible which isn't really a good thing since most network
>>> controllers will use NAPI which will disable the interrupts and leave
>>> them disabled whenever the system is under heavy stress so you should
>>> be able to get the maximum performance by configuring an adapter with
>>> small ring sizes and for high interrupt rates.
>> Sure this is bad to setup rx-usec for high values - cause at some point
>> this will add high latency for packet traversing both sides - and start
>> to hurt buffers
>>
>> But my problem is a little different now i have no problems with RX side
>> - cause i can setup anything like:
>>
>> coalescence from 16 to 64
>>
>> rx ring from 3000 to max 8192
>>
>> And it does not change my max bw - only produces less or more interrupts.
> Right so the issue itself isn't Rx, you aren't throttled there. We are
> probably looking at an issue of PCIe bandwidth or Tx slowing things
> down. The fact that you are still filing interrupts is a bit
> surprising though. Are the Tx and Rx interrupts linked for the device
> you are using or are they firing them seperately? Normally Rx traffic
> won't generate many interrupts under a stress test as NAPI will leave
> the interrupts disabled unless it can keep up. Anyway, my suggestion
> would be to look at tuning things for as small a ring size as
> possible.

PCIe bw was eliminated - previously there was one 2 port 100G card 
installed in one pciex16 (max bw for pcie x16 gen3 is 32GB/s 16/16GB 
bidirectional)

Currently there are two separate nic's installed in two separate x16 
slots - so can't be problem with pcie bandwidth

But i think I reach memory bandwidth limit now for 70Gbit/70Gbit :)

But wondering if there is any counter that can help me to diagnose 
problems with memory bandwidth ?

stream app tests gives me results like:

./stream_c.exe
-------------------------------------------------------------
STREAM version $Revision: 5.10 $
-------------------------------------------------------------
This system uses 8 bytes per array element.
-------------------------------------------------------------
Array size = 10000000 (elements), Offset = 0 (elements)
Memory per array = 76.3 MiB (= 0.1 GiB).
Total memory required = 228.9 MiB (= 0.2 GiB).
Each kernel will be executed 10 times.
 A The *best* time for each kernel (excluding the first iteration)
 A will be used to compute the reported bandwidth.
-------------------------------------------------------------
Number of Threads requested = 56
Number of Threads counted = 56
-------------------------------------------------------------
Your clock granularity/precision appears to be 1 microseconds.
Each test below will take on the order of 4081 microseconds.
 A A  (= 4081 clock ticks)
Increase the size of the arrays if this shows that
you are not getting at least 20 clock ticks per test.
-------------------------------------------------------------
WARNING -- The above is only a rough guideline.
For best results, please be sure you know the
precision of your system timer.
-------------------------------------------------------------
FunctionA A A  Best Rate MB/sA  Avg timeA A A A  Min timeA A A A  Max time
Copy:A A A A A A A A A A  29907.2A A A A  0.005382A A A A  0.005350A A A A  0.005405
Scale:A A A A A A A A A  28787.3A A A A  0.005611A A A A  0.005558A A A A  0.005650
Add:A A A A A A A A A A A  34153.3A A A A  0.007037A A A A  0.007027A A A A  0.007055
Triad:A A A A A A A A A  34944.0A A A A  0.006880A A A A  0.006868A A A A  0.006887
-------------------------------------------------------------
Solution Validates: avg error less than 1.000000e-13 on all three arrays

But this is for node 0+1

When limiting test to one node and cores used by network controllers:

-------------------------------------------------------------
STREAM version $Revision: 5.10 $
-------------------------------------------------------------
This system uses 8 bytes per array element.
-------------------------------------------------------------
Array size = 10000000 (elements), Offset = 0 (elements)
Memory per array = 76.3 MiB (= 0.1 GiB).
Total memory required = 228.9 MiB (= 0.2 GiB).
Each kernel will be executed 10 times.
 A The *best* time for each kernel (excluding the first iteration)
 A will be used to compute the reported bandwidth.
-------------------------------------------------------------
Number of Threads requested = 28
Number of Threads counted = 28
-------------------------------------------------------------
Your clock granularity/precision appears to be 1 microseconds.
Each test below will take on the order of 6107 microseconds.
 A A  (= 6107 clock ticks)
Increase the size of the arrays if this shows that
you are not getting at least 20 clock ticks per test.
-------------------------------------------------------------
WARNING -- The above is only a rough guideline.
For best results, please be sure you know the
precision of your system timer.
-------------------------------------------------------------
FunctionA A A  Best Rate MB/sA  Avg timeA A A A  Min timeA A A A  Max time
Copy:A A A A A A A A A A  20156.4A A A A  0.007946A A A A  0.007938A A A A  0.007958
Scale:A A A A A A A A A  19436.1A A A A  0.008237A A A A  0.008232A A A A  0.008243
Add:A A A A A A A A A A A  20184.7A A A A  0.011896A A A A  0.011890A A A A  0.011904
Triad:A A A A A A A A A  20687.9A A A A  0.011607A A A A  0.011601A A A A  0.011613
-------------------------------------------------------------
Solution Validates: avg error less than 1.000000e-13 on all three arrays
-------------------------------------------------------------

Close to the limit but still some place - there can be some doubled 
operations like for RX/TX side and network controllers can use more 
bandwidth or just can't do this more optimally - cause of 
bulking/buffers etc.


So currently there are only four from six channels used - i will upgrade 
also memory and populate all six channels left/right side for two memory 
controllers that cpu have.


>> So I start to change params for TX side - and for now i know that the
>> best for me is
>>
>> coalescence adaptative on
>>
>> TX buffer 128
>>
>> This helps with max BW that for now is close to 70Gbit/s RX and 70Gbit
>> TX but after this change i have increasing DROPS on TX side for vlan
>> interfaces.
> So this sounds like you are likely bottlenecked due to either PCIe
> bandwidth or latency. When you start putting back-pressure on the Tx
> like you have described it starts pushing packets onto the Qdisc
> layer. One thing that happens when packets are on the qdisc layer is
> that they can start to perform a bulk dequeue. The side effect of this
> is that you write multiple packets to the descriptor ring and then
> update the hardware doorbell only once for the entire group of packets
> instead of once per packet.

yes the problem is i just can't find any place where counters will shows 
me why nic's start to drop packets

it does not reflect in cpu load or any other counter besides rx_phy 
drops and tx_vlan drop packets


>> And only 50% cpu (max was 50% for 70Gbit/s)
>>
>>
>>> It is easiest to think of it this way. Your total packet rate is equal
>>> to your interrupt rate times the number of buffers you will store in
>>> the ring. So if you have some fixed rate "X" for packets and an
>>> interrupt rate of "i" then your optimal ring size should be "X/i". So
>>> if you lower the interrupt rate you end up hurting the throughput
>>> unless you increase the buffer size. However at a certain point the
>>> buffer size starts becoming an issue. For example with UDP flows I
>>> often see massive packet drops if you tune the interrupt rate too low
>>> and then put the system under heavy stress.
>> Yes - in normal life traffic - most of ddos'es are like this many pps
>> with small frames.
> It sounds to me like XDP would probably be your best bet. With that
> you could probably get away with smaller ring sizes, higher interrupt
> rates, and get the advantage of it batching the Tx without having to
> drop packets.

Yes im testing in lab xdp_fwd currently - but have some problems with 
random drops that occuring randomly where server forwards only 1/10A  
packet and after some time it starts to work normally.

Currently trying to eliminate nic's offloading that can cause this - so 
turning off one by one and running tests.
