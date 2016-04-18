Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8A9DC6B007E
	for <linux-mm@kvack.org>; Mon, 18 Apr 2016 15:45:28 -0400 (EDT)
Received: by mail-vk0-f72.google.com with SMTP id f185so225198655vkb.3
        for <linux-mm@kvack.org>; Mon, 18 Apr 2016 12:45:28 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id p1si122071qkf.260.2016.04.18.12.45.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Apr 2016 12:45:26 -0700 (PDT)
Subject: Re: [PATCH 12/16] page-flags: define PG_mlocked behavior on compound
 pages
References: <20150921153509.fef7ecdf313ef74307c43b65@linux-foundation.org>
 <1443106264-78075-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1443106264-78075-13-git-send-email-kirill.shutemov@linux.intel.com>
From: Sasha Levin <sasha.levin@oracle.com>
Message-ID: <5715393B.5030901@oracle.com>
Date: Mon, 18 Apr 2016 15:44:59 -0400
MIME-Version: 1.0
In-Reply-To: <1443106264-78075-13-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 09/24/2015 10:51 AM, Kirill A. Shutemov wrote:
> Transparent huge pages can be mlocked -- whole compund page at once.
> Something went wrong if we're trying to mlock() tail page.
> Let's use PF_NO_TAIL.

Kirill, Hugh,

I seem to be hitting this with trinity:

[  242.257552] page:ffffea0001517fc0 count:0 mapcount:0 mapping:dead000000000400 index:0x0 compound_mapcount: 0
[  242.258680] flags: 0x1fffff80000000()
[  242.261853] page dumped because: VM_BUG_ON_PAGE(1 && PageTail(page))
[  242.262712] ------------[ cut here ]------------
[  242.263182] kernel BUG at include/linux/page-flags.h:332!
[  242.263731] invalid opcode: 0000 [#1] PREEMPT SMP KASAN
[  242.264246] Modules linked in:
[  242.264603] CPU: 2 PID: 9302 Comm: trinity-c67 Not tainted 4.6.0-rc3-next-20160412-sasha-00024-geaec67e #3001
[  242.265574] task: ffff88013270c000 ti: ffff88012d0d0000 task.ti: ffff88012d0d0000
[  242.266306] RIP: clear_pages_mlock (include/linux/page-flags.h:332 mm/mlock.c:82)
[  242.267325] RSP: 0018:ffff88012d0d70e0  EFLAGS: 00010286
[  242.267894] RAX: 0000000000000000 RBX: ffffea0001517fc0 RCX: 0000000000000000
[  242.268773] RDX: 1ffffd40002a2fff RSI: 0000000000000282 RDI: ffffea0001517ff8
[  242.269495] RBP: ffff88012d0d7120 R08: ffffffffb66a1566 R09: fffffbfff6cd42ad
[  242.270227] R10: ffffffffb61dc140 R11: 00000000e27286ff R12: ffffea0001517fe0
[  242.270961] R13: ffffea0001518000 R14: dffffc0000000000 R15: 0000000000000000
[  242.271686] FS:  00007f594abad700(0000) GS:ffff8801b5a00000(0000) knlGS:0000000000000000
[  242.272494] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  242.273073] CR2: 0000000001f27000 CR3: 0000000132418000 CR4: 00000000000006a0
[  242.273815] Stack:
[  242.274036]  0000000000000008 ffff880083fd3000 0000000100000000 ffffea0001517fc0
[  242.274847]  ffffea0001517fe0 ffffea0001510000 ffffea0001510001 0000000000000000
[  242.275656]  ffff88012d0d7170 ffffffff9d712322 ffffffff9d7221ab 0000000001400000
[  242.276458] Call Trace:
[  242.276746] page_remove_rmap (include/linux/page-flags.h:157 include/linux/page-flags.h:522 mm/rmap.c:1383)
[  242.277989] __split_huge_pmd_locked (include/linux/compiler.h:222 (discriminator 3) include/linux/page-flags.h:143 (discriminator 3) include/linux/mm.h:736 (discriminator 3) mm/huge_memory.c:3075 (discriminator 3))
[  242.279909] __split_huge_pmd (include/linux/spinlock.h:347 mm/huge_memory.c:3102)
[  242.280515] split_huge_pmd_address (mm/huge_memory.c:3137)
[  242.281181] try_to_unmap_one (include/linux/compiler.h:222 include/linux/page-flags.h:143 include/linux/page-flags.h:268 include/linux/mm.h:495 mm/rmap.c:1425)
[  242.285008] rmap_walk_anon (mm/rmap.c:1762)
[  242.286167] rmap_walk_locked (mm/rmap.c:1845)
[  242.286753] try_to_unmap (mm/rmap.c:1643)
[  242.291004] split_huge_page_to_list (mm/huge_memory.c:3191 mm/huge_memory.c:3380)
[  242.293499] queue_pages_pte_range (mm/mempolicy.c:505)
[  242.294728] __walk_page_range (mm/pagewalk.c:51 mm/pagewalk.c:90 mm/pagewalk.c:116 mm/pagewalk.c:204)
[  242.295331] walk_page_range (mm/pagewalk.c:282)
[  242.295910] queue_pages_range (mm/mempolicy.c:667)
[  242.299552] migrate_to_node (include/linux/compiler.h:222 include/linux/list.h:189 mm/mempolicy.c:1002)
[  242.301994] do_migrate_pages (mm/mempolicy.c:1105)
[  242.303811] SYSC_migrate_pages (mm/mempolicy.c:1451)
[  242.307712] SyS_migrate_pages (mm/mempolicy.c:1369)
[  242.308290] ? SyS_set_mempolicy (mm/mempolicy.c:1369)
[  242.308892] do_syscall_64 (arch/x86/entry/common.c:350)
[  242.310743] entry_SYSCALL64_slow_path (arch/x86/entry/entry_64.S:251)
[ 242.311395] Code: 42 80 3c 30 00 74 08 4c 89 e7 e8 c7 f8 08 00 48 8b 43 20 a8 01 74 22 e8 da e2 ea ff 48 c7 c6 e0 9b 31 a7 48 89 df e8 0b 01 fe ff <0f> 0b 48 c7 c7 e0 3b 52 ab e8 5f 3b 9d 01 e8 b8 e2 ea ff 48 8b
All code
========
   0:   42 80 3c 30 00          cmpb   $0x0,(%rax,%r14,1)
   5:   74 08                   je     0xf
   7:   4c 89 e7                mov    %r12,%rdi
   a:   e8 c7 f8 08 00          callq  0x8f8d6
   f:   48 8b 43 20             mov    0x20(%rbx),%rax
  13:   a8 01                   test   $0x1,%al
  15:   74 22                   je     0x39
  17:   e8 da e2 ea ff          callq  0xffffffffffeae2f6
  1c:   48 c7 c6 e0 9b 31 a7    mov    $0xffffffffa7319be0,%rsi
  23:   48 89 df                mov    %rbx,%rdi
  26:   e8 0b 01 fe ff          callq  0xfffffffffffe0136
  2b:*  0f 0b                   ud2             <-- trapping instruction
  2d:   48 c7 c7 e0 3b 52 ab    mov    $0xffffffffab523be0,%rdi
  34:   e8 5f 3b 9d 01          callq  0x19d3b98
  39:   e8 b8 e2 ea ff          callq  0xffffffffffeae2f6
  3e:   48 8b 00                mov    (%rax),%rax

Code starting with the faulting instruction
===========================================
   0:   0f 0b                   ud2
   2:   48 c7 c7 e0 3b 52 ab    mov    $0xffffffffab523be0,%rdi
   9:   e8 5f 3b 9d 01          callq  0x19d3b6d
   e:   e8 b8 e2 ea ff          callq  0xffffffffffeae2cb
  13:   48 8b 00                mov    (%rax),%rax
[  242.314398] RIP clear_pages_mlock (include/linux/page-flags.h:332 mm/mlock.c:82)
[  242.315049]  RSP <ffff88012d0d70e0>


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
