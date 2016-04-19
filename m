Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3E94A6B007E
	for <linux-mm@kvack.org>; Tue, 19 Apr 2016 09:55:38 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id zy2so21754846pac.1
        for <linux-mm@kvack.org>; Tue, 19 Apr 2016 06:55:38 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id 81si13123403pfq.221.2016.04.19.06.55.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Apr 2016 06:55:37 -0700 (PDT)
Subject: Re: [PATCHv2 4/4] thp: rewrite freeze_page()/unfreeze_page() with
 generic rmap walkers
References: <1457351838-114702-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1457351838-114702-5-git-send-email-kirill.shutemov@linux.intel.com>
From: Sasha Levin <sasha.levin@oracle.com>
Message-ID: <571638CF.5090709@oracle.com>
Date: Tue, 19 Apr 2016 09:55:27 -0400
MIME-Version: 1.0
In-Reply-To: <1457351838-114702-5-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org

On 03/07/2016 06:57 AM, Kirill A. Shutemov wrote:
> freeze_page() and unfreeze_page() helpers evolved in rather complex
> beasts. It would be nice to cut complexity of this code.
> 
> This patch rewrites freeze_page() using standard try_to_unmap().
> unfreeze_page() is rewritten with remove_migration_ptes().
> 
> The result is much simpler.
> 
> But the new variant is somewhat slower for PTE-mapped THPs.
> Current helpers iterates over VMAs the compound page is mapped to, and
> then over ptes within this VMA. New helpers iterates over small page,
> then over VMA the small page mapped to, and only then find relevant pte.
> 
> We have short cut for PMD-mapped THP: we directly install migration
> entries on PMD split.
> 
> I don't think the slowdown is critical, considering how much simpler
> result is and that split_huge_page() is quite rare nowadays. It only
> happens due memory pressure or migration.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

Hey Kirill,

I'm seeing the following while fuzzing:

[  302.029712] page:ffffea0002fa7fc0 count:0 mapcount:0 mapping:dead000000000400 index:0x0 compound_mapcount: 0

[  302.033158] flags: 0x1fffff80000000()

[  302.037878] ------------[ cut here ]------------

[  302.038574] kernel BUG at include/linux/page-flags.h:332!

[  302.038574] invalid opcode: 0000 [#1] PREEMPT SMP KASAN

[  302.038574] Modules linked in:

[  302.038574] CPU: 0 PID: 9538 Comm: trinity-c394 Not tainted 4.6.0-rc3-next-20160412-sasha-00024-geaec67e-dirty #3002

[  302.038574] task: ffff8800c29fc000 ti: ffff8800c2a90000 task.ti: ffff8800c2a90000

[  302.046951] RIP: clear_pages_mlock (include/linux/page-flags.h:332 mm/mlock.c:82)
[  302.046951] RSP: 0018:ffff8800c2a970e0  EFLAGS: 00010286

[  302.046951] RAX: 0000000000000000 RBX: ffffea0002fa7fc0 RCX: 0000000000000000

[  302.046951] RDX: 1ffffd40005f4fff RSI: 0000000000000282 RDI: ffffea0002fa7ff8

[  302.046951] RBP: ffff8800c2a97120 R08: 6d75642065676170 R09: 6163656220646570

[  302.046951] R10: ffff8800c2a97ad8 R11: 5f4d56203a657375 R12: ffffea0002fa7fe0

[  302.046951] R13: ffffea0002fa8000 R14: dffffc0000000000 R15: 0000000000000000

[  302.046951] FS:  00007f26730a5700(0000) GS:ffff8801b1a00000(0000) knlGS:0000000000000000

[  302.063233] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033

[  302.063233] CR2: 00000000025cff00 CR3: 00000000c2a6d000 CR4: 00000000000006b0

[  302.063233] Stack:

[  302.063233]  0000000000000008 ffff8801b7fd3000 0000000100000000 ffffea0002fa7fc0

[  302.063233]  ffffea0002fa7fe0 ffffea0002fa0000 ffffea0002fa0001 0000000000000000

[  302.063233]  ffff8800c2a97170 ffffffff81712322 ffffffff817221ab 0000000000e00000

[  302.063233] Call Trace:

[  302.063233] page_remove_rmap (include/linux/page-flags.h:157 include/linux/page-flags.h:522 mm/rmap.c:1383)
[  302.063233] __split_huge_pmd_locked (include/linux/compiler.h:222 (discriminator 3) include/linux/page-flags.h:143 (discriminator 3) include/linux/mm.h:736 (discriminator 3) mm/huge_memory.c:3075 (discriminator 3))
[  302.063233] __split_huge_pmd (include/linux/spinlock.h:347 mm/huge_memory.c:3102)
[  302.063233] split_huge_pmd_address (mm/huge_memory.c:3137)
[  302.063233] try_to_unmap_one (include/linux/compiler.h:222 include/linux/page-flags.h:143 include/linux/page-flags.h:268 include/linux/mm.h:495 mm/rmap.c:1425)
[  302.063233] rmap_walk_anon (mm/rmap.c:1762)
[  302.063233] rmap_walk_locked (mm/rmap.c:1845)
[  302.063233] try_to_unmap (mm/rmap.c:1643)
[  302.063233] split_huge_page_to_list (mm/huge_memory.c:3191 mm/huge_memory.c:3380)
[  302.063233] queue_pages_pte_range (mm/mempolicy.c:505)
[  302.063233] __walk_page_range (mm/pagewalk.c:51 mm/pagewalk.c:90 mm/pagewalk.c:116 mm/pagewalk.c:204)
[  302.063233] walk_page_range (mm/pagewalk.c:282)
[  302.063233] queue_pages_range (mm/mempolicy.c:667)
[  302.063233] migrate_to_node (include/linux/compiler.h:222 include/linux/list.h:189 mm/mempolicy.c:1002)
[  302.063233] do_migrate_pages (mm/mempolicy.c:1105)
[  302.063233] SYSC_migrate_pages (mm/mempolicy.c:1451)
[  302.063233] SyS_migrate_pages (mm/mempolicy.c:1369)
[  302.063233] do_syscall_64 (arch/x86/entry/common.c:350)
[  302.063233] entry_SYSCALL64_slow_path (arch/x86/entry/entry_64.S:251)
[ 302.063233] Code: 42 80 3c 30 00 74 08 4c 89 e7 e8 c7 f8 08 00 48 8b 43 20 a8 01 74 22 e8 da e2 ea ff 48 c7 c6 e0 9b 31 8b 48 89 df e8 0b 01 fe ff <0f> 0b 48 c7 c7 e0 3b 52 8f e8 5f 3b 9d 01 e8 b8 e2 ea ff 48 8b

All code
========
   0:	42 80 3c 30 00       	cmpb   $0x0,(%rax,%r14,1)
   5:	74 08                	je     0xf
   7:	4c 89 e7             	mov    %r12,%rdi
   a:	e8 c7 f8 08 00       	callq  0x8f8d6
   f:	48 8b 43 20          	mov    0x20(%rbx),%rax
  13:	a8 01                	test   $0x1,%al
  15:	74 22                	je     0x39
  17:	e8 da e2 ea ff       	callq  0xffffffffffeae2f6
  1c:	48 c7 c6 e0 9b 31 8b 	mov    $0xffffffff8b319be0,%rsi
  23:	48 89 df             	mov    %rbx,%rdi
  26:	e8 0b 01 fe ff       	callq  0xfffffffffffe0136
  2b:*	0f 0b                	ud2    		<-- trapping instruction
  2d:	48 c7 c7 e0 3b 52 8f 	mov    $0xffffffff8f523be0,%rdi
  34:	e8 5f 3b 9d 01       	callq  0x19d3b98
  39:	e8 b8 e2 ea ff       	callq  0xffffffffffeae2f6
  3e:	48 8b 00             	mov    (%rax),%rax

Code starting with the faulting instruction
===========================================
   0:	0f 0b                	ud2
   2:	48 c7 c7 e0 3b 52 8f 	mov    $0xffffffff8f523be0,%rdi
   9:	e8 5f 3b 9d 01       	callq  0x19d3b6d
   e:	e8 b8 e2 ea ff       	callq  0xffffffffffeae2cb
  13:	48 8b 00             	mov    (%rax),%rax
[  302.063233] RIP clear_pages_mlock (include/linux/page-flags.h:332 mm/mlock.c:82)
[  302.063233]  RSP <ffff8800c2a970e0>




Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
