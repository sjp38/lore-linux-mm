Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 77D376B0253
	for <linux-mm@kvack.org>; Mon, 16 Nov 2015 07:09:47 -0500 (EST)
Received: by wmvv187 with SMTP id v187so172863789wmv.1
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 04:09:46 -0800 (PST)
Received: from mail-wm0-x22e.google.com (mail-wm0-x22e.google.com. [2a00:1450:400c:c09::22e])
        by mx.google.com with ESMTPS id i26si25254262wmc.111.2015.11.16.04.09.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Nov 2015 04:09:46 -0800 (PST)
Received: by wmdw130 with SMTP id w130so108015792wmd.0
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 04:09:45 -0800 (PST)
From: Yigal Korman <yigal@plexistor.com>
Subject: [PATCH] mm, dax: fix DAX deadlocks (COW fault)
Date: Mon, 16 Nov 2015 14:09:15 +0200
Message-Id: <1447675755-5692-1-git-send-email-yigal@plexistor.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-nvdimm@lists.01.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, david@fromorbit.com, akpm@linux-foundation.org, Yigal Korman <yigal@plexistor.com>, Stable Tree <stable@vger.kernel.org>, Boaz Harrosh <boaz@plexistor.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <dchinner@redhat.com>, Jan Kara <jack@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>

DAX handling of COW faults has wrong locking sequence:
	dax_fault does i_mmap_lock_read
	do_cow_fault does i_mmap_unlock_write

Ross's commit[1] missed a fix[2] that Kirill added to Matthew's
commit[3].

Original COW locking logic was introduced by Matthew here[4].

This should be applied to v4.3 as well.

[1] 0f90cc6609c7 mm, dax: fix DAX deadlocks
[2] 52a2b53ffde6 mm, dax: use i_mmap_unlock_write() in do_cow_fault()
[3] 843172978bb9 dax: fix race between simultaneous faults
[4] 2e4cdab0584f mm: allow page fault handlers to perform the COW

Signed-off-by: Yigal Korman <yigal@plexistor.com>

Cc: Stable Tree <stable@vger.kernel.org>
Cc: Boaz Harrosh <boaz@plexistor.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Dave Chinner <dchinner@redhat.com>
Cc: Jan Kara <jack@suse.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>
---
 mm/memory.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index c716913..e5071af 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3015,9 +3015,9 @@ static int do_cow_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		} else {
 			/*
 			 * The fault handler has no page to lock, so it holds
-			 * i_mmap_lock for write to protect against truncate.
+			 * i_mmap_lock for read to protect against truncate.
 			 */
-			i_mmap_unlock_write(vma->vm_file->f_mapping);
+			i_mmap_unlock_read(vma->vm_file->f_mapping);
 		}
 		goto uncharge_out;
 	}
@@ -3031,9 +3031,9 @@ static int do_cow_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	} else {
 		/*
 		 * The fault handler has no page to lock, so it holds
-		 * i_mmap_lock for write to protect against truncate.
+		 * i_mmap_lock for read to protect against truncate.
 		 */
-		i_mmap_unlock_write(vma->vm_file->f_mapping);
+		i_mmap_unlock_read(vma->vm_file->f_mapping);
 	}
 	return ret;
 uncharge_out:
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
