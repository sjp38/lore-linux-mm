Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id C1C726B007E
	for <linux-mm@kvack.org>; Mon, 18 Apr 2016 11:07:10 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id u190so333799220pfb.0
        for <linux-mm@kvack.org>; Mon, 18 Apr 2016 08:07:10 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id t56si12874229ott.0.2016.04.18.08.07.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Apr 2016 08:07:09 -0700 (PDT)
Subject: Re: [PATCH] mm: __delete_from_page_cache show Bad page if mapped
References: <alpine.LSU.2.11.1602282042110.1472@eggly.anvils>
 <20160229095216.GA9616@node.shutemov.name>
 <alpine.LSU.2.11.1602292217070.7377@eggly.anvils>
 <alpine.LSU.2.11.1602292244320.7377@eggly.anvils>
From: Sasha Levin <sasha.levin@oracle.com>
Message-ID: <5714F813.2090506@oracle.com>
Date: Mon, 18 Apr 2016 11:06:59 -0400
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1602292244320.7377@eggly.anvils>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Sasha Levin <sasha.levin@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 03/01/2016 01:45 AM, Hugh Dickins wrote:
> Commit e1534ae95004 ("mm: differentiate page_mapped() from page_mapcount()
> for compound pages") changed the famous BUG_ON(page_mapped(page)) in
> __delete_from_page_cache() to VM_BUG_ON_PAGE(page_mapped(page)): which
> gives us more info when CONFIG_DEBUG_VM=y, but nothing at all when not.
> 
> Although it has not usually been very helpul, being hit long after the
> error in question, we do need to know if it actually happens on users'
> systems; but reinstating a crash there is likely to be opposed :)
> 
> In the non-debug case, pr_alert("BUG: Bad page cache") plus dump_page(),
> dump_stack(), add_taint() - I don't really believe LOCKDEP_NOW_UNRELIABLE,
> but that seems to be the standard procedure now.  Move that, or the
> VM_BUG_ON_PAGE(), up before the deletion from tree: so that the
> unNULLified page->mapping gives a little more information.
> 
> If the inode is being evicted (rather than truncated), it won't have
> any vmas left, so it's safe(ish) to assume that the raised mapcount is
> erroneous, and we can discount it from page_count to avoid leaking the
> page (I'm less worried by leaking the occasional 4kB, than losing a
> potential 2MB page with each 4kB page leaked).
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>
> ---
> I think this should go into v4.5, so I've written it with an atomic_sub
> on page->_count; Joonsoo has noticed, and kindly agreed to page_ref'ify
> it for mmotm after it's merged.

Hey Hugh,

I seem to be hitting this while fuzzing:

[  817.413969] BUG: Bad rss-counter state mm:ffff8801b2a1d000 idx:0 val:1
[  817.413974] BUG: Bad rss-counter state mm:ffff8801b2a1d000 idx:1 val:2
[  817.413977] BUG: non-zero nr_ptes on freeing mm: 2
[  817.606318] page:ffffea0002fb6cc0 count:3 mapcount:1 mapping:ffff8801b58129e8 index:0x0
[  817.606328] flags: 0x1fffff8000002d(locked|referenced|uptodate|lru)
[  817.606333] page dumped because: VM_BUG_ON_PAGE(page_mapped(page))
[  817.606336] page->mem_cgroup:ffff8801d1ce1be0
[  817.606489] ------------[ cut here ]------------
[  817.606493] kernel BUG at mm/filemap.c:196!
[  817.606509] invalid opcode: 0000 [#1] PREEMPT SMP KASAN
[  817.606519] Modules linked in:
[  817.606529] CPU: 0 PID: 23148 Comm: modprobe Tainted: G    B           4.6.0-rc3-next-20160412-sasha-00023-g0b02d6d-dirty #2998
[  817.606535] task: ffff8801acc31000 ti: ffff8801acc38000 task.ti: ffff8801acc38000
[  817.606573] RIP: __delete_from_page_cache (mm/filemap.c:196 (discriminator 1))
[  817.606577] RSP: 0000:ffff8801acc3f660  EFLAGS: 00010082
[  817.606582] RAX: 0000000000000000 RBX: ffffea0002fb6cc0 RCX: 0000000000000000
[  817.606586] RDX: 0000000000000000 RSI: 0000000000000082 RDI: ffffed0035987eb2
[  817.606591] RBP: ffff8801acc3f7a0 R08: ffff8801d3ddfbf7 R09: ffff8801d3ddfbf5
[  817.606596] R10: 000000000013000d R11: 00000000e949c223 R12: ffff8801b58129e8
[  817.606601] R13: ffff8800c7296620 R14: ffff8801acc3f778 R15: ffffea0002b298a0
[  817.606612] FS:  00007f5159f41700(0000) GS:ffff8801d4200000(0000) knlGS:0000000000000000
[  817.606617] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  817.606622] CR2: 000055c523664d20 CR3: 00000001c28ec000 CR4: 00000000000406f0
[  817.606629] Stack:
[  817.606638]  ffff8800cb5d43c0 0000000000000282 1ffff10035987ed3 ffffea0002fb6cc8
[  817.606646]  ffff8801acc31000 ffffea0002fb6ce0 0000000000000000 0000000041b58ab3
[  817.606654]  ffffffffa967ddb8 ffffffff9d637a20 ffffffff9d3e26e0 0000000000000000
[  817.606655] Call Trace:
[  817.606717] delete_from_page_cache (include/linux/spinlock.h:362 mm/filemap.c:264)
[  817.606726] truncate_inode_page (mm/truncate.c:165)
[  817.606735] truncate_inode_pages_range (mm/truncate.c:290)
[  817.606817] truncate_inode_pages_final (mm/truncate.c:447)
[  817.606826] v9fs_evict_inode (fs/9p/vfs_inode.c:455)
[  817.606837] evict (fs/inode.c:548)
[  817.606855] iput (fs/inode.c:1483 fs/inode.c:1510)
[  817.606872] __dentry_kill (fs/dcache.c:345 fs/dcache.c:532)
[  817.606917] dput (fs/dcache.c:786)
[  817.606938] __fput (fs/file_table.c:227)
[  817.606947] ____fput (fs/file_table.c:245)
[  817.606958] task_work_run (kernel/task_work.c:117 (discriminator 1))
[  817.606969] do_exit (kernel/exit.c:749)
[  817.607031] do_group_exit (kernel/exit.c:862)
[  817.607048] SyS_exit_group (kernel/exit.c:889)
[  817.607056] do_syscall_64 (arch/x86/entry/common.c:350)
[  817.607076] entry_SYSCALL64_slow_path (arch/x86/entry/entry_64.S:251)
[ 817.607151] Code: e7 e8 8c 7d 19 00 e8 97 6f f6 ff 48 89 df e8 af 00 07 00 84 c0 74 22 e8 86 6f f6 ff 48 c7 c6 c0 5f 30 a7 48 89 df e8 87 8d 09 00 <0f> 0b 48 c7 c7 60 3a 42
ab e8 cb c7 a8 01 e8 64 6f f6 ff 48 8b
All code
========
   0:   e7 e8                   out    %eax,$0xe8
   2:   8c 7d 19                mov    %?,0x19(%rbp)
   5:   00 e8                   add    %ch,%al
   7:   97                      xchg   %eax,%edi
   8:   6f                      outsl  %ds:(%rsi),(%dx)
   9:   f6 ff                   idiv   %bh
   b:   48 89 df                mov    %rbx,%rdi
   e:   e8 af 00 07 00          callq  0x700c2
  13:   84 c0                   test   %al,%al
  15:   74 22                   je     0x39
  17:   e8 86 6f f6 ff          callq  0xfffffffffff66fa2
  1c:   48 c7 c6 c0 5f 30 a7    mov    $0xffffffffa7305fc0,%rsi
  23:   48 89 df                mov    %rbx,%rdi
  26:   e8 87 8d 09 00          callq  0x98db2
  2b:*  0f 0b                   ud2             <-- trapping instruction
  2d:   48 c7 c7 60 3a 42 ab    mov    $0xffffffffab423a60,%rdi
  34:   e8 cb c7 a8 01          callq  0x1a8c804
  39:   e8 64 6f f6 ff          callq  0xfffffffffff66fa2
  3e:   48 8b 00                mov    (%rax),%rax

Code starting with the faulting instruction
===========================================
   0:   0f 0b                   ud2
   2:   48 c7 c7 60 3a 42 ab    mov    $0xffffffffab423a60,%rdi
   9:   e8 cb c7 a8 01          callq  0x1a8c7d9
   e:   e8 64 6f f6 ff          callq  0xfffffffffff66f77
  13:   48 8b 00                mov    (%rax),%rax
[  817.607160] RIP __delete_from_page_cache (mm/filemap.c:196 (discriminator 1))
[  817.607162]  RSP <ffff8801acc3f660>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
