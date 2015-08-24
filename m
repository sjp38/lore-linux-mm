Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 3B7B16B0253
	for <linux-mm@kvack.org>; Mon, 24 Aug 2015 17:25:57 -0400 (EDT)
Received: by pacdd16 with SMTP id dd16so105599496pac.2
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 14:25:57 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id b6si29393184pbu.118.2015.08.24.14.25.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Aug 2015 14:25:56 -0700 (PDT)
Date: Mon, 24 Aug 2015 14:25:55 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: mmap: Check all failures before set values
Message-Id: <20150824142555.76d9cf840dcbf8bbd9489b8c@linux-foundation.org>
In-Reply-To: <20150824113212.GL17078@dhcp22.suse.cz>
References: <1440349179-18304-1-git-send-email-gang.chen.5i5j@qq.com>
	<20150824113212.GL17078@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: gang.chen.5i5j@qq.com, kirill.shutemov@linux.intel.com, riel@redhat.com, sasha.levin@oracle.com, gang.chen.5i5j@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 24 Aug 2015 13:32:13 +0200 Michal Hocko <mhocko@kernel.org> wrote:

> On Mon 24-08-15 00:59:39, gang.chen.5i5j@qq.com wrote:
> > From: Chen Gang <gang.chen.5i5j@gmail.com>
> > 
> > When failure occurs and return, vma->vm_pgoff is already set, which is
> > not a good idea.
> 
> Why? The vma is not inserted anywhere and the failure path is supposed
> to simply free the vma.

Yes, it's pretty marginal but I suppose the code is a bit better with
the patch than without.  I did this:


From: Chen Gang <gang.chen.5i5j@gmail.com>
Subject: mm/mmap.c:insert_vm_struct(): check for failure before setting values

There's no point in initializing vma->vm_pgoff if the insertion attempt
will be failing anyway.  Run the checks before performing the initialization.

Signed-off-by: Chen Gang <gang.chen.5i5j@gmail.com>
Cc: Michal Hocko <mhocko@kernel.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/mmap.c |   13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff -puN mm/mmap.c~mm-mmap-check-all-failures-before-set-values mm/mmap.c
--- a/mm/mmap.c~mm-mmap-check-all-failures-before-set-values
+++ a/mm/mmap.c
@@ -2859,6 +2859,13 @@ int insert_vm_struct(struct mm_struct *m
 	struct vm_area_struct *prev;
 	struct rb_node **rb_link, *rb_parent;
 
+	if (find_vma_links(mm, vma->vm_start, vma->vm_end,
+			   &prev, &rb_link, &rb_parent))
+		return -ENOMEM;
+	if ((vma->vm_flags & VM_ACCOUNT) &&
+	     security_vm_enough_memory_mm(mm, vma_pages(vma)))
+		return -ENOMEM;
+
 	/*
 	 * The vm_pgoff of a purely anonymous vma should be irrelevant
 	 * until its first write fault, when page's anon_vma and index
@@ -2875,12 +2882,6 @@ int insert_vm_struct(struct mm_struct *m
 		BUG_ON(vma->anon_vma);
 		vma->vm_pgoff = vma->vm_start >> PAGE_SHIFT;
 	}
-	if (find_vma_links(mm, vma->vm_start, vma->vm_end,
-			   &prev, &rb_link, &rb_parent))
-		return -ENOMEM;
-	if ((vma->vm_flags & VM_ACCOUNT) &&
-	     security_vm_enough_memory_mm(mm, vma_pages(vma)))
-		return -ENOMEM;
 
 	vma_link(mm, vma, prev, rb_link, rb_parent);
 	return 0;
_


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
