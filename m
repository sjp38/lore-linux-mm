Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id A8140831F4
	for <linux-mm@kvack.org>; Fri, 19 May 2017 05:46:14 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id s62so54961312pgc.2
        for <linux-mm@kvack.org>; Fri, 19 May 2017 02:46:14 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [45.249.212.188])
        by mx.google.com with ESMTPS id r191si7843663pgr.62.2017.05.19.02.46.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 19 May 2017 02:46:13 -0700 (PDT)
Message-ID: <591EBE71.7080402@huawei.com>
Date: Fri, 19 May 2017 17:44:17 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: mm, something wring in page_lock_anon_vma_read()?
References: <591D6D79.7030704@huawei.com> <591EB25C.9080901@huawei.com>
In-Reply-To: <591EB25C.9080901@huawei.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel
 Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, David
 Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, aarcange@redhat.com, sumeet.keswani@hpe.com, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, zhong jiang <zhongjiang@huawei.com>

On 2017/5/19 16:52, Xishi Qiu wrote:

> On 2017/5/18 17:46, Xishi Qiu wrote:
> 
>> Hi, my system triggers this bug, and the vmcore shows the anon_vma seems be freed.
>> The kernel is RHEL 7.2, and the bug is hard to reproduce, so I don't know if it
>> exists in mainline, any reply is welcome!
>>
> 
> When we alloc anon_vma, we will init the value of anon_vma->root,
> so can we set anon_vma->root to NULL when calling
> anon_vma_free -> kmem_cache_free(anon_vma_cachep, anon_vma);
> 
> anon_vma_free()
> 	...
> 	anon_vma->root = NULL;
> 	kmem_cache_free(anon_vma_cachep, anon_vma);
> 
> I find if we do this above, system boot failed, why?
> 

If anon_vma was freed, we should not to access the root_anon_vma, because it maybe also
freed(e.g. anon_vma == root_anon_vma), right?

page_lock_anon_vma_read()
	...
	anon_vma = (struct anon_vma *) (anon_mapping - PAGE_MAPPING_ANON);
	root_anon_vma = ACCESS_ONCE(anon_vma->root);
	if (down_read_trylock(&root_anon_vma->rwsem)) {  // it's not safe
	...
	if (!atomic_inc_not_zero(&anon_vma->refcount)) {  // check anon_vma was not freed
	...
	anon_vma_lock_read(anon_vma);  // it's safe
	...


> Thanks,
> Xishi Qiu
> 
>> [35030.332666] general protection fault: 0000 [#1] SMP
>> [35030.333016] Modules linked in: veth ipt_MASQUERADE nf_nat_masquerade_ipv4 iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 xt_addrtype iptable_filter xt_conntrack nf_nat nf_conntrack bridge stp llc dm_thin_pool dm_persistent_data dm_bio_prison dm_bufio libcrc32c rtos_kbox_panic(OE) ipmi_devintf ipmi_si ipmi_msghandler signo_catch(O) cirrus syscopyarea sysfillrect sysimgblt ttm crc32_pclmul ghash_clmulni_intel drm_kms_helper aesni_intel ppdev drm lrw gf128mul parport_pc glue_helper ablk_helper serio_raw cryptd i2c_piix4 parport pcspkr sg floppy i2c_core dm_mod sha512_generic ip_tables sd_mod crc_t10dif crct10dif_generic sr_mod cdrom virtio_console virtio_scsi virtio_net ata_generic pata_acpi crct10dif_pclmul crct10dif_common crc32c_intel virtio_pci virtio_ring virtio ata_piix libata ext4 mbcache
>> [35030.333016]  jbd2
>> [35030.333016] CPU: 3 PID: 48 Comm: kswapd0 Tainted: G           OE  ---- -------   3.10.0-327.36.58.4.x86_64 #1
>> [35030.333016] Hardware name: OpenStack Foundation OpenStack Nova, BIOS rel-1.8.1-0-g4adadbd-20160826_044443-hghoulaslx112 04/01/2014
>> [35030.333016] task: ffff8801b2d20000 ti: ffff8801b4c38000 task.ti: ffff8801b4c38000
>> [35030.333016] RIP: 0010:[<ffffffff810acac5>]  [<ffffffff810acac5>] down_read_trylock+0x5/0x50
>> [35030.333016] RSP: 0000:ffff8801b4c3ba90  EFLAGS: 00010282
>> [35030.333016] RAX: 0000000000000000 RBX: ffff8801b3e2a100 RCX: 0000000000000000
>> [35030.333016] RDX: 0000000000000000 RSI: 0000000000000000 RDI: deb604d497705c5d
>> [35030.333016] RBP: ffff8801b4c3bab8 R08: ffffea0002c34460 R09: ffff8801b3d7e8a0
>> [35030.333016] R10: 0000000000000004 R11: fff00000fe000000 R12: ffff8801b3e2a101
>> [35030.333016] R13: ffffea0002c34440 R14: deb604d497705c5d R15: ffffea0002c34440
>> [35030.333016] FS:  0000000000000000(0000) GS:ffff8801bed80000(0000) knlGS:0000000000000000
>> [35030.333016] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>> [35030.333016] CR2: 000000c422011080 CR3: 0000000001976000 CR4: 00000000001407e0
>> [35030.333016] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
>> [35030.333016] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
>> [35030.333016] Stack:
>> [35030.333016]  ffffffff811b2795 ffffea0002c34440 0000000000000000 000000000000000f
>> [35030.333016]  0000000000000001 ffff8801b4c3bb30 ffffffff811b2a17 ffff8800a712d640
>> [35030.333016]  000000000c4229e2 ffff8801b4c3bb80 0000000100000000 000000000c41fe38
>> [35030.333016] Call Trace:
>> [35030.333016]  [<ffffffff811b2795>] ? page_lock_anon_vma_read+0x55/0x110
>> [35030.333016]  [<ffffffff811b2a17>] page_referenced+0x1c7/0x350
>> [35030.333016]  [<ffffffff8118d9b4>] shrink_active_list+0x1e4/0x400
>> [35030.333016]  [<ffffffff8118e08d>] shrink_lruvec+0x4bd/0x770
>> [35030.333016]  [<ffffffff8118e3b6>] shrink_zone+0x76/0x1a0
>> [35030.333016]  [<ffffffff8118f6cc>] balance_pgdat+0x49c/0x610
>> [35030.333016]  [<ffffffff8118f9b3>] kswapd+0x173/0x450
>> [35030.333016]  [<ffffffff810a8a00>] ? wake_up_atomic_t+0x30/0x30
>> [35030.333016]  [<ffffffff8118f840>] ? balance_pgdat+0x610/0x610
>> [35030.333016]  [<ffffffff810a79bf>] kthread+0xcf/0xe0
>> [35030.333016]  [<ffffffff810a78f0>] ? kthread_create_on_node+0x120/0x120
>> [35030.333016]  [<ffffffff81665bd8>] ret_from_fork+0x58/0x90
>> [35030.333016]  [<ffffffff810a78f0>] ? kthread_create_on_node+0x120/0x120
>> [35030.333016] Code: 00 ba ff ff ff ff 48 89 d8 f0 48 0f c1 10 79 05 e8 31 06 27 00 5b 5d c3 66 66 66 66 66 2e 0f 1f 84 00 00 00 00 00 0f 1f 44 00 00 <48> 8b 07 48 89 c2 48 83 c2 01 7e 07 f0 48 0f b1 17 75 f0 48 f7
>> [35030.333016] RIP  [<ffffffff810acac5>] down_read_trylock+0x5/0x50
>> [35030.333016]  RSP <ffff8801b4c3ba90>
>> [35030.333016] ------------[ cut here ]------------
>>
>> struct page {
>>   flags = 9007194960298056,
>>   mapping = 0xffff8801b3e2a101,
>>   {
>>     {
>>       index = 34324593617,
>>       freelist = 0x7fde7bbd1,
>>       pfmemalloc = 209,
>>       thp_mmu_gather = {
>>         counter = -35144751
>>       },
>>       pmd_huge_pte = 0x7fde7bbd1
>>     },
>>     {
>>       counters = 8589934592,
>>       {
>>         {
>>           _mapcount = {
>>             counter = 0
>>           },
>>           {
>>             inuse = 0,
>>             objects = 0,
>>             frozen = 0
>>           },
>>           units = 0
>>         },
>>         _count = {
>>           counter = 2
>>         }
>>       }
>>     }
>>   },
>>   {
>>     lru = {
>>       next = 0xdead000000100100,
>>       prev = 0xdead000000200200
>>     },
>>     {
>>       next = 0xdead000000100100,
>>       pages = 2097664,
>>       pobjects = -559087616
>>     },
>>     list = {
>>       next = 0xdead000000100100,
>>       prev = 0xdead000000200200
>>     },
>>     slab_page = 0xdead000000100100
>>   },
>>   {
>>     private = 0,
>>     ptl = {
>>       {
>>         rlock = {
>>           raw_lock = {
>>             {
>>               head_tail = 0,
>>               tickets = {
>>                 head = 0,
>>                 tail = 0
>>               }
>>             }
>>           }
>>         }
>>       }
>>     },
>>     slab_cache = 0x0,
>>     first_page = 0x0
>>   }
>> }
>>
>>
>>
>> crash> struct anon_vma 0xffff8801b3e2a100
>> struct anon_vma {
>>   root = 0xdeb604d497705c55,
>>   rwsem = {
>>     count = -8192007903225070328,
>>     wait_lock = {
>>       raw_lock = {
>>         {
>>           head_tail = 2955503940,
>>           tickets = {
>>             head = 26948,
>>             tail = 45097
>>           }
>>         }
>>       }
>>     },
>>     wait_list = {
>>       next = 0x559f9107c1b47439,
>>       prev = 0x3de13f709bfa043b
>>     }
>>   },
>>   refcount = {
>>     counter = -13243516
>>   },
>>   rb_root = {
>>     rb_node = 0x11dd18f9ce0bb2e9
>>   }
>> }
>>
>> This address 0xffff8801b3e2a100 can not find in "kmem -S anon_vma"
>>
>> The page flags is
>> crash> kmem -g 0x1FFFFF00080048
>> FLAGS: 1fffff00080048
>>   PAGE-FLAG        BIT  VALUE
>>   PG_uptodate        3  0000008
>>   PG_active          6  0000040
>>   PG_swapbacked     19  0080000
>>
>>
>> .
>>
> 
> 
> 
> 
> .
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
