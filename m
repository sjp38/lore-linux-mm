Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 9B1476B002D
	for <linux-mm@kvack.org>; Wed, 16 Nov 2011 12:45:39 -0500 (EST)
Received: by wwf10 with SMTP id 10so993872wwf.26
        for <linux-mm@kvack.org>; Wed, 16 Nov 2011 09:45:37 -0800 (PST)
Message-ID: <1321465534.4182.37.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Subject: Re: [rfc 00/18] slub: irqless/lockless slow allocation paths
From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 16 Nov 2011 18:45:34 +0100
In-Reply-To: <1321465198.4182.35.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <20111111200711.156817886@linux.com>
	 <1321465198.4182.35.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: David Miller <davem@davemloft.net>, Pekka Enberg <penberg@cs.helsinki.fi>, David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, tj@kernel.org, Metathronius Galabant <m.galabant@googlemail.com>, Matt Mackall <mpm@selenic.com>, Adrian Drzewiecki <z@drze.net>, Shaohua Li <shaohua.li@intel.com>, Alex Shi <alex.shi@intel.com>, linux-mm@kvack.org, netdev <netdev@vger.kernel.org>

Le mercredi 16 novembre 2011 A  18:39 +0100, Eric Dumazet a A(C)crit :

> Adding SLUB_STATS gives :
> 
> $ cd /sys/kernel/slab/skbuff_head_cache ; grep . *
> aliases:6
> align:8
> grep: alloc_calls: Function not implemented
> alloc_fastpath:89181782 C0=89173048 C1=1599 C2=1357 C3=2140 C4=802 C5=675 C6=638 C7=1523
> alloc_from_partial:412658 C0=412658
> alloc_node_mismatch:0
> alloc_refill:593417 C0=593189 C1=19 C2=15 C3=24 C4=51 C5=18 C6=17 C7=84
> alloc_slab:2831313 C0=2831285 C1=2 C2=2 C3=2 C4=2 C5=12 C6=4 C7=4
> alloc_slowpath:4430371 C0=4430112 C1=20 C2=17 C3=25 C4=57 C5=31 C6=21 C7=88
> cache_dma:0
> cmpxchg_double_cpu_fail:0
> cmpxchg_double_fail:1 C0=1
> cpu_partial:30
> cpu_partial_alloc:592991 C0=592981 C2=1 C4=5 C5=2 C6=1 C7=1
> cpu_partial_free:4429836 C0=592981 C1=25 C2=19 C3=23 C4=3836767 C5=6 C6=8 C7=7
> cpuslab_flush:0
> cpu_slabs:107
> deactivate_bypass:3836954 C0=3836923 C1=1 C2=2 C3=1 C4=6 C5=13 C6=4 C7=4
> deactivate_empty:2831168 C4=2831168
> deactivate_full:0
> deactivate_remote_frees:0
> deactivate_to_head:0
> deactivate_to_tail:0
> destroy_by_rcu:0
> free_add_partial:0
> grep: free_calls: Function not implemented
> free_fastpath:21192924 C0=21186268 C1=1420 C2=1204 C3=1966 C4=572 C5=349 C6=380 C7=765
> free_frozen:67988498 C0=516 C1=121 C2=85 C3=841 C4=67986468 C5=215 C6=76 C7=176
> free_remove_partial:18 C4=18
> free_slab:2831186 C4=2831186
> free_slowpath:71825749 C0=609 C1=146 C2=104 C3=864 C4=71823538 C5=221 C6=84 C7=183
> hwcache_align:0
> min_partial:5
> objects:2494
> object_size:192
> objects_partial:121
> objs_per_slab:21
> order:0
> order_fallback:0
> partial:14
> poison:0
> reclaim_account:0
> red_zone:0
> reserved:0
> sanity_checks:0
> slabs:127
> slabs_cpu_partial:99(99) C1=25(25) C2=18(18) C3=23(23) C4=16(16) C5=4(4) C6=7(7) C7=6(6)
> slab_size:192
> store_user:0
> total_objects:2667
> trace:0
> 

And the SLUB stats for the 2048 bytes slab is even worse : About every
alloc/free is slow path

$ cd /sys/kernel/slab/:t-0002048 ; grep . *
aliases:0
align:8
grep: alloc_calls: Function not implemented
alloc_fastpath:8199220 C0=8196915 C1=306 C2=63 C3=297 C4=319 C5=550
C6=722 C7=48
alloc_from_partial:13931406 C0=13931401 C3=1 C5=4
alloc_node_mismatch:0
alloc_refill:70871657 C0=70871629 C1=2 C3=3 C4=9 C5=11 C6=3
alloc_slab:1335 C0=1216 C1=17 C2=2 C3=15 C4=17 C5=22 C6=44 C7=2
alloc_slowpath:155455299 C0=155455144 C1=18 C2=1 C3=21 C4=27 C5=40 C6=47
C7=1
cache_dma:0
cmpxchg_double_cpu_fail:0
cmpxchg_double_fail:27341 C0=12769 C4=14572
cpu_partial:6
cpu_partial_alloc:70650909 C0=70650899 C3=3 C4=2 C5=4 C6=1
cpu_partial_free:136279924 C0=71504388 C1=13 C2=1 C3=52 C4=64775461 C5=6
C6=2 C7=1
cpuslab_flush:0
cpu_slabs:29
deactivate_bypass:84583642 C0=84583515 C1=16 C2=1 C3=18 C4=18 C5=29
C6=44 C7=1
deactivate_empty:570 C0=80 C3=34 C4=456
deactivate_full:0
deactivate_remote_frees:0
deactivate_to_head:0
deactivate_to_tail:0
destroy_by_rcu:0
free_add_partial:0
grep: free_calls: Function not implemented
free_fastpath:89153 C0=88972 C1=34 C2=35 C3=27 C4=12 C5=23 C6=30 C7=20
free_frozen:5971363 C0=554097 C1=196 C2=14 C3=730 C4=5416278 C5=16 C6=19
C7=13
free_remove_partial:401 C1=1 C4=400
free_slab:971 C0=80 C1=1 C3=34 C4=856
free_slowpath:92913113 C0=21090357 C1=212 C2=15 C3=784 C4=71821691 C5=19
C6=21 C7=14
hwcache_align:0
min_partial:5
objects:1873
object_size:2048
objects_partial:945
objs_per_slab:16
order:3
order_fallback:0
partial:306
poison:0
reclaim_account:0
red_zone:0
reserved:0
sanity_checks:0
slabs:364
slabs_cpu_partial:21(21) C0=3(3) C1=6(6) C2=1(1) C3=7(7) C5=2(2) C6=1(1)
C7=1(1)
slab_size:2048
store_user:0
total_objects:5824
trace:0


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
