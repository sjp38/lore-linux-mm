Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id A23C76B0292
	for <linux-mm@kvack.org>; Wed, 24 May 2017 04:19:00 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id f124so210638808oia.14
        for <linux-mm@kvack.org>; Wed, 24 May 2017 01:19:00 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [45.249.212.189])
        by mx.google.com with ESMTP id f191si10152699oib.36.2017.05.24.01.18.50
        for <linux-mm@kvack.org>;
        Wed, 24 May 2017 01:18:59 -0700 (PDT)
Message-ID: <59253E84.6010506@huawei.com>
Date: Wed, 24 May 2017 16:04:20 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: mm, we use rcu access task_struct in mm_match_cgroup(), but not
 use rcu free in free_task_struct()
References: <5924E4A7.7000601@huawei.com> <59250EA3.60905@huawei.com> <263518b9-5a39-1af9-ac9e-055da3384aef@suse.cz>
In-Reply-To: <263518b9-5a39-1af9-ac9e-055da3384aef@suse.cz>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, "wencongyang (A)" <wencongyang2@huawei.com>, Johannes
 Weiner <hannes@cmpxchg.org>, Dmitry Vyukov <dvyukov@google.com>, zhong jiang <zhongjiang@huawei.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2017/5/24 15:49, Vlastimil Babka wrote:

> On 05/24/2017 06:40 AM, Xishi Qiu wrote:
>> On 2017/5/24 9:40, Xishi Qiu wrote:
>>
>>> Hi, I find we use rcu access task_struct in mm_match_cgroup(), but not use
>>> rcu free in free_task_struct(), is it right?
>>>
>>> Here is the backtrace.
> 
> Can you post the whole oops, including kernel version etc? Is it the
> same 3.10 RH kernel as in the other report?
> 

Hi Vlastimil,

Yes, it's RHEL 7.2

[  663.687410] Modules linked in: dm_service_time dm_multipath iscsi_tcp libiscsi_tcp libiscsi scsi_transport_iscsi ocfs2_lockfs(OE) ocfs2(OE) ocfs2_adl(OE) jbd2 ocfs2_stack_o2cb(OE) ocfs2_dlm(OE) ocfs2_nodemanager(OE) ocfs2_stackglue(OE) kboxdriver(O) kbox(O) 8021q garp stp mrp llc dev_connlimit(O) vhba(OE) signo_catch(O) hotpatch(OE) bum(O) ip_set nfnetlink prio(O) nat(O) vport_vxlan(O) openvswitch(O) nf_defrag_ipv6 gre ipmi_devintf pmcint(O) ipmi_si ipmi_msghandler coretemp iTCO_wdt kvm_intel(O) iTCO_vendor_support intel_rapl kvm(O) crc32_pclmul crc32c_intel ghash_clmulni_intel aesni_intel lrw gf128mul glue_helper mei_me ablk_helper cryptd i2c_i801 be2net mei lpc_ich i2c_core vxlan sb_edac pcspkr mfd_core edac_core sg ip6_udp_tunnel udp_tunnel shpchp acpi_power_meter remote_trigger(O) nf_conntrack_ipv4
[  663.759402]  nf_defrag_ipv4 vhost_net(O) tun(O) vhost(O) macvtap macvlan vfio_pci irqbypass vfio_iommu_type1 vfio xt_sctp nf_conntrack_proto_sctp nf_nat_proto_sctp nf_nat nf_conntrack sctp libcrc32c ip_tables ext3 mbcache jbd dm_mod sd_mod lpfc crc_t10dif ahci crct10dif_generic libahci crct10dif_pclmul mpt2sas scsi_transport_fc libata raid_class scsi_tgt crct10dif_common scsi_transport_sas nbd(OE) [last unloaded: kbox]
[  663.796117] CPU: 2 PID: 2133 Comm: CPU 15/KVM Tainted: G           OE  ---- -------   3.10.0-327.49.58.52_13.x86_64 #1
[  663.807080] Hardware name: Huawei CH121 V3/IT11SGCA1, BIOS 1.51 06/11/2015
[  663.814107] task: ffff881fe3353300 ti: ffff881fe2768000 task.ti: ffff881fe2768000
[  663.821854] RIP: 0010:[<ffffffff811db536>]  [<ffffffff811db536>] mem_cgroup_from_task+0x16/0x20
[  663.830895] RSP: 0000:ffff881fe276b810  EFLAGS: 00010286
[  663.836333] RAX: 6b6b6b6b6b6b6b6b RBX: ffffea007f988880 RCX: 0000000000020000
[  663.843621] RDX: 00000007fa607d67 RSI: 00000007fa607d67 RDI: ffff880fe36d72c0
[  663.850878] RBP: ffff881fe276b880 R08: 00000007fa607600 R09: a801fd67b3000000
[  663.858164] R10: 57fdec98cc59ecc0 R11: ffff880fe2e8dbd0 R12: ffffc9001cb74000
[  663.865420] R13: ffff881fdb8cfda0 R14: ffff881fe2581570 R15: 00000007fa607d67
[  663.872696] FS:  00007fdaaba6d700(0000) GS:ffff88103fc80000(0000) knlGS:0000000000000000
[  663.881092] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  663.886996] CR2: 00007fdaba65cf88 CR3: 0000000fe4919000 CR4: 00000000001427e0
[  663.894252] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  663.901533] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[  663.908788] Stack:
[  663.910966]  ffffffff811a6b8a ffff881fd828d980 00000007fa607d67 ffff881fe276b950
[  663.918753]  0000000000000000 00000007fa607600 00007fa607600000 000000017f59ece0
[  663.926541]  00000000675ac78b ffff881fe276bc70 ffffea007f9888a0 ffff881fe276ba40
[  663.934324]  ffffea007f988880 0000000000000001 ffff881fe276b9b8 ffffffff81180994
[  663.942113]  ffff881fe3353300 ffff881fe3353300 ffff881fe3353300 0000000000000000
[  663.949903]  ffff881fe276ba38 ffff881fe276ba30 ffff881fe276ba20 ffff881fe276ba28
[  663.957691]  ffff881fe276ba18 0000000000000000 ffff88207efd6000 0000000000000000
[  663.965468]  ffff881fe3353300 0000000000000000 00ff881000000008 0000000000000000
[  663.973261]  0000000000000000 0000000000000000 0000000000000000 0000881fe5400410
[  663.980994]  ffffea007f59ece0 ffffea007f691ca0 ffff881fe276b940 ffff881fe276b940
[  663.988773]  0000000000000000 ffff881fe276b9b8 ffff881fe276bca0 ffff881fe276ba10
[  663.996563]  0000000000000001 ffff881fe276ba40 ffff881fe5400410 00000000675ac78b
[  664.004359]  ffff881fe276ba40 0000000000000000 ffff881fe276bc70 0000000000000020
[  664.012139]  ffff88207efd6000 ffff881fe276ba80 ffffffff8118166a ffff881fe276ba20
[  664.019926]  ffff881fe276ba30 ffff881fe276ba38 0000001700000000 0000000000000016
[  664.027718]  ffff88207efd6540 00000003ffffffe0 0000000000400410 ffff881fe5400410
[  664.035497]  0000000000000020 0000000000000000 0000000000000000 0000000000000000
[  664.043284]  0000000000000000 0000000000000000 ffffea007f625aa0 ffffea007f9888e0
[  664.051073]  00000000675ac78b 0000000000000000 0000000000000020 ffff881fe5400410
[  664.058870]  0000000000000020 0000000000000000 ffff881fe276bb80 ffffffff81182135
[  664.066629]  0000000000011628 ffff881fe276baa8 ffffffff00000003 ffff881fe276ba00
[  664.074419]  0000000000000020 0000000000000000 ffff881fe276bc70 00000000000002dd
[  664.082149]  0000000000000000 0000000000000000 0000000000000000 0000000000000000
[  664.089933]  000000000000045d 0000000000000000 0000000000000000 0000000000000001
[  664.097726] Call Trace:
[  664.100341]  [<ffffffff811a6b8a>] ? page_referenced+0x24a/0x350
[  664.106417]  [<ffffffff81180994>] shrink_page_list+0x4b4/0xad0
[  664.112412]  [<ffffffff8118166a>] shrink_inactive_list+0x1ea/0x560
[  664.118746]  [<ffffffff81182135>] shrink_lruvec+0x375/0x760
[  664.124448]  [<ffffffff81182596>] shrink_zone+0x76/0x1a0
[  664.129911]  [<ffffffff81182a90>] do_try_to_free_pages+0xe0/0x3f0
[  664.136161]  [<ffffffff810b4be8>] ? finish_task_switch+0xd8/0x170
[  664.142410]  [<ffffffff81649957>] ? __schedule+0x2b7/0x790
[  664.148047]  [<ffffffff81182fea>] try_to_free_mem_cgroup_pages+0xca/0x160
[  664.154978]  [<ffffffff811dd8de>] mem_cgroup_reclaim+0x4e/0xe0
[  664.160961]  [<ffffffff811ddd9c>] __mem_cgroup_try_charge+0x42c/0x650
[  664.167526]  [<ffffffff811e1295>] ? swap_cgroup_record+0x55/0x80
[  664.173692]  [<ffffffff811df62b>] __mem_cgroup_try_charge_swapin+0x9b/0xd0
[  664.180719]  [<ffffffff8116bd5e>] ? __find_get_page+0x1e/0xa0
[  664.186620]  [<ffffffff811e0537>] mem_cgroup_try_charge_swapin+0x57/0x70
[  664.193477]  [<ffffffff8119abdd>] handle_mm_fault+0x82d/0xf50
[  664.199381]  [<ffffffff816502d6>] __do_page_fault+0x166/0x470
[  664.205289]  [<ffffffff81650603>] do_page_fault+0x23/0x80
[  664.210813]  [<ffffffff811fdc3b>] ? SyS_ioctl+0x8b/0xc0
[  664.216196]  [<ffffffff8164c808>] page_fault+0x28/0x30
[  664.221483] Code: 00 00 00 00 00 0f 1f 44 00 00 55 48 8b 47 70 48 89 e5 5d c3 90 0f 1f 44 00 00 55 48 85 ff 48 89 e5 74 0d 48 8b 87 40 09 00 00 5d <48> 8b 40 50 c3 31 c0 5d c3 90 0f 1f 44 00 00 55 48 85 ff 48 89 
[  664.242054] RIP  [<ffffffff811db536>] mem_cgroup_from_task+0x16/0x20
[  664.248581]  RSP <ffff881fe276b810>
[  664.252746] ---[ end trace dac00ad920bb710a ]---


> 
> .
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
