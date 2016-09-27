Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 516D96B0273
	for <linux-mm@kvack.org>; Tue, 27 Sep 2016 14:33:13 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 21so44205546pfy.3
        for <linux-mm@kvack.org>; Tue, 27 Sep 2016 11:33:13 -0700 (PDT)
Received: from mail.windriver.com (mail.windriver.com. [147.11.1.11])
        by mx.google.com with ESMTPS id tb2si3744461pab.244.2016.09.27.11.33.11
        for <linux-mm@kvack.org>
        (version=TLS1_1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 27 Sep 2016 11:33:12 -0700 (PDT)
Received: from ALA-HCA.corp.ad.wrs.com (ala-hca.corp.ad.wrs.com [147.11.189.40])
	by mail.windriver.com (8.15.2/8.15.1) with ESMTPS id u8RIXBPR021631
	(version=TLSv1 cipher=AES128-SHA bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Tue, 27 Sep 2016 11:33:11 -0700 (PDT)
Message-ID: <57EABB64.7070607@windriver.com>
Date: Tue, 27 Sep 2016 12:33:08 -0600
From: Chris Friesen <chris.friesen@windriver.com>
MIME-Version: 1.0
Subject: Re: Oops in slab.c in CentOS kernel, looking for ideas -- correction,
 it's in slub.c
References: <57EA9A78.8080509@windriver.com>
In-Reply-To: <57EA9A78.8080509@windriver.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org


Sorry, I had a typo in my earlier message.  The issue is actually in slub.c.

Chris

On 09/27/2016 10:12 AM, Chris Friesen wrote:
>
> I've got a CentOS 7 kernel that has been slightly modified, but the mm
> subsystem hasn't been touched.  I'm hoping you can give me some guidance.
>
> I have an intermittent Oops that looks like what is below.  The issue
> is currently occurring on one CPU of one system, but has been seen
> before infrequently.  Once the corruption occurs it causes an Oops on
> every call to __mpol_dup() on this CPU.
>
> Basically it appears that __mpol_dup() is failing because the value of
> c->freelist in slab_alloc_node() is corrupt, causing the call to
> get_freepointer_safe(s, object) to Oops because it tries to dereference
> "object + s->offset".  (Where s->offset is zero.)
>
> In the trace, "kmem_cache_alloc+0x87" maps to the following assembly:
>     0xffffffff8118be17 <+135>:   mov    (%r12,%rax,1),%rbx
>
> This corresponds to this line in get_freepointer():
> 	return *(void **)(object + s->offset);
>
> In the assembly code, R12 is "object", and RAX is s->offset.
>
> So the question becomes, why is "object" (which corresponds to c->freelist)
> corrupt?
>
> Looking at the value of R12 (0x1ada8000), it's nonzero but also not a
> valid pointer. Does the value mean anything to you?  (I'm not really
> a memory subsystem guy, so I'm hoping you might have some ideas.)
>
> Do you have any suggestions on how to track down what's going on here?
>
> Thanks,
> Chris
>
> PS: Please CC me on replies, I'm not subscribed to the list.
>
>
>
>
> 2016-09-24T16:43:45.125 controller-1 kernel: alert [90390.702162] BUG: unable to handle kernel paging request at 000000001ada8000
> 2016-09-24T16:43:45.125 controller-1 kernel: alert [90390.709965] IP: [<ffffffff8118be17>] kmem_cache_alloc+0x87/0x250
> 2016-09-24T16:43:45.125 controller-1 kernel: warning [90390.716689] PGD 0
> 2016-09-24T16:43:45.125 controller-1 kernel: warning [90390.718945] Oops: 0000 [#43] PREEMPT SMP
> 2016-09-24T16:43:45.125 controller-1 kernel: warning [90390.723454] Modules linked in: target_core_pscsi target_core_file target_core_iblock iscsi_target_mod target_core_mod dm_thin_pool dm_persistent_data dm_bio_prison dm_bufio iptable_raw xt_CHECKSUM xt_connmark iptable_
> mangle nbd ebtable_filter ebtables igb_uio(OE) uio drbd(OE) libcrc32c nf_log_ipv6 nf_conntrack_ipv6 nf_defrag_ipv6 ip6table_filter ip6_tables virtio_net nf_log_ipv4 nf_log_common xt_LOG xt_limit xt_conntrack iptable_filter xt_nat xt_comment xt_multiport iptable_nat nf_conn
> track_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack veth nfsv3 nfs fscache 8021q garp stp mrp llc cls_u32 sch_sfq sch_htb dm_mod iTCO_wdt iTCO_vendor_support ipmi_devintf intel_powerclamp coretemp kvm_intel kvm crc32_pclmul ghash_clmulni_intel aesni_intel glue_helper
>   lrw gf128mul ablk_helper cryptd lpc_ich mfd_core mei_me mei i2c_i801 ipmi_si ipmi_msghandler acpi_power_meter wrs_avp(OE) nfsd auth_rpcgss nfs_acl lockd grace sunrpc ip_tables ext4 jbd2 sd_mod crc_t10dif crct10dif_generic crct10dif_pclmul crct10dif_common crc32c_intel ahc
> i libahci ixgbe mdio igb i2c_algo_bit i2c_core libata dca i40e(OE) vxlan ip6_udp_tunnel udp_tunnel ptp pps_core
> 2016-09-24T16:43:45.125 controller-1 kernel: warning [90390.836474] CPU: 48 PID: 42192 Comm: qemu-kvm Tainted: G      D    OE  ------------   3.10.0-327.28.3.6.tis.x86_64 #1
> 2016-09-24T16:43:45.125 controller-1 kernel: warning [90390.848328] Hardware name: Intel Corporation S2600WT2R/S2600WT2R, BIOS SE5C610.86B.01.01.0016.033120161139 03/31/2016
> 2016-09-24T16:43:45.125 controller-1 kernel: warning [90390.860181] task: ffff880463f75a90 ti: ffff8804120f0000 task.ti: ffff8804120f0000
> 2016-09-24T16:43:45.125 controller-1 kernel: warning [90390.868540] RIP: 0010:[<ffffffff8118be17>]  [<ffffffff8118be17>] kmem_cache_alloc+0x87/0x250
> 2016-09-24T16:43:45.125 controller-1 kernel: warning [90390.877980] RSP: 0018:ffff8804120f3d40  EFLAGS: 00010286
> 2016-09-24T16:43:45.125 controller-1 kernel: warning [90390.883913] RAX: 0000000000000000 RBX: 0000000000000000 RCX: 0000000000019230
> 2016-09-24T16:43:45.125 controller-1 kernel: warning [90390.891883] RDX: 0000000000019130 RSI: 00000000000000d0 RDI: ffff8804120f3fd8
> 2016-09-24T16:43:45.125 controller-1 kernel: warning [90390.899853] RBP: ffff8804120f3d88 R08: 0000000000018710 R09: ffffffff811832e8
> 2016-09-24T16:43:45.125 controller-1 kernel: warning [90390.907823] R10: 0000000000000000 R11: ffffffffffffff83 R12: 000000001ada8000
> 2016-09-24T16:43:45.125 controller-1 kernel: warning [90390.915794] R13: 00000000000000d0 R14: ffff88103ec06200 R15: ffff88103ec06200
> 2016-09-24T16:43:45.125 controller-1 kernel: warning [90390.923765] FS:  00007fb6cb236e00(0000) GS:ffff88103f540000(0000) knlGS:0000000000000000
> 2016-09-24T16:43:45.125 controller-1 kernel: warning [90390.932804] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> 2016-09-24T16:43:45.125 controller-1 kernel: warning [90390.939222] CR2: 000000001ada8000 CR3: 0000000464152000 CR4: 00000000003427e0
> 2016-09-24T16:43:45.125 controller-1 kernel: warning [90390.947194] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> 2016-09-24T16:43:45.125 controller-1 kernel: warning [90390.955166] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
> 2016-09-24T16:43:45.125 controller-1 kernel: warning [90390.963135] Stack:
> 2016-09-24T16:43:45.125 controller-1 kernel: warning [90390.965380]  00ff880400000002 0000000000000246 ffff88107ffda000 00000000997694b3
> 2016-09-24T16:43:45.125 controller-1 kernel: warning [90390.973688]  0000000000000000 ffff88046d4815a8 00000000003d0f00 ffff8802c8003c60
> 2016-09-24T16:43:45.125 controller-1 kernel: warning [90390.981996]  ffff880463f75a90 ffff8804120f3e38 ffffffff811832e8 ffff88107ffda000
> 2016-09-24T16:43:45.125 controller-1 kernel: warning [90390.990304] Call Trace:
> 2016-09-24T16:43:45.125 controller-1 kernel: warning [90390.993039]  [<ffffffff811832e8>] __mpol_dup+0x38/0x140
> 2016-09-24T16:43:45.125 controller-1 kernel: warning [90390.998876]  [<ffffffff8118bea2>] ? kmem_cache_alloc+0x112/0x250
> 2016-09-24T16:43:45.125 controller-1 kernel: warning [90391.005591]  [<ffffffff8100be69>] ? read_tsc+0x9/0x10
> 2016-09-24T16:43:45.125 controller-1 kernel: warning [90391.011235]  [<ffffffff8105ef91>] copy_process.part.30+0x611/0x1570
> 2016-09-24T16:43:45.125 controller-1 kernel: warning [90391.018230]  [<ffffffff810600d1>] do_fork+0xe1/0x350
> 2016-09-24T16:43:45.142 controller-1 kernel: warning [90391.023778]  [<ffffffff810603c6>] SyS_clone+0x16/0x20
> 2016-09-24T16:43:45.142 controller-1 kernel: warning [90391.029421]  [<ffffffff816792d9>] stub_clone+0x69/0x90
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
