Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3139C8E0001
	for <linux-mm@kvack.org>; Tue, 18 Dec 2018 17:31:28 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id u32so23314686qte.1
        for <linux-mm@kvack.org>; Tue, 18 Dec 2018 14:31:28 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id q74sor832466qkq.28.2018.12.18.14.31.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 18 Dec 2018 14:31:27 -0800 (PST)
Message-ID: <1545172285.18411.26.camel@lca.pw>
Subject: kernel panic with page_owner=on
From: Qian Cai <cai@lca.pw>
Date: Tue, 18 Dec 2018 17:31:25 -0500
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: pasha.tatashin@oracle.com, mingo@kernel.org, mhocko@suse.com, akpm@linux-foundation.org
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, hpa@zytor.com, mgorman@techsingularity.net, tglx@linutronix.de

CONFIG_DEBUG_VM_PGFLAGS=y
PAGE_OWNER=y
NODE_NOT_IN_PAGE_FLAGS=n

This seems due to f165b378bbd (mm: uninitialized struct page poisoning sanity
checking) shoots itself in the foot.

[   11.917212] page:ffffea0004200000 is uninitialized and poisoned
[   11.917220] raw: ffffffffffffffff ffffffffffffffff ffffffffffffffff
ffffffffffffffff
[   11.921745] raw: ffffffffffffffff ffffffffffffffff ffffffffffffffff
ffffffffffffffff
[   11.924523] page dumped because: VM_BUG_ON_PAGE(PagePoisoned(p))
[   11.926498] page_owner info is not active (free page?)
[   11.928234] ------------[ c-----
[   12.329560] kernel BUG at include/linux/mm.h:990!
[   12.337632] RIP: 0010:init_page_owner+0x486/0x520
[   12.345238] RSP: 0000:ffffffff87c07d28 EFLAGS: 00010286
[   12.346953] RAX: 0000000000000000 RBX: 0000000000108000 RCX: ffffffff85e5984c
[   12.349253] RDX: 0000000000000000 RSI: 0000000000000000 RDI: ffffffff87c07800
[   12.351546] RBP: ffffffff87c07df8 R08: fffffbfff0fc0d41 R09: 0000000000000000
[   12.353911] R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000108200
[   12.356186] R13: ffffea0004200000 R14: 0000000000280000 R15: ffffffffffffffff
[   12.358532] FS:  0000000000000000(0000) GS:ffff8881eb600000(0000)
knlGS:0000000000000000
[   12.361190] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   12.363065] CR2: ffff8882d7401000 CR3: 00000002d4214001 CR4: 00000000000606b0
[   12.365434] Call Trace:
[   12.366566]  ? read_page_owner+0x470/0x470
[   12.367944]  ? kmemleak_not_leak+0x45/0x80
[   12.369293]  page_ext_init+0x233/0x23f
[   12.370535]  start_kernel+0x592/0x6b6
[   12.371735]_cache_init+0xb/0xb
[   12.773100]  ? init_intel_microcode+0xd7/0xd7
[   12.774614]  ? cmdline_find_option_bool+0x82/0x1b0
[   12.776221]  x86_64_start_reserons+0x24/0x26
[   12.877703]  x86_64_start_kernel+0xf9/0x100
[   12.879120]  secondary_startup_64+0xb6/0xc0

At first,

start_kernel
  setup_arch
    pagetable_init
      paging_init
        sparse_init
          sparse_init_nid
            sparse_buffer_init
              memblock_virt_alloc_try_nid_raw

It poisons all the allocated pages there.

memset(ptr, PAGE_POISON_PATTERN, size)

Later,

page_ext_init
  invoke_init_callbacks
    init_section_page_ext
      init_page_owner
        init_early_allocated_pages
          init_zones_in_node
            init_pages_in_zone
              lookup_page_ext
                page_to_nid
                  PF_POISONED_CHECK <--- panic here.

This because all allocated pages are not initialized until later.

init_pages_in_zone
  __set_page_owner_handle
