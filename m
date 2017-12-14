Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id ECB0F6B0253
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 05:55:36 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id d76so2328368oig.12
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 02:55:36 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l11si1256401otc.257.2017.12.14.02.55.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Dec 2017 02:55:35 -0800 (PST)
From: "Yan, Zheng" <zyan@redhat.com>
Subject: [PATCH] mm: save/restore current->journal_info in handle_mm_fault
Date: Thu, 14 Dec 2017 18:55:27 +0800
Message-Id: <20171214105527.5885-1-zyan@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, ceph-devel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org
Cc: viro@zeniv.linux.org.uk, jlayton@redhat.com, "Yan, Zheng" <zyan@redhat.com>, stable@vger.kernel.org

We recently got an Oops report:

BUG: unable to handle kernel NULL pointer dereference at (null)
IP: jbd2__journal_start+0x38/0x1a2
[...]
Call Trace:
  ext4_page_mkwrite+0x307/0x52b
  _ext4_get_block+0xd8/0xd8
  do_page_mkwrite+0x6e/0xd8
  handle_mm_fault+0x686/0xf9b
  mntput_no_expire+0x1f/0x21e
  __do_page_fault+0x21d/0x465
  dput+0x4a/0x2f7
  page_fault+0x22/0x30
  copy_user_generic_string+0x2c/0x40
  copy_page_to_iter+0x8c/0x2b8
  generic_file_read_iter+0x26e/0x845
  timerqueue_del+0x31/0x90
  ceph_read_iter+0x697/0xa33 [ceph]
  hrtimer_cancel+0x23/0x41
  futex_wait+0x1c8/0x24d
  get_futex_key+0x32c/0x39a
  __vfs_read+0xe0/0x130
  vfs_read.part.1+0x6c/0x123
  handle_mm_fault+0x831/0xf9b
  __fget+0x7e/0xbf
  SyS_read+0x4d/0xb5

ceph_read_iter() uses current->journal_info to pass context info to
ceph_readpages(). Because ceph_readpages() needs to know if its caller
has already gotten capability of using page cache (distinguish read
from readahead/fadvise). ceph_read_iter() set current->journal_info,
then calls generic_file_read_iter().

In above Oops, page fault happened when copying data to userspace.
Page fault handler called ext4_page_mkwrite(). Ext4 code read
current->journal_info and assumed it is journal handle.

I checked other filesystems, btrfs probably suffers similar problem
for its readpage. (page fault happens when write() copies data from
userspace memory and the memory is mapped to a file in btrfs.
verify_parent_transid() can be called during readpage)

Cc: stable@vger.kernel.org
Signed-off-by: "Yan, Zheng" <zyan@redhat.com>
---
 mm/memory.c | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/mm/memory.c b/mm/memory.c
index a728bed16c20..db2a50233c49 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -4044,6 +4044,7 @@ int handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
 		unsigned int flags)
 {
 	int ret;
+	void *old_journal_info;
 
 	__set_current_state(TASK_RUNNING);
 
@@ -4065,11 +4066,24 @@ int handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
 	if (flags & FAULT_FLAG_USER)
 		mem_cgroup_oom_enable();
 
+	/*
+	 * Fault can happen when filesystem A's read_iter()/write_iter()
+	 * copies data to/from userspace. Filesystem A may have set
+	 * current->journal_info. If the userspace memory is MAP_SHARED
+	 * mapped to a file in filesystem B, we later may call filesystem
+	 * B's vm operation. Filesystem B may also want to read/set
+	 * current->journal_info.
+	 */
+	old_journal_info = current->journal_info;
+	current->journal_info = NULL;
+
 	if (unlikely(is_vm_hugetlb_page(vma)))
 		ret = hugetlb_fault(vma->vm_mm, vma, address, flags);
 	else
 		ret = __handle_mm_fault(vma, address, flags);
 
+	current->journal_info = old_journal_info;
+
 	if (flags & FAULT_FLAG_USER) {
 		mem_cgroup_oom_disable();
 		/*
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
