Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f171.google.com (mail-we0-f171.google.com [74.125.82.171])
	by kanga.kvack.org (Postfix) with ESMTP id 087B46B0032
	for <linux-mm@kvack.org>; Thu, 26 Feb 2015 09:23:54 -0500 (EST)
Received: by wesp10 with SMTP id p10so9029223wes.12
        for <linux-mm@kvack.org>; Thu, 26 Feb 2015 06:23:53 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p8si1754876wjx.82.2015.02.26.06.23.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 26 Feb 2015 06:23:50 -0800 (PST)
Message-ID: <54EF2C74.60908@suse.cz>
Date: Thu, 26 Feb 2015 15:23:48 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: 3.19.0 / kswap0 bug
References: <CAH4oapfOf8-5dpLhsejMEFRAO6ZFEiYq7dkXXQo=QdumyJOxjQ@mail.gmail.com>
In-Reply-To: <CAH4oapfOf8-5dpLhsejMEFRAO6ZFEiYq7dkXXQo=QdumyJOxjQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavol Cupka <pavol.cupka@gmail.com>, linux-kernel@vger.kernel.org
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>

On 02/21/2015 05:16 PM, Pavol Cupka wrote:
> Hi list,
> 
> I am encountering a bug on my desktop PC. Running gentoo-sources
> (patches for gentoo) 3.19.0, gcc 4.8.4, glibc 2.19

Although there don't seem to be many gentoo patches on top, you should try
reproducing this with vanilla 3.19 kernel first.

> MB: GA-MA785GT-UD3H
> CPU: AMD Phenom(tm) II X4 965 Processor
> RAM: 2x DIMM 1333 MHz 2GB
> SATA controller: SB7x0/SB8x0/SB9x0 SATA Controller [AHCI mode]
> HDD: 3x HGST 4TB disks
> SSD: Intel SSD SSDSC2CT060A3 fw: i300
> swap on first two hdd 1,5 GB in size
> /dev/sda2                               partition       1571836 85824   -1
> /dev/sdb2                               partition       1571836 0       -2
> 
> this is what I've got after running dd if=/dev/urandom of=/dev/sdd1 bs=512
> the computer was not doing other things, there is a glances instance
> running in tmux and the dd is also running in the same tmux session.

Is it easily reproducible? Is there a last known-working kernel version? If yes,
bisect could be an option.

> [13397.986449] BUG: Bad page state in process kswapd0  pfn:104b06
> [13397.986462] page:ffffea000412c180 count:0 mapcount:-1 mapping:
>     (null) index:0x45fc53
> [13397.986493] flags: 0x200000000000008(uptodate)
> [13397.986513] page dumped because: nonzero mapcount

Mapcount underflow, hm, I don't recall a similar report to this.

> [13397.986517] Modules linked in: xfs libcrc32c exportfs firewire_ohci
> kvm firewire_core k10temp crc_itu_t
> [13397.986537] CPU: 2 PID: 664 Comm: kswapd0 Not tainted 3.19.0-gentoo-suc #1
> [13397.986543] Hardware name: Gigabyte Technology Co., Ltd.
> GA-MA785GT-UD3H/GA-MA785GT-UD3H, BIOS F8 05/25/2010
> [13397.986547]  ffffffff81c27a04 ffff88013a603938 ffffffff819da02a
> 0000000000000092
> [13397.986555]  ffffea000412c180 ffff88013a603968 ffffffff819d640f
> ffffea000412c1c0
> [13397.986561]  ffffea000412c180 0000000000000000 ffffffff81c27a26
> ffff88013a6039b8
> [13397.986568] Call Trace:
> [13397.986582]  [<ffffffff819da02a>] dump_stack+0x45/0x57
> [13397.986592]  [<ffffffff819d640f>] bad_page+0xdb/0xf9
> [13397.986600]  [<ffffffff8110d52f>] free_pages_prepare+0xff/0x160
> [13397.986607]  [<ffffffff8110f670>] free_hot_cold_page+0x30/0x130
> [13397.986614]  [<ffffffff8110f7bb>] free_hot_cold_page_list+0x4b/0xa0
> [13397.986623]  [<ffffffff8111a547>] shrink_page_list+0x507/0xa90
> [13397.986632]  [<ffffffff8111b04d>] shrink_inactive_list+0x18d/0x4f0
> [13397.986640]  [<ffffffff8111bd25>] shrink_lruvec+0x5d5/0x7c0
> [13397.986648]  [<ffffffff8111bfa7>] shrink_zone+0x97/0x240
> [13397.986656]  [<ffffffff8111d0c9>] kswapd+0x509/0x9d0
> [13397.986666]  [<ffffffff8111cbc0>] ? mem_cgroup_shrink_node_zone+0x140/0x140
> [13397.986673]  [<ffffffff81065ee4>] kthread+0xc4/0xe0
> [13397.986680]  [<ffffffff81065e20>] ? kthread_create_on_node+0x180/0x180
> [13397.986688]  [<ffffffff819e382c>] ret_from_fork+0x7c/0xb0
> [13397.986695]  [<ffffffff81065e20>] ? kthread_create_on_node+0x180/0x180
> [13397.986700] Disabling lock debugging due to kernel taint
> [17030.761818] BUG: Bad page state in process kswapd0  pfn:6cd0e
> [17030.761831] page:ffffea0001b34380 count:0 mapcount:-1 mapping:
>     (null) index:0x17265b3
> [17030.761861] flags: 0x100000000000008(uptodate)
> [17030.761881] page dumped because: nonzero mapcount
> [17030.761884] Modules linked in: xfs libcrc32c exportfs firewire_ohci
> kvm firewire_core k10temp crc_itu_t
> [17030.761905] CPU: 3 PID: 664 Comm: kswapd0 Tainted: G    B
> 3.19.0-gentoo-suc #1
> [17030.761910] Hardware name: Gigabyte Technology Co., Ltd.
> GA-MA785GT-UD3H/GA-MA785GT-UD3H, BIOS F8 05/25/2010
> [17030.761915]  ffffffff81c27a04 ffff88013a603938 ffffffff819da02a
> 0000000000000011
> [17030.761922]  ffffea0001b34380 ffff88013a603968 ffffffff819d640f
> ffffea0001b343c0
> [17030.761929]  ffffea0001b34380 0000000000000000 ffffffff81c27a26
> ffff88013a6039b8
> [17030.761936] Call Trace:
> [17030.761949]  [<ffffffff819da02a>] dump_stack+0x45/0x57
> [17030.761979]  [<ffffffff819d640f>] bad_page+0xdb/0xf9
> [17030.761987]  [<ffffffff8110d52f>] free_pages_prepare+0xff/0x160
> [17030.761995]  [<ffffffff8110f670>] free_hot_cold_page+0x30/0x130
> [17030.762001]  [<ffffffff8110f7bb>] free_hot_cold_page_list+0x4b/0xa0
> [17030.762010]  [<ffffffff8111a547>] shrink_page_list+0x507/0xa90
> [17030.762019]  [<ffffffff8111b04d>] shrink_inactive_list+0x18d/0x4f0
> [17030.762028]  [<ffffffff8111bd25>] shrink_lruvec+0x5d5/0x7c0
> [17030.762037]  [<ffffffff8111bfa7>] shrink_zone+0x97/0x240
> [17030.762045]  [<ffffffff8111d0c9>] kswapd+0x509/0x9d0
> [17030.762054]  [<ffffffff8111cbc0>] ? mem_cgroup_shrink_node_zone+0x140/0x140
> [17030.762062]  [<ffffffff81065ee4>] kthread+0xc4/0xe0
> [17030.762069]  [<ffffffff81065e20>] ? kthread_create_on_node+0x180/0x180
> [17030.762077]  [<ffffffff819e382c>] ret_from_fork+0x7c/0xb0
> [17030.762084]  [<ffffffff81065e20>] ? kthread_create_on_node+0x180/0x180
> [19295.212650] BUG: Bad page state in process kswapd0  pfn:60a0e
> [19295.212663] page:ffffea0001828380 count:0 mapcount:-1 mapping:
>     (null) index:0x34a1449
> [19295.212693] flags: 0x100000000000008(uptodate)
> [19295.212713] page dumped because: nonzero mapcount
> [19295.212717] Modules linked in: xfs libcrc32c exportfs firewire_ohci
> kvm firewire_core k10temp crc_itu_t
> [19295.212737] CPU: 1 PID: 664 Comm: kswapd0 Tainted: G    B
> 3.19.0-gentoo-suc #1
> [19295.212742] Hardware name: Gigabyte Technology Co., Ltd.
> GA-MA785GT-UD3H/GA-MA785GT-UD3H, BIOS F8 05/25/2010
> [19295.212747]  ffffffff81c27a04 ffff88013a603938 ffffffff819da02a
> 00000000000000bb
> [19295.212754]  ffffea0001828380 ffff88013a603968 ffffffff819d640f
> ffffea00018283c0
> [19295.212761]  ffffea0001828380 0000000000000000 ffffffff81c27a26
> ffff88013a6039b8
> [19295.212768] Call Trace:
> [19295.212782]  [<ffffffff819da02a>] dump_stack+0x45/0x57
> [19295.212793]  [<ffffffff819d640f>] bad_page+0xdb/0xf9
> [19295.212801]  [<ffffffff8110d52f>] free_pages_prepare+0xff/0x160
> [19295.212808]  [<ffffffff8110f670>] free_hot_cold_page+0x30/0x130
> [19295.212815]  [<ffffffff8110f7bb>] free_hot_cold_page_list+0x4b/0xa0
> [19295.212823]  [<ffffffff8111a547>] shrink_page_list+0x507/0xa90
> [19295.212832]  [<ffffffff8111b04d>] shrink_inactive_list+0x18d/0x4f0
> [19295.212841]  [<ffffffff8111bd25>] shrink_lruvec+0x5d5/0x7c0
> [19295.212849]  [<ffffffff8111bfa7>] shrink_zone+0x97/0x240
> [19295.212857]  [<ffffffff8111d0c9>] kswapd+0x509/0x9d0
> [19295.212867]  [<ffffffff8111cbc0>] ? mem_cgroup_shrink_node_zone+0x140/0x140
> [19295.212874]  [<ffffffff81065ee4>] kthread+0xc4/0xe0
> [19295.212881]  [<ffffffff81065e20>] ? kthread_create_on_node+0x180/0x180
> [19295.212889]  [<ffffffff819e382c>] ret_from_fork+0x7c/0xb0
> [19295.212895]  [<ffffffff81065e20>] ? kthread_create_on_node+0x180/0x180
> [25754.399681] BUG: Bad page state in process kswapd0  pfn:110e06
> [25754.399694] page:ffffea0004438180 count:0 mapcount:-1 mapping:
>     (null) index:0x52f5b87
> [25754.399723] flags: 0x200000000000008(uptodate)
> [25754.399742] page dumped because: nonzero mapcount
> [25754.399746] Modules linked in: xfs libcrc32c exportfs firewire_ohci
> kvm firewire_core k10temp crc_itu_t
> [25754.399766] CPU: 0 PID: 664 Comm: kswapd0 Tainted: G    B
> 3.19.0-gentoo-suc #1
> [25754.399771] Hardware name: Gigabyte Technology Co., Ltd.
> GA-MA785GT-UD3H/GA-MA785GT-UD3H, BIOS F8 05/25/2010
> [25754.399776]  ffffffff81c27a04 ffff88013a603938 ffffffff819da02a
> 0000000000000089
> [25754.399783]  ffffea0004438180 ffff88013a603968 ffffffff819d640f
> ffffea00044381c0
> [25754.399790]  ffffea0004438180 0000000000000000 ffffffff81c27a26
> ffff88013a6039b8
> [25754.399796] Call Trace:
> [25754.399811]  [<ffffffff819da02a>] dump_stack+0x45/0x57
> [25754.399820]  [<ffffffff819d640f>] bad_page+0xdb/0xf9
> [25754.399828]  [<ffffffff8110d52f>] free_pages_prepare+0xff/0x160
> [25754.399835]  [<ffffffff8110f670>] free_hot_cold_page+0x30/0x130
> [25754.399842]  [<ffffffff8110f7bb>] free_hot_cold_page_list+0x4b/0xa0
> [25754.399850]  [<ffffffff8111a547>] shrink_page_list+0x507/0xa90
> [25754.399859]  [<ffffffff8111b04d>] shrink_inactive_list+0x18d/0x4f0
> [25754.399868]  [<ffffffff8111bd25>] shrink_lruvec+0x5d5/0x7c0
> [25754.399876]  [<ffffffff8111bfa7>] shrink_zone+0x97/0x240
> [25754.399884]  [<ffffffff8111d0c9>] kswapd+0x509/0x9d0
> [25754.399894]  [<ffffffff8111cbc0>] ? mem_cgroup_shrink_node_zone+0x140/0x140
> [25754.399901]  [<ffffffff81065ee4>] kthread+0xc4/0xe0
> [25754.399908]  [<ffffffff81065e20>] ? kthread_create_on_node+0x180/0x180
> [25754.399916]  [<ffffffff819e382c>] ret_from_fork+0x7c/0xb0
> [25754.399922]  [<ffffffff81065e20>] ? kthread_create_on_node+0x180/0x180
> [37925.847674] BUG: Bad page state in process kswapd0  pfn:2cd0e
> [37925.847686] page:ffffea0000b34380 count:0 mapcount:-1 mapping:
>     (null) index:0x8c1fd03
> [37925.847716] flags: 0x100000000000008(uptodate)
> [37925.847736] page dumped because: nonzero mapcount
> [37925.847739] Modules linked in: xfs libcrc32c exportfs firewire_ohci
> kvm firewire_core k10temp crc_itu_t
> [37925.847759] CPU: 1 PID: 664 Comm: kswapd0 Tainted: G    B
> 3.19.0-gentoo-suc #1
> [37925.847765] Hardware name: Gigabyte Technology Co., Ltd.
> GA-MA785GT-UD3H/GA-MA785GT-UD3H, BIOS F8 05/25/2010
> [37925.847769]  ffffffff81c27a04 ffff88013a603938 ffffffff819da02a
> 00000000000000a9
> [37925.847776]  ffffea0000b34380 ffff88013a603968 ffffffff819d640f
> ffffea0000b343c0
> [37925.847783]  ffffea0000b34380 0000000000000000 ffffffff81c27a26
> ffff88013a6039b8
> [37925.847789] Call Trace:
> [37925.847803]  [<ffffffff819da02a>] dump_stack+0x45/0x57
> [37925.847813]  [<ffffffff819d640f>] bad_page+0xdb/0xf9
> [37925.847821]  [<ffffffff8110d52f>] free_pages_prepare+0xff/0x160
> [37925.847847]  [<ffffffff8110f670>] free_hot_cold_page+0x30/0x130
> [37925.847854]  [<ffffffff8110f7bb>] free_hot_cold_page_list+0x4b/0xa0
> [37925.847863]  [<ffffffff8111a547>] shrink_page_list+0x507/0xa90
> [37925.847872]  [<ffffffff8111b04d>] shrink_inactive_list+0x18d/0x4f0
> [37925.847880]  [<ffffffff8111bd25>] shrink_lruvec+0x5d5/0x7c0
> [37925.847889]  [<ffffffff8111bfa7>] shrink_zone+0x97/0x240
> [37925.847897]  [<ffffffff8111d0c9>] kswapd+0x509/0x9d0
> [37925.847906]  [<ffffffff8111cbc0>] ? mem_cgroup_shrink_node_zone+0x140/0x140
> [37925.847914]  [<ffffffff81065ee4>] kthread+0xc4/0xe0
> [37925.847920]  [<ffffffff81065e20>] ? kthread_create_on_node+0x180/0x180
> [37925.847929]  [<ffffffff819e382c>] ret_from_fork+0x7c/0xb0
> [37925.847935]  [<ffffffff81065e20>] ? kthread_create_on_node+0x180/0x180
> [60015.145582] pickup (26811) used greatest stack depth: 10776 bytes left
> [65101.140582] BUG: Bad page state in process kswapd0  pfn:1ed06
> [65101.140595] page:ffffea00007b4180 count:0 mapcount:-1 mapping:
>     (null) index:0x18160edd
> [65101.140624] flags: 0x100000000000008(uptodate)
> [65101.140644] page dumped because: nonzero mapcount
> [65101.140647] Modules linked in: xfs libcrc32c exportfs firewire_ohci
> kvm firewire_core k10temp crc_itu_t
> [65101.140668] CPU: 3 PID: 664 Comm: kswapd0 Tainted: G    B
> 3.19.0-gentoo-suc #1
> [65101.140673] Hardware name: Gigabyte Technology Co., Ltd.
> GA-MA785GT-UD3H/GA-MA785GT-UD3H, BIOS F8 05/25/2010
> [65101.140677]  ffffffff81c27a04 ffff88013a603938 ffffffff819da02a
> 000000000000008b
> [65101.140685]  ffffea00007b4180 ffff88013a603968 ffffffff819d640f
> ffffea00007b41c0
> [65101.140691]  ffffea00007b4180 0000000000000000 ffffffff81c27a26
> ffff88013a6039b8
> [65101.140697] Call Trace:
> [65101.140712]  [<ffffffff819da02a>] dump_stack+0x45/0x57
> [65101.140721]  [<ffffffff819d640f>] bad_page+0xdb/0xf9
> [65101.140729]  [<ffffffff8110d52f>] free_pages_prepare+0xff/0x160
> [65101.140737]  [<ffffffff8110f670>] free_hot_cold_page+0x30/0x130
> [65101.140743]  [<ffffffff8110f7bb>] free_hot_cold_page_list+0x4b/0xa0
> [65101.140752]  [<ffffffff8111a547>] shrink_page_list+0x507/0xa90
> [65101.140761]  [<ffffffff8111b04d>] shrink_inactive_list+0x18d/0x4f0
> [65101.140769]  [<ffffffff8111bd25>] shrink_lruvec+0x5d5/0x7c0
> [65101.140778]  [<ffffffff8111bfa7>] shrink_zone+0x97/0x240
> [65101.140786]  [<ffffffff8111d0c9>] kswapd+0x509/0x9d0
> [65101.140796]  [<ffffffff8111cbc0>] ? mem_cgroup_shrink_node_zone+0x140/0x140
> [65101.140803]  [<ffffffff81065ee4>] kthread+0xc4/0xe0
> [65101.140810]  [<ffffffff81065e20>] ? kthread_create_on_node+0x180/0x180
> [65101.140818]  [<ffffffff819e382c>] ret_from_fork+0x7c/0xb0
> [65101.140825]  [<ffffffff81065e20>] ? kthread_create_on_node+0x180/0x180
> 
> is there something i can do to diagnose it more?
> 
> Thank you for your help.
> 
> Pavol
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
