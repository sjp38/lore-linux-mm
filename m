Return-Path: <linux-kernel-owner+w=401wt.eu-S1758084AbYLLFvF@vger.kernel.org>
Date: Fri, 12 Dec 2008 06:50:51 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc][patch] SLQB slab allocator
Message-ID: <20081212055051.GE15804@wotan.suse.de>
References: <20081212002518.GH8294@wotan.suse.de> <4941F8D2.4060807@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <4941F8D2.4060807@cosmosbay.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Archive: <https://lore.kernel.org/lkml/>
List-Post: <mailto:linux-kernel@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, Dec 12, 2008 at 06:38:26AM +0100, Eric Dumazet wrote:
> Nick Piggin a écrit :
> > I'm going to continue working on this as I get time, and I plan to soon ask
> > to have it merged. It would be great if people could comment or test it.
> > 
> 
> It seems really good, but will need some hours to review :)
> 
> Minor nit : You spelled Qeued instead of Queued in init/Kconfig
> 
> +config SLQB
> +	bool "SLQB (Qeued allocator)"

OK, thanks.

 
> One of the problem I see with SLAB & SLUB is the irq masking stuff.
> Some (many ???) kmem_cache are only used in process context, I see no point of
> disabling irqs for them.

That's a very good point actually, and something I want to look at...

I'm thinking it will make most sense to provide a
kmem_cache_alloc/free_irqsafe for callers who either don't do any
interrupt context allocations, or already have irqs off (another
slab flag will just add another branch in the fastpaths).

And then also a kmalloc/kfree_irqsoff for code which already has
irqs off.

That's something which benefit all slab allocators roughly equally,
so at the moment I'm concentrating on the core code. But it's a very
good idea.
 

> I tested your patch on my 8 ways HP BL460c G1, on top
> on my last patch serie. (linux-2.6, not net-next-2.6)
> 
> # time ./socketallocbench
> 
> real    0m1.300s
> user    0m0.078s
> sys     0m1.207s
> # time ./socketallocbench -n 8
> 
> real    0m1.686s
> user    0m0.614s
> sys     0m12.737s
> 
> So no bad effect (same than SLUB).

Cool, thanks.

 
> For the record, SLAB is really really bad for this workload
> 
> PU: Core 2, speed 3000.1 MHz (estimated)
> Counted CPU_CLK_UNHALTED events (Clock cycles when not halted) with a unit mask of 0x00 (Unhalted core cycles) count 100
> 000
> samples  cum. samples  %        cum. %     symbol name
> 136537   136537        10.8300  10.8300    kmem_cache_alloc
> 129380   265917        10.2623  21.0924    tcp_close
> 79696    345613         6.3214  27.4138    tcp_v4_init_sock
> 73873    419486         5.8596  33.2733    tcp_v4_destroy_sock
> 63436    482922         5.0317  38.3050    sysenter_past_esp
> 62140    545062         4.9289  43.2339    inet_csk_destroy_sock
> 56565    601627         4.4867  47.7206    kmem_cache_free
> 40430    642057         3.2069  50.9275    __percpu_counter_add
> 35742    677799         2.8350  53.7626    init_timer
> 35611    713410         2.8246  56.5872    copy_from_user
> 21616    735026         1.7146  58.3018    d_alloc
> 20821    755847         1.6515  59.9533    alloc_inode
> 19645    775492         1.5582  61.5115    alloc_fd
> 18935    794427         1.5019  63.0134    __fput
> 18922    813349         1.5009  64.5143    inet_create
> 18919    832268         1.5006  66.0149    sys_close
> 16074    848342         1.2750  67.2899    release_sock
> 15337    863679         1.2165  68.5064    lock_sock_nested
> 15172    878851         1.2034  69.7099    sock_init_data
> 14196    893047         1.1260  70.8359    fd_install
> 13677    906724         1.0849  71.9207    drop_file_write_access
> 13195    919919         1.0466  72.9673    dput
> 12768    932687         1.0127  73.9801    inotify_d_instantiate
> 11404    944091         0.9046  74.8846    init_waitqueue_head
> 11228    955319         0.8906  75.7752    sysenter_do_call
> 11213    966532         0.8894  76.6647    local_bh_enable_ip
> 10948    977480         0.8684  77.5330    __sock_create
> 10912    988392         0.8655  78.3986    local_bh_enable
> 10665    999057         0.8459  79.2445    __new_inode
> 10579    1009636        0.8391  80.0836    inet_release
> 9665     1019301        0.7666  80.8503    iput_single
> 9545     1028846        0.7571  81.6074    fput
> 7950     1036796        0.6306  82.2379    sock_release
> 7236     1044032        0.5740  82.8119    local_bh_disable
> 
> 
> We can see most of the time is taken by the memset() to clear object,
> then irq masking stuff...

Yep, it's difficult to make the local alloc/free fastpath much more
optimal as-is.

Is SLAB still bad at the test with the slab-rcu patch in place?
SLAB has a pretty optimal fastpath as well, although if its queues
start overflowing, it can run into contention quite easily.

> 
> c0281e10 <kmem_cache_alloc>: /* kmem_cache_alloc total: 140659 10.8277 */

I guess you're compiling with -Os? I find gcc can pack the fastpath
much better with -O2, and actually decrease the effective icache
footprint size even if the total text size increases...


>   2414  0.1858 :c0281e10:       push   %ebp
>      7 5.4e-04 :c0281e11:       mov    %esp,%ebp
>                :c0281e13:       push   %edi
>   1454  0.1119 :c0281e14:       push   %esi
>    310  0.0239 :c0281e15:       mov    %eax,%esi
>                :c0281e17:       push   %ebx
>    368  0.0283 :c0281e18:       sub    $0x10,%esp
>    949  0.0731 :c0281e1b:       mov    %edx,-0x18(%ebp)
>    383  0.0295 :c0281e1e:       mov    0x4(%ebp),%eax
>   1189  0.0915 :c0281e21:       mov    %eax,-0x14(%ebp)
>   1240  0.0955 :c0281e24:       jmp    c0281e6e <kmem_cache_alloc+0x5e>
>                :c0281e26:       lea    0x0(%esi),%esi
>                :c0281e29:       lea    0x0(%edi,%eiz,1),%edi
>   1188  0.0915 :c0281e30:       mov    0x10(%esi),%eax
>                :c0281e33:       mov    (%edx,%eax,1),%eax
>   1483  0.1142 :c0281e36:       decl   (%ebx)
>    898  0.0691 :c0281e38:       mov    %eax,0x4(%ebx)
>    586  0.0451 :c0281e3b:       mov    %edx,-0x1c(%ebp)
>      1 7.7e-05 :c0281e3e:       pushl  -0x10(%ebp)
>   1226  0.0944 :c0281e41:       popf
>  26385  2.0311 :c0281e42:       testl  $0x210d00,(%esi)
>   1188  0.0915 :c0281e48:       je     c0281ef8 <kmem_cache_alloc+0xe8>
>                :c0281e4e:       mov    -0x1c(%ebp),%eax
>                :c0281e51:       test   %eax,%eax
>                :c0281e53:       je     c0281ef8 <kmem_cache_alloc+0xe8>
>                :c0281e59:       mov    -0x14(%ebp),%ecx
>                :c0281e5c:       mov    -0x1c(%ebp),%edx
>                :c0281e5f:       mov    %esi,%eax
>                :c0281e61:       call   c0280d60 <alloc_debug_processing>
>                :c0281e66:       test   %eax,%eax
>                :c0281e68:       jne    c0281ef8 <kmem_cache_alloc+0xe8>
>   1205  0.0928 :c0281e6e:       pushf
>   4888  0.3763 :c0281e6f:       popl   -0x10(%ebp)
>    319  0.0246 :c0281e72:       cli
>   5975  0.4599 :c0281e73:       nop
>                :c0281e74:       lea    0x0(%esi,%eiz,1),%esi
>                :c0281e78:       mov    %fs:0xc068d004,%eax
>   1166  0.0898 :c0281e7e:       mov    0x38(%esi,%eax,4),%ebx
>     26  0.0020 :c0281e82:       mov    0x4(%ebx),%edx
>    662  0.0510 :c0281e85:       test   %edx,%edx
>                :c0281e87:       jne    c0281e30 <kmem_cache_alloc+0x20>
>                :c0281e89:       mov    0xc(%ebx),%eax
>                :c0281e8c:       test   %eax,%eax
>                :c0281e8e:       jne    c0281ec8 <kmem_cache_alloc+0xb8>
>                :c0281e90:       mov    %ebx,%edx
>                :c0281e92:       mov    %esi,%eax
>                :c0281e94:       call   c0280010 <__cache_list_get_page>
>                :c0281e99:       mov    %eax,%edx
>                :c0281e9b:       test   %eax,%eax
>                :c0281e9d:       jne    c0281f31 <kmem_cache_alloc+0x121>
>                :c0281ea3:       mov    $0xffffffff,%ecx
>      1 7.7e-05 :c0281ea8:       mov    -0x18(%ebp),%edx
>                :c0281eab:       mov    %esi,%eax
>                :c0281ead:       call   c02815a0 <__slab_alloc_page>
>                :c0281eb2:       test   %eax,%eax
>                :c0281eb4:       jne    c0281e78 <kmem_cache_alloc+0x68>
>                :c0281eb6:       movl   $0x0,-0x1c(%ebp)
>                :c0281ebd:       jmp    c0281e3e <kmem_cache_alloc+0x2e>
>                :c0281ec2:       lea    0x0(%esi),%esi
>                :c0281ec8:       mov    %esi,%eax
>                :c0281eca:       mov    %ebx,%edx
>                :c0281ecc:       call   c0280240 <claim_remote_free_list>
>                :c0281ed1:       mov    0x4(%esi),%eax
>                :c0281ed4:       shl    $0x2,%eax
>                :c0281ed7:       cmp    %eax,(%ebx)
>                :c0281ed9:       ja     c0281f48 <kmem_cache_alloc+0x138>
>                :c0281edb:       mov    0x4(%ebx),%edx
>                :c0281ede:       mov    %edx,-0x1c(%ebp)
>                :c0281ee1:       test   %edx,%edx
>                :c0281ee3:       je     c0281e90 <kmem_cache_alloc+0x80>
>                :c0281ee5:       mov    0x10(%esi),%eax
>                :c0281ee8:       mov    (%edx,%eax,1),%eax
>                :c0281eeb:       decl   (%ebx)
>                :c0281eed:       mov    %eax,0x4(%ebx)
>                :c0281ef0:       jmp    c0281e3e <kmem_cache_alloc+0x2e>
> 
>                :c0281ef5:       lea    0x0(%esi),%esi
>   1261  0.0971 :c0281ef8:       cmpw   $0x0,-0x18(%ebp)
>    957  0.0737 :c0281efd:       jns    c0281f26 <kmem_cache_alloc+0x116>
>    627  0.0483 :c0281eff:       mov    -0x1c(%ebp),%eax
>                :c0281f02:       test   %eax,%eax
>                :c0281f04:       je     c0281f26 <kmem_cache_alloc+0x116>
>     82  0.0063 :c0281f06:       mov    0xc(%esi),%esi
>      2 1.5e-04 :c0281f09:       mov    -0x1c(%ebp),%ebx
>    527  0.0406 :c0281f0c:       mov    %esi,%ecx
>                :c0281f0e:       mov    %ebx,%edi
>     86  0.0066 :c0281f10:       shr    $0x2,%ecx
>    602  0.0463 :c0281f13:       xor    %eax,%eax
>      1 7.7e-05 :c0281f15:       mov    %esi,%edx
>  74845  5.7614 :c0281f17:       rep stos %eax,%es:(%edi)
>   1170  0.0901 :c0281f19:       test   $0x2,%dl
>      2 1.5e-04 :c0281f1c:       je     c0281f20 <kmem_cache_alloc+0x110>
>                :c0281f1e:       stos   %ax,%es:(%edi)
>    600  0.0462 :c0281f20:       test   $0x1,%dl
>                :c0281f23:       je     c0281f26 <kmem_cache_alloc+0x116>
>                :c0281f25:       stos   %al,%es:(%edi)
>   1171  0.0901 :c0281f26:       mov    -0x1c(%ebp),%eax
>    199  0.0153 :c0281f29:       add    $0x10,%esp
>                :c0281f2c:       pop    %ebx
>      2 1.5e-04 :c0281f2d:       pop    %esi
>   1215  0.0935 :c0281f2e:       pop    %edi
>    548  0.0422 :c0281f2f:       leave
>   1251  0.0963 :c0281f30:       ret
>                :c0281f31:       mov    0x10(%edx),%ecx
>                :c0281f34:       mov    %ecx,-0x1c(%ebp)
>                :c0281f37:       mov    0x10(%esi),%eax
>                :c0281f3a:       mov    (%ecx,%eax,1),%eax
>                :c0281f3d:       mov    %eax,0x10(%edx)
>                :c0281f40:       jmp    c0281e3e <kmem_cache_alloc+0x2e>
>                :c0281f45:       lea    0x0(%esi),%esi
>                :c0281f48:       mov    %ebx,%edx
>                :c0281f4a:       mov    %esi,%eax
>                :c0281f4c:       call   c02811d0 <flush_free_list>
>                :c0281f51:       jmp    c0281edb <kmem_cache_alloc+0xcb>
>                :c0281f53:       lea    0x0(%esi),%esi
