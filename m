Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f54.google.com (mail-la0-f54.google.com [209.85.215.54])
	by kanga.kvack.org (Postfix) with ESMTP id 95ECD6B006E
	for <linux-mm@kvack.org>; Wed, 27 May 2015 14:42:50 -0400 (EDT)
Received: by laat2 with SMTP id t2so14264726laa.1
        for <linux-mm@kvack.org>; Wed, 27 May 2015 11:42:49 -0700 (PDT)
Received: from mail-la0-x229.google.com (mail-la0-x229.google.com. [2a00:1450:4010:c03::229])
        by mx.google.com with ESMTPS id o5si14177844lae.1.2015.05.27.11.42.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 May 2015 11:42:48 -0700 (PDT)
Received: by labpy14 with SMTP id py14so2448267lab.0
        for <linux-mm@kvack.org>; Wed, 27 May 2015 11:42:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CABPcSq+uMcDSBU1xt7oRqPXn-89ZpJmxK+C46M7rX7+Y7-x7iQ@mail.gmail.com>
References: <CABPcSq+uMcDSBU1xt7oRqPXn-89ZpJmxK+C46M7rX7+Y7-x7iQ@mail.gmail.com>
Date: Wed, 27 May 2015 11:42:47 -0700
Message-ID: <CABPcSqK+bfX+oPhCF2a9WQs0=+sQ8pde8r6dH-JQamsrCcJ8gg@mail.gmail.com>
Subject: Re: kernel bug(VM_BUG_ON_PAGE) with 3.18.13 in mm/migrate.c
From: Jovi Zhangwei <jovi@cloudflare.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, sasha.levin@oracle.com, n-horiguchi@ah.jp.nec.com, akpm@linux-foundation.org, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, vbabka@suse.cz, rientjes@google.com

On Wed, May 27, 2015 at 11:05 AM, Jovi Zhangwei <jovi@cloudflare.com> wrote:
> Hi,
>
> I got below kernel bug error in our 3.18.13 stable kernel.
> "kernel BUG at mm/migrate.c:1661!"
>
> Source code:
>
> 1657    static int numamigrate_isolate_page(pg_data_t *pgdat, struct page *page)
> 1658   {
> 1659            int page_lru;
> 1660
> 1661           VM_BUG_ON_PAGE(compound_order(page) &&
> !PageTransHuge(page), page);
>
> It's easy to trigger the error by run tcpdump in our system.(not sure
> it will easily be reproduced in another system)
> "sudo tcpdump -i bond0.100 'tcp port 4242' -c 100000000000 -w 4242.pcap"
>
> Any comments for this bug would be great appreciated. thanks.
>
> -----------------------------------------------------------------
> dmesg:
>
> [Mon May 25 05:29:33 2015] page:ffffea0015414000 count:66 mapcount:1
> mapping:          (null) index:0x0
> [Mon May 25 05:29:33 2015] flags: 0x20047580004000(head)
> [Mon May 25 05:29:33 2015] page dumped because:
> VM_BUG_ON_PAGE(compound_order(page) && !PageTransHuge(page))
> [Mon May 25 05:29:33 2015] ------------[ cut here ]------------
> [Mon May 25 05:29:33 2015] kernel BUG at mm/migrate.c:1661!
> [Mon May 25 05:29:33 2015] invalid opcode: 0000 [#1] SMP
> [Mon May 25 05:29:33 2015] Modules linked in: veth xt_comment xt_CT
> iptable_raw xt_addrtype ipt_MASQUERADE nf_nat_masquerade_ipv4
> iptable_nat nf_nat_ipv4 nf_nat bridge overlay tcp_cubic binfmt_misc
> nf_conntrack_ipv6 nf_defrag_ipv6 xt_tcpudp ip6table_filter ip6_tables
> nf_conntrack_ipv4 nf_defrag_ipv4 xt_conntrack nf_conntrack
> xt_multiport iptable_filter ip_tables x_tables rpcsec_gss_krb5
> auth_rpcgss oid_registry nfsv4 nfs lockd grace sunrpc fscache ses
> enclosure 8021q garp stp llc bonding ext4 crc16 jbd2 mbcache sg sd_mod
> ipmi_watchdog x86_pkg_temp_thermal coretemp kvm_intel iTCO_wdt evdev
> kvm crc32c_intel aesni_intel aes_x86_64 lrw gf128mul glue_helper
> ablk_helper cryptd ahci libahci ehci_pci mpt3sas raid_class ehci_hcd
> ixgbe libata igb scsi_transport_sas mdio usbcore ptp lpc_ich i2c_i801
> mfd_core i2c_algo_bit
> [Mon May 25 05:29:33 2015]  pps_core usb_common scsi_mod dca i2c_core
> wmi acpi_pad acpi_cpufreq md_mod processor thermal_sys button ipmi_si
> ipmi_poweroff ipmi_devintf ipmi_msghandler autofs4
> [Mon May 25 05:29:33 2015] CPU: 8 PID: 25835 Comm: tcpdump Not tainted
> 3.18.13-cloudflare #1
> [Mon May 25 05:29:33 2015] Hardware name: Quanta Computer Inc D51B-2U
> (dual 1G LoM)/S2B-MB (dual 1G LoM), BIOS S2B_3A17 11/07/2014
> [Mon May 25 05:29:34 2015] task: ffff880fb4605580 ti: ffff880f7ca54000
> task.ti: ffff880f7ca54000
> [Mon May 25 05:29:34 2015] RIP: 0010:[<ffffffff8112346c>]
> [<ffffffff8112346c>] migrate_misplaced_page+0xeb/0x2a1
> [Mon May 25 05:29:34 2015] RSP: 0000:ffff880f7ca57d28  EFLAGS: 00010246
> [Mon May 25 05:29:34 2015] RAX: 0000000000000000 RBX: ffffea0015414000
> RCX: 0000000000000000
> [Mon May 25 05:29:34 2015] RDX: 0000000000000000 RSI: ffff88207fc0c1a8
> RDI: 0000000000000540
> [Mon May 25 05:29:34 2015] RBP: ffff88207ffd7000 R08: 0000000000000000
> R09: 0000000000000000
> [Mon May 25 05:29:34 2015] R10: ffffffff81678b40 R11: ffff88207ff9aa00
> R12: ffff880f7ca57d38
> [Mon May 25 05:29:34 2015] R13: 0000000000000001 R14: 0000000000000000
> R15: 0000000000000000
> [Mon May 25 05:29:34 2015] FS:  00007fcb89855700(0000)
> GS:ffff88207fc00000(0000) knlGS:0000000000000000
> [Mon May 25 05:29:34 2015] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [Mon May 25 05:29:34 2015] CR2: 00007fcb88859008 CR3: 0000000f6a3f9000
> CR4: 00000000001407e0
> [Mon May 25 05:29:34 2015] Stack:
> [Mon May 25 05:29:34 2015]  0000000000000000 ffffea0015414000
> ffff880f7ca57d38 ffff880f7ca57d38
> [Mon May 25 05:29:34 2015]  0000000000000001 ffff880f6a3b8450
> ffffea003fa43330 0000000000000001
> [Mon May 25 05:29:34 2015]  ffffea0015414000 0000000000000000
> 0000000000000000 ffffffff81100c85
> [Mon May 25 05:29:34 2015] Call Trace:
> [Mon May 25 05:29:34 2015]  [<ffffffff81100c85>] ? handle_mm_fault+0x945/0xa62
> [Mon May 25 05:29:34 2015]  [<ffffffff81105bc6>] ? change_protection+0x12a/0x580
> [Mon May 25 05:29:34 2015]  [<ffffffff81034502>] ? __do_page_fault+0x2bf/0x395
> [Mon May 25 05:29:34 2015]  [<ffffffff8112dcf6>] ? new_sync_write+0x6a/0x8e
> [Mon May 25 05:29:34 2015]  [<ffffffff81158cfe>] ? fsnotify+0x276/0x2bf
> [Mon May 25 05:29:34 2015]  [<ffffffff81061467>] ? vtime_account_user+0x35/0x40
> [Mon May 25 05:29:34 2015]  [<ffffffff8103460f>] ? do_page_fault+0x37/0x58
> [Mon May 25 05:29:34 2015]  [<ffffffff81491082>] ? page_fault+0x22/0x30
> [Mon May 25 05:29:34 2015] Code: a5 00 00 00 48 ff c0 48 89 85 b8 5f
> 02 00 48 8b 03 f6 c4 40 74 17 83 7b 68 00 74 11 48 c7 c6 79 71 7f 81
> 48 89 df e8 b1 86 fd ff <0f> 0b 48 8b 03 31 c9 f6 c4 40 74 03 8b 4b 68
> 8b 85 40 5f 02 00
> [Mon May 25 05:29:34 2015] RIP  [<ffffffff8112346c>]
> migrate_misplaced_page+0xeb/0x2a1
> [Mon May 25 05:29:34 2015]  RSP <ffff880f7ca57d28>
> [Mon May 25 05:29:34 2015] ---[ end trace 83fa2f6761648dbd ]---
> [Mon May 25 05:29:34 2015] device bond0.100 left promiscuous mode
> [Mon May 25 05:29:34 2015] device bond0 left promiscuous mode
> [Mon May 25 05:29:34 2015] device eth2 left promiscuous mode
> [Mon May 25 05:29:34 2015] device eth3 left promiscuous mode
> [Mon May 25 05:29:46 2015] device bond0.100 entered promiscuous mode
> [Mon May 25 05:29:46 2015] device bond0 entered promiscuous mode
> [Mon May 25 05:29:46 2015] device eth2 entered promiscuous mode
> [Mon May 25 05:29:46 2015] device eth3 entered promiscuous mode
>
> Thanks.

Hi Mel,

Would you please give me some hints on this bug? it seems very wried
that the page is compounded but is not hugepage.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
