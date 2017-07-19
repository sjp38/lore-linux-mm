Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6883D6B0279
	for <linux-mm@kvack.org>; Wed, 19 Jul 2017 06:09:10 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id o132so10395172lfe.7
        for <linux-mm@kvack.org>; Wed, 19 Jul 2017 03:09:10 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [45.249.212.187])
        by mx.google.com with ESMTPS id r16si2293595lff.418.2017.07.19.03.09.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 19 Jul 2017 03:09:08 -0700 (PDT)
Message-ID: <596F2D65.8020902@huawei.com>
Date: Wed, 19 Jul 2017 17:59:01 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: mm, something wrong in page_lock_anon_vma_read()?
References: <591D6D79.7030704@huawei.com> <591EB25C.9080901@huawei.com> <591EBE71.7080402@huawei.com> <alpine.LSU.2.11.1705191453040.3819@eggly.anvils> <591F9A09.6010707@huawei.com> <alpine.LSU.2.11.1705191852360.11060@eggly.anvils> <591FA78E.9050307@huawei.com> <alpine.LSU.2.11.1705191935220.11750@eggly.anvils> <591FB173.4020409@huawei.com> <a94c202d-7d9f-0a62-3049-9f825a1db50d@suse.cz> <5923FF31.5020801@huawei.com> <aea91199-2b40-85fd-8c93-2d807ed726bd@suse.cz> <593954BD.9060703@huawei.com> <e8dacd42-e5c5-998b-5f9a-a34dbfb986f1@suse.cz> <596DEA07.5000009@huawei.com> <24bd80c6-1bb7-c8b8-2acf-b91e5e10dbb1@suse.cz>
In-Reply-To: <24bd80c6-1bb7-c8b8-2acf-b91e5e10dbb1@suse.cz>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: "'Kirill A . Shutemov'" <kirill.shutemov@linux.intel.com>, zhong jiang <zhongjiang@huawei.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>, Minchan Kim <minchan@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, aarcange@redhat.com, sumeet.keswani@hpe.com, Rik van Riel <riel@redhat.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2017/7/19 16:40, Vlastimil Babka wrote:

> On 07/18/2017 12:59 PM, Xishi Qiu wrote:
>> Hi,
>>
>> Unfortunately, this patch(mm: thp: fix SMP race condition between
>> THP page fault and MADV_DONTNEED) didn't help, I got the panic again.
> 
> Too bad then. I don't know of any other patch from my own experience
> being directly related, try to look for similar THP-related race fixes.
> Did you already check whether disabling THP (set it to "never" under
> /sys/...) prevents the issue? I forgot.
> 

Hi Vlastimil,

Thanks for your reply.

This bug is hard to reproduce, and my production line don't allowed 
disable THP because performance regression. Also I have no condition to
reproduce this bug(I don't have the user apps or stress from production
line).

>> And I find this error before panic, "[468229.996610] BUG: Bad rss-counter state mm:ffff8806aebc2580 idx:1 val:1"
> 
> This likely means that a pte was overwritten to zero, and an anon page
> had no other reference than this pte, so it became orphaned. Its
> anon_vma object was freed as the process exited, and eventually
> overwritten by a new user, so compaction or reclaim looking at it sooner
> or later makes a bad memory access.
> 
> The pte overwriting may be a result of races with multiple threads
> trying to either read or write within the same page, involving THP zero
> page. It doesn't have to be MADV_DONTNEED related.
> 

I find two patches from upstream.
887843961c4b4681ee993c36d4997bf4b4aa8253
a9c8e4beeeb64c22b84c803747487857fe424b68

I can't find any relations to the panic from the first one, and the second
one seems triggered from xen, but we use kvm.

Thanks,
Xishi Qiu 

>> [468451.702807] BUG: unable to handle kernel NULL pointer dereference at 0000000000000008
>> [468451.702861] IP: [<ffffffff810ac089>] down_read_trylock+0x9/0x30
>> [468451.702900] PGD 12445e067 PUD 11acaa067 PMD 0 
>> [468451.702931] Oops: 0000 [#1] SMP 
>> [468451.702953] kbox catch die event.
>> [468451.703003] collected_len = 1047419, LOG_BUF_LEN_LOCAL = 1048576
>> [468451.703003] kbox: notify die begin
>> [468451.703003] kbox: no notify die func register. no need to notify
>> [468451.703003] do nothing after die!
>> [468451.703003] Modules linked in: ipt_REJECT macvlan ip_set_hash_ipport vport_vxlan(OVE) xt_statistic xt_physdev xt_nat xt_recent xt_mark xt_comment veth ct_limit(OVE) bum_extract(OVE) policy(OVE) bum(OVE) ip_set nfnetlink openvswitch(OVE) nf_defrag_ipv6 gre ext3 jbd ipt_MASQUERADE nf_nat_masquerade_ipv4 iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 xt_addrtype iptable_filter xt_conntrack nf_nat nf_conntrack bridge stp llc kboxdriver(O) kbox(O) dm_thin_pool dm_persistent_data crc32_pclmul dm_bio_prison dm_bufio ghash_clmulni_intel libcrc32c aesni_intel lrw gf128mul glue_helper ablk_helper cryptd ppdev sg parport_pc cirrus virtio_console parport syscopyarea sysfillrect sysimgblt ttm drm_kms_helper drm i2c_piix4 i2c_core pcspkr ip_tables ext4 jbd2 mbcache sr_mod cdrom ata_generic pata_acpi
>> [468451.703003]  virtio_net virtio_blk crct10dif_pclmul crct10dif_common ata_piix virtio_pci libata serio_raw virtio_ring crc32c_intel virtio dm_mirror dm_region_hash dm_log dm_mod
>> [468451.703003] CPU: 6 PID: 21965 Comm: docker-containe Tainted: G           OE  ----V-------   3.10.0-327.53.58.73.x86_64 #1
>> [468451.703003] Hardware name: OpenStack Foundation OpenStack Nova, BIOS rel-1.8.1-0-g4adadbd-20170107_142945-9_64_246_229 04/01/2014
>> [468451.703003] task: ffff880692402e00 ti: ffff88018209c000 task.ti: ffff88018209c000
>> [468451.703003] RIP: 0010:[<ffffffff810ac089>]  [<ffffffff810ac089>] down_read_trylock+0x9/0x30
>> [468451.703003] RSP: 0018:ffff88018209f8f8  EFLAGS: 00010202
>> [468451.703003] RAX: 0000000000000000 RBX: ffff880720cd7740 RCX: ffff880720cd7740
>> [468451.703003] RDX: 0000000000000001 RSI: 0000000000000301 RDI: 0000000000000008
>> [468451.703003] RBP: ffff88018209f8f8 R08: 00000000c0e0f310 R09: ffff880720cd7740
>> [468451.703003] R10: ffff88083efd8000 R11: 0000000000000000 R12: ffff880720cd7741
>> [468451.703003] R13: ffffea000824d100 R14: 0000000000000008 R15: 0000000000000000
>> [468451.703003] FS:  00007fc0e2a85700(0000) GS:ffff88083ed80000(0000) knlGS:0000000000000000
>> [468451.703003] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>> [468451.703003] CR2: 0000000000000008 CR3: 0000000661906000 CR4: 00000000001407e0
>> [468451.703003] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
>> [468451.703003] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
>> [468451.703003] Stack:
>> [468451.703003]  ffff88018209f928 ffffffff811a7eb5 ffffea000824d100 ffff88018209fa90
>> [468451.703003]  ffffea00082f9680 0000000000000301 ffff88018209f978 ffffffff811a82e1
>> [468451.703003]  ffffea000824d100 ffff88018209fa00 0000000000000001 ffffea000824d100
>> [468451.703003] Call Trace:
>> [468451.703003]  [<ffffffff811a7eb5>] page_lock_anon_vma_read+0x55/0x110
>> [468451.703003]  [<ffffffff811a82e1>] try_to_unmap_anon+0x21/0x120
>> [468451.703003]  [<ffffffff811a842d>] try_to_unmap+0x4d/0x60
>> [468451.712006]  [<ffffffff811cc749>] migrate_pages+0x439/0x790
>> [468451.712006]  [<ffffffff81193280>] ? __reset_isolation_suitable+0xe0/0xe0
>> [468451.712006]  [<ffffffff811941f9>] compact_zone+0x299/0x400
>> [468451.712006]  [<ffffffff81059aff>] ? kvm_clock_get_cycles+0x1f/0x30
>> [468451.712006]  [<ffffffff811943fc>] compact_zone_order+0x9c/0xf0
>> [468451.712006]  [<ffffffff811947b1>] try_to_compact_pages+0x121/0x1a0
>> [468451.712006]  [<ffffffff8163ace6>] __alloc_pages_direct_compact+0xac/0x196
>> [468451.712006]  [<ffffffff811783e2>] __alloc_pages_nodemask+0xbc2/0xca0
>> [468451.712006]  [<ffffffff811bcb7a>] alloc_pages_vma+0x9a/0x150
>> [468451.712006]  [<ffffffff811d1573>] do_huge_pmd_anonymous_page+0x123/0x510
>> [468451.712006]  [<ffffffff8119bc58>] handle_mm_fault+0x1a8/0xf50
>> [468451.712006]  [<ffffffff8164b4d6>] __do_page_fault+0x166/0x470
>> [468451.712006]  [<ffffffff8164b8a3>] trace_do_page_fault+0x43/0x110
>> [468451.712006]  [<ffffffff8164af79>] do_async_page_fault+0x29/0xe0
>> [468451.712006]  [<ffffffff81647a38>] async_page_fault+0x28/0x30
>> [468451.712006] Code: 00 00 00 ba 01 00 00 00 48 89 de e8 12 fe ff ff eb ce 48 c7 c0 f2 ff ff ff eb c5 e8 42 ff fc ff 66 90 0f 1f 44 00 00 55 48 89 e5 <48> 8b 07 48 89 c2 48 83 c2 01 7e 07 f0 48 0f b1 17 75 f0 48 f7 
>> [468451.712006] RIP  [<ffffffff810ac089>] down_read_trylock+0x9/0x30
>> [468451.738667]  RSP <ffff88018209f8f8>
>> [468451.738667] CR2: 0000000000000008
>>
>>
>>
> 
> 
> .
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
