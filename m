Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 64E166B004D
	for <linux-mm@kvack.org>; Tue, 10 Nov 2009 11:58:16 -0500 (EST)
Subject: [PATCH] prevent deadlock in __unmap_hugepage_range() when
	alloc_huge_page() fails.
From: Larry Woodman <lwoodman@redhat.com>
Content-Type: multipart/mixed; boundary="=-OO+By7Lz7MYtHsqpzyd2"
Date: Tue, 10 Nov 2009 12:00:56 -0500
Message-Id: <1257872456.3227.2.camel@dhcp-100-19-198.bos.redhat.com>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


--=-OO+By7Lz7MYtHsqpzyd2
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


hugetlb_fault() takes the mm->page_table_lock spinlock then calls
hugetlb_cow().  If the alloc_huge_page() in hugetlb_cow() fails due to
an insufficient huge page pool it calls unmap_ref_private() with the
mm->page_table_lock held.  unmap_ref_private() then calls
unmap_hugepage_range() which tries to acquire the mm->page_table_lock.


[<ffffffff810928c3>] print_circular_bug_tail+0x80/0x9f 
 [<ffffffff8109280b>] ? check_noncircular+0xb0/0xe8
 [<ffffffff810935e0>] __lock_acquire+0x956/0xc0e
 [<ffffffff81093986>] lock_acquire+0xee/0x12e
 [<ffffffff8111a7a6>] ? unmap_hugepage_range+0x3e/0x84
 [<ffffffff8111a7a6>] ? unmap_hugepage_range+0x3e/0x84
 [<ffffffff814c348d>] _spin_lock+0x40/0x89
 [<ffffffff8111a7a6>] ? unmap_hugepage_range+0x3e/0x84
 [<ffffffff8111afee>] ? alloc_huge_page+0x218/0x318
 [<ffffffff8111a7a6>] unmap_hugepage_range+0x3e/0x84
 [<ffffffff8111b2d0>] hugetlb_cow+0x1e2/0x3f4
 [<ffffffff8111b935>] ? hugetlb_fault+0x453/0x4f6
 [<ffffffff8111b962>] hugetlb_fault+0x480/0x4f6
 [<ffffffff8111baee>] follow_hugetlb_page+0x116/0x2d9
 [<ffffffff814c31a7>] ? _spin_unlock_irq+0x3a/0x5c
 [<ffffffff81107b4d>] __get_user_pages+0x2a3/0x427
 [<ffffffff81107d0f>] get_user_pages+0x3e/0x54
 [<ffffffff81040b8b>] get_user_pages_fast+0x170/0x1b5
 [<ffffffff81160352>] dio_get_page+0x64/0x14a
 [<ffffffff8116112a>] __blockdev_direct_IO+0x4b7/0xb31
 [<ffffffff8115ef91>] blkdev_direct_IO+0x58/0x6e
 [<ffffffff8115e0a4>] ? blkdev_get_blocks+0x0/0xb8
 [<ffffffff810ed2c5>] generic_file_aio_read+0xdd/0x528
 [<ffffffff81219da3>] ? avc_has_perm+0x66/0x8c
 [<ffffffff81132842>] do_sync_read+0xf5/0x146
 [<ffffffff8107da00>] ? autoremove_wake_function+0x0/0x5a
 [<ffffffff81211857>] ? security_file_permission+0x24/0x3a
 [<ffffffff81132fd8>] vfs_read+0xb5/0x126
 [<ffffffff81133f6b>] ? fget_light+0x5e/0xf8
 [<ffffffff81133131>] sys_read+0x54/0x8c
 [<ffffffff81011e42>] system_call_fastpath+0x16/0x1b

This can be fixed by dropping the mm->page_table_lock around the call 
to unmap_ref_private() if alloc_huge_page() fails, its dropped right below
in the normal path anyway:


diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 5d7601b..f4daef4 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1973,12 +1973,15 @@ retry_avoidcopy:
                 */
                if (outside_reserve) {
                        BUG_ON(huge_pte_none(pte));
+                       spin_unlock(&mm->page_table_lock);
                        if (unmap_ref_private(mm, vma, old_page, address)) {
+                               spin_lock(&mm->page_table_lock);
                                BUG_ON(page_count(old_page) != 1);
                                BUG_ON(huge_pte_none(pte));
                                goto retry_avoidcopy;
                        }
                        WARN_ON_ONCE(1);
+                       spin_lock(&mm->page_table_lock);
                }

                return -PTR_ERR(new_page);


Signed-off-by: Larry Woodman <lwooman@redhat.com>

--=-OO+By7Lz7MYtHsqpzyd2
Content-Disposition: attachment; filename=hugetlb_cow.diff
Content-Type: text/x-patch; name=hugetlb_cow.diff; charset=UTF-8
Content-Transfer-Encoding: 7bit

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 5d7601b..f4daef4 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1973,12 +1973,15 @@ retry_avoidcopy:
 		 */
 		if (outside_reserve) {
 			BUG_ON(huge_pte_none(pte));
+			spin_unlock(&mm->page_table_lock);
 			if (unmap_ref_private(mm, vma, old_page, address)) {
+				spin_lock(&mm->page_table_lock);
 				BUG_ON(page_count(old_page) != 1);
 				BUG_ON(huge_pte_none(pte));
 				goto retry_avoidcopy;
 			}
 			WARN_ON_ONCE(1);
+			spin_lock(&mm->page_table_lock);
 		}
 
 		return -PTR_ERR(new_page);

--=-OO+By7Lz7MYtHsqpzyd2--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
