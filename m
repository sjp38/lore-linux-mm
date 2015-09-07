Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 66DC46B025A
	for <linux-mm@kvack.org>; Mon,  7 Sep 2015 07:40:56 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so81194614wic.1
        for <linux-mm@kvack.org>; Mon, 07 Sep 2015 04:40:56 -0700 (PDT)
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com. [209.85.212.175])
        by mx.google.com with ESMTPS id jw6si20257662wjb.51.2015.09.07.04.40.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Sep 2015 04:40:54 -0700 (PDT)
Received: by wicge5 with SMTP id ge5so80896962wic.0
        for <linux-mm@kvack.org>; Mon, 07 Sep 2015 04:40:54 -0700 (PDT)
Received: from localhost.localdomain ([82.118.240.130])
        by smtp.gmail.com with ESMTPSA id gt4sm19897769wib.21.2015.09.07.04.40.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Sep 2015 04:40:53 -0700 (PDT)
Subject: Fwd: Re: Kernel 4.1.6 Panic due to slab corruption
References: <55ED7186.7060503@kyup.com>
From: Nikolay Borisov <kernel@kyup.com>
Message-ID: <55ED77C2.8080407@kyup.com>
Date: Mon, 7 Sep 2015 14:40:50 +0300
MIME-Version: 1.0
In-Reply-To: <55ED7186.7060503@kyup.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

[Sending to linux-mm as it is related to the memory subsystem]


-------- Forwarded Message --------
Subject: Re: Kernel 4.1.6 Panic due to slab corruption
Date: Mon, 7 Sep 2015 14:14:14 +0300
From: Nikolay Borisov <kernel@kyup.com>
To: Linux-Kernel@Vger. Kernel. Org <linux-kernel@vger.kernel.org>
CC: Marian Marinov <mm@1h.com>, SiteGround Operations
<operations@siteground.com>, cl@linux.com

Did a bit more investigation and it turns out the
corruption is happening in slab_alloc_node, in the
'else' branch when get_freepointer is being called:

0xffffffff81182a50 <+144>:	movsxd rax,DWORD PTR [r12+0x20]
0xffffffff81182a55 <+149>:	mov    rdi,QWORD PTR [r12]
0xffffffff81182a59 <+153>:	mov    rbx,QWORD PTR [r13+rax*1+0x0]

The problematic line is the +153 offset, running addr2line shows that,
this is get_freepointer:

addr2line -f -e vmlinux-4.1.6-clouder1 ffffffff81182a59
get_freepointer
/home/projects/linux-stable/mm/slub.c:247

In this case the values of the arguments of this function are completely
bogus (or so it seems):

1. RAX is shown to be 0 and rax is supposed to hold the pointer to
struct kmem_cache. But curiously there isn't an error for NULL ptr,
as well as the check for the return value of slab_pre_alloc_hook would
have terminated the function early.

2. The value of r13 (which holds the pointer to the first free object
from the freelist) is also bogus: 0000000000028001

I'm a bit puzzled as to why am I not getting a NULL ptr error. But in
any case it looks that the per-cpu slub cache freelist has been corrupted.

Doing addr2line on the other paging request failures also show that the
issue is in the same function - get_freepointer:

addr2line -f -e vmlinux-4.1.6-clouder1 ffffffff811824e5
get_freepointer
/home/projects/linux-stable/mm/slub.c:247

Regards,
Nikolay

On 09/07/2015 11:41 AM, Nikolay Borisov wrote:
> Hello, 
> 
> On one of our servers I've observed the a kernel pannic 
> happening with the following backtrace:
> 
> [654405.527070] BUG: unable to handle kernel paging request at 0000000000028001
> [654405.527076] IP: [<ffffffff81182a59>] kmem_cache_alloc_node+0x99/0x1e0
> [654405.527085] PGD 14bef58067 PUD 2ab358067 PMD 0 
> [654405.527089] Oops: 0000 [#11] SMP 
> [654405.527093] Modules linked in: xt_multiport tcp_diag inet_diag act_police cls_basic sch_ingress scsi_transport_iscsi ipt_REJECT nf_reject_ipv4 xt_pkttype xt_state veth openvswitch xt_owner xt_conntrack iptable_filter iptable_mangle xt_nat iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat xt_CT nf_conntrack iptable_raw ip_tables ib_ipoib rdma_ucm ib_ucm ib_uverbs ib_umad rdma_cm ib_cm iw_cm ib_sa ib_mad ib_core ib_addr ipv6 ext2 dm_thin_pool dm_bio_prison dm_persistent_data dm_bufio libcrc32c dm_mirror dm_region_hash dm_log iTCO_wdt iTCO_vendor_support sb_edac edac_core i2c_i801 lpc_ich mfd_core igb i2c_algo_bit i2c_core ioatdma dca ipmi_devintf ipmi_si ipmi_msghandler mpt2sas scsi_transport_sas raid_class
> [654405.527145] CPU: 14 PID: 32267 Comm: httpd Tainted: G      D      L  4.1.6-clouder1 #1
> [654405.527147] Hardware name: Supermicro X9DRD-7LN4F(-JBOD)/X9DRD-EF/X9DRD-7LN4F, BIOS 3.0  07/09/2013
> [654405.527149] task: ffff88139d3b1ec0 ti: ffff8808eda14000 task.ti: ffff8808eda14000
> [654405.527151] RIP: 0010:[<ffffffff81182a59>]  [<ffffffff81182a59>] kmem_cache_alloc_node+0x99/0x1e0
> [654405.527155] RSP: 0018:ffff88407fcc3a98  EFLAGS: 00210246
> [654405.527156] RAX: 0000000000000000 RBX: 0000000000000000 RCX: ffff8814ce9acf80
> [654405.527157] RDX: 00000000837ad864 RSI: 0000000000050200 RDI: 0000000000018ce0
> [654405.527158] RBP: ffff88407fcc3af8 R08: ffff88407fcd8ce0 R09: ffffffffa033d990
> [654405.527159] R10: ffff88058676fdd8 R11: 0000000000007b4a R12: ffff881fff807ac0
> [654405.527161] R13: 0000000000028001 R14: 0000000000000001 R15: ffff881fff807ac0
> [654405.527162] FS:  0000000000000000(0000) GS:ffff88407fcc0000(0063) knlGS:0000000055c832e0
> [654405.527164] CS:  0010 DS: 002b ES: 002b CR0: 0000000080050033
> [654405.527165] CR2: 0000000000028001 CR3: 0000001467b64000 CR4: 00000000000406e0
> [654405.527166] Stack:
> [654405.527167]  0000000000000000 0000000000000000 0000000000000000 ffff881ff2d05000
> [654405.527170]  ffff88407fcc3ae8 00050200812b5903 ffff88407fcc3ae8 00000000000001a2
> [654405.527172]  0000000000000001 ffff88058676fc60 ffff88058676fe80 0000000000001800
> [654405.527175] Call Trace:
> [654405.527177]  <IRQ> 
> [654405.527184]  [<ffffffffa033d990>] ovs_flow_stats_update+0x110/0x160 [openvswitch]
> [654405.527189]  [<ffffffffa033ae74>] ovs_dp_process_packet+0x64/0xf0 [openvswitch]
> [654405.527193]  [<ffffffffa0345c60>] ? netdev_port_receive+0x110/0x110 [openvswitch]
> [654405.527197]  [<ffffffffa0345c60>] ? netdev_port_receive+0x110/0x110 [openvswitch]
> [654405.527201]  [<ffffffffa0344815>] ovs_vport_receive+0x85/0xb0 [openvswitch]
> [654405.527207]  [<ffffffff812c7636>] ? blk_mq_free_hctx_request+0x36/0x40
> [654405.527209]  [<ffffffff812c7671>] ? blk_mq_free_request+0x31/0x40
> [654405.527214]  [<ffffffff8100c2f9>] ? read_tsc+0x9/0x10
> [654405.527220]  [<ffffffff810b9f04>] ? ktime_get+0x54/0xc0
> [654405.527225]  [<ffffffff813cf577>] ? put_device+0x17/0x20
> [654405.527227]  [<ffffffffa0048a50>] ? tcf_act_police+0x150/0x210 [act_police]
> [654405.527232]  [<ffffffff8150cdc1>] ? tcf_action_exec+0x51/0xa0
> [654405.527235]  [<ffffffffa0011445>] ? basic_classify+0x75/0xe0 [cls_basic]
> [654405.527237]  [<ffffffff815091d5>] ? tc_classify+0x55/0xc0
> [654405.527241]  [<ffffffffa0345bed>] netdev_port_receive+0x9d/0x110 [openvswitch]
> [654405.527245]  [<ffffffffa0345c94>] netdev_frame_hook+0x34/0x50 [openvswitch]
> [654405.527250]  [<ffffffff814e58e6>] __netif_receive_skb_core+0x206/0x880
> [654405.527252]  [<ffffffff814e5f87>] __netif_receive_skb+0x27/0x70
> [654405.527254]  [<ffffffff814e60c1>] process_backlog+0xf1/0x1b0
> [654405.527257]  [<ffffffff814e68d3>] napi_poll+0xd3/0x1c0
> [654405.527259]  [<ffffffff814e6a50>] net_rx_action+0x90/0x1c0
> [654405.527264]  [<ffffffff810595ab>] __do_softirq+0xfb/0x2a0
> [654405.527270]  [<ffffffff815b269c>] do_softirq_own_stack+0x1c/0x30
> [654405.527271]  <EOI> 
> [654405.527273]  [<ffffffff810590b5>] do_softirq+0x55/0x60
> [654405.527276]  [<ffffffff81059198>] __local_bh_enable_ip+0x88/0x90
> [654405.527279]  [<ffffffff8152b062>] ip_finish_output+0x282/0x490
> [654405.527281]  [<ffffffff8152b55b>] ip_output+0xab/0xc0
> [654405.527283]  [<ffffffff8152ade0>] ? ip_finish_output_gso+0x4e0/0x4e0
> [654405.527285]  [<ffffffff815296fb>] ip_local_out_sk+0x3b/0x50
> [654405.527287]  [<ffffffff81529e0e>] ip_queue_xmit+0x14e/0x3c0
> [654405.527291]  [<ffffffff815422d2>] tcp_transmit_skb+0x4c2/0x850
> [654405.527294]  [<ffffffff81544c1d>] tcp_write_xmit+0x19d/0x670
> [654405.527298]  [<ffffffff812f32d1>] ? copy_user_generic_string+0x31/0x40
> [654405.527300]  [<ffffffff81545cd2>] __tcp_push_pending_frames+0x32/0xd0
> [654405.527302]  [<ffffffff81532911>] tcp_push+0xf1/0x120
> [654405.527304]  [<ffffffff815361f3>] tcp_sendmsg+0x373/0xb60
> [654405.527307]  [<ffffffff811be0b3>] ? mntput+0x23/0x40
> [654405.527310]  [<ffffffff811a7c32>] ? path_put+0x22/0x30
> [654405.527315]  [<ffffffff81561272>] inet_sendmsg+0x42/0xb0
> [654405.527317]  [<ffffffff81182e4e>] ? kmem_cache_alloc+0xee/0x1c0
> [654405.527321]  [<ffffffff814c639d>] sock_sendmsg+0x4d/0x60
> [654405.527324]  [<ffffffff814c64a6>] sock_write_iter+0xb6/0x100
> [654405.527328]  [<ffffffff8119d9d0>] do_iter_readv_writev+0x60/0x90
> [654405.527330]  [<ffffffff814c63f0>] ? kernel_sendmsg+0x40/0x40
> [654405.527332]  [<ffffffff8119e354>] compat_do_readv_writev+0x174/0x1f0
> [654405.527337]  [<ffffffff810aa6d9>] ? rcu_eqs_exit+0x79/0xb0
> [654405.527339]  [<ffffffff810aa723>] ? rcu_user_exit+0x13/0x20
> [654405.527342]  [<ffffffff8119e591>] compat_SyS_writev+0xc1/0x110
> [654405.527346]  [<ffffffff811274a3>] ? context_tracking_user_enter+0x13/0x20
> [654405.527349]  [<ffffffff815b2fc5>] sysenter_dispatch+0x7/0x25
> [654405.527350] Code: 8b 00 48 c1 e8 38 41 39 c6 74 17 4c 89 c9 44 89 f2 8b 75 cc 4c 89 e7 e8 46 f6 ff ff 49 89 c5 eb 2b 90 49 63 44 24 20 49 8b 3c 24 <49> 8b 5c 05 00 48 8d 4a 01 4c 89 e8 65 48 0f c7 0f 0f 94 c0 3c 
> [654405.527378] RIP  [<ffffffff81182a59>] kmem_cache_alloc_node+0x99/0x1e0
> [654405.527381]  RSP <ffff88407fcc3a98>
> [654405.527383] CR2: 0000000000028001
> 
> Before this occurs there are also several more "can't handle paging requests" e.g:
> 
> [654405.518482] BUG: unable to handle kernel paging request at 0000000000028001
> [654405.518488] IP: [<ffffffff811824e5>] kmem_cache_alloc_trace+0x75/0x1d0
> [654405.518496] PGD 364da24067 PUD 3733ae2067 PMD 0 
> [654405.518501] Oops: 0000 [#10] SMP 
> [654405.518504] Modules linked in: xt_multiport tcp_diag inet_diag act_police cls_basic sch_ingress scsi_transport_iscsi ipt_REJECT nf_reject_ipv4 xt_pkttype xt_state veth openvswitch xt_owner xt_conntrack iptable_filter iptable_mangle xt_nat iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat xt_CT nf_conntrack iptable_raw ip_tables ib_ipoib rdma_ucm ib_ucm ib_uverbs ib_umad rdma_cm ib_cm iw_cm ib_sa ib_mad ib_core ib_addr ipv6 ext2 dm_thin_pool dm_bio_prison dm_persistent_data dm_bufio libcrc32c dm_mirror dm_region_hash dm_log iTCO_wdt iTCO_vendor_support sb_edac edac_core i2c_i801 lpc_ich mfd_core igb i2c_algo_bit i2c_core ioatdma dca ipmi_devintf ipmi_si ipmi_msghandler mpt2sas scsi_transport_sas raid_class
> [654405.518555] CPU: 14 PID: 15732 Comm: guardian Tainted: G      D      L  4.1.6-clouder1 #1
> [654405.518557] Hardware name: Supermicro X9DRD-7LN4F(-JBOD)/X9DRD-EF/X9DRD-7LN4F, BIOS 3.0  07/09/2013
> [654405.518559] task: ffff88373303e680 ti: ffff88369b388000 task.ti: ffff88369b388000
> [654405.518560] RIP: 0010:[<ffffffff811824e5>]  [<ffffffff811824e5>] kmem_cache_alloc_trace+0x75/0x1d0
> [654405.518564] RSP: 0018:ffff88369b38bb48  EFLAGS: 00010282
> [654405.518565] RAX: 0000000000000000 RBX: 0000000000000000 RCX: 0000000000000001
> [654405.518567] RDX: 00000000837ad864 RSI: 00000000000000d0 RDI: 0000000000018ce0
> [654405.518568] RBP: ffff88369b38bb88 R08: ffff88407fcd8ce0 R09: ffffffff811c272c
> [654405.518569] R10: ffff88369b38bb74 R11: ffff881f7c678db8 R12: ffff881fff807ac0
> [654405.518570] R13: 0000000000028001 R14: ffff881fff807ac0 R15: 00000000000000d0
> [654405.518572] FS:  00002b784bf66800(0000) GS:ffff88407fcc0000(0000) knlGS:0000000000000000
> [654405.518574] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [654405.518575] CR2: 0000000000028001 CR3: 000000364d574000 CR4: 00000000000406e0
> [654405.518576] Stack:
> [654405.518578]  000000013a481c58 0000000000000020 ffff883600010000 ffff88245528ca00
> [654405.518580]  ffffffff8120bc50 ffff881a3d3433c8 ffff88245528ca10 ffffffff81209ed0
> [654405.518583]  ffff88369b38bbc8 ffffffff811c272c ffff88245528ca10 0000000000000000
> [654405.518586] Call Trace:
> [654405.518593]  [<ffffffff8120bc50>] ? proc_pid_follow_link+0x80/0x80
> [654405.518596]  [<ffffffff81209ed0>] ? sched_autogroup_open+0x50/0x50
> [654405.518601]  [<ffffffff811c272c>] single_open+0x3c/0xb0
> [654405.518603]  [<ffffffff81209eeb>] proc_single_open+0x1b/0x20
> [654405.518606]  [<ffffffff8119b69a>] do_dentry_open+0x22a/0x350
> [654405.518608]  [<ffffffff8119b809>] vfs_open+0x49/0x50
> [654405.518612]  [<ffffffff811ae652>] do_last+0x412/0x890
> [654405.518615]  [<ffffffff81182e4e>] ? kmem_cache_alloc+0xee/0x1c0
> [654405.518620]  [<ffffffff8129d6b6>] ? security_file_alloc+0x16/0x20
> [654405.518623]  [<ffffffff811aeb62>] path_openat+0x92/0x470
> [654405.518626]  [<ffffffff811ac753>] ? user_path_at_empty+0x63/0xa0
> [654405.518628]  [<ffffffff811aef8a>] do_filp_open+0x4a/0xa0
> [654405.518633]  [<ffffffff812fb140>] ? find_next_zero_bit+0x10/0x20
> [654405.518637]  [<ffffffff811bb64c>] ? __alloc_fd+0xac/0x150
> [654405.518640]  [<ffffffff8119ce9a>] do_sys_open+0x11a/0x230
> [654405.518644]  [<ffffffff8101190e>] ? syscall_trace_enter_phase1+0x14e/0x160
> [654405.518650]  [<ffffffff811274a3>] ? context_tracking_user_enter+0x13/0x20
> [654405.518652]  [<ffffffff8119cfee>] SyS_open+0x1e/0x20
> [654405.518656]  [<ffffffff815b0bee>] system_call_fastpath+0x12/0x71
> [654405.518658] Code: 08 65 4c 03 05 5d 7c e8 7e 4d 8b 28 49 8b 40 10 4d 85 ed 0f 84 8c 00 00 00 48 85 c0 0f 84 83 00 00 00 49 63 44 24 20 49 8b 3c 24 <49> 8b 5c 05 00 48 8d 4a 01 4c 89 e8 65 48 0f c7 0f 0f 94 c0 3c 
> [654405.518686] RIP  [<ffffffff811824e5>] kmem_cache_alloc_trace+0x75/0x1d0
> [654405.518689]  RSP <ffff88369b38bb48>
> [654405.518690] CR2: 0000000000028001
> 
> 
> [654405.511613] BUG: unable to handle kernel paging request at 0000000000028001
> [654405.511619] IP: [<ffffffff811824e5>] kmem_cache_alloc_trace+0x75/0x1d0
> [654405.511628] PGD 3f9a016067 PUD 3ee598c067 PMD 0 
> [654405.511632] Oops: 0000 [#9] SMP 
> [654405.511634] Modules linked in: xt_multiport tcp_diag inet_diag act_police cls_basic sch_ingress scsi_transport_iscsi ipt_REJECT nf_reject_ipv4 xt_pkttype xt_state veth openvswitch xt_owner xt_conntrack iptable_filter iptable_mangle xt_nat iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat xt_CT nf_conntrack iptable_raw ip_tables ib_ipoib rdma_ucm ib_ucm ib_uverbs ib_umad rdma_cm ib_cm iw_cm ib_sa ib_mad ib_core ib_addr ipv6 ext2 dm_thin_pool dm_bio_prison dm_persistent_data dm_bufio libcrc32c dm_mirror dm_region_hash dm_log iTCO_wdt iTCO_vendor_support sb_edac edac_core i2c_i801 lpc_ich mfd_core igb i2c_algo_bit i2c_core ioatdma dca ipmi_devintf ipmi_si ipmi_msghandler mpt2sas scsi_transport_sas raid_class
> [654405.511684] CPU: 14 PID: 14914 Comm: templar.pl Tainted: G      D      L  4.1.6-clouder1 #1
> [654405.511687] Hardware name: Supermicro X9DRD-7LN4F(-JBOD)/X9DRD-EF/X9DRD-7LN4F, BIOS 3.0  07/09/2013
> [654405.511689] task: ffff881f46d8bd80 ti: ffff883ee583c000 task.ti: ffff883ee583c000
> [654405.511690] RIP: 0010:[<ffffffff811824e5>]  [<ffffffff811824e5>] kmem_cache_alloc_trace+0x75/0x1d0
> [654405.511694] RSP: 0018:ffff883ee583fe38  EFLAGS: 00010282
> [654405.511695] RAX: 0000000000000000 RBX: 0000000000000000 RCX: ffff881f3e1f8540
> [654405.511697] RDX: 00000000837ad864 RSI: 00000000000080d0 RDI: 0000000000018ce0
> [654405.511698] RBP: ffff883ee583fe78 R08: ffff88407fcd8ce0 R09: ffffffff8129028f
> [654405.511699] R10: 0000000000000008 R11: 0000000000000246 R12: ffff881fff807ac0
> [654405.511701] R13: 0000000000028001 R14: ffff881fff807ac0 R15: 00000000000080d0
> [654405.511703] FS:  00002b06256163a0(0000) GS:ffff88407fcc0000(0000) knlGS:0000000000000000
> [654405.511704] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [654405.511706] CR2: 0000000000028001 CR3: 0000003f520c4000 CR4: 00000000000406e0
> [654405.511707] Stack:
> [654405.511708]  0000000100000404 0000000000000020 ffff883ee583fe78 0000000000000000
> [654405.511711]  0000000000001000 0000000000000001 0000000000018003 0000000000000001
> [654405.511715]  ffff883ee583ff28 ffffffff8129028f 0000000000000001 00000000000007d0
> [654405.511717] Call Trace:
> [654405.511726]  [<ffffffff8129028f>] do_shmat+0x22f/0x4a0
> [654405.511729]  [<ffffffff8129051c>] SyS_shmat+0x1c/0x30
> [654405.511734]  [<ffffffff815b0bee>] system_call_fastpath+0x12/0x71
> [654405.511736] Code: 08 65 4c 03 05 5d 7c e8 7e 4d 8b 28 49 8b 40 10 4d 85 ed 0f 84 8c 00 00 00 48 85 c0 0f 84 83 00 00 00 49 63 44 24 20 49 8b 3c 24 <49> 8b 5c 05 00 48 8d 4a 01 4c 89 e8 65 48 0f c7 0f 0f 94 c0 3c 
> [654405.511763] RIP  [<ffffffff811824e5>] kmem_cache_alloc_trace+0x75/0x1d0
> [654405.511765]  RSP <ffff883ee583fe38>
> [654405.511766] CR2: 0000000000028001
> 
> [654405.502947] BUG: unable to handle kernel paging request at 0000000000028001
> [654405.502952] IP: [<ffffffff811824e5>] kmem_cache_alloc_trace+0x75/0x1d0
> [654405.502961] PGD 1c7d1ba067 PUD 1d7c06d067 PMD 0 
> [654405.502965] Oops: 0000 [#8] SMP 
> [654405.502968] Modules linked in: xt_multiport tcp_diag inet_diag act_police cls_basic sch_ingress scsi_transport_iscsi ipt_REJECT nf_reject_ipv4 xt_pkttype xt_state veth openvswitch xt_owner xt_conntrack iptable_filter iptable_mangle xt_nat iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat xt_CT nf_conntrack iptable_raw ip_tables ib_ipoib rdma_ucm ib_ucm ib_uverbs ib_umad rdma_cm ib_cm iw_cm ib_sa ib_mad ib_core ib_addr ipv6 ext2 dm_thin_pool dm_bio_prison dm_persistent_data dm_bufio libcrc32c dm_mirror dm_region_hash dm_log iTCO_wdt iTCO_vendor_support sb_edac edac_core i2c_i801 lpc_ich mfd_core igb i2c_algo_bit i2c_core ioatdma dca ipmi_devintf ipmi_si ipmi_msghandler mpt2sas scsi_transport_sas raid_class
> [654405.503021] CPU: 14 PID: 1342 Comm: gather_daemon.p Tainted: G      D      L  4.1.6-clouder1 #1
> [654405.503024] Hardware name: Supermicro X9DRD-7LN4F(-JBOD)/X9DRD-EF/X9DRD-7LN4F, BIOS 3.0  07/09/2013
> [654405.503026] task: ffff883dc1e170c0 ti: ffff881df4f80000 task.ti: ffff881df4f80000
> [654405.503027] RIP: 0010:[<ffffffff811824e5>]  [<ffffffff811824e5>] kmem_cache_alloc_trace+0x75/0x1d0
> [654405.503031] RSP: 0018:ffff881df4f83a98  EFLAGS: 00010282
> [654405.503033] RAX: 0000000000000000 RBX: 0000000000000000 RCX: 0000000001884e6d
> [654405.503034] RDX: 00000000837ad864 RSI: 00000000000000d0 RDI: 0000000000018ce0
> [654405.503035] RBP: ffff881df4f83ad8 R08: ffff88407fcd8ce0 R09: ffffffff811c272c
> [654405.503037] R10: 0000000000000008 R11: 0000000000000001 R12: ffff881fff807ac0
> [654405.503038] R13: 0000000000028001 R14: ffff881fff807ac0 R15: 00000000000000d0
> [654405.503040] FS:  0000000000000000(0000) GS:ffff88407fcc0000(0063) knlGS:00000000558d2c00
> [654405.503041] CS:  0010 DS: 002b ES: 002b CR0: 0000000080050033
> [654405.503043] CR2: 0000000000028001 CR3: 0000001daa3cd000 CR4: 00000000000406e0
> [654405.503044] Stack:
> [654405.503046]  ffff883a856c0402 0000000000000020 ffff881df4f83af8 ffff8825209b0b00
> [654405.503049]  ffffffff81212960 0000000000000000 ffffffff81212960 0000000000000000
> [654405.503051]  ffff881df4f83b18 ffffffff811c272c ffffffff81212960 0000000000000000
> [654405.503054] Call Trace:
> [654405.503063]  [<ffffffff81212960>] ? get_iowait_time+0x70/0x70
> [654405.503066]  [<ffffffff81212960>] ? get_iowait_time+0x70/0x70
> [654405.503070]  [<ffffffff811c272c>] single_open+0x3c/0xb0
> [654405.503073]  [<ffffffff81212960>] ? get_iowait_time+0x70/0x70
> [654405.503075]  [<ffffffff81212960>] ? get_iowait_time+0x70/0x70
> [654405.503077]  [<ffffffff811c27f0>] single_open_size+0x50/0x90
> [654405.503080]  [<ffffffff811c1d20>] ? seq_release_private+0x60/0x60
> [654405.503082]  [<ffffffff8121286a>] stat_open+0x4a/0x60
> [654405.503085]  [<ffffffff81209574>] proc_reg_open+0x84/0x120
> [654405.503088]  [<ffffffff812094f0>] ? proc_entry_rundown+0xa0/0xa0
> [654405.503091]  [<ffffffff8119b69a>] do_dentry_open+0x22a/0x350
> [654405.503093]  [<ffffffff8119b809>] vfs_open+0x49/0x50
> [654405.503097]  [<ffffffff811ae652>] do_last+0x412/0x890
> [654405.503102]  [<ffffffff8100c299>] ? sched_clock+0x9/0x10
> [654405.503107]  [<ffffffff81084a7b>] ? sched_clock_cpu+0xab/0xc0
> [654405.503110]  [<ffffffff81182e4e>] ? kmem_cache_alloc+0xee/0x1c0
> [654405.503115]  [<ffffffff8129d6b6>] ? security_file_alloc+0x16/0x20
> [654405.503118]  [<ffffffff811aeb62>] path_openat+0x92/0x470
> [654405.503122]  [<ffffffff8108ff1f>] ? put_prev_task_fair+0x2f/0x50
> [654405.503126]  [<ffffffff810b2931>] ? lock_hrtimer_base+0x31/0x60
> [654405.503128]  [<ffffffff811aef8a>] do_filp_open+0x4a/0xa0
> [654405.503132]  [<ffffffff812fb140>] ? find_next_zero_bit+0x10/0x20
> [654405.503136]  [<ffffffff811bb64c>] ? __alloc_fd+0xac/0x150
> [654405.503140]  [<ffffffff8119ce9a>] do_sys_open+0x11a/0x230
> [654405.503145]  [<ffffffff810b9b2e>] ? getnstimeofday64+0xe/0x30
> [654405.503150]  [<ffffffff811274a3>] ? context_tracking_user_enter+0x13/0x20
> [654405.503154]  [<ffffffff811ee4cb>] compat_SyS_open+0x1b/0x20
> [654405.503160]  [<ffffffff815b2fc5>] sysenter_dispatch+0x7/0x25
> [654405.503162] Code: 08 65 4c 03 05 5d 7c e8 7e 4d 8b 28 49 8b 40 10 4d 85 ed 0f 84 8c 00 00 00 48 85 c0 0f 84 83 00 00 00 49 63 44 24 20 49 8b 3c 24 <49> 8b 5c 05 00 48 8d 4a 01 4c 89 e8 65 48 0f c7 0f 0f 94 c0 3c 
> [654405.503191] RIP  [<ffffffff811824e5>] kmem_cache_alloc_trace+0x75/0x1d0
> [654405.503194]  RSP <ffff881df4f83a98>
> [654405.503195] CR2: 0000000000028001
> 
> 
> I have more but like these but I believe those are enough. The
> following things arise as a pattern in those failures: 
> 
> 1. All these failures are happening when allocating 32 bytes struct, 
> this leads me to believe that the corruption has happened in the 
> kmalloc-32 slab cache. 
> 
> 2. Another thing which also stands out is the faulting address: 
> The value 0000000000028001 can predominantly be seen. In the case
> when the panic has occured here is what the docded code shows:
> 
> Code: 8b 00 48 c1 e8 38 41 39 c6 74 17 4c 89 c9 44 89 f2 8b 75 cc 4c 89 e7 e8 46 f6 ff ff 49 89 c5 eb 2b 90 49 63 44 24 20 49 8b 3c 24 <49> 8b 5c 05 00 48 8d 4a 01 4c 89 e8 65 48 0f c7 0f 0f 94 c0 3c
> 
> Code starting with the faulting instruction
> ===========================================
>    0:	49 8b 5c 05 00       	mov    0x0(%r13,%rax,1),%rbx
>    5:	48 8d 4a 01          	lea    0x1(%rdx),%rcx
>    9:	4c 89 e8             	mov    %r13,%rax
>    c:	65 48 0f c7 0f       	cmpxchg16b %gs:(%rdi)
>   11:	0f 94 c0             	sete   %al
>   14:	3c                   	.byte 0x3c
> 
> r13 takes part in the calculation of the address rbx has to be stored, 
> r13 =  0000000000028001
> 
> Any ideas how to debug this? The first thing that comes to mind, is
> to boot the machine with slab merging disabled, in the hopes
> that this would reduce the scope of the memory corruption and 
> the next time this occurs it would be easier to identify the culprit.
> 
> Here are the config options for the allocator in use: 
> 
> grep -i slub kernel-conf-4.1
> # CONFIG_SLUB_DEBUG is not set
> CONFIG_SLUB=y
> CONFIG_SLUB_CPU_PARTIAL=y
> # CONFIG_SLUB_STATS is not set
> 
> If more information is needed I'm happy to provide it. 
> 
> Any help will be much appreciated.
> 
> Regards, 
> Nikolay
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 
--
To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
Please read the FAQ at  http://www.tux.org/lkml/


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
