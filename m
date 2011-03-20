Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 66E4B8D0039
	for <linux-mm@kvack.org>; Sun, 20 Mar 2011 01:30:47 -0400 (EDT)
Received: from wpaz9.hot.corp.google.com (wpaz9.hot.corp.google.com [172.24.198.73])
	by smtp-out.google.com with ESMTP id p2K5Uk4g008821
	for <linux-mm@kvack.org>; Sat, 19 Mar 2011 22:30:46 -0700
Received: from iwc10 (iwc10.prod.google.com [10.241.65.138])
	by wpaz9.hot.corp.google.com with ESMTP id p2K5Uetf001813
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sat, 19 Mar 2011 22:30:45 -0700
Received: by iwc10 with SMTP id 10so5212814iwc.10
        for <linux-mm@kvack.org>; Sat, 19 Mar 2011 22:30:40 -0700 (PDT)
Date: Sat, 19 Mar 2011 22:30:28 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH] shmem: let shared anonymous be nonlinear again
Message-ID: <alpine.LSU.2.00.1103192227570.1659@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Kenny Simpson <theonetruekenny@yahoo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Up to 2.6.22, you could use remap_file_pages(2) on a tmpfs file or a
shared mapping of /dev/zero or a shared anonymous mapping.  In 2.6.23
we disabled it by default, but set VM_CAN_NONLINEAR to enable it on
safe mappings.  We made sure to set it in shmem_mmap() for tmpfs files,
but missed it in shmem_zero_setup() for the others.  Fix that at last.

Reported-by: Kenny Simpson <theonetruekenny@yahoo.com>
Signed-off-by: Hugh Dickins <hughd@google.com>
---

 mm/shmem.c |    1 +
 1 file changed, 1 insertion(+)

--- 2.6.38/mm/shmem.c	2011-03-14 18:20:32.000000000 -0700
+++ linux/mm/shmem.c	2011-03-19 15:09:26.000000000 -0700
@@ -2791,5 +2791,6 @@ int shmem_zero_setup(struct vm_area_stru
 		fput(vma->vm_file);
 	vma->vm_file = file;
 	vma->vm_ops = &shmem_vm_ops;
+	vma->vm_flags |= VM_CAN_NONLINEAR;
 	return 0;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
