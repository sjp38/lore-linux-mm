Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1E78E6B0033
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 06:46:56 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id m4so16093154pgc.23
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 03:46:56 -0800 (PST)
Received: from huawei.com (szxga04-in.huawei.com. [45.249.212.190])
        by mx.google.com with ESMTPS id b3si7727584pls.370.2017.11.27.03.46.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Nov 2017 03:46:54 -0800 (PST)
From: guoxuenan <guoxuenan@huawei.com>
Subject: [PATCH] mm,madvise: bugfix of madvise systemcall infinite loop under special circumstances.
Date: Mon, 27 Nov 2017 19:53:18 +0800
Message-ID: <20171127115318.911-1-guoxuenan@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@suse.com, minchan@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: yi.zhang@huawei.com, miaoxie@huawei.com, rppt@linux.vnet.ibm.com, shli@fb.com, aarcange@redhat.com, mgorman@techsingularity.net, kirill.shutemov@linux.intel.com, rientjes@google.com, khandual@linux.vnet.ibm.com, riel@redhat.com

From: chenjie <chenjie6@huawei.com>

The madvise() system call supported a set of "conventional" advice values,
the MADV_WILLNEED parameter has possibility of triggering an infinite loop under
direct access mode(DAX).

Infinite loop situation:
1a??initial state [ start = vam->vm_start < vam->vm_end < end ].
2a??madvise_vma() using MADV_WILLNEED parameter;
   madvise_vma() -> madvise_willneed() -> return 0 && the value of [prev] is not updated.

In function SYSCALL_DEFINE3(madvise,...)
When [start = vam->vm_start] the program enters "for" loop,
find_vma_prev() will set the pointer vma and the pointer prev(prev = vam->vm_prev).
Normally ,madvise_vma() will always move the pointer prev ,but when use DAX mode,
it will never update the value of [prev].

=======================================================================
SYSCALL_DEFINE3(madvise,...)
{
	[...]
	//start = vam->start  => prev=vma->prev
    vma = find_vma_prev(current->mm, start, &prev);
	[...]
	for(;;)
	{
	      update [start = vma->vm_start]

	con0: if (start >= end)                 //false always;
	    goto out;
	       tmp = vma->vm_end;

	//do not update [prev] and always return 0;
	       error = madvise_willneed();

	con1: if (error)                        //false always;
	    goto out;

	//[ vam->vm_start < start = vam->vm_end  <end ]
	       update [start = tmp ]

	con2: if (start >= end)                 //false always ;
	    goto out;

	//because of pointer [prev] did not change,[vma] keep as it was;
	       update [ vma = prev->vm_next ]
	}
	[...]
}
=======================================================================
After the first cycle ;it will always keep
vam->vm_start < start = vam->vm_end  < end  && vma = prev->vm_next;
since Circulation exit conditions (con{0,1,2}) will never meet ,the
program stuck in infinite loop.

Signed-off-by: chenjie <chenjie6@huawei.com>
Signed-off-by: guoxuenan <guoxuenan@huawei.com>
---
 mm/madvise.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/mm/madvise.c b/mm/madvise.c
index 375cf32..751e97a 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -276,15 +276,14 @@ static long madvise_willneed(struct vm_area_struct *vma,
 {
 	struct file *file = vma->vm_file;
 
+	*prev = vma;
 #ifdef CONFIG_SWAP
 	if (!file) {
-		*prev = vma;
 		force_swapin_readahead(vma, start, end);
 		return 0;
 	}
 
 	if (shmem_mapping(file->f_mapping)) {
-		*prev = vma;
 		force_shm_swapin_readahead(vma, start, end,
 					file->f_mapping);
 		return 0;
@@ -299,7 +298,6 @@ static long madvise_willneed(struct vm_area_struct *vma,
 		return 0;
 	}
 
-	*prev = vma;
 	start = ((start - vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
 	if (end > vma->vm_end)
 		end = vma->vm_end;
-- 
2.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
