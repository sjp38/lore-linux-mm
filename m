Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id BEEC26B0082
	for <linux-mm@kvack.org>; Thu, 12 Feb 2015 12:08:28 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id bj1so12696475pad.5
        for <linux-mm@kvack.org>; Thu, 12 Feb 2015 09:08:28 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id dt4si5811549pdb.34.2015.02.12.09.08.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 12 Feb 2015 09:08:27 -0800 (PST)
Message-ID: <54DCDDEE.5030501@oracle.com>
Date: Thu, 12 Feb 2015 12:07:58 -0500
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCHv3 14/24] thp: implement new split_huge_page()
References: <1423757918-197669-1-git-send-email-kirill.shutemov@linux.intel.com> <1423757918-197669-15-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1423757918-197669-15-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 02/12/2015 11:18 AM, Kirill A. Shutemov wrote:
> +void __get_page_tail(struct page *page);
>  static inline void get_page(struct page *page)
>  {
> -	struct page *page_head = compound_head(page);
> -	VM_BUG_ON_PAGE(atomic_read(&page_head->_count) <= 0, page);
> -	atomic_inc(&page_head->_count);
> +	if (unlikely(PageTail(page)))
> +		return __get_page_tail(page);
> +
> +	/*
> +	 * Getting a normal page or the head of a compound page
> +	 * requires to already have an elevated page->_count.
> +	 */
> +	VM_BUG_ON_PAGE(atomic_read(&page->_count) <= 0, page);

This BUG_ON seems to get hit:

[  612.180784] page:ffffea00004cb180 count:0 mapcount:0 mapping:          (null) index:0x2
[  612.188538] flags: 0x1fffff80000000()
[  612.190452] page dumped because: VM_BUG_ON_PAGE(atomic_read(&page->_count) <= 0)
[  612.195857] ------------[ cut here ]------------
[  612.196636] kernel BUG at include/linux/mm.h:463!
[  612.196636] invalid opcode: 0000 [#1] PREEMPT SMP KASAN
[  612.196636] Dumping ftrace buffer:
[  612.196636]    (ftrace buffer empty)
[  612.196636] Modules linked in:
[  612.196636] CPU: 21 PID: 16300 Comm: trinity-c99 Not tainted 3.19.0-next-20150212-sasha-00072-gdc1aa32 #1913
[  612.196636] task: ffff880012dbb000 ti: ffff880012df8000 task.ti: ffff880012df8000
[  612.196636] RIP: copy_page_range (include/linux/mm.h:463 mm/memory.c:921 mm/memory.c:971 mm/memory.c:993 mm/memory.c:1055)
[  612.196636] RSP: 0018:ffff880012dffad0  EFLAGS: 00010286
[  612.196636] RAX: dffffc0000000000 RBX: 00000000132c6100 RCX: 0000000000000000
[  612.196636] RDX: 1ffffd4000099637 RSI: 0000000000000000 RDI: ffffea00004cb1b8
[  612.196636] RBP: ffff880012dffc60 R08: 0000000000000001 R09: 0000000000000000
[  612.196636] R10: ffffffffa5875ce8 R11: 0000000000000001 R12: ffff880012df6630
[  612.196636] R13: ffff880711fe6630 R14: 00007f33954c6000 R15: 0000000000000010
[  612.196636] FS:  00007f33993b0700(0000) GS:ffff880712800000(0000) knlGS:0000000000000000
[  612.196636] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  612.196636] CR2: 00007f33993b06c8 CR3: 000000002ab33000 CR4: 00000000000007a0
[  612.196636] DR0: ffffffff80000fff DR1: 0000000000000000 DR2: 0000000000000000
[  612.196636] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000b1060a
[  612.196636] Stack:
[  612.196636]  ffffffffa1937460 0000000000000002 ffff880012dffb30 ffffffff944141f6
[  612.196636]  ffff880012df8010 0000000000000020 ffff880012dffbf0 0000000000000000
[  612.196636]  0000000008100073 1ffff100025bff7a ffff880012df1e50 1ffff100025bf002
[  612.196636] Call Trace:
[  612.196636] ? __lock_is_held (kernel/locking/lockdep.c:3518)
[  612.196636] ? apply_to_page_range (mm/memory.c:1002)
[  612.196636] ? __vma_link_rb (mm/mmap.c:633)
[  612.196636] ? anon_vma_fork (mm/rmap.c:351)
[  612.196636] copy_process (kernel/fork.c:470 kernel/fork.c:869 kernel/fork.c:923 kernel/fork.c:1395)
[  612.196636] ? __cleanup_sighand (kernel/fork.c:1196)
[  612.196636] do_fork (kernel/fork.c:1659)
[  612.196636] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2554 kernel/locking/lockdep.c:2601)
[  612.196636] ? fork_idle (kernel/fork.c:1636)
[  612.196636] ? syscall_trace_enter_phase2 (arch/x86/kernel/ptrace.c:1598)
[  612.196636] SyS_clone (kernel/fork.c:1748)
[  612.196636] stub_clone (arch/x86/kernel/entry_64.S:517)
[  612.196636] ? tracesys_phase2 (arch/x86/kernel/entry_64.S:422)
[ 612.196636] Code: ff df 48 89 f9 48 c1 e9 03 80 3c 11 00 0f 85 4c 04 00 00 48 8b 48 30 e9 fe f9 ff ff 48 c7 c6 40 34 f4 9e 48 89 c7 e8 0e ca fe ff <0f> 0b 0f 0b 48 89 c7 e8 12 2a ff ff e9 df fb ff ff 0f 0b 0f 0b
All code
========
   0:   ff df                   lcallq *<internal disassembler error>
   2:   48 89 f9                mov    %rdi,%rcx
   5:   48 c1 e9 03             shr    $0x3,%rcx
   9:   80 3c 11 00             cmpb   $0x0,(%rcx,%rdx,1)
   d:   0f 85 4c 04 00 00       jne    0x45f
  13:   48 8b 48 30             mov    0x30(%rax),%rcx
  17:   e9 fe f9 ff ff          jmpq   0xfffffffffffffa1a
  1c:   48 c7 c6 40 34 f4 9e    mov    $0xffffffff9ef43440,%rsi
  23:   48 89 c7                mov    %rax,%rdi
  26:   e8 0e ca fe ff          callq  0xfffffffffffeca39
  2b:*  0f 0b                   ud2             <-- trapping instruction
  2d:   0f 0b                   ud2
  2f:   48 89 c7                mov    %rax,%rdi
  32:   e8 12 2a ff ff          callq  0xffffffffffff2a49
  37:   e9 df fb ff ff          jmpq   0xfffffffffffffc1b
  3c:   0f 0b                   ud2
  3e:   0f 0b                   ud2
        ...

Code starting with the faulting instruction
===========================================
   0:   0f 0b                   ud2
   2:   0f 0b                   ud2
   4:   48 89 c7                mov    %rax,%rdi
   7:   e8 12 2a ff ff          callq  0xffffffffffff2a1e
   c:   e9 df fb ff ff          jmpq   0xfffffffffffffbf0
  11:   0f 0b                   ud2
  13:   0f 0b                   ud2
        ...
[  612.196636] RIP copy_page_range (include/linux/mm.h:463 mm/memory.c:921 mm/memory.c:971 mm/memory.c:993 mm/memory.c:1055)
[  612.196636]  RSP <ffff880012dffad0>


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
