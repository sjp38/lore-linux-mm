Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 192066B005A
	for <linux-mm@kvack.org>; Wed, 19 Sep 2012 10:19:00 -0400 (EDT)
From: Haggai Eran <haggaie@mellanox.com>
Subject: [PATCH] mm: call invalidate_range_end in do_wp_page even for zero pages
Date: Wed, 19 Sep 2012 17:18:37 +0300
Message-Id: <1348064317-9943-1-git-send-email-haggaie@mellanox.com>
In-Reply-To: <5058CE2F.7030302@suse.cz>
References: <5058CE2F.7030302@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Slaby <jslaby@suse.cz>
Cc: linux-kernel@vger.kernel.org, kvm@vger.kernel.org, linux-mm@kvack.org, Shachar Raindel <raindel@mellanox.com>, Haggai Eran <haggaie@mellanox.com>, Avi Kivity <avi@redhat.com>, Andrew Morton <akpm@linux-foundation.org>

The previous patch "mm: wrap calls to set_pte_at_notify with
invalidate_range_start and invalidate_range_end" only called the
invalidate_range_end mmu notifier function in do_wp_page when the new_page
variable wasn't NULL. This was done in order to only call invalidate_range_end
after invalidate_range_start was called. Unfortunately, there are situations
where new_page is NULL and invalidate_range_start is called. This caused
invalidate_range_start to be called without a matching invalidate_range_end,
causing kvm to loop indefinitely on the first page fault.

This patch adds a flag variable to do_wp_page that marks whether the
invalidate_range_start notifier was called. invalidate_range_end is then
called if the flag is true.

Reported-by: Jiri Slaby <jslaby@suse.cz>
Cc: Avi Kivity <avi@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Haggai Eran <haggaie@mellanox.com>
---
I tested this patch against yesterday's linux-next (next-20120918), and it
seems to solve the problem with kvm. I used the same command line you reported:

  qemu-kvm -k en-us -usbdevice tablet -balloon virtio -hda IMAGE -smp 2 \
  -m 1000M -net user -net nic,model=e1000 -usb -serial pty

I was hoping you could also test it yourself, and see that it also works for
you, if you don't mind.

 mm/memory.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 1a92d87..76ec199 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2529,6 +2529,7 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	struct page *dirty_page = NULL;
 	unsigned long mmun_start;	/* For mmu_notifiers */
 	unsigned long mmun_end;		/* For mmu_notifiers */
+	bool mmun_called = false;	/* For mmu_notifiers */
 
 	old_page = vm_normal_page(vma, address, orig_pte);
 	if (!old_page) {
@@ -2706,8 +2707,9 @@ gotten:
 	if (mem_cgroup_newpage_charge(new_page, mm, GFP_KERNEL))
 		goto oom_free_new;
 
-	mmun_start = address & PAGE_MASK;
-	mmun_end   = (address & PAGE_MASK) + PAGE_SIZE;
+	mmun_start  = address & PAGE_MASK;
+	mmun_end    = (address & PAGE_MASK) + PAGE_SIZE;
+	mmun_called = true;
 	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
 
 	/*
@@ -2776,8 +2778,7 @@ gotten:
 		page_cache_release(new_page);
 unlock:
 	pte_unmap_unlock(page_table, ptl);
-	if (new_page)
-		/* Only call the end notifier if the begin was called. */
+	if (mmun_called)
 		mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
 	if (old_page) {
 		/*
-- 
1.7.11.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
