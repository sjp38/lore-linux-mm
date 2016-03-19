Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 857066B025E
	for <linux-mm@kvack.org>; Sat, 19 Mar 2016 18:26:17 -0400 (EDT)
Received: by mail-wm0-f41.google.com with SMTP id r129so8166607wmr.1
        for <linux-mm@kvack.org>; Sat, 19 Mar 2016 15:26:17 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gd1si7056568wjb.154.2016.03.19.15.26.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 19 Mar 2016 15:26:16 -0700 (PDT)
Subject: Re: divide error: 0000 [#1] SMP in task_numa_migrate -
 handle_mm_fault vanilla 4.4.6
References: <56EAF98B.50605@profihost.ag> <20160317184514.GA6141@kroah.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56EDD206.3070202@suse.cz>
Date: Sat, 19 Mar 2016 23:26:14 +0100
MIME-Version: 1.0
In-Reply-To: <20160317184514.GA6141@kroah.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg KH <greg@kroah.com>, Stefan Priebe <s.priebe@profihost.ag>
Cc: LKML <linux-kernel@vger.kernel.org>, stable <stable@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-mm@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Rik van Riel <riel@redhat.com>

On 03/17/2016 07:45 PM, Greg KH wrote:
> On Thu, Mar 17, 2016 at 07:38:03PM +0100, Stefan Priebe wrote:
>> Hi,
>>
>> while running qemu 2.5 on a host running 4.4.6 the host system has crashed
>> (load > 200) 3 times in the last 3 days.
>>
>> Always with this stack trace: (copy left here:
>> http://pastebin.com/raw/bCWTLKyt)
>>
>> [69068.874268] divide error: 0000 [#1] SMP
>> [69068.875242] Modules linked in: ebtable_filter ebtables ip6t_REJECT
>> nf_reject_ipv6 nf_conntrack_ipv6 nf_defrag_ipv6 ip6table_filter ip6_tables
>> ipt_REJECT nf_reject_ipv4 xt_physdev xt_comment nf_conntrack_ipv4
>> nf_defrag_ipv4 xt_tcpudp xt_mark xt_set xt_addrtype xt_conntrack
>> nf_conntrack ip_set_hash_net ip_set vhost_net tun vhost macvtap macvlan
>> kvm_intel nfnetlink_log kvm nfnetlink irqbypass netconsole dlm xt_multiport
>> iptable_filter ip_tables x_tables iscsi_tcp libiscsi_tcp libiscsi
>> scsi_transport_iscsi nfsd auth_rpcgss oid_registry bonding coretemp 8021q
>> garp fuse i2c_i801 i7core_edac edac_core i5500_temp button btrfs xor
>> raid6_pq dm_mod raid1 md_mod usb_storage ohci_hcd bcache sg usbhid sd_mod
>> ata_generic uhci_hcd ehci_pci ehci_hcd usbcore ata_piix usb_common igb
>> i2c_algo_bit mpt3sas raid_class ixgbe scsi_transport_sas i2c_core mdio ptp
>> pps_core
>> [69068.895604] CPU: 14 PID: 6673 Comm: ceph-osd Not tainted 4.4.6+7-ph #1
>> [69068.897052] Hardware name: Supermicro X8DT3/X8DT3, BIOS 2.1 03/17/2012
>> [69068.898578] task: ffff880fc7f28000 ti: ffff880fda2c4000 task.ti:
>> ffff880fda2c4000
>> [69068.900377] RIP: 0010:[<ffffffff860b372c>]  [<ffffffff860b372c>]
>> task_h_load+0xcc/0x100

decodecode says:

   27:   48 83 c1 01             add    $0x1,%rcx
   2b:*  48 f7 f1                div    %rcx             <-- trapping instruction

This suggests the CONFIG_FAIR_GROUP_SCHED version of task_h_load:

         update_cfs_rq_h_load(cfs_rq);
         return div64_ul(p->se.avg.load_avg * cfs_rq->h_load,
                         cfs_rq_load_avg(cfs_rq) + 1);

So the load avg is -1, thus after adding 1 we get division by 0, huh?

>> [69068.961763] RSP: 0000:ffff880fda2c7b50  EFLAGS: 00010257
>> [69069.023910] RAX: 0000000000000000 RBX: ffff880fda2c7c10 RCX:
>> 0000000000000000
>> [69069.085953] RDX: 0000000000000000 RSI: 0000000000000001 RDI:
>> ffff880fc7f28000
>> [69069.151731] RBP: ffff880fda2c7bc8 R08: 00000001041955df R09:
>> ffff880fffd153f8
>> [69069.213757] R10: 0000000000000009 R11: 0000000000000193 R12:
>> ffff881f6832c780
>> [69069.274271] R13: ffff88203fc35380 R14: 0000000000000007 R15:
>> 00000000000000b6
>> [69069.334727] FS:  00007f578a3fb700(0000) GS:ffff880fffd00000(0000)
>> knlGS:0000000000000000
>> [69069.396435] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>> [69069.458522] CR2: 00007f5784f18468 CR3: 0000001fe9738000 CR4:
>> 00000000000026e0
>> [69069.520799] Stack:
>> [69069.581430]  ffffffff860b6855 ffff880fda2c7b78 0000000000000000
>> 0000000000000005
>> [69069.642629]  ffff880fffd00000 0000000000000015 fffffffffffffe7d
>> 0000000000000015
>> [69069.702815]  0000000000015380 ffff880fda2c7bc8 ffff880fc7f28000
>> 00000000000001e9
>> [69069.761881] Call Trace:
>> [69069.819883]  [<ffffffff860b6855>] ? task_numa_find_cpu+0x225/0x670
>> [69069.878368]  [<ffffffff860b79f0>] task_numa_migrate+0x550/0x950
>> [69069.936059]  [<ffffffff863d9138>] ? find_next_bit+0x18/0x20
>> [69069.993262]  [<ffffffff860b7e6d>] numa_migrate_preferred+0x7d/0x90
>> [69070.050528]  [<ffffffff860b89a5>] task_numa_fault+0x7c5/0xaa0
>> [69070.106544]  [<ffffffff861a2c0b>] ? mpol_misplaced+0x16b/0x1b0
>> [69070.163705]  [<ffffffff8618104e>] __handle_mm_fault+0x9ae/0x11f0
>> [69070.220013]  [<ffffffff865e4c52>] ? inet_recvmsg+0x72/0x90
>> [69070.276558]  [<ffffffff8655240b>] ? SYSC_recvfrom+0x12b/0x170
>> [69070.332283]  [<ffffffff8618196f>] handle_mm_fault+0xdf/0x180
>> [69070.388515]  [<ffffffff8604f324>] __do_page_fault+0x164/0x380
>> [69070.443897]  [<ffffffff860b25c3>] ? account_user_time+0x73/0x80
>> [69070.498534]  [<ffffffff860b2b3e>] ? vtime_account_user+0x4e/0x70
>> [69070.552598]  [<ffffffff8604f5a7>] do_page_fault+0x37/0x90
>> [69070.605960]  [<ffffffff86002a23>] ? syscall_return_slowpath+0x83/0xf0
>> [69070.660705]  [<ffffffff866b32f8>] page_fault+0x28/0x30
>> [69070.715707] Code: 86 b8 00 00 00 48 89 86 b0 00 00 00 48 85 c9 75 ca 49
>> 8b 81 b0 00 00 00 49 8b 49 78 31 d2 48 0f af 87 d8 01 00 00 5d 48 83 c1 01
>> <48> f7 f1 c3 4c 89 ce 48 8b 8e c0 00 00 00 48 8b 46 78 4c 89 86
>> [69070.835144] RIP  [<ffffffff860b372c>] task_h_load+0xcc/0x100
>> [69070.894095]  RSP <ffff880fda2c7b50>
>> [69070.953213] ---[ end trace 8d6f449a03dacfd4 ]---
>>
>> Would be nice if we can fix this in 4.4?
>
> Does this also happen in 4.5?  Did this work on 4.4.5?  Some previous
> release?  If you can find the offending patch using 'git bisect', that
> would be great.
>
> thanks,
>
> greg k-h
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
