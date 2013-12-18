Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 50F036B0035
	for <linux-mm@kvack.org>; Wed, 18 Dec 2013 04:01:53 -0500 (EST)
Received: by mail-pd0-f178.google.com with SMTP id y10so7929982pdj.23
        for <linux-mm@kvack.org>; Wed, 18 Dec 2013 01:01:52 -0800 (PST)
Received: from e23smtp05.au.ibm.com (e23smtp05.au.ibm.com. [202.81.31.147])
        by mx.google.com with ESMTPS id pi8si13782499pac.175.2013.12.18.01.01.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 18 Dec 2013 01:01:51 -0800 (PST)
Received: from /spool/local
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Wed, 18 Dec 2013 19:01:42 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 400D82CE8055
	for <linux-mm@kvack.org>; Wed, 18 Dec 2013 20:01:39 +1100 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rBI91Lnp9830656
	for <linux-mm@kvack.org>; Wed, 18 Dec 2013 20:01:26 +1100
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rBI91X1f031861
	for <linux-mm@kvack.org>; Wed, 18 Dec 2013 20:01:33 +1100
Date: Wed, 18 Dec 2013 17:01:31 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm/mlock: fix BUG_ON unlocked page for nolinear VMAs
Message-ID: <52b1647f.c8da420a.1e7a.ffffbcb4SMTPIN_ADDED_BROKEN@mx.google.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1387267550-8689-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <52B162B8.6090507@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52B162B8.6090507@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>
Cc: Sasha Levin <sasha.levin@oracle.com>, Michel Lespinasse <walken@google.com>, Bob Liu <bob.liu@oracle.com>, npiggin@suse.de, kosaki.motohiro@jp.fujitsu.com, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Vlastimil,
On Wed, Dec 18, 2013 at 09:54:16AM +0100, Vlastimil Babka wrote:
>On 12/17/2013 09:05 AM, Wanpeng Li wrote:
>>objrmap doesn't work for nonlinear VMAs because the assumption that offset-into-file
>>correlates with offset-into-virtual-addresses does not hold. Hence what
>>try_to_unmap_cluster does is a mini "virtual scan" of each nonlinear VMA which maps
>>the file to which the target page belongs. If vma locked, mlock the pages in the
>>cluster, rather than unmapping them. However, not all pages are guarantee page
>>locked instead of the check page. This patch fix the BUG by just confirm check page
>>hold page lock instead of all pages in the virtual scan window against nolinear VMAs.
>
>This may fix the symptom, but I don't understand from the description
>why in this case is it ok not to have page locked for
>mlock_vma_page(), while in the other cases it's not ok.
>

Here is a latest version of the bugfix patch. 

http://marc.info/?l=linux-mm&m=138733994417230&w=2

Regards,
Wanpeng Li 

>>[  253.869145] kernel BUG at mm/mlock.c:82!
>>[  253.869549] invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
>>[  253.870098] Dumping ftrace buffer:
>>[  253.870098]    (ftrace buffer empty)
>>[  253.870098] Modules linked in:
>>[  253.870098] CPU: 10 PID: 9162 Comm: trinity-child75 Tainted: G        W    3.13.0-rc4-next-20131216-sasha-00011-g5f105ec-dirty #4137
>>[  253.873310] task: ffff8800c98cb000 ti: ffff8804d34e8000 task.ti: ffff8804d34e8000
>>[  253.873310] RIP: 0010:[<ffffffff81281f28>]  [<ffffffff81281f28>] mlock_vma_page+0x18/0xc0
>>[  253.873310] RSP: 0000:ffff8804d34e99e8  EFLAGS: 00010246
>>[  253.873310] RAX: 006fffff8038002c RBX: ffffea00474944c0 RCX: ffff880807636000
>>[  253.873310] RDX: ffffea0000000000 RSI: 00007f17a9bca000 RDI: ffffea00474944c0
>>[  253.873310] RBP: ffff8804d34e99f8 R08: ffff880807020000 R09: 0000000000000000
>>[  253.873310] R10: 0000000000000001 R11: 0000000000002000 R12: 00007f17a9bca000
>>[  253.873310] R13: ffffea00474944c0 R14: 00007f17a9be0000 R15: ffff880807020000
>>[  253.873310] FS:  00007f17aa31a700(0000) GS:ffff8801c9c00000(0000) knlGS:0000000000000000
>>[  253.873310] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
>>[  253.873310] CR2: 00007f17a94fa000 CR3: 00000004d3b02000 CR4: 00000000000006e0
>>[  253.873310] DR0: 00007f17a74ca000 DR1: 0000000000000000 DR2: 0000000000000000
>>[  253.873310] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000600
>>[  253.873310] Stack:
>>[  253.873310]  0000000b3de28067 ffff880b3de28e50 ffff8804d34e9aa8 ffffffff8128bc31
>>[  253.873310]  0000000000000301 ffffea0011850220 ffff8809a4039000 ffffea0011850238
>>[  253.873310]  ffff8804d34e9aa8 ffff880807636060 0000000000000001 ffff880807636348
>>[  253.873310] Call Trace:
>>[  253.873310]  [<ffffffff8128bc31>] try_to_unmap_cluster+0x1c1/0x340
>>[  253.873310]  [<ffffffff8128c60a>] try_to_unmap_file+0x20a/0x2e0
>>[  253.873310]  [<ffffffff8128c7b3>] try_to_unmap+0x73/0x90
>>[  253.873310]  [<ffffffff812b526d>] __unmap_and_move+0x18d/0x250
>>[  253.873310]  [<ffffffff812b53e9>] unmap_and_move+0xb9/0x180
>>[  253.873310]  [<ffffffff812b559b>] migrate_pages+0xeb/0x2f0
>>[  253.873310]  [<ffffffff812a0660>] ? queue_pages_pte_range+0x1a0/0x1a0
>>[  253.873310]  [<ffffffff812a193c>] migrate_to_node+0x9c/0xc0
>>[  253.873310]  [<ffffffff812a30b8>] do_migrate_pages+0x1b8/0x240
>>[  253.873310]  [<ffffffff812a3456>] SYSC_migrate_pages+0x316/0x380
>>[  253.873310]  [<ffffffff812a31ec>] ? SYSC_migrate_pages+0xac/0x380
>>[  253.873310]  [<ffffffff811763c6>] ? vtime_account_user+0x96/0xb0
>>[  253.873310]  [<ffffffff812a34ce>] SyS_migrate_pages+0xe/0x10
>>[  253.873310]  [<ffffffff843c4990>] tracesys+0xdd/0xe2
>>[  253.873310] Code: 0f 1f 00 65 48 ff 04 25 10 25 1d 00 48 83 c4 08
>>5b c9 c3 55 48 89 e5 53 48 83 ec 08 66 66 66 66 90 48 8b 07 48 89 fb
>>a8 01 75 10 <0f> 0b 66 0f 1f 44 00 00 eb fe 66 0f 1f 44 00 00 f0 0f ba
>>2f 15
>>[  253.873310] RIP  [<ffffffff81281f28>] mlock_vma_page+0x18/0xc0
>>[  253.873310]  RSP <ffff8804d34e99e8>
>>[  253.904194] ---[ end trace be59c4a7f8edab3f ]---
>>
>>Reported-by: Sasha Levin <sasha.levin@oracle.com>
>>Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
>>---
>>  mm/huge_memory.c | 2 +-
>>  mm/internal.h    | 4 ++--
>>  mm/ksm.c         | 2 +-
>>  mm/memory.c      | 2 +-
>>  mm/mlock.c       | 5 +++--
>>  mm/rmap.c        | 4 ++--
>>  6 files changed, 10 insertions(+), 9 deletions(-)
>>
>>diff --git a/mm/huge_memory.c b/mm/huge_memory.c
>>index 33a5dc4..7a15b04 100644
>>--- a/mm/huge_memory.c
>>+++ b/mm/huge_memory.c
>>@@ -1264,7 +1264,7 @@ struct page *follow_trans_huge_pmd(struct vm_area_struct *vma,
>>  		if (page->mapping && trylock_page(page)) {
>>  			lru_add_drain();
>>  			if (page->mapping)
>>-				mlock_vma_page(page);
>>+				mlock_vma_page(page, true);
>>  			unlock_page(page);
>>  		}
>>  	}
>>diff --git a/mm/internal.h b/mm/internal.h
>>index a85a3ab..4ea2d4e 100644
>>--- a/mm/internal.h
>>+++ b/mm/internal.h
>>@@ -192,7 +192,7 @@ static inline int mlocked_vma_newpage(struct vm_area_struct *vma,
>>  /*
>>   * must be called with vma's mmap_sem held for read or write, and page locked.
>>   */
>>-extern void mlock_vma_page(struct page *page);
>>+extern void mlock_vma_page(struct page *page, bool check_page);
>>  extern unsigned int munlock_vma_page(struct page *page);
>>
>>  /*
>>@@ -236,7 +236,7 @@ static inline int mlocked_vma_newpage(struct vm_area_struct *v, struct page *p)
>>  	return 0;
>>  }
>>  static inline void clear_page_mlock(struct page *page) { }
>>-static inline void mlock_vma_page(struct page *page) { }
>>+static inline void mlock_vma_page(struct page *page, bool check_page) { }
>>  static inline void mlock_migrate_page(struct page *new, struct page *old) { }
>>
>>  #endif /* !CONFIG_MMU */
>>diff --git a/mm/ksm.c b/mm/ksm.c
>>index 175fff7..ec36f04 100644
>>--- a/mm/ksm.c
>>+++ b/mm/ksm.c
>>@@ -1064,7 +1064,7 @@ static int try_to_merge_one_page(struct vm_area_struct *vma,
>>  		if (!PageMlocked(kpage)) {
>>  			unlock_page(page);
>>  			lock_page(kpage);
>>-			mlock_vma_page(kpage);
>>+			mlock_vma_page(kpage, true);
>>  			page = kpage;		/* for final unlock */
>>  		}
>>  	}
>>diff --git a/mm/memory.c b/mm/memory.c
>>index cf6098c..a41df6a 100644
>>--- a/mm/memory.c
>>+++ b/mm/memory.c
>>@@ -1602,7 +1602,7 @@ split_fallthrough:
>>  			 * know the page is still mapped, we don't even
>>  			 * need to check for file-cache page truncation.
>>  			 */
>>-			mlock_vma_page(page);
>>+			mlock_vma_page(page, true);
>>  			unlock_page(page);
>>  		}
>>  	}
>>diff --git a/mm/mlock.c b/mm/mlock.c
>>index d480cd6..c395ec5 100644
>>--- a/mm/mlock.c
>>+++ b/mm/mlock.c
>>@@ -77,9 +77,10 @@ void clear_page_mlock(struct page *page)
>>   * Mark page as mlocked if not already.
>>   * If page on LRU, isolate and putback to move to unevictable list.
>>   */
>>-void mlock_vma_page(struct page *page)
>>+void mlock_vma_page(struct page *page, bool check_page)
>>  {
>>-	BUG_ON(!PageLocked(page));
>>+	if (check_page)
>>+		BUG_ON(!PageLocked(page));
>>
>>  	if (!TestSetPageMlocked(page)) {
>>  		mod_zone_page_state(page_zone(page), NR_MLOCK,
>>diff --git a/mm/rmap.c b/mm/rmap.c
>>index 55c8b8d..79d456f 100644
>>--- a/mm/rmap.c
>>+++ b/mm/rmap.c
>>@@ -1297,7 +1297,7 @@ out_mlock:
>>  	 */
>>  	if (down_read_trylock(&vma->vm_mm->mmap_sem)) {
>>  		if (vma->vm_flags & VM_LOCKED) {
>>-			mlock_vma_page(page);
>>+			mlock_vma_page(page, true);
>>  			ret = SWAP_MLOCK;
>>  		}
>>  		up_read(&vma->vm_mm->mmap_sem);
>>@@ -1385,7 +1385,7 @@ static int try_to_unmap_cluster(unsigned long cursor, unsigned int *mapcount,
>>  		BUG_ON(!page || PageAnon(page));
>>
>>  		if (locked_vma) {
>>-			mlock_vma_page(page);   /* no-op if already mlocked */
>>+			mlock_vma_page(page, page == check_page);   /* no-op if already mlocked */
>>  			if (page == check_page)
>>  				ret = SWAP_MLOCK;
>>  			continue;	/* don't unmap */
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
