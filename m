Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f176.google.com (mail-qc0-f176.google.com [209.85.216.176])
	by kanga.kvack.org (Postfix) with ESMTP id 6C23A6B0073
	for <linux-mm@kvack.org>; Wed, 17 Dec 2014 07:08:56 -0500 (EST)
Received: by mail-qc0-f176.google.com with SMTP id i17so11874592qcy.21
        for <linux-mm@kvack.org>; Wed, 17 Dec 2014 04:08:56 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y30si4367054qge.9.2014.12.17.04.08.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Dec 2014 04:08:54 -0800 (PST)
Date: Wed, 17 Dec 2014 13:08:41 +0100
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH 0/7] slub: Fastpath optimization (especially for RT) V1
Message-ID: <20141217130841.100dac71@redhat.com>
In-Reply-To: <CAAmzW4NCpx5aJyW36fgOfu3EaDj6=uv6MUiBC+a0ggePWPXndQ@mail.gmail.com>
References: <20141210163017.092096069@linux.com>
	<20141215075933.GD4898@js1304-P5Q-DELUXE>
	<CAAmzW4NCpx5aJyW36fgOfu3EaDj6=uv6MUiBC+a0ggePWPXndQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Christoph Lameter <cl@linux.com>, akpm@linuxfoundation.org, Steven Rostedt <rostedt@goodmis.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Linux Memory Management List <linux-mm@kvack.org>, Pekka Enberg <penberg@kernel.org>, brouer@redhat.com

On Wed, 17 Dec 2014 16:13:49 +0900 Joonsoo Kim <js1304@gmail.com> wrote:

> Ping... and I found another way to remove preempt_disable/enable
> without complex changes.
> 
> What we want to ensure is getting tid and kmem_cache_cpu
> on the same cpu. We can achieve that goal with below condition loop.
> 
> I ran Jesper's benchmark and saw 3~5% win in a fast-path loop over
> kmem_cache_alloc+free in CONFIG_PREEMPT.
> 
> 14.5 ns -> 13.8 ns

Hi Kim,

I've tested you patch.  Full report below patch.

Summary, I'm seeing 18.599 ns -> 17.523 ns (-1.076ns better).

For network overload tests:

Dropping packets in iptables raw, which is hitting the slub fast-path.
Here I'm seeing an improvement of 3ns.

For IP-forward, which is also invoking the slub slower path, I'm seeing
an improvement of 6ns (I were not expecting to see any improvement
here, the kmem_cache_alloc code is 24bytes smaller, so perhaps it's
saving some icache).

Full report below patch...
 
> See following patch.
> 
> Thanks.
> 
> ----------->8-------------
> diff --git a/mm/slub.c b/mm/slub.c
> index 95d2142..e537af5 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -2399,8 +2399,10 @@ redo:
>          * on a different processor between the determination of the pointer
>          * and the retrieval of the tid.
>          */
> -       preempt_disable();
> -       c = this_cpu_ptr(s->cpu_slab);
> +       do {
> +               tid = this_cpu_read(s->cpu_slab->tid);
> +               c = this_cpu_ptr(s->cpu_slab);
> +       } while (IS_ENABLED(CONFIG_PREEMPT) && unlikely(tid != c->tid));
> 
>         /*
>          * The transaction ids are globally unique per cpu and per operation on
> @@ -2408,8 +2410,6 @@ redo:
>          * occurs on the right processor and that there was no operation on the
>          * linked list in between.
>          */
> -       tid = c->tid;
> -       preempt_enable();
> 
>         object = c->freelist;
>         page = c->page;
> @@ -2655,11 +2655,10 @@ redo:
>          * data is retrieved via this pointer. If we are on the same cpu
>          * during the cmpxchg then the free will succedd.
>          */
> -       preempt_disable();
> -       c = this_cpu_ptr(s->cpu_slab);
> -
> -       tid = c->tid;
> -       preempt_enable();
> +       do {
> +               tid = this_cpu_read(s->cpu_slab->tid);
> +               c = this_cpu_ptr(s->cpu_slab);
> +       } while (IS_ENABLED(CONFIG_PREEMPT) && unlikely(tid != c->tid));
> 
>         if (likely(page == c->page)) {
>                 set_freepointer(s, object, c->freelist);

SLUB evaluation 03
==================

Testing patch from Joonsoo Kim <iamjoonsoo.kim@lge.com> slub fast-path
preempt_{disable,enable} avoidance.

Kernel
======
Compiler: GCC 4.9.1

Kernel config ::

 $ grep PREEMPT .config
 CONFIG_PREEMPT_RCU=y
 CONFIG_PREEMPT_NOTIFIERS=y
 # CONFIG_PREEMPT_NONE is not set
 # CONFIG_PREEMPT_VOLUNTARY is not set
 CONFIG_PREEMPT=y
 CONFIG_PREEMPT_COUNT=y
 # CONFIG_DEBUG_PREEMPT is not set

 $ egrep -e "SLUB|SLAB" .config
 # CONFIG_SLUB_DEBUG is not set
 # CONFIG_SLAB is not set
 CONFIG_SLUB=y
 # CONFIG_SLUB_CPU_PARTIAL is not set
 # CONFIG_SLUB_STATS is not set

On top of::

 commit f96fe225677b3efb74346ebd56fafe3997b02afa
 Merge: 5543798 eea3e8f
 Author: Linus Torvalds <torvalds@linux-foundation.org>
 Date:   Fri Dec 12 16:11:12 2014 -0800

    Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net


Setup
=====

netfilter_unload_modules.sh
netfilter_unload_modules.sh
sudo rmmod nf_reject_ipv4 nf_reject_ipv6

base_device_setup.sh eth4  # 10G sink/receiving interface (ixgbe)
base_device_setup.sh eth5
sudo ethtool --coalesce eth4 rx-usecs 30
sudo ip neigh add 192.168.21.66 dev eth5 lladdr 00:00:ba:d0:ba:d0
sudo ip route add 198.18.0.0/15 via 192.168.21.66 dev eth5


# sudo tuned-adm active
Current active profile: latency-performance

Drop in raw
-----------
alias iptables='sudo iptables'
iptables -t raw -N simple || iptables -t raw -F simple
iptables -t raw -I simple -d 198.18.0.0/15 -j DROP
iptables -t raw -D PREROUTING -j simple
iptables -t raw -I PREROUTING -j simple

Generator
---------
./pktgen02_burst.sh -d 198.18.0.2 -i eth8 -m 90:E2:BA:0A:56:B4 -b 8 -t 3 -s 64


Patch by Joonsoo Kim to avoid preempt in slub
=============================================

baseline: without patch
-----------------------

baseline kernel v3.18-7016-gf96fe22 at commit f96fe22567

Type:kmem fastpath reuse Per elem: 46 cycles(tsc) 18.599 ns
 - (measurement period time:1.859917529 sec time_interval:1859917529)
 - (invoke count:100000000 tsc_interval:4649791431)

alloc N-pattern before free with 256 elements

Type:kmem alloc+free N-pattern Per elem: 100 cycles(tsc) 40.077 ns
 - (measurement period time:1.025993290 sec time_interval:1025993290)
 - (invoke count:25600000 tsc_interval:2564981743)

single flow/CPU
 * IP-forward
  - instant rx:0 tx:1165376 pps n:60 average: rx:0 tx:1165928 pps
    (instant variation TX -0.407 ns (min:-0.828 max:0.507) RX 0.000 ns)
 * Drop in RAW (slab fast-path test)
   - instant rx:3245248 tx:0 pps n:60 average: rx:3245325 tx:0 pps
     (instant variation TX 0.000 ns (min:0.000 max:0.000) RX -0.007 ns)

Christoph's slab_test, baseline kernel (at commit f96fe22567)::

 Single thread testing
 =====================
 1. Kmalloc: Repeatedly allocate then free test
 10000 times kmalloc(8) -> 49 cycles kfree -> 62 cycles
 10000 times kmalloc(16) -> 48 cycles kfree -> 64 cycles
 10000 times kmalloc(32) -> 53 cycles kfree -> 70 cycles
 10000 times kmalloc(64) -> 64 cycles kfree -> 77 cycles
 10000 times kmalloc(128) -> 74 cycles kfree -> 84 cycles
 10000 times kmalloc(256) -> 84 cycles kfree -> 114 cycles
 10000 times kmalloc(512) -> 83 cycles kfree -> 116 cycles
 10000 times kmalloc(1024) -> 81 cycles kfree -> 120 cycles
 10000 times kmalloc(2048) -> 104 cycles kfree -> 136 cycles
 10000 times kmalloc(4096) -> 142 cycles kfree -> 165 cycles
 10000 times kmalloc(8192) -> 238 cycles kfree -> 226 cycles
 10000 times kmalloc(16384) -> 403 cycles kfree -> 264 cycles
 2. Kmalloc: alloc/free test
 10000 times kmalloc(8)/kfree -> 68 cycles
 10000 times kmalloc(16)/kfree -> 68 cycles
 10000 times kmalloc(32)/kfree -> 69 cycles
 10000 times kmalloc(64)/kfree -> 68 cycles
 10000 times kmalloc(128)/kfree -> 68 cycles
 10000 times kmalloc(256)/kfree -> 68 cycles
 10000 times kmalloc(512)/kfree -> 74 cycles
 10000 times kmalloc(1024)/kfree -> 75 cycles
 10000 times kmalloc(2048)/kfree -> 74 cycles
 10000 times kmalloc(4096)/kfree -> 74 cycles
 10000 times kmalloc(8192)/kfree -> 75 cycles
 10000 times kmalloc(16384)/kfree -> 510 cycles

$ nm --print-size vmlinux | egrep -e 'kmem_cache_alloc|kmem_cache_free|is_pointer_to_page'
ffffffff81163bd0 00000000000000e1 T kmem_cache_alloc
ffffffff81163ac0 000000000000010c T kmem_cache_alloc_node
ffffffff81162cb0 000000000000013b T kmem_cache_free


with patch
----------

single flow/CPU
 * IP-forward
  - instant rx:0 tx:1174652 pps n:60 average: rx:0 tx:1174222 pps
    (instant variation TX 0.311 ns (min:-0.230 max:1.018) RX 0.000 ns)
 * compare against baseline:
  - 1174222-1165928 = +8294pps
  - (1/1174222*10^9)-(1/1165928*10^9) = -6.058ns

 * Drop in RAW (slab fast-path test)
  - instant rx:3277440 tx:0 pps n:74 average: rx:3277737 tx:0 pps
    (instant variation TX 0.000 ns (min:0.000 max:0.000) RX -0.028 ns)
 * compare against baseline:
  - 3277737-3245325 = +32412 pps
  - (1/3277737*10^9)-(1/3245325*10^9) = -3.047ns

SLUB fast-path test: time_bench_kmem_cache1
 * modprobe time_bench_kmem_cache1 ; rmmod time_bench_kmem_cache1; sudo dmesg -c

Type:kmem fastpath reuse Per elem: 43 cycles(tsc) 17.523 ns (step:0)
 - (measurement period time:1.752338378 sec time_interval:1752338378)
 - (invoke count:100000000 tsc_interval:4380843588)
  * difference: 17.523 - 18.599 = -1.076ns

alloc N-pattern before free with 256 elements

Type:kmem alloc+free N-pattern Per elem: 100 cycles(tsc) 40.369 ns (step:0)
 - (measurement period time:1.033447112 sec time_interval:1033447112)
 - (invoke count:25600000 tsc_interval:2583616203)
    * difference: 40.369 - 40.077 = +0.292ns


Christoph's slab_test::

 Single thread testing
 =====================
 1. Kmalloc: Repeatedly allocate then free test
 10000 times kmalloc(8) -> 46 cycles kfree -> 61 cycles
 10000 times kmalloc(16) -> 46 cycles kfree -> 63 cycles
 10000 times kmalloc(32) -> 49 cycles kfree -> 69 cycles
 10000 times kmalloc(64) -> 57 cycles kfree -> 76 cycles
 10000 times kmalloc(128) -> 66 cycles kfree -> 83 cycles
 10000 times kmalloc(256) -> 84 cycles kfree -> 110 cycles
 10000 times kmalloc(512) -> 77 cycles kfree -> 114 cycles
 10000 times kmalloc(1024) -> 80 cycles kfree -> 116 cycles
 10000 times kmalloc(2048) -> 102 cycles kfree -> 131 cycles
 10000 times kmalloc(4096) -> 135 cycles kfree -> 163 cycles
 10000 times kmalloc(8192) -> 238 cycles kfree -> 218 cycles
 10000 times kmalloc(16384) -> 399 cycles kfree -> 262 cycles
 2. Kmalloc: alloc/free test
 10000 times kmalloc(8)/kfree -> 65 cycles
 10000 times kmalloc(16)/kfree -> 66 cycles
 10000 times kmalloc(32)/kfree -> 65 cycles
 10000 times kmalloc(64)/kfree -> 66 cycles
 10000 times kmalloc(128)/kfree -> 66 cycles
 10000 times kmalloc(256)/kfree -> 71 cycles
 10000 times kmalloc(512)/kfree -> 72 cycles
 10000 times kmalloc(1024)/kfree -> 71 cycles
 10000 times kmalloc(2048)/kfree -> 71 cycles
 10000 times kmalloc(4096)/kfree -> 71 cycles
 10000 times kmalloc(8192)/kfree -> 65 cycles
 10000 times kmalloc(16384)/kfree -> 511 cycles

$ nm --print-size vmlinux | egrep -e 'kmem_cache_alloc|kmem_cache_free|is_pointer_to_page'
ffffffff81163ba0 00000000000000c9 T kmem_cache_alloc
ffffffff81163aa0 00000000000000f8 T kmem_cache_alloc_node
ffffffff81162cb0 0000000000000133 T kmem_cache_free



Kernel size change
------------------

 $ scripts/bloat-o-meter vmlinux vmlinux-kim-preempt-avoid
 add/remove: 0/0 grow/shrink: 0/8 up/down: 0/-248 (-248)
 function                                     old     new   delta
 kmem_cache_free                              315     307      -8
 kmem_cache_alloc_node                        268     248     -20
 kmem_cache_alloc                             225     201     -24
 kfree                                        274     250     -24
 __kmalloc_node_track_caller                  356     324     -32
 __kmalloc_node                               340     308     -32
 __kmalloc                                    324     273     -51
 __kmalloc_track_caller                       343     286     -57


Qmempool notes:
---------------

On baseline kernel:

Type:qmempool fastpath reuse SOFTIRQ Per elem: 33 cycles(tsc) 13.287 ns
 - (measurement period time:0.398628965 sec time_interval:398628965)
 - (invoke count:30000000 tsc_interval:996571541)

Type:qmempool fastpath reuse BH-disable Per elem: 47 cycles(tsc) 19.180 ns
 - (measurement period time:0.575425927 sec time_interval:575425927)
 - (invoke count:30000000 tsc_interval:1438563781)

qmempool_bench: N-pattern with 256 elements

Type:qmempool alloc+free N-pattern Per elem: 62 cycles(tsc) 24.955 ns (step:0)
 - (measurement period time:0.638871008 sec time_interval:638871008)
 - (invoke count:25600000 tsc_interval:1597176303)


-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
