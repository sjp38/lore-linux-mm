Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 2DE076B01F0
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 14:02:06 -0400 (EDT)
Message-ID: <4C74097A.5020504@kernel.org>
Date: Tue, 24 Aug 2010 21:03:38 +0300
From: Pekka Enberg <penberg@kernel.org>
MIME-Version: 1.0
Subject: Re: 2.6.34.1 page allocation failure
References: <4C70BFF3.8030507@hardwarefreak.com> <alpine.DEB.1.10.1008220842400.8562@uplift.swm.pp.se> <AANLkTin48SJ58HvFqjrOnQBMqLcbECtqXokweV00dNgv@mail.gmail.com> <alpine.DEB.2.00.1008221734410.21916@router.home> <4C724141.8060000@kernel.org> <4C72F7C6.3020109@hardwarefreak.com>
In-Reply-To: <4C72F7C6.3020109@hardwarefreak.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Stan Hoeppner <stan@hardwarefreak.com>
Cc: Christoph Lameter <cl@linux.com>, Mikael Abrahamsson <swmike@swm.pp.se>, Linux Kernel List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, Linux Netdev List <netdev@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

  [ I'm CC'ing netdev. ]

On 24.8.2010 1.35, Stan Hoeppner wrote:
> Pekka Enberg put forth on 8/23/2010 4:37 AM:
>>   On 8/23/10 1:40 AM, Christoph Lameter wrote:
>>> On Sun, 22 Aug 2010, Pekka Enberg wrote:
>>>
>>>> In Stan's case, it's a order-1 GFP_ATOMIC allocation but there are
>>>> only order-0 pages available. Mel, any recent page allocator fixes in
>>>> 2.6.35 or 2.6.36-rc1 that Stan/Mikael should test?
>>> This is the TCP slab? Best fix would be in the page allocator. However,
>>> in this particular case the slub allocator would be able to fall back to
>>> an order 0 allocation and still satisfy the request.
>> Looking at the stack trace of the oops, I think Stan has CONFIG_SLAB
>> which doesn't have order-0 fallback.
> That is correct.  The menuconfig help screen led me to believe the SLAB
> allocator was the "safe" choice:
>
> "CONFIG_SLAB:
> The regular slab allocator that is established and known to work well in
> all environments"
>
> Should I be using SLUB instead?  Any downsides to SLUB on an old and
> slow (500 MHz) single core dual CPU box with<512MB RAM?
I don't think the problem here is SLAB so it shouldn't matter which one 
you use. You might not see the problems with SLUB, though, because it 
falls back to 0-order allocations.
> Also, what is the impact of these oopses?  Despite the entries in dmesg,
> the system "seems" to be running ok.  Or is this simply the calm before
> the impending storm?
The page allocation failure in question is this:

kswapd0: page allocation failure. order:1, mode:0x20
Pid: 139, comm: kswapd0 Not tainted 2.6.34.1 #1
Call Trace:
  [<c104b6b3>] ? __alloc_pages_nodemask+0x448/0x48a
  [<c1062ffb>] ? cache_alloc_refill+0x22f/0x422
  [<c11a9a73>] ? tcp_v4_send_check+0x6e/0xa4
  [<c10632c3>] ? kmem_cache_alloc+0x41/0x6a
  [<c11773a5>] ? sk_prot_alloc+0x19/0x55
  [<c117744b>] ? sk_clone+0x16/0x1cc
  [<c119a71d>] ? inet_csk_clone+0xf/0x80
  [<c11ac0e3>] ? tcp_create_openreq_child+0x1a/0x3c8
  [<c11aaf0a>] ? tcp_v4_syn_recv_sock+0x4b/0x151
  [<c11abf9d>] ? tcp_check_req+0x209/0x335
  [<c11aa892>] ? tcp_v4_do_rcv+0x8d/0x14d
  [<c11aacd5>] ? tcp_v4_rcv+0x383/0x56d
  [<c1193ba4>] ? ip_local_deliver+0x76/0xc0
  [<c1193b10>] ? ip_rcv+0x3dc/0x3fa
  [<c103655e>] ? ktime_get_real+0xf/0x2b
  [<c117f8d3>] ? netif_receive_skb+0x219/0x234
  [<c115ff46>] ? e100_poll+0x1d0/0x47e
  [<c117fa98>] ? net_rx_action+0x58/0xf8
  [<c102539c>] ? __do_softirq+0x78/0xe5
  [<c102542c>] ? do_softirq+0x23/0x27
  [<c1003955>] ? do_IRQ+0x7d/0x8e
  [<c1002aa9>] ? common_interrupt+0x29/0x30
  [<c1062870>] ? kmem_cache_free+0xbd/0xc5
  [<c10fa7d1>] ? __xfs_inode_set_reclaim_tag+0x29/0x2f
  [<c1075215>] ? destroy_inode+0x1c/0x2b
  [<c10752ce>] ? dispose_list+0xaa/0xd0
  [<c107548c>] ? shrink_icache_memory+0x198/0x1c5
  [<c104f76b>] ? shrink_slab+0xda/0x12f
  [<c104fc28>] ? kswapd+0x468/0x63b
  [<c104dca3>] ? isolate_pages_global+0x0/0x1bc
  [<c10304d6>] ? autoremove_wake_function+0x0/0x2d
  [<c1018faf>] ? complete+0x28/0x36
  [<c104f7c0>] ? kswapd+0x0/0x63b
  [<c10301cd>] ? kthread+0x61/0x66
  [<c103016c>] ? kthread+0x0/0x66
  [<c1002ab6>] ? kernel_thread_helper+0x6/0x10

It looks to me as if tcp_create_openreq_child() is able to cope with the 
situation so the warning could be harmless. If that's the case, we 
should probably stick a __GFP_NOWARN there.

                 Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
