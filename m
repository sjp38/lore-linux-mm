Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 808206B0007
	for <linux-mm@kvack.org>; Thu, 28 Jun 2018 10:10:15 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id d66-v6so1456592qkf.11
        for <linux-mm@kvack.org>; Thu, 28 Jun 2018 07:10:15 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id n18-v6si2599484qvo.60.2018.06.28.07.10.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Jun 2018 07:10:14 -0700 (PDT)
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w5SE8XHt048708
	for <linux-mm@kvack.org>; Thu, 28 Jun 2018 14:10:13 GMT
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by userp2130.oracle.com with ESMTP id 2jum582eb0-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Thu, 28 Jun 2018 14:10:13 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id w5SEACdG025187
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Thu, 28 Jun 2018 14:10:12 GMT
Received: from abhmp0011.oracle.com (abhmp0011.oracle.com [141.146.116.17])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id w5SEAC36014856
	for <linux-mm@kvack.org>; Thu, 28 Jun 2018 14:10:12 GMT
Received: by mail-qt0-f178.google.com with SMTP id 92-v6so4801799qta.11
        for <linux-mm@kvack.org>; Thu, 28 Jun 2018 07:10:11 -0700 (PDT)
MIME-Version: 1.0
References: <20180628062857.29658-1-bhe@redhat.com> <20180628062857.29658-5-bhe@redhat.com>
 <20180628120937.GC12956@techadventures.net> <CAGM2reZsZVhhg2=dQZf6D-NmPTFRN-_95+s61pC7Axz5G5mkMQ@mail.gmail.com>
 <3e014554-abf9-8a18-e890-be43d48d5eb0@intel.com>
In-Reply-To: <3e014554-abf9-8a18-e890-be43d48d5eb0@intel.com>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Thu, 28 Jun 2018 10:09:06 -0400
Message-ID: <CAGM2reasSYwj7DtCiSFctA4q8eP9FShiAj5ou=xz4Pbk4C7mzw@mail.gmail.com>
Subject: Re: [PATCH v6 4/5] mm/sparse: Optimize memmap allocation during sparse_init()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dave.hansen@intel.com
Cc: osalvador@techadventures.net, bhe@redhat.com, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, pagupta@redhat.com, Linux Memory Management List <linux-mm@kvack.org>, kirill.shutemov@linux.intel.com

> Is this at a point in boot where a BUG_ON() generally produces useful
> output, or will it just produce and early-boot silent hang with no
> console output?

Probably depends on the platform, but in KVM, I see a nice panic
message (inserted BUG_ON(1) into sparse_init()):

[    0.000000] kernel BUG at mm/sparse.c:490!
PANIC: early exception 0x06 IP 10:ffffffffb6bd43d9 error 0 cr2
0xffff898747575000
[    0.000000] CPU: 0 PID: 0 Comm: swapper Not tainted 4.18.0-rc2_pt_sparse #6
[    0.000000] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996),
BIOS 1.11.0-20171110_100015-anatol 04/01/2014
[    0.000000] RIP: 0010:sparse_init+0x0/0x2
[    0.000000] Code: fe 3b 05 ba d0 16 00 7e 06 89 05 b2 d0 16 00 49
83 08 01 48 81 c3 00 80 00 00 e9 73 ff ff ff 48 83 c4 10 5b 5d 41 5c
41 5d c3 <0f> 0b 48 8b 05 ae 46 8f ff 48 c1 e2 15 48 01 d0 c3 41 56 48
8b 05
[    0.000000] RSP: 0000:ffffffffb6603e98 EFLAGS: 00010086 ORIG_RAX:
0000000000000000
[    0.000000] RAX: 0000000000000000 RBX: 0000000000000000 RCX: ffffffffb6603e80
[    0.000000] RDX: ffffffffb6603e78 RSI: 0000000000000040 RDI: ffffffffb6603e70
[    0.000000] RBP: 0000000007f7ec00 R08: ffffffffb6603e74 R09: 0000000000007fe0
[    0.000000] R10: 0000000000000100 R11: 0000000007fd6000 R12: 0000000000000000
[    0.000000] R13: ffffffffb6603f18 R14: 0000000000000000 R15: 0000000000000000
[    0.000000] FS:  0000000000000000(0000) GS:ffffffffb6b82000(0000)
knlGS:0000000000000000
[    0.000000] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[    0.000000] CR2: ffff898747575000 CR3: 0000000006e0a000 CR4: 00000000000606b0
[    0.000000] Call Trace:
[    0.000000]  ? paging_init+0xf/0x2c
[    0.000000]  ? setup_arch+0xae8/0xc17
[    0.000000]  ? printk+0x53/0x6a
[    0.000000]  ? start_kernel+0x62/0x4b3
[    0.000000]  ? load_ucode_bsp+0x3d/0x129
[    0.000000]  ? secondary_startup_64+0xa5/0xb0
