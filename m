Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id E8A75440608
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 10:52:59 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id s186so39116322qkb.5
        for <linux-mm@kvack.org>; Fri, 17 Feb 2017 07:52:59 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n68si7743032qte.207.2017.02.17.07.52.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Feb 2017 07:52:43 -0800 (PST)
Date: Fri, 17 Feb 2017 16:52:41 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] userfaultfd: hugetlbfs: add UFFDIO_COPY support for
 shared mappings
Message-ID: <20170217155241.GT25530@redhat.com>
References: <1487195210-12839-1-git-send-email-mike.kravetz@oracle.com>
 <20170216184100.GS25530@redhat.com>
 <c9c8cafe-baa7-05b4-34ea-1dfa5523a85f@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c9c8cafe-baa7-05b4-34ea-1dfa5523a85f@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Pavel Emelyanov <xemul@parallels.com>, "Kirill A. Shutemov" <kirill@shutemov.name>

On Thu, Feb 16, 2017 at 04:18:51PM -0800, Mike Kravetz wrote:
> Thanks Andrea, I incorporated your suggestions into a new version of the patch. 
> While changing (dst_vma->vm_flags & VM_SHARED) to integers, I noticed an issue
> in the error path of __mcopy_atomic_hugetlb().

Indeed good point!

> +	int vm_alloc_shared = dst_vma->vm_flags & VM_SHARED;
> +	int vm_shared = dst_vma->vm_flags & VM_SHARED;

Other minor nitpick, this could have been:

     int vm_shared = vm_alloc_shared;

But I'm sure gcc will emit the same asm.

For greppability (if such word exist) calling it vm_shared_alloc would
have been preferable. We can clean it up post upstream merge or it
should be diffed against mm latest or it may cause more rejects.

Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>


The patches were not against latest -mm so I solved the rejects during
merge in my tree. Then I looked at the result of all my merges after
everything is applied and I think I spotted a merge gone wrong in this
patch:

https://ozlabs.org/~akpm/mmots/broken-out/userfaultfd-mcopy_atomic-return-enoent-when-no-compatible-vma-found.patch

Below is a hand edited git diff that shows the only meaningful
difference.

The below should be included in
userfaultfd-mcopy_atomic-return-enoent-when-no-compatible-vma-found.patch
or as -fix2 at the end.

Everything else is identical which is great. Mike Rapoport could you
verify the below hunk is missing in mm?

Once it'll all be merged upstream then there will be less merge crunch
as we've been working somewhat in parallel on the same files, so this
is resulting in more merge rejects than ideal :).

diff --git a/../mm/mm/userfaultfd.c b/mm/userfaultfd.c
index 830bed7..3ec9aad 100644
--- a/../mm/mm/userfaultfd.c
+++ b/mm/userfaultfd.c
@@ -199,6 +201,12 @@ static __always_inline ssize_t __mcopy_atomic_hugetlb(struct mm_struct *dst_mm,
 		dst_vma = find_vma(dst_mm, dst_start);
 		if (!dst_vma || !is_vm_hugetlb_page(dst_vma))
 			goto out_unlock;
+		/*
+		 * Only allow __mcopy_atomic_hugetlb on userfaultfd
+		 * registered ranges.
+		 */
+		if (!dst_vma->vm_userfaultfd_ctx.ctx)
+			goto out_unlock;
 
 		if (dst_start < dst_vma->vm_start ||
 		    dst_start + len > dst_vma->vm_end)
@@ -214,16 +224,10 @@ static __always_inline ssize_t __mcopy_atomic_hugetlb(struct mm_struct *dst_mm,
 		goto out_unlock;
 
 	/*
-	 * Only allow __mcopy_atomic_hugetlb on userfaultfd registered ranges.
-	 */
-	if (!dst_vma->vm_userfaultfd_ctx.ctx)
-		goto out_unlock;
-
-	/*
 	 * If not shared, ensure the dst_vma has a anon_vma.
 	 */
 	err = -ENOMEM;

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
