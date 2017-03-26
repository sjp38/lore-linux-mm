Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0CD056B0038
	for <linux-mm@kvack.org>; Sun, 26 Mar 2017 06:17:10 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id u1so16937371wra.5
        for <linux-mm@kvack.org>; Sun, 26 Mar 2017 03:17:09 -0700 (PDT)
Received: from mail-wr0-x244.google.com (mail-wr0-x244.google.com. [2a00:1450:400c:c0c::244])
        by mx.google.com with ESMTPS id t5si10493395wra.75.2017.03.26.03.17.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 26 Mar 2017 03:17:08 -0700 (PDT)
Received: by mail-wr0-x244.google.com with SMTP id w43so1524302wrb.1
        for <linux-mm@kvack.org>; Sun, 26 Mar 2017 03:17:08 -0700 (PDT)
Subject: Re: Page allocator order-0 optimizations merged
References: <58b48b1f.F/jo2/WiSxvvGm/z%akpm@linux-foundation.org>
 <20170301144845.783f8cad@redhat.com>
 <d4c1625e-cacf-52a9-bfcb-b32a185a2008@mellanox.com>
 <83a0e3ef-acfa-a2af-2770-b9a92bda41bb@mellanox.com>
 <20170322234004.kffsce4owewgpqnm@techsingularity.net>
 <20170323144347.1e6f29de@redhat.com>
 <20170323145133.twzt4f5ci26vdyut@techsingularity.net>
 <779ab72d-94b9-1a28-c192-377e91383b4e@gmail.com>
From: Tariq Toukan <ttoukan.linux@gmail.com>
Message-ID: <1fc7338f-2b36-75f7-8a7e-8321f062207b@gmail.com>
Date: Sun, 26 Mar 2017 13:17:05 +0300
MIME-Version: 1.0
In-Reply-To: <779ab72d-94b9-1a28-c192-377e91383b4e@gmail.com>
Content-Type: text/plain; charset=iso-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Tariq Toukan <tariqt@mellanox.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, akpm@linux-foundation.org, linux-mm <linux-mm@kvack.org>, Saeed Mahameed <saeedm@mellanox.com>



On 26/03/2017 11:21 AM, Tariq Toukan wrote:
>
>
> On 23/03/2017 4:51 PM, Mel Gorman wrote:
>> On Thu, Mar 23, 2017 at 02:43:47PM +0100, Jesper Dangaard Brouer wrote:
>>> On Wed, 22 Mar 2017 23:40:04 +0000
>>> Mel Gorman <mgorman@techsingularity.net> wrote:
>>>
>>>> On Wed, Mar 22, 2017 at 07:39:17PM +0200, Tariq Toukan wrote:
>>>>>>>> This modification may slow allocations from IRQ context slightly
>>>>>>>> but the
>>>>>>>> main gain from the per-cpu allocator is that it scales better for
>>>>>>>> allocations from multiple contexts.  There is an implicit
>>>>>>>> assumption that
>>>>>>>> intensive allocations from IRQ contexts on multiple CPUs from a
>>>>>>>> single
>>>>>>>> NUMA node are rare
>>>>> Hi Mel, Jesper, and all.
>>>>>
>>>>> This assumption contradicts regular multi-stream traffic that is
>>>>> naturally
>>>>> handled
>>>>> over close numa cores.  I compared iperf TCP multistream (8 streams)
>>>>> over CX4 (mlx5 driver) with kernels v4.10 (before this series) vs
>>>>> kernel v4.11-rc1 (with this series).
>>>>> I disabled the page-cache (recycle) mechanism to stress the page
>>>>> allocator,
>>>>> and see a drastic degradation in BW, from 47.5 G in v4.10 to 31.4 G in
>>>>> v4.11-rc1 (34% drop).
>>>>> I noticed queued_spin_lock_slowpath occupies 62.87% of CPU time.
>>>>
>>>> Can you get the stack trace for the spin lock slowpath to confirm it's
>>>> from IRQ context?
>>>
>>> AFAIK allocations happen in softirq.  Argh and during review I missed
>>> that in_interrupt() also covers softirq.  To Mel, can we use a in_irq()
>>> check instead?
>>>
>>> (p.s. just landed and got home)
>
> Glad to hear. Thanks for your suggestion.
>
>>
>> Not built or even boot tested. I'm unable to run tests at the moment
>
> Thanks Mel, I will test it soon.
>
Crashed in iperf single stream test:

[ 3974.123386] ------------[ cut here ]------------
[ 3974.128778] WARNING: CPU: 2 PID: 8754 at lib/list_debug.c:53 
__list_del_entry_valid+0xa3/0xd0
[ 3974.138751] list_del corruption. prev->next should be 
ffffea0040369c60, but was dead000000000100
[ 3974.149016] Modules linked in: netconsole nfsv3 nfs fscache dm_mirror 
dm_region_hash dm_log dm_mod sb_edac edac_core x86_pkg_temp_thermal 
coretemp i2c_diolan_u2c kvm irqbypass ipmi_si ipmi_devintf crc32_pclmul 
iTCO_wdt ghash_clmulni_intel ipmi_msghandler dcdbas iTCO_vendor_support 
sg pcspkr lpc_ich shpchp wmi mfd_core acpi_power_meter nfsd auth_rpcgss 
nfs_acl lockd grace sunrpc binfmt_misc ip_tables mlx4_en sr_mod cdrom 
sd_mod i2c_algo_bit drm_kms_helper syscopyarea sysfillrect sysimgblt 
fb_sys_fops mlx5_core ttm tg3 ahci libahci mlx4_core drm libata ptp 
megaraid_sas crc32c_intel i2c_core pps_core [last unloaded: netconsole]
[ 3974.212743] CPU: 2 PID: 8754 Comm: iperf Not tainted 4.11.0-rc2+ #30
[ 3974.220073] Hardware name: Dell Inc. PowerEdge R730/0H21J3, BIOS 
1.5.4 10/002/2015
[ 3974.228974] Call Trace:
[ 3974.231925]  <IRQ>
[ 3974.234405]  dump_stack+0x63/0x8c
[ 3974.238355]  __warn+0xd1/0xf0
[ 3974.241891]  warn_slowpath_fmt+0x4f/0x60
[ 3974.246494]  __list_del_entry_valid+0xa3/0xd0
[ 3974.251583]  get_page_from_freelist+0x84c/0xb40
[ 3974.256868]  ? napi_gro_receive+0x38/0x140
[ 3974.261666]  __alloc_pages_nodemask+0xca/0x200
[ 3974.266866]  mlx5e_alloc_rx_wqe+0x49/0x130 [mlx5_core]
[ 3974.272862]  mlx5e_post_rx_wqes+0x84/0xc0 [mlx5_core]
[ 3974.278725]  mlx5e_napi_poll+0xc7/0x450 [mlx5_core]
[ 3974.284409]  net_rx_action+0x23d/0x3a0
[ 3974.288819]  __do_softirq+0xd1/0x2a2
[ 3974.293054]  irq_exit+0xb5/0xc0
[ 3974.296783]  do_IRQ+0x51/0xd0
[ 3974.300353]  common_interrupt+0x89/0x89
[ 3974.304859] RIP: 0010:free_hot_cold_page+0x228/0x280
[ 3974.310629] RSP: 0018:ffffc9000ea07c90 EFLAGS: 00000202 ORIG_RAX: 
ffffffffffffffa8
[ 3974.319565] RAX: 0000000000000001 RBX: ffff88103f85f158 RCX: 
ffffea0040369c60
[ 3974.327764] RDX: ffffea0040369c60 RSI: ffff88103f85f168 RDI: 
ffffea0040369ca0
[ 3974.335961] RBP: ffffc9000ea07cc0 R08: ffff88103f85f168 R09: 
00000000000005a8
[ 3974.344178] R10: 00000000000005a8 R11: 0000000000010468 R12: 
ffffea0040369c80
[ 3974.352387] R13: ffff88103f85f168 R14: ffff88107ffdeb80 R15: 
ffffea0040369ca0
[ 3974.360577]  </IRQ>
[ 3974.363145]  __put_page+0x34/0x40
[ 3974.367068]  skb_release_data+0xca/0xe0
[ 3974.371575]  skb_release_all+0x24/0x30
[ 3974.375984]  __kfree_skb+0x12/0x20
[ 3974.380003]  tcp_recvmsg+0x6ac/0xaf0
[ 3974.384251]  inet_recvmsg+0x3c/0xa0
[ 3974.388394]  sock_recvmsg+0x3d/0x50
[ 3974.392511]  SYSC_recvfrom+0xd3/0x140
[ 3974.396826]  ? handle_mm_fault+0xce/0x240
[ 3974.401535]  ? SyS_futex+0x71/0x150
[ 3974.405653]  SyS_recvfrom+0xe/0x10
[ 3974.409673]  entry_SYSCALL_64_fastpath+0x1a/0xa9
[ 3974.415056] RIP: 0033:0x7f04ca9315bb
[ 3974.419309] RSP: 002b:00007f04c955de70 EFLAGS: 00000246 ORIG_RAX: 
000000000000002d
[ 3974.428243] RAX: ffffffffffffffda RBX: 0000000000020000 RCX: 
00007f04ca9315bb
[ 3974.436450] RDX: 0000000000020000 RSI: 00007f04bc0008f0 RDI: 
0000000000000004
[ 3974.444653] RBP: 0000000000000000 R08: 0000000000000000 R09: 
0000000000000000
[ 3974.452851] R10: 0000000000000000 R11: 0000000000000246 R12: 
00007f04bc0008f0
[ 3974.461051] R13: 0000000000034ac8 R14: 00007f04bc020910 R15: 
000000000001c480
[ 3974.469297] ---[ end trace 6fd472c9e1973d53 ]---


>>
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index 6cbde310abed..f82225725bc1 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -2481,7 +2481,7 @@ void free_hot_cold_page(struct page *page, bool
>> cold)
>>      unsigned long pfn = page_to_pfn(page);
>>      int migratetype;
>>
>> -    if (in_interrupt()) {
>> +    if (in_irq()) {
>>          __free_pages_ok(page, 0);
>>          return;
>>      }
>> @@ -2647,7 +2647,7 @@ static struct page *__rmqueue_pcplist(struct
>> zone *zone, int migratetype,
>>  {
>>      struct page *page;
>>
>> -    VM_BUG_ON(in_interrupt());
>> +    VM_BUG_ON(in_irq());
>>
>>      do {
>>          if (list_empty(list)) {
>> @@ -2704,7 +2704,7 @@ struct page *rmqueue(struct zone *preferred_zone,
>>      unsigned long flags;
>>      struct page *page;
>>
>> -    if (likely(order == 0) && !in_interrupt()) {
>> +    if (likely(order == 0) && !in_irq()) {
>>          page = rmqueue_pcplist(preferred_zone, zone, order,
>>                  gfp_flags, migratetype);
>>          goto out;
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
