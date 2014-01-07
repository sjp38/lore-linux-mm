Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f171.google.com (mail-ea0-f171.google.com [209.85.215.171])
	by kanga.kvack.org (Postfix) with ESMTP id C51236B0031
	for <linux-mm@kvack.org>; Tue,  7 Jan 2014 14:28:01 -0500 (EST)
Received: by mail-ea0-f171.google.com with SMTP id h10so402886eak.16
        for <linux-mm@kvack.org>; Tue, 07 Jan 2014 11:28:01 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id a9si929556eem.174.2014.01.07.11.27.59
        for <linux-mm@kvack.org>;
        Tue, 07 Jan 2014 11:28:00 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH] mm/memory-failure.c: shift page lock from head page to tail page after thp split
Date: Tue,  7 Jan 2014 14:27:36 -0500
Message-Id: <1389122856-11718-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-mm@kvack.org

After thp split in hwpoison_user_mappings(), we hold page lock on the raw
error page only between try_to_unmap, hence we are in danger of race condition.

I found in the RHEL7 MCE-relay testing that we have "bad page" error
when a memory error happens on a thp tail page used by qemu-kvm:

  Triggering MCE exception on CPU 10
  mce: [Hardware Error]: Machine check events logged
  MCE exception done on CPU 10
  MCE 0x38c535: Killing qemu-kvm:8418 due to hardware memory corruption
  MCE 0x38c535: dirty LRU page recovery: Recovered
  qemu-kvm[8418]: segfault at 20 ip 00007ffb0f0f229a sp 00007fffd6bc5240 error 4 in qemu-kvm[7ffb0ef14000+420000]
  BUG: Bad page state in process qemu-kvm  pfn:38c400
  page:ffffea000e310000 count:0 mapcount:0 mapping:          (null) index:0x7ffae3c00
  page flags: 0x2fffff0008001d(locked|referenced|uptodate|dirty|swapbacked)
  Modules linked in: hwpoison_inject mce_inject vhost_net macvtap macvlan ...
  CPU: 0 PID: 8418 Comm: qemu-kvm Tainted: G   M        --------------   3.10.0-54.0.1.el7.mce_test_fixed.x86_64 #1
  Hardware name: NEC NEC Express5800/R120b-1 [N8100-1719F]/MS-91E7-001, BIOS 4.6.3C19 02/10/2011
   000fffff00000000 ffff8802fc9239a0 ffffffff815b4cc0 ffff8802fc9239b8
   ffffffff815b072e 0000000000000000 ffff8802fc9239f8 ffffffff8113b918
   ffffea000e310000 ffffea000e310000 002fffff0008001d 0000000000000000
  Call Trace:
   [<ffffffff815b4cc0>] dump_stack+0x19/0x1b
   [<ffffffff815b072e>] bad_page.part.59+0xcf/0xe8
   [<ffffffff8113b918>] free_pages_prepare+0x148/0x160
   [<ffffffff8113c231>] free_hot_cold_page+0x31/0x140
   [<ffffffff8113c386>] free_hot_cold_page_list+0x46/0xa0
   [<ffffffff81141361>] release_pages+0x1c1/0x200
   [<ffffffff8116e47d>] free_pages_and_swap_cache+0xad/0xd0
   [<ffffffff8115850c>] tlb_flush_mmu.part.46+0x4c/0x90
   [<ffffffff81159045>] tlb_finish_mmu+0x55/0x60
   [<ffffffff81163e6b>] exit_mmap+0xcb/0x170
   [<ffffffff81055f87>] mmput+0x67/0xf0
   [<ffffffffa05c7451>] vhost_dev_cleanup+0x231/0x260 [vhost_net]
   [<ffffffffa05ca0df>] vhost_net_release+0x3f/0x90 [vhost_net]
   [<ffffffff8119f649>] __fput+0xe9/0x270
   [<ffffffff8119f8fe>] ____fput+0xe/0x10
   [<ffffffff8107b754>] task_work_run+0xc4/0xe0
   [<ffffffff8105e88b>] do_exit+0x2bb/0xa40
   [<ffffffff8106b0cc>] ? __dequeue_signal+0x13c/0x220
   [<ffffffff8105f08f>] do_group_exit+0x3f/0xa0
   [<ffffffff8106dcc0>] get_signal_to_deliver+0x1d0/0x6e0
   [<ffffffff81012408>] do_signal+0x48/0x5e0
   [<ffffffff8106ee48>] ? do_sigaction+0x88/0x1f0
   [<ffffffff81012a11>] do_notify_resume+0x71/0xc0
   [<ffffffff815bc53c>] retint_signal+0x48/0x8c

The reason of this bug is that a page fault happens before unlocking
the head page at the end of memory_failure().
This strange page fault is trying to access to address 0x20 and I'm not
sure why qemu-kvm does this, but anyway as a result the SIGSEGV makes
qemu-kvm exit and on the way we catch the bad page bug/warning because
we try to free a locked page (which was the former head page.)

To fix this, this patch suggests to shift page lock from head page to
tail page just after thp split. SIGSEGV still happens, but it affects
only error affected VMs, not a whole system.

Cc: <stable@vger.kernel.org>        [3.9+] # a3e0f9e47d5ef "mm/memory-failure.c: transfer page count from head page to tail page after split thp"
Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/memory-failure.c | 21 +++++++++++----------
 1 file changed, 11 insertions(+), 10 deletions(-)

diff --git v3.13-rc7.orig/mm/memory-failure.c v3.13-rc7/mm/memory-failure.c
index fabe55046c1d..6420be516073 100644
--- v3.13-rc7.orig/mm/memory-failure.c
+++ v3.13-rc7/mm/memory-failure.c
@@ -856,14 +856,14 @@ static int page_action(struct page_state *ps, struct page *p,
  * the pages and send SIGBUS to the processes if the data was dirty.
  */
 static int hwpoison_user_mappings(struct page *p, unsigned long pfn,
-				  int trapno, int flags)
+				  int trapno, int flags, struct page **hpagep)
 {
 	enum ttu_flags ttu = TTU_UNMAP | TTU_IGNORE_MLOCK | TTU_IGNORE_ACCESS;
 	struct address_space *mapping;
 	LIST_HEAD(tokill);
 	int ret;
 	int kill = 1, forcekill;
-	struct page *hpage = compound_head(p);
+	struct page *hpage = *hpagep;
 	struct page *ppage;
 
 	if (PageReserved(p) || PageSlab(p))
@@ -942,11 +942,14 @@ static int hwpoison_user_mappings(struct page *p, unsigned long pfn,
 			 * We pinned the head page for hwpoison handling,
 			 * now we split the thp and we are interested in
 			 * the hwpoisoned raw page, so move the refcount
-			 * to it.
+			 * to it. Similarly, page lock is shifted.
 			 */
 			if (hpage != p) {
 				put_page(hpage);
 				get_page(p);
+				lock_page(p);
+				unlock_page(hpage);
+				*hpagep = p;
 			}
 			/* THP is split, so ppage should be the real poisoned page. */
 			ppage = p;
@@ -964,17 +967,11 @@ static int hwpoison_user_mappings(struct page *p, unsigned long pfn,
 	if (kill)
 		collect_procs(ppage, &tokill);
 
-	if (hpage != ppage)
-		lock_page(ppage);
-
 	ret = try_to_unmap(ppage, ttu);
 	if (ret != SWAP_SUCCESS)
 		printk(KERN_ERR "MCE %#lx: failed to unmap page (mapcount=%d)\n",
 				pfn, page_mapcount(ppage));
 
-	if (hpage != ppage)
-		unlock_page(ppage);
-
 	/*
 	 * Now that the dirty bit has been propagated to the
 	 * struct page and all unmaps done we can decide if
@@ -1193,8 +1190,12 @@ int memory_failure(unsigned long pfn, int trapno, int flags)
 	/*
 	 * Now take care of user space mappings.
 	 * Abort on fail: __delete_from_page_cache() assumes unmapped page.
+	 *
+	 * When the raw error page is thp tail page, hpage points to the raw
+	 * page after thp split.
 	 */
-	if (hwpoison_user_mappings(p, pfn, trapno, flags) != SWAP_SUCCESS) {
+	if (hwpoison_user_mappings(p, pfn, trapno, flags, &hpage)
+	    != SWAP_SUCCESS) {
 		printk(KERN_ERR "MCE %#lx: cannot unmap page, give up\n", pfn);
 		res = -EBUSY;
 		goto out;
-- 
1.8.4.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
