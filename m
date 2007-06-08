Received: by ug-out-1314.google.com with SMTP id m2so1109534uge
        for <linux-mm@kvack.org>; Fri, 08 Jun 2007 12:32:43 -0700 (PDT)
Message-ID: <4669AED3.8020204@googlemail.com>
Date: Fri, 08 Jun 2007 21:32:35 +0200
MIME-Version: 1.0
Subject: Re: [patch 00/12] Slab defragmentation V3
References: <20070607215529.147027769@sgi.com>  <466999A2.8020608@googlemail.com>  <Pine.LNX.4.64.0706081110580.1464@schroedinger.engr.sgi.com> <6bffcb0e0706081156u4ad0cc9dkf6d55ebcbd79def2@mail.gmail.com> <Pine.LNX.4.64.0706081207400.2082@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0706081207400.2082@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dgc@sgi.com, Mel Gorman <mel@skynet.ie>
List-ID: <linux-mm.kvack.org>

Christoph Lameter pisze:
> On Fri, 8 Jun 2007, Michal Piotrowski wrote:
> 
>> Yes, it does. Thanks!
> 
> Ahhh... That leds to the discovery more sysfs problems. I need to make 
> sure not to be holding locks while calling into sysfs. More cleanup...
> 
> 

sysfs... I forgot about my sysfs test case

#! /bin/sh

for i in `find /sys/ -type f`
do
    echo "wyA?wietlam $i"
    sudo cat $i > /dev/null
#    sleep 1s
done

[ 2816.175573] BUG: sleeping function called from invalid context at mm/page_alloc.c:1547
[ 2816.183578] in_atomic():1, irqs_disabled():1
[ 2816.187946] 1 lock held by cat/12586:
[ 2816.191705]  #0:  (&n->list_lock){++..}, at: [<c0481630>] list_locations+0x3d/0x26b

l *list_locations+0x3d
0xc1081630 is in list_locations (mm/slub.c:3388).
3383                    struct page *page;
3384
3385                    if (!atomic_read(&n->nr_slabs))
3386                            continue;
3387
3388                    spin_lock_irqsave(&n->list_lock, flags);
3389                    list_for_each_entry(page, &n->partial, lru)
3390                            process_slab(&t, s, page, alloc);
3391                    list_for_each_entry(page, &n->full, lru)
3392                            process_slab(&t, s, page, alloc);


[ 2816.199571] irq event stamp: 11526
[ 2816.203054] hardirqs last  enabled at (11525): [<c042adbd>] on_each_cpu+0x3b/0x71
[ 2816.210689] hardirqs last disabled at (11526): [<c065d241>] _spin_lock_irqsave+0x13/0x6e
[ 2816.218910] softirqs last  enabled at (11236): [<c042b5dd>] __do_softirq+0xdf/0xe5
[ 2816.226635] softirqs last disabled at (11229): [<c0406d65>] do_softirq+0x68/0x11f

l *on_each_cpu+0x3b
0xc102adbd is in on_each_cpu (include/asm/irqflags.h:36).
31              asm volatile("cli": : :"memory");
32      }
33
34      static inline void native_irq_enable(void)
35      {
36              asm volatile("sti": : :"memory");
37      }
38
39      static inline void native_safe_halt(void)
40      {

l *_spin_lock_irqsave+0x13
0xc125d241 is in _spin_lock_irqsave (kernel/spinlock.c:84).
79      unsigned long __lockfunc _spin_lock_irqsave(spinlock_t *lock)
80      {
81              unsigned long flags;
82
83              local_irq_save(flags);
84              preempt_disable();
85              spin_acquire(&lock->dep_map, 0, 0, _RET_IP_);
86              /*
87               * On lockdep we dont want the hand-coded irq-enable of
88               * _raw_spin_lock_flags() code, because lockdep assumes

l *__do_softirq+0xdf
0xc102b5dd is in __do_softirq (kernel/softirq.c:252).
247
248             trace_softirq_exit();
249
250             account_system_vtime(current);
251             _local_bh_enable();
252     }
253
254     #ifndef __ARCH_HAS_DO_SOFTIRQ
255
256     asmlinkage void do_softirq(void)

l *do_softirq+0x68
0xc1006d65 is in do_softirq (arch/i386/kernel/irq.c:222).
217                     irqctx->tinfo.previous_esp = current_stack_pointer;
218
219                     /* build the stack frame on the softirq stack */
220                     isp = (u32*) ((char*)irqctx + sizeof(*irqctx));
221
222                     asm volatile(
223                             "       xchgl   %%ebx,%%esp     \n"
224                             "       call    __do_softirq    \n"
225                             "       movl    %%ebx,%%esp     \n"
226                             : "=b"(isp)


[ 2816.234235]  [<c04052ad>] dump_trace+0x63/0x1eb
[ 2816.238888]  [<c040544f>] show_trace_log_lvl+0x1a/0x2f
[ 2816.244211]  [<c040608d>] show_trace+0x12/0x14
[ 2816.248757]  [<c04060a5>] dump_stack+0x16/0x18
[ 2816.253288]  [<c041eef1>] __might_sleep+0xce/0xd5
[ 2816.258046]  [<c04680b5>] __alloc_pages+0x33/0x324
[ 2816.262968]  [<c04683fb>] __get_free_pages+0x55/0x66
[ 2816.268060]  [<c0481517>] process_slab+0x1bd/0x299
[ 2816.272988]  [<c048164a>] list_locations+0x57/0x26b
[ 2816.277981]  [<c0481880>] free_calls_show+0x22/0x29
[ 2816.282965]  [<c047e702>] slab_attr_show+0x1c/0x20
[ 2816.287891]  [<c04c1bd9>] sysfs_read_file+0x94/0x105
[ 2816.293018]  [<c048580b>] vfs_read+0xcf/0x158
[ 2816.297539]  [<c0485c71>] sys_read+0x3d/0x72
[ 2816.301910]  [<c040420c>] syscall_call+0x7/0xb
[ 2816.306486]  [<b7f30410>] 0xb7f30410
[ 2816.310165]  =======================
[ 2818.826341] BUG: sleeping function called from invalid context at mm/page_alloc.c:1547
[ 2818.834388] in_atomic():1, irqs_disabled():1
[ 2818.838751] 1 lock held by cat/12635:
[ 2818.842506]  #0:  (&n->list_lock){++..}, at: [<c0481630>] list_locations+0x3d/0x26b
[ 2818.850460] irq event stamp: 11494
[ 2818.853908] hardirqs last  enabled at (11493): [<c042adbd>] on_each_cpu+0x3b/0x71
[ 2818.861505] hardirqs last disabled at (11494): [<c065d241>] _spin_lock_irqsave+0x13/0x6e
[ 2818.869831] softirqs last  enabled at (11258): [<c042b5dd>] __do_softirq+0xdf/0xe5
[ 2818.877576] softirqs last disabled at (11215): [<c0406d65>] do_softirq+0x68/0x11f
[ 2818.885217]  [<c04052ad>] dump_trace+0x63/0x1eb
[ 2818.889893]  [<c040544f>] show_trace_log_lvl+0x1a/0x2f
[ 2818.895112]  [<c040608d>] show_trace+0x12/0x14
[ 2818.899667]  [<c04060a5>] dump_stack+0x16/0x18
[ 2818.904232]  [<c041eef1>] __might_sleep+0xce/0xd5
[ 2818.909046]  [<c04680b5>] __alloc_pages+0x33/0x324
[ 2818.913956]  [<c04683fb>] __get_free_pages+0x55/0x66
[ 2818.919022]  [<c0481517>] process_slab+0x1bd/0x299
[ 2818.923923]  [<c048164a>] list_locations+0x57/0x26b
[ 2818.928961]  [<c0481880>] free_calls_show+0x22/0x29
[ 2818.933916]  [<c047e702>] slab_attr_show+0x1c/0x20
[ 2818.938825]  [<c04c1bd9>] sysfs_read_file+0x94/0x105
[ 2818.943900]  [<c048580b>] vfs_read+0xcf/0x158
[ 2818.948335]  [<c0485c71>] sys_read+0x3d/0x72
[ 2818.952683]  [<c040420c>] syscall_call+0x7/0xb
[ 2818.957213]  [<b7f82410>] 0xb7f82410
[ 2818.960896]  =======================

http://www.stardust.webpages.pl/files/tbf/bitis-gabonica/2.6.22-rc4-mm2-sd3/sd-dmesg2

Regards,
Michal

-- 
"Najbardziej brakowaA?o mi twojego milczenia."
-- Andrzej Sapkowski "CoA? wiA?cej"

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
