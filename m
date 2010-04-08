Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 0787A600337
	for <linux-mm@kvack.org>; Thu,  8 Apr 2010 15:40:50 -0400 (EDT)
Message-ID: <4BBE30F6.30607@redhat.com>
Date: Thu, 08 Apr 2010 22:39:34 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [Bugme-new] [Bug 15709] New: swapper page allocation failure
References: <bug-15709-10286@https.bugzilla.kernel.org/> <20100408123438.1cadc5b6.akpm@linux-foundation.org>
In-Reply-To: <20100408123438.1cadc5b6.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, Rusty Russell <rusty@rustcorp.com.au>, kernel@tauceti.net, Mel Gorman <mel@csn.ul.ie>, "Michael S. Tsirkin" <mst@redhat.com>
List-ID: <linux-mm.kvack.org>

cc: mst

On 04/08/2010 10:34 PM, Andrew Morton wrote:
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
>
> On Wed, 7 Apr 2010 10:29:20 GMT
> bugzilla-daemon@bugzilla.kernel.org wrote:
>
>    
>> https://bugzilla.kernel.org/show_bug.cgi?id=15709
>>
>>             Summary: swapper page allocation failure
>>             Product: Memory Management
>>             Version: 2.5
>>      Kernel Version: 2.6.32 and 2.6.33
>>            Platform: All
>>          OS/Version: Linux
>>                Tree: Mainline
>>              Status: NEW
>>            Severity: normal
>>            Priority: P1
>>           Component: Slab Allocator
>>          AssignedTo: akpm@linux-foundation.org
>>          ReportedBy: kernel@tauceti.net
>>          Regression: No
>>
>>
>> Created an attachment (id=25903)
>>   -->  (https://bugzilla.kernel.org/attachment.cgi?id=25903)
>> dmesg output
>>
>> I'm having problems with "swapper page allocation failure's" since upgrading
>> from kernel 2.6.30 to 2.6.32/2.6.33. The problems occur inside a kernel virtual
>> maschine (KVM). Running Gentoo with kernel 2.6.32 as host which works fine. As
>> long as kernel 2.6.30 is used as guest kernel the guest runs fine. But after
>> upgrading to 2.6.32 and 2.6.33 I get "swapper page allocation failure's" (see
>> attachment of dmesg output). The guest is only running a Apache webserver and
>> serves files from a NFS share. It has 1 GB RAM and 2 virtual CPUs. I've tried
>> different kernel configurations (e.g. a unmodified version from Sabayon Linux
>> Distribution) but doesn't help. Load of the guest (and host) is very low.
>> Network traffic is about 20-50 MBit/s.
>>
>>      
> hm, this is a regression.
>
> : [  454.006706] users: page allocation failure. order:0, mode:0x20
> : [  454.006712] Pid: 7992, comm: users Not tainted 2.6.34-rc3-git6 #2
> : [  454.006714] Call Trace:
> : [  454.006717]<IRQ>   [<ffffffff8109dff7>] __alloc_pages_nodemask+0x5c8/0x615
> : [  454.006796]  [<ffffffff817860ce>] ? ip_local_deliver+0x65/0x6d
> : [  454.006820]  [<ffffffff810c39c4>] alloc_pages_current+0x96/0x9f
> : [  454.006842]  [<ffffffff8167f2c7>] try_fill_recv+0x5e/0x20f
> : [  454.006846]  [<ffffffff8167fe13>] virtnet_poll+0x52a/0x5c7
> : [  454.006858]  [<ffffffff8104fe74>] ? run_timer_softirq+0x1dc/0x1f4
> : [  454.006873]  [<ffffffff8176035d>] net_rx_action+0xad/0x1a5
> : [  454.006882]  [<ffffffff8104b6cd>] __do_softirq+0x9c/0x127
> : [  454.006897]  [<ffffffff81008ffc>] call_softirq+0x1c/0x30
> : [  454.006901]  [<ffffffff8100af01>] do_softirq+0x41/0x7e
> : [  454.006904]  [<ffffffff8104b3e3>] irq_exit+0x36/0x75
> : [  454.006907]  [<ffffffff8100a5ee>] do_IRQ+0xaa/0xc1
> : [  454.006926]  [<ffffffff8183bc13>] ret_from_intr+0x0/0x11
> : [  454.006928]<EOI>   [<ffffffff81026b25>] ? kvm_deferred_mmu_op+0x5e/0xe7
> : [  454.006942]  [<ffffffff81026b19>] ? kvm_deferred_mmu_op+0x52/0xe7
> : [  454.006946]  [<ffffffff81026c03>] kvm_mmu_write+0x2e/0x35
> : [  454.006949]  [<ffffffff81026c7d>] kvm_set_pte_at+0x19/0x1b
> : [  454.006953]  [<ffffffff810aba67>] __do_fault+0x3c4/0x492
> : [  454.006957]  [<ffffffff810adcf4>] handle_mm_fault+0x478/0x9d8
> : [  454.006966]  [<ffffffff810deb59>] ? path_put+0x2c/0x30
> : [  454.006975]  [<ffffffff8102f162>] do_page_fault+0x2f6/0x31a
> : [  454.006979]  [<ffffffff8183b81e>] ? _raw_spin_lock+0x9/0xd
> : [  454.006982]  [<ffffffff8183bef5>] page_fault+0x25/0x30
> : [  454.006985] Mem-Info:
> : [  454.006987] Node 0 DMA per-cpu:
> : [  454.006990] CPU    0: hi:    0, btch:   1 usd:   0
> : [  454.006992] CPU    1: hi:    0, btch:   1 usd:   0
> : [  454.006993] Node 0 DMA32 per-cpu:
> : [  454.006996] CPU    0: hi:  186, btch:  31 usd: 185
> : [  454.006998] CPU    1: hi:  186, btch:  31 usd: 112
> : [  454.007003] active_anon:8308 inactive_anon:8544 isolated_anon:0
> : [  454.007005]  active_file:4882 inactive_file:205902 isolated_file:0
> : [  454.007006]  unevictable:0 dirty:11 writeback:0 unstable:0
> : [  454.007007]  free:1385 slab_reclaimable:2445 slab_unreclaimable:4466
> : [  454.007008]  mapped:1895 shmem:113 pagetables:1370 bounce:0
> : [  454.007010] Node 0 DMA free:4000kB min:60kB low:72kB high:88kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:11844kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15768kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:64kB slab_unreclaimable:32kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
> : [  454.007021] lowmem_reserve[]: 0 994 994 994
> : [  454.007025] Node 0 DMA32 free:1540kB min:4000kB low:5000kB high:6000kB active_anon:33232kB inactive_anon:34176kB active_file:19528kB inactive_file:811764kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:1018068kB mlocked:0kB dirty:44kB writeback:0kB mapped:7580kB shmem:452kB slab_reclaimable:9716kB slab_unreclaimable:17832kB kernel_stack:1144kB pagetables:5480kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
> : [  454.007036] lowmem_reserve[]: 0 0 0 0
> : [  454.007040] Node 0 DMA: 0*4kB 4*8kB 6*16kB 5*32kB 6*64kB 4*128kB 1*256kB 1*512kB 0*1024kB 1*2048kB 0*4096kB = 4000kB
> : [  454.007050] Node 0 DMA32: 13*4kB 2*8kB 3*16kB 1*32kB 2*64kB 0*128kB 1*256kB 0*512kB 1*1024kB 0*2048kB 0*4096kB = 1556kB
> : [  454.007059] 210914 total pagecache pages
> : [  454.007061] 0 pages in swap cache
> : [  454.007063] Swap cache stats: add 0, delete 0, find 0/0
> : [  454.007065] Free swap  = 1959924kB
> : [  454.007067] Total swap = 1959924kB
> : [  454.014238] 262140 pages RAM
> : [  454.014241] 7489 pages reserved
> : [  454.014242] 21430 pages shared
> : [  454.014244] 247174 pages non-shared
>
> Either page reclaim got worse or kvm/virtio-net got more aggressive.
>
> Avi, Rusty: can you think of any changes in the KVM/virtio area in the
> 2.6.30 ->  2.6.32 timeframe which may have increased the GFP_ATOMIC
> demands upon the page allocator?
>
> Thanks.
>    


-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
