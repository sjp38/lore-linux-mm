Return-Path: <linux-kernel-owner+w=401wt.eu-S1757438AbYLLHHg@vger.kernel.org>
Message-ID: <49420DAB.7090604@cosmosbay.com>
Date: Fri, 12 Dec 2008 08:07:23 +0100
From: Eric Dumazet <dada1@cosmosbay.com>
MIME-Version: 1.0
Subject: Re: [rfc][patch] SLQB slab allocator
References: <20081212002518.GH8294@wotan.suse.de> <4941F8D2.4060807@cosmosbay.com> <20081212055051.GE15804@wotan.suse.de>
In-Reply-To: <20081212055051.GE15804@wotan.suse.de>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Sender: linux-kernel-owner@vger.kernel.org
List-Archive: <https://lore.kernel.org/lkml/>
List-Post: <mailto:linux-kernel@vger.kernel.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Nick Piggin a écrit :
> On Fri, Dec 12, 2008 at 06:38:26AM +0100, Eric Dumazet wrote:
>> Nick Piggin a écrit :
>>> I'm going to continue working on this as I get time, and I plan to soon ask
>>> to have it merged. It would be great if people could comment or test it.
>>>
>> It seems really good, but will need some hours to review :)
>>
>> Minor nit : You spelled Qeued instead of Queued in init/Kconfig
>>
>> +config SLQB
>> +	bool "SLQB (Qeued allocator)"
> 
> OK, thanks.
> 
>  
>> One of the problem I see with SLAB & SLUB is the irq masking stuff.
>> Some (many ???) kmem_cache are only used in process context, I see no point of
>> disabling irqs for them.
> 
> That's a very good point actually, and something I want to look at...
> 
> I'm thinking it will make most sense to provide a
> kmem_cache_alloc/free_irqsafe for callers who either don't do any
> interrupt context allocations, or already have irqs off (another
> slab flag will just add another branch in the fastpaths).
> 
> And then also a kmalloc/kfree_irqsoff for code which already has
> irqs off.
> 
> That's something which benefit all slab allocators roughly equally,
> so at the moment I'm concentrating on the core code. But it's a very
> good idea.
>  
> 
>> I tested your patch on my 8 ways HP BL460c G1, on top
>> on my last patch serie. (linux-2.6, not net-next-2.6)
>>
>> # time ./socketallocbench
>>
>> real    0m1.300s
>> user    0m0.078s
>> sys     0m1.207s
>> # time ./socketallocbench -n 8
>>
>> real    0m1.686s
>> user    0m0.614s
>> sys     0m12.737s
>>
>> So no bad effect (same than SLUB).
> 
> Cool, thanks.
> 
>  
>> For the record, SLAB is really really bad for this workload
>>
>> PU: Core 2, speed 3000.1 MHz (estimated)
>> Counted CPU_CLK_UNHALTED events (Clock cycles when not halted) with a unit mask of 0x00 (Unhalted core cycles) count 100
>> 000
>> samples  cum. samples  %        cum. %     symbol name
>> 136537   136537        10.8300  10.8300    kmem_cache_alloc
>> 129380   265917        10.2623  21.0924    tcp_close
>> 79696    345613         6.3214  27.4138    tcp_v4_init_sock
>> 73873    419486         5.8596  33.2733    tcp_v4_destroy_sock
>> 63436    482922         5.0317  38.3050    sysenter_past_esp
>> 62140    545062         4.9289  43.2339    inet_csk_destroy_sock
>> 56565    601627         4.4867  47.7206    kmem_cache_free
>> 40430    642057         3.2069  50.9275    __percpu_counter_add
>> 35742    677799         2.8350  53.7626    init_timer
>> 35611    713410         2.8246  56.5872    copy_from_user
>> 21616    735026         1.7146  58.3018    d_alloc
>> 20821    755847         1.6515  59.9533    alloc_inode
>> 19645    775492         1.5582  61.5115    alloc_fd
>> 18935    794427         1.5019  63.0134    __fput
>> 18922    813349         1.5009  64.5143    inet_create
>> 18919    832268         1.5006  66.0149    sys_close
>> 16074    848342         1.2750  67.2899    release_sock
>> 15337    863679         1.2165  68.5064    lock_sock_nested
>> 15172    878851         1.2034  69.7099    sock_init_data
>> 14196    893047         1.1260  70.8359    fd_install
>> 13677    906724         1.0849  71.9207    drop_file_write_access
>> 13195    919919         1.0466  72.9673    dput
>> 12768    932687         1.0127  73.9801    inotify_d_instantiate
>> 11404    944091         0.9046  74.8846    init_waitqueue_head
>> 11228    955319         0.8906  75.7752    sysenter_do_call
>> 11213    966532         0.8894  76.6647    local_bh_enable_ip
>> 10948    977480         0.8684  77.5330    __sock_create
>> 10912    988392         0.8655  78.3986    local_bh_enable
>> 10665    999057         0.8459  79.2445    __new_inode
>> 10579    1009636        0.8391  80.0836    inet_release
>> 9665     1019301        0.7666  80.8503    iput_single
>> 9545     1028846        0.7571  81.6074    fput
>> 7950     1036796        0.6306  82.2379    sock_release
>> 7236     1044032        0.5740  82.8119    local_bh_disable
>>
>>
>> We can see most of the time is taken by the memset() to clear object,
>> then irq masking stuff...
> 
> Yep, it's difficult to make the local alloc/free fastpath much more
> optimal as-is.
> 
> Is SLAB still bad at the test with the slab-rcu patch in place?
> SLAB has a pretty optimal fastpath as well, although if its queues
> start overflowing, it can run into contention quite easily.

Yes, I forgot I applied Christoph patch (SLAB_DESTROY_BY_RCU for struct file) 
in the meantime, silly me, this was with the v2 of my serie, with only 5 patches.

With SLAB, results are quite good !

# time ./socketallocbench

real    0m1.201s
user    0m0.071s
sys     0m1.122s
# time ./socketallocbench -n8

real    0m1.616s
user    0m0.578s
sys     0m12.220s


> 
>> c0281e10 <kmem_cache_alloc>: /* kmem_cache_alloc total: 140659 10.8277 */
> 
> I guess you're compiling with -Os? I find gcc can pack the fastpath
> much better with -O2, and actually decrease the effective icache
> footprint size even if the total text size increases...

No, I dont use -Os, unless something got wrong

# CONFIG_CC_OPTIMIZE_FOR_SIZE is not set
# CONFIG_OPTIMIZE_INLINING is not set
