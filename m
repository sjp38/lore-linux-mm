Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f51.google.com (mail-ee0-f51.google.com [74.125.83.51])
	by kanga.kvack.org (Postfix) with ESMTP id D5CF66B00E0
	for <linux-mm@kvack.org>; Tue,  6 May 2014 04:43:39 -0400 (EDT)
Received: by mail-ee0-f51.google.com with SMTP id e51so1471989eek.10
        for <linux-mm@kvack.org>; Tue, 06 May 2014 01:43:39 -0700 (PDT)
Received: from jenni1.inet.fi (mta-out1.inet.fi. [62.71.2.198])
        by mx.google.com with ESMTP id n7si12720590eeu.109.2014.05.06.01.43.37
        for <linux-mm@kvack.org>;
        Tue, 06 May 2014 01:43:38 -0700 (PDT)
Date: Tue, 6 May 2014 11:43:33 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm, thp: close race between mremap() and
 split_huge_page()
Message-ID: <20140506084333.GA5575@node.dhcp.inet.fi>
References: <1399328011-15317-1-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1399328011-15317-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Dave Jones <davej@redhat.com>, stable@vger.kernel.org

On Tue, May 06, 2014 at 01:13:31AM +0300, Kirill A. Shutemov wrote:
> It's critical for split_huge_page() (and migration) to catch and freeze
> all PMDs on rmap walk. It gets tricky if there's concurrent fork() or
> mremap() since usually we copy/move page table entries on dup_mm() or
> move_page_tables() without rmap lock taken. To get it work we rely on
> rmap walk order to not miss any entry. We expect to see destination VMA
> after source one to work correctly.
> 
> But after switching rmap implementation to interval tree it's not always
> possible to preserve expected walk order.
> 
> It works fine for dup_mm() since new VMA has the same vma_start_pgoff()
> / vma_last_pgoff() and explicitly insert dst VMA after src one with
> vma_interval_tree_insert_after().
> 
> But on move_vma() destination VMA can be merged into adjacent one and as
> result shifted left in interval tree. Fortunately, we can detect the
> situation and prevent race with rmap walk by moving page table entries
> under rmap lock. See commit 38a76013ad80.
> 
> Problem is that we miss the lock when we move transhuge PMD. Most likely
> this bug caused the crash[1].
> 
> [1] http://thread.gmane.org/gmane.linux.kernel.mm/96473

It took a night but I was able to trigger crash which this patch fixes.

Test case:

#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/mman.h>
#include <sys/wait.h>

#define MB (1024UL*1024)
#define SIZE (4*MB)
#define BASE ((void *)0x400000000000)

int main()
{
	char *x1, *x2;

	for (;;) {
		x1 = mmap(BASE, 2 * SIZE, PROT_READ | PROT_WRITE,
			MAP_PRIVATE | MAP_ANONYMOUS | MAP_POPULATE | MAP_FIXED,
			-1, 0);
                if (x1 == MAP_FAILED)
                        perror("x1"), exit(1);
		x2 = mremap(x1 + SIZE, SIZE, SIZE,
				MREMAP_FIXED | MREMAP_MAYMOVE,
				x1 + 2 * SIZE);
                if (x2 == MAP_FAILED)
                        perror("x2"), exit(1);

		if (!fork())
			return 0;

		if (!fork()) {
			if (!fork())
				return 0;

			mprotect(x2, 4096, PROT_NONE);
			return 0;
		}

		x2 = mremap(x2, SIZE, SIZE,
				MREMAP_FIXED | MREMAP_MAYMOVE,
				x1 + SIZE);
		if (x2 == MAP_FAILED)
			perror("x2"), exit(1);
		munmap(x1, SIZE);
		munmap(x2, SIZE);
		while (waitpid(-1, NULL, WNOHANG) > 0);
	}
	return 0;
}

Crash:

[54438.764230] mapcount 2 page_mapcount 3
[54438.764985] ------------[ cut here ]------------
[54438.765735] kernel BUG at /home/space/kas/git/public/linux/mm/huge_memory.c:1836!
[54438.766926] invalid opcode: 0000 [#1] SMP 
[54438.767637] Modules linked in:
[54438.768078] CPU: 0 PID: 12638 Comm: test_split Not tainted 3.15.0-rc4-00001-gdb77ce6c9fe5-dirty #1282
[54438.768078] Hardware name: QEMU Standard PC (Q35 + ICH9, 2009), BIOS Bochs 01/01/2011
[54438.768078] task: ffff8804633c8410 ti: ffff88046376c000 task.ti: ffff88046376c000
[54438.768078] RIP: 0010:[<ffffffff81140594>]  [<ffffffff81140594>] split_huge_page_to_list+0x434/0x6c0
[54438.768078] RSP: 0018:ffff88046376dcc8  EFLAGS: 00010297
[54438.768078] RAX: 0000000000000003 RBX: ffff88046881c520 RCX: 0000000000000006
[54438.768078] RDX: 0000000000000006 RSI: ffff8804633c8b18 RDI: ffff8804633c8410
[54438.768078] RBP: ffff88046376dd30 R08: 0000000000000001 R09: 0000000000000000
[54438.768078] R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000000
[54438.768078] R13: 0000400000800000 R14: ffffea000ede4000 R15: 0000000400000400
[54438.768078] FS:  00007fea6a7be700(0000) GS:ffff88047fc00000(0000) knlGS:0000000000000000
[54438.768078] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[54438.768078] CR2: 00007fea6a2db7d0 CR3: 0000000469bdf000 CR4: 00000000001407f0
[54438.768078] Stack:
[54438.768078]  ffff8804698f4020 0000400000a00000 0000000000000000 ffff880467a04900
[54438.768078]  0000000000000000 ffff880467a04880 ffff880400000002 ffff880462b5ccf8
[54438.768078]  0000400000800000 ffff88046370ac50 ffff8804698f4020 0000400000a00000
[54438.768078] Call Trace:
[54438.768078]  [<ffffffff81141050>] __split_huge_page_pmd+0xc0/0x1f0
[54438.768078]  [<ffffffff8114196e>] split_huge_page_pmd_mm+0x3e/0x40
[54438.768078]  [<ffffffff81141995>] split_huge_page_address+0x25/0x30
[54438.768078]  [<ffffffff81141a3c>] __vma_adjust_trans_huge+0x9c/0xf0
[54438.768078]  [<ffffffff8132268d>] ? __rb_insert_augmented+0xcd/0x1f0
[54438.768078]  [<ffffffff81116f06>] vma_adjust+0x626/0x6a0
[54438.768078]  [<ffffffff811170ad>] __split_vma.isra.35+0x12d/0x200
[54438.768078]  [<ffffffff81117e94>] split_vma+0x24/0x30
[54438.768078]  [<ffffffff8111a3ca>] mprotect_fixup+0x22a/0x260
[54438.768078]  [<ffffffff8111a542>] SyS_mprotect+0x142/0x230
[54438.768078]  [<ffffffff8173cb62>] system_call_fastpath+0x16/0x1b
[54438.768078] Code: 0f 1f 80 00 00 00 00 0f 0b 66 0f 1f 44 00 00 0f 0b 66 0f 1f 44 00 00 0f 0b 66 0f 1f 44 00 00 0f 0b 0f 0b 0f 0b 0f 0b 0f 0b 0f 0b <0f> 0b 0f 0b 0f 0b 0f 0b 0f 0b 0f 0b 0f 0b 49 8b 16 4c 89 f0 80 
[54438.768078] RIP  [<ffffffff81140594>] split_huge_page_to_list+0x434/0x6c0
[54438.768078]  RSP <ffff88046376dcc8>
[54438.805154] ---[ end trace 12d4dde45cf392c6 ]---


-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
