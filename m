Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id E00A26B05FA
	for <linux-mm@kvack.org>; Wed,  2 Aug 2017 12:52:10 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id o65so24378744qkl.12
        for <linux-mm@kvack.org>; Wed, 02 Aug 2017 09:52:10 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 126si6991243qkj.540.2017.08.02.09.52.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Aug 2017 09:52:10 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 1/6] userfaultfd: hugetlbfs: remove superfluous page unlock in VM_SHARED case
Date: Wed,  2 Aug 2017 18:51:40 +0200
Message-Id: <20170802165145.22628-2-aarcange@redhat.com>
In-Reply-To: <20170802165145.22628-1-aarcange@redhat.com>
References: <20170802165145.22628-1-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Maxime Coquelin <maxime.coquelin@redhat.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Mike Kravetz <mike.kravetz@oracle.com>, Alexey Perevalov <a.perevalov@samsung.com>

huge_add_to_page_cache->add_to_page_cache implicitly unlock the page
before returning in case of errors.

The error returned was -EEXIST by running UFFDIO_COPY on a non-hole
offset of a VM_SHARED hugetlbfs mapping. It was an userland bug that
triggered it and the kernel must cope with it returning -EEXIST from
ioctl(UFFDIO_COPY) as expected.

page dumped because: VM_BUG_ON_PAGE(!PageLocked(page))
------------[ cut here ]------------
kernel BUG at mm/filemap.c:964!
invalid opcode: 0000 [#1] SMP
CPU: 1 PID: 22582 Comm: qemu-system-x86 Not tainted 4.11.11-300.fc26.x86_64 #1
task: ffff973131ab2600 task.stack: ffffacc0cba78000
RIP: 0010:unlock_page+0x4a/0x50
RSP: 0018:ffffacc0cba7bca0 EFLAGS: 00010246
RAX: 0000000000000036 RBX: fffff99d09f38000 RCX: 0000000000000006
RDX: 0000000000000000 RSI: 0000000000000000 RDI: ffff97326148e0c0
RBP: ffffacc0cba7bca0 R08: 00000000000006be R09: 0000000000000004
R10: 00000000000007ae R11: ffffffffb622cbed R12: 0000000000000008
R13: ffff972f9a265240 R14: ffff972de2919740 R15: ffffffffb62da820
FS:  00007f122efff700(0000) GS:ffff973261480000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007fd52f788ea8 CR3: 000000036d022000 CR4: 00000000003426e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
Call Trace:
 hugetlb_mcopy_atomic_pte+0xc0/0x320
 mcopy_atomic+0x96f/0xbe0
 userfaultfd_ioctl+0x218/0xe90
 ? __schedule+0x23c/0x8d0
 ? hrtimer_start_range_ns+0x1bd/0x330
 do_vfs_ioctl+0xa5/0x600
 ? do_vfs_ioctl+0xa5/0x600
 SyS_ioctl+0x79/0x90
 entry_SYSCALL_64_fastpath+0x1a/0xa9

Tested-by: Maxime Coquelin <maxime.coquelin@redhat.com>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/hugetlb.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index bc48ee783dd9..5a240c72c3b6 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -4062,9 +4062,9 @@ int hugetlb_mcopy_atomic_pte(struct mm_struct *dst_mm,
 	return ret;
 out_release_unlock:
 	spin_unlock(ptl);
-out_release_nounlock:
 	if (vm_shared)
 		unlock_page(page);
+out_release_nounlock:
 	put_page(page);
 	goto out;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
