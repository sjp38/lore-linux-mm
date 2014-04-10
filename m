From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: mm: kernel BUG at mm/huge_memory.c:1829!
Date: Thu, 10 Apr 2014 16:44:36 +0300
Message-ID: <20140410134436.GA25933@node.dhcp.inet.fi>
References: <53440991.9090001@oracle.com>
 <20140410102527.GA24111@node.dhcp.inet.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140410102527.GA24111@node.dhcp.inet.fi>
Sender: linux-kernel-owner@vger.kernel.org
To: Michel Lespinasse <walken@google.com>, Andrea Arcangeli <aarcange@redhat.com>
Cc: Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Jones <davej@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Bob Liu <lliubbo@gmail.com>
List-Id: linux-mm.kvack.org

On Thu, Apr 10, 2014 at 01:25:27PM +0300, Kirill A. Shutemov wrote:
> On Tue, Apr 08, 2014 at 10:37:05AM -0400, Sasha Levin wrote:
> > Hi all,
> > 
> > While fuzzing with trinity inside a KVM tools guest running the latest -next
> > kernel, I've stumbled on the following:
> > 
> > [ 1275.253114] kernel BUG at mm/huge_memory.c:1829!
> > [ 1275.253642] invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
> > [ 1275.254775] Dumping ftrace buffer:
> > [ 1275.255631]    (ftrace buffer empty)
> > [ 1275.256440] Modules linked in:
> > [ 1275.257347] CPU: 20 PID: 22807 Comm: trinity-c299 Not tainted 3.14.0-next-20140407-sasha-00023-gd35b0d6 #382
> > [ 1275.258686] task: ffff8803e7873000 ti: ffff8803e7896000 task.ti: ffff8803e7896000
> > [ 1275.259416] RIP: __split_huge_page (mm/huge_memory.c:1829 (discriminator 1))
> > [ 1275.260527] RSP: 0018:ffff8803e7897bb8  EFLAGS: 00010297
> > [ 1275.261323] RAX: 000000000000012c RBX: ffff8803e789d600 RCX: 0000000000000006
> > [ 1275.261323] RDX: 0000000000005b80 RSI: ffff8803e7873d00 RDI: 0000000000000282
> > [ 1275.261323] RBP: ffff8803e7897c68 R08: 0000000000000000 R09: 0000000000000000
> > [ 1275.261323] R10: 0000000000000001 R11: 30303320746e756f R12: 0000000000000000
> > [ 1275.261323] R13: 0000000000a00000 R14: ffff8803ede73000 R15: ffffea0010030000
> > [ 1275.261323] FS:  00007f899d23f700(0000) GS:ffff880437000000(0000) knlGS:0000000000000000
> > [ 1275.261323] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> > [ 1275.261323] CR2: 00000000024cf048 CR3: 00000003e787f000 CR4: 00000000000006a0
> > [ 1275.261323] DR0: 0000000000696000 DR1: 0000000000696000 DR2: 0000000000000000
> > [ 1275.261323] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000600
> > [ 1275.261323] Stack:
> > [ 1275.261323]  ffff8803e7897bd8 ffff880024dab898 ffff8803e7897bd8 ffffffffac1bea0e
> > [ 1275.261323]  ffff8803e7897c28 0000000000000282 00000014b06cc072 0000000000000000
> > [ 1275.261323]  0000012be7897c28 0000000000000a00 ffff880024dab8d0 ffff880024dab898
> > [ 1275.261323] Call Trace:
> > [ 1275.261323] ? put_lock_stats.isra.12 (arch/x86/include/asm/preempt.h:98 kernel/locking/lockdep.c:254)
> > [ 1275.261323] ? down_write (kernel/locking/rwsem.c:51 (discriminator 2))
> > [ 1275.261323] ? split_huge_page_to_list (mm/huge_memory.c:1874)
> > [ 1275.261323] split_huge_page_to_list (include/linux/vmstat.h:37 mm/huge_memory.c:1879)
> > [ 1275.261323] __split_huge_page_pmd (mm/huge_memory.c:2811)
> > [ 1275.261323] ? mutex_unlock (kernel/locking/mutex.c:220)
> > [ 1275.261323] ? __mutex_unlock_slowpath (arch/x86/include/asm/paravirt.h:809 kernel/locking/mutex.c:713 kernel/locking/mutex.c:722)
> > [ 1275.261323] ? get_parent_ip (kernel/sched/core.c:2471)
> > [ 1275.261323] ? preempt_count_sub (kernel/sched/core.c:2526)
> > [ 1275.261323] follow_page_mask (mm/memory.c:1518 (discriminator 1))
> > [ 1275.261323] SYSC_move_pages (mm/migrate.c:1227 mm/migrate.c:1353 mm/migrate.c:1508)
> > [ 1275.261323] ? SYSC_move_pages (include/linux/rcupdate.h:800 mm/migrate.c:1472)
> > [ 1275.261323] ? sched_clock_local (kernel/sched/clock.c:213)
> > [ 1275.261323] SyS_move_pages (mm/migrate.c:1456)
> > [ 1275.261323] tracesys (arch/x86/kernel/entry_64.S:749)
> > [ 1275.261323] Code: c0 01 39 45 94 74 18 41 8b 57 18 48 c7 c7 90 5e 6d b0 31 c0 8b 75 94 83 c2 01 e8 3d 6a 23 03 41 8b 47 18 83 c0 01 39 45 94 74 02 <0f> 0b 49 8b 07 48 89 c2 48 c1 e8 34 83 e0 03 48 c1 ea 36 4c 8d
> > [ 1275.261323] RIP __split_huge_page (mm/huge_memory.c:1829 (discriminator 1))
> > [ 1275.261323]  RSP <ffff8803e7897bb8>
> > 
> > Looking at the code, there was supposed to be a printk printing both
> > mapcounts if they're different. However, there was no matching entry
> > in the log for that.
> 
> We had the bug triggered a year ago[1] and I tried to ask whether it can
> caused by chaining the same_anon_vma list with interval tree[2].
> 
> It's not obvious for me how new implementation of anon rmap with interval
> tree guarantee behaviour of anon_vma_interval_tree_foreach() vs.
> anon_vma_interval_tree_insert() which __split_huge_page() expects.
> 
> Michel, could you clarify that?
> 
> [1] https://bugzilla.redhat.com/show_bug.cgi?id=923817
> [2] http://article.gmane.org/gmane.linux.kernel.mm/96518

Okay, below is my attempt to fix the bug. I'm not entirely sure it's
correct. Andrea, could you take a look?

I used this program to reproduce the issue:

#include <sys/mman.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/wait.h>
#include <stdio.h>

#define SIZE (2*1024*1024)

int main()
{
	char * x;

	for (;;) {
		x = mmap(NULL, SIZE+SIZE-4096, PROT_READ|PROT_WRITE,
				MAP_PRIVATE|MAP_ANONYMOUS, -1, 0);
		if (x == MAP_FAILED)
			perror("error"), exit(1);
		x[SIZE] = 0;
		if (!fork()) {
			_exit(0);
		}
		if (!fork()) {
			if (!fork()) {
				_exit(0);
			}
			mprotect(x + SIZE, 4096, PROT_NONE);
			_exit(0);
		}
		mprotect(x + SIZE, 4096, PROT_NONE);
		munmap(x, SIZE+SIZE-4096);
		while (waitpid(-1, NULL, WNOHANG) > 0);
	}
	return 0;
}

>From 1b3051b8613de3e55f1062ec0b8914d838e7c266 Mon Sep 17 00:00:00 2001
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Date: Thu, 10 Apr 2014 15:41:04 +0300
Subject: [PATCH] mm, thp: fix race between split huge page and insert into
 anon_vma tree

__split_huge_page() has assumption that iteration over anon_vma will
catch all VMAs the page belongs to. The assumption relies on new VMA to
be added to the tail of VMA list, so list_for_each_entry() can catch
them.

Commit bf181b9f9d8d has replaced same_anon_vma linked list with an
interval tree and, I believe, it breaks the assumption.

Let's retry walk over huge anon VMA tree if number of VMA we found
doesn't match with page_mapcount().

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Michel Lespinasse <walken@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/huge_memory.c | 28 +++++++++++++++-------------
 1 file changed, 15 insertions(+), 13 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 64635f5278ff..6d868a13ca3c 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1807,6 +1807,7 @@ static void __split_huge_page(struct page *page,
 	BUG_ON(PageTail(page));
 
 	mapcount = 0;
+retry:
 	anon_vma_interval_tree_foreach(avc, &anon_vma->rb_root, pgoff, pgoff) {
 		struct vm_area_struct *vma = avc->vma;
 		unsigned long addr = vma_address(page, vma);
@@ -1814,19 +1815,14 @@ static void __split_huge_page(struct page *page,
 		mapcount += __split_huge_page_splitting(page, vma, addr);
 	}
 	/*
-	 * It is critical that new vmas are added to the tail of the
-	 * anon_vma list. This guarantes that if copy_huge_pmd() runs
-	 * and establishes a child pmd before
-	 * __split_huge_page_splitting() freezes the parent pmd (so if
-	 * we fail to prevent copy_huge_pmd() from running until the
-	 * whole __split_huge_page() is complete), we will still see
-	 * the newly established pmd of the child later during the
-	 * walk, to be able to set it as pmd_trans_splitting too.
+	 * There's chance that iteration over interval tree will race with
+	 * insert to it. Let's try catch new entries by retrying.
 	 */
-	if (mapcount != page_mapcount(page))
-		printk(KERN_ERR "mapcount %d page_mapcount %d\n",
+	if (mapcount != page_mapcount(page)) {
+		printk(KERN_DEBUG "mapcount %d page_mapcount %d\n",
 		       mapcount, page_mapcount(page));
-	BUG_ON(mapcount != page_mapcount(page));
+		goto retry;
+	}
 
 	__split_huge_page_refcount(page, list);
 
@@ -1837,10 +1833,16 @@ static void __split_huge_page(struct page *page,
 		BUG_ON(is_vma_temporary_stack(vma));
 		mapcount2 += __split_huge_page_map(page, vma, addr);
 	}
-	if (mapcount != mapcount2)
+	/*
+	 * By the time __split_huge_page_refcount() called all PMDs should be
+	 * marked pmd_trans_splitting() and new mappings of the page shouldn't
+	 * be created or removed. If number of mappings is changed it's a BUG().
+	 */
+	if (mapcount != mapcount2) {
 		printk(KERN_ERR "mapcount %d mapcount2 %d page_mapcount %d\n",
 		       mapcount, mapcount2, page_mapcount(page));
-	BUG_ON(mapcount != mapcount2);
+		BUG();
+	}
 }
 
 /*
-- 
 Kirill A. Shutemov
