Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 09A496B0011
	for <linux-mm@kvack.org>; Fri, 20 Apr 2018 11:43:33 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id r188-v6so1007404ith.2
        for <linux-mm@kvack.org>; Fri, 20 Apr 2018 08:43:33 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id l190-v6si5739662iof.289.2018.04.20.08.43.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Apr 2018 08:43:31 -0700 (PDT)
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w3KFevRU126679
	for <linux-mm@kvack.org>; Fri, 20 Apr 2018 15:43:31 GMT
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by aserp2120.oracle.com with ESMTP id 2hdrxnn9dr-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Fri, 20 Apr 2018 15:43:30 +0000
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id w3KFhTEb012126
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Fri, 20 Apr 2018 15:43:30 GMT
Received: from abhmp0009.oracle.com (abhmp0009.oracle.com [141.146.116.15])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id w3KFhToO022533
	for <linux-mm@kvack.org>; Fri, 20 Apr 2018 15:43:29 GMT
Received: by mail-oi0-f43.google.com with SMTP id n65-v6so8429294oig.6
        for <linux-mm@kvack.org>; Fri, 20 Apr 2018 08:43:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAGM2reZvZZy6b+SEtpz_a_JTGBEB2nhBdfZJSZ89F99szv9peA@mail.gmail.com>
References: <20180418233825.GA33106@big-sky.local> <20180419013128.iurzouiqxvcnpbvz@wfg-t540p.sh.intel.com>
 <CAGM2reZvZZy6b+SEtpz_a_JTGBEB2nhBdfZJSZ89F99szv9peA@mail.gmail.com>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Fri, 20 Apr 2018 11:42:48 -0400
Message-ID: <CAGM2rebm1nU4=SAVQAObxsYEa9JpKZbYgeh+dcfb_pfEW6rxfA@mail.gmail.com>
Subject: Re: c9e97a1997 BUG: kernel reboot-without-warning in early-boot
 stage, last printk: early console in setup code
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Dennis Zhou <dennisszhou@gmail.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Steven Sistare <steven.sistare@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, LKP <lkp@01.org>, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Linus Torvalds <torvalds@linux-foundation.org>, Josef Bacik <jbacik@fb.com>

I have root caused the issue, and will submit a fix shortly. The fix
also fixes the per_cpu_ptr_to_phys bug that is sent in a separate
thread.

The issue arises in this stack:

start_kernel()
 trap_init()
  setup_cpu_entry_areas()
   setup_cpu_entry_area(cpu)
    get_cpu_gdt_paddr(cpu)
     per_cpu_ptr_to_phys(addr)
      pcpu_addr_to_page(addr)
       virt_to_page(addr)
        pfn_to_page(__pa(addr) >> PAGE_SHIFT)
The returned "struct page" is sometimes uninitialized, and thus
failing later when used. It turns out sometimes is because it depends
on KASLR.

When boot is failing we have this when  pfn_to_page() is called:
kasrl: 0x000000000d600000
 addr: ffffffff83e0d000
    pa: 1040d000
   pfn: 1040d
page: ffff88001f113340
page->flags ffffffffffffffff <- Uninitialized!

When boot is successful:
kaslr: 0x000000000a800000
 addr: ffffffff83e0d000
     pa: d60d000
    pfn: d60d
 page: ffff88001f05b340
page->flags 280000000000 <- Initialized!

Here are physical addresses that BIOS provided to us:
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reserved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x000000001ffdffff] usable
[    0.000000] BIOS-e820: [mem 0x000000001ffe0000-0x000000001fffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000feffc000-0x00000000feffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff] reserved

In both cases, working and non-working the real physical address is the same:
pa - kasrl = 0x2E0D000

The only thing that is different is PFN.

We initialize struct pages in four places:

1. Early in boot a small set of struct pages is initialized to fill
the first section, and lower zones.
2. During mm_init() we initialize "struct pages" for all the memory
that is allocated, i.e reserved in memblock.
3. Using on-demand logic when pages are allocated after mm_init call
4. After smp_init() when the rest free deferred pages are initialized.

The above path happens before deferred memory is initialized, and thus
it must be covered either by 1, 2 or 3.

So, lets check what PFNs are initialized after (1).

memmap_init_zone() is called for pfn ranges:
1 - 1000, and 1000 - 1ffe0, but it quits after reaching pfn 0x10000,
as it leaves the rest to be initialized as deferred pages.

In the working scenario pfn ended up being below 1000, but in the
failing scenario it is above. Hence, we must initialize this page in
(2). But trap_init() is called before mm_init().

The bug was introduced by "mm: initialize pages on demand during boot"
because we lowered amount of pages that is initialized in the step
(1). But, it still could happen, because the number of initialized
pages was a guessing.

The proposed fix is this:

diff --git a/init/main.c b/init/main.c
index b795aa341a3a..870f75581cea 100644
--- a/init/main.c
+++ b/init/main.c
@@ -585,8 +585,8 @@ asmlinkage __visible void __init start_kernel(void)
        setup_log_buf(0);
        vfs_caches_init_early();
        sort_main_extable();
-       trap_init();
        mm_init();
+       trap_init();

        ftrace_init();
