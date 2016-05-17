Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9901C6B025E
	for <linux-mm@kvack.org>; Tue, 17 May 2016 05:21:42 -0400 (EDT)
Received: by mail-yw0-f198.google.com with SMTP id y6so21583278ywe.0
        for <linux-mm@kvack.org>; Tue, 17 May 2016 02:21:42 -0700 (PDT)
Received: from mail-yw0-x235.google.com (mail-yw0-x235.google.com. [2607:f8b0:4002:c05::235])
        by mx.google.com with ESMTPS id k130si717868ywb.53.2016.05.17.02.21.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 May 2016 02:21:41 -0700 (PDT)
Received: by mail-yw0-x235.google.com with SMTP id g133so9457120ywb.2
        for <linux-mm@kvack.org>; Tue, 17 May 2016 02:21:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <573AB3BF.3030604@profihost.ag>
References: <56EAF98B.50605@profihost.ag>
	<20160317184514.GA6141@kroah.com>
	<56EDD206.3070202@suse.cz>
	<56EF15BB.3080509@profihost.ag>
	<20160320214130.GB23920@kroah.com>
	<56EFD267.9070609@profihost.ag>
	<20160321133815.GA14188@kroah.com>
	<573AB3BF.3030604@profihost.ag>
Date: Tue, 17 May 2016 21:21:41 +1200
Message-ID: <CAPerZE_OCJGp2v8dXM=dY8oP1ydX_oB29UbzaXMHKZcrsL_iJg@mail.gmail.com>
Subject: Re: divide error: 0000 [#1] SMP in task_numa_migrate -
 handle_mm_fault vanilla 4.4.6
From: Campbell Steven <casteven@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Cc: Greg KH <greg@kroah.com>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-mm@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Rik van Riel <riel@redhat.com>

Thanks Stefan,

I am seeing this on 4.5.0 and 4.5.4 both are compiled from mainline
neither include any patches over and above the tree. I ran for well
over a month in production on 4.5.0 with no issues at all on a single
socket server (E5-2670 v3 @ 2.30GHz) but as soon as we try to run
either 4.5.0 or 4.5.4 on a dual socket box we get these traces after
12 or so hours of uptime and the same sky rocketing load. Given you
have stopped your issues by applying those patches to 4.4 it's
possible I have different issues, but the symptoms are too similar to
ignore, our trace is here:

http://pastebin.com/Q7nd8nfP

I am using the cfg scheduler, and not the fair scheduler as Stefan
reported so that is another difference.

Happy to proceed with any suggestions or further information that may
help isolate this, use case on these servers are 12 x CEPH osd's with
bcache so they are seeing alot of disk activity via NVMe and SATA
buses.

Thanks

Campbell

On 17 May 2016 at 18:01, Stefan Priebe - Profihost AG
<s.priebe@profihost.ag> wrote:
> Am 21.03.2016 um 14:38 schrieb Greg KH:
>> On Mon, Mar 21, 2016 at 11:52:23AM +0100, Stefan Priebe - Profihost AG wrote:
>>>
>>> Am 20.03.2016 um 22:41 schrieb Greg KH:
>>>> On Sun, Mar 20, 2016 at 10:27:23PM +0100, Stefan Priebe wrote:
>>>>>
>>>>> Am 19.03.2016 um 23:26 schrieb Vlastimil Babka:
>>>>>> On 03/17/2016 07:45 PM, Greg KH wrote:
>>>>>>> On Thu, Mar 17, 2016 at 07:38:03PM +0100, Stefan Priebe wrote:
>>>>>>>> Hi,
>>>>>>>>
>>>>>>>> while running qemu 2.5 on a host running 4.4.6 the host system has
>>>>>>>> crashed
>>>>>>>> (load > 200) 3 times in the last 3 days.
>>>>>>>>
>>>>>>>> Always with this stack trace: (copy left here:
>>>>>>>> http://pastebin.com/raw/bCWTLKyt)
>>>>>>>>
>>>>>>>> [69068.874268] divide error: 0000 [#1] SMP
>>>>>>>> [69068.875242] Modules linked in: ebtable_filter ebtables ip6t_REJECT
>>>>>>>> nf_reject_ipv6 nf_conntrack_ipv6 nf_defrag_ipv6 ip6table_filter
>>>>>>>> ip6_tables
>>>>>>>> ipt_REJECT nf_reject_ipv4 xt_physdev xt_comment nf_conntrack_ipv4
>>>>>>>> nf_defrag_ipv4 xt_tcpudp xt_mark xt_set xt_addrtype xt_conntrack
>>>>>>>> nf_conntrack ip_set_hash_net ip_set vhost_net tun vhost macvtap macvlan
>>>>>>>> kvm_intel nfnetlink_log kvm nfnetlink irqbypass netconsole dlm
>>>>>>>> xt_multiport
>>>>>>>> iptable_filter ip_tables x_tables iscsi_tcp libiscsi_tcp libiscsi
>>>>>>>> scsi_transport_iscsi nfsd auth_rpcgss oid_registry bonding coretemp
>>>>>>>> 8021q
>>>>>>>> garp fuse i2c_i801 i7core_edac edac_core i5500_temp button btrfs xor
>>>>>>>> raid6_pq dm_mod raid1 md_mod usb_storage ohci_hcd bcache sg usbhid
>>>>>>>> sd_mod
>>>>>>>> ata_generic uhci_hcd ehci_pci ehci_hcd usbcore ata_piix usb_common igb
>>>>>>>> i2c_algo_bit mpt3sas raid_class ixgbe scsi_transport_sas i2c_core
>>>>>>>> mdio ptp
>>>>>>>> pps_core
>>>>>>>> [69068.895604] CPU: 14 PID: 6673 Comm: ceph-osd Not tainted
>>>>>>>> 4.4.6+7-ph #1
>>>>>>>> [69068.897052] Hardware name: Supermicro X8DT3/X8DT3, BIOS 2.1
>>>>>>>> 03/17/2012
>>>>>>>> [69068.898578] task: ffff880fc7f28000 ti: ffff880fda2c4000 task.ti:
>>>>>>>> ffff880fda2c4000
>>>>>>>> [69068.900377] RIP: 0010:[<ffffffff860b372c>]  [<ffffffff860b372c>]
>>>>>>>> task_h_load+0xcc/0x100
>>>>>>
>>>>>> decodecode says:
>>>>>>
>>>>>>   27:   48 83 c1 01             add    $0x1,%rcx
>>>>>>   2b:*  48 f7 f1                div    %rcx             <-- trapping
>>>>>> instruction
>>>>>>
>>>>>> This suggests the CONFIG_FAIR_GROUP_SCHED version of task_h_load:
>>>>>>
>>>>>>         update_cfs_rq_h_load(cfs_rq);
>>>>>>         return div64_ul(p->se.avg.load_avg * cfs_rq->h_load,
>>>>>>                         cfs_rq_load_avg(cfs_rq) + 1);
>>>>>>
>>>>>> So the load avg is -1, thus after adding 1 we get division by 0, huh?
>>>>>
>>>>> Yes CONFIG_FAIR_GROUP_SCHED is set. I cherry picked now all those commits up
>>>>> to 4.5 for fair.c:
>>>>> https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/log/kernel/sched/fair.c?h=v4.5
>>>>>
>>>>> It didn't happen again with v4.4.6 + 4.5 patches for fair.c
>>>>
>>>> Ok, that's a lot of patches, how about figuring out which single patch,
>>>> or shortest number of patches, makes things work again?
>>>
>>> will do so but it seems most out of those 9 patches are based on each
>>> other. So it wouldn't be easy.
>>
>> Worst case, we take all 9.  Best case, we only need one :)
>
> Today i got another report from: casteven (at) gmail.com having the same
> issue. I wasn't able to figure out which of those 9 patches helps - i
> still can just tell that it does not happen with this series on top of 4.4.
>
> Stefan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
