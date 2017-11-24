Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 861656B0033
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 21:25:21 -0500 (EST)
Received: by mail-oi0-f70.google.com with SMTP id n16so9570948oig.19
        for <linux-mm@kvack.org>; Thu, 23 Nov 2017 18:25:21 -0800 (PST)
Received: from szxga04-in.huawei.com (szxga04-in.huawei.com. [45.249.212.190])
        by mx.google.com with ESMTPS id y32si2957274otb.419.2017.11.23.18.25.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 23 Nov 2017 18:25:20 -0800 (PST)
From: guoxuenan <guoxuenan@huawei.com>
Subject: [PATCH] mm,madvise: bugfix of madvise systemcall infinite loop under special circumstances.
Date: Fri, 24 Nov 2017 10:27:57 +0800
Message-ID: <20171124022757.4991-1-guoxuenan@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@suse.com, minchan@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: rppt@linux.vnet.ibm.com, hillf.zj@alibaba-inc.com, shli@fb.com, aarcange@redhat.com, mgorman@techsingularity.net, kirill.shutemov@linux.intel.com, rientjes@google.com, khandual@linux.vnet.ibm.com, riel@redhat.com

From: chenjie <chenjie6@huawei.com>

The madvise() system call supported a set of "conventional" advice values,
the MADV_WILLNEED parameter will trigger an infinite loop under direct
access mode(DAX). In DAX mode, the function madvise_vma() will return
directly without updating the pointer [prev].

For example:
Special circumstances:
1a??init [ start < vam->vm_start < vam->vm_end < end ]
2a??madvise_vma() using MADV_WILLNEED parameter ;
madvise_vma() -> madvise_willneed() -> return 0 && without updating [prev]

=======================================================================
in Function SYSCALL_DEFINE3(madvise,...)

for (;;)
{
//[first loop: start = vam->vm_start < vam->vm_end  <end ];
      update [start = vma->vm_start | end  ]

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

=======================================================================
After the first cycle ;it will always keep
[ vam->vm_start < start = vam->vm_end  < end ].
since Circulation exit conditions (con{0,1,2}) will never meet ,the
program stuck in infinite loop.

Signed-off-by: chenjie <chenjie6@huawei.com>
Signed-off-by: guoxuenan <guoxuenan@huawei.com>
---
 mm/madvise.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/madvise.c b/mm/madvise.c
index 21261ff..c355fee 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -294,6 +294,7 @@ static long madvise_willneed(struct vm_area_struct *vma,
 #endif
 
 	if (IS_DAX(file_inode(file))) {
+		*prev = vma;
 		/* no bad return value, but ignore advice */
 		return 0;
 	}
-- 
2.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
