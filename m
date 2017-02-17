Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id C03656B0038
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 16:35:03 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id q3so45644510qtf.4
        for <linux-mm@kvack.org>; Fri, 17 Feb 2017 13:35:03 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c126si8323341qkd.37.2017.02.17.13.35.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Feb 2017 13:35:02 -0800 (PST)
Date: Fri, 17 Feb 2017 22:34:58 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] userfaultfd: hugetlbfs: add UFFDIO_COPY support for
 shared mappings
Message-ID: <20170217213458.GW25530@redhat.com>
References: <1487195210-12839-1-git-send-email-mike.kravetz@oracle.com>
 <20170216184100.GS25530@redhat.com>
 <c9c8cafe-baa7-05b4-34ea-1dfa5523a85f@oracle.com>
 <20170217155241.GT25530@redhat.com>
 <20170217121738.f5b2e24474021f38fdb72845@linux-foundation.org>
 <20170217205124.GV25530@redhat.com>
 <20170217130855.57813d7e96c7547202bba544@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170217130855.57813d7e96c7547202bba544@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Pavel Emelyanov <xemul@parallels.com>, "Kirill A. Shutemov" <kirill@shutemov.name>

On Fri, Feb 17, 2017 at 01:08:55PM -0800, Andrew Morton wrote:
> I had a bunch more rejects to fix in that function.  Below is the final
> result - please check it carefully.

Sure, reviewed and this is the diff that remains (vm_shared assignment
location is irrelevant, I put it at the end as it's only needed later
and not checked in the out_unlock path, err = -EINVAL also is fine to
stay):

diff --git a/tmp/x b/mm/userfaultfd.c
index a3ba029..3ec9aad 100644
--- a/tmp/x
+++ b/mm/userfaultfd.c
@@ -63,22 +212,17 @@ static __always_inline ssize_t __mcopy_atomic_hugetlb(struct mm_struct *dst_mm,
 		    dst_start + len > dst_vma->vm_end)
 			goto out_unlock;
 
-		vm_shared = dst_vma->vm_flags & VM_SHARED;
-
 		err = -EINVAL;
 		if (vma_hpagesize != vma_kernel_pagesize(dst_vma))
 			goto out_unlock;
+
+		vm_shared = dst_vma->vm_flags & VM_SHARED;
 	}
 
-	err = -EINVAL;
 	if (WARN_ON(dst_addr & (vma_hpagesize - 1) ||
 		    (len - copied) & (vma_hpagesize - 1)))
 		goto out_unlock;
 
-	if (dst_start < dst_vma->vm_start ||
-	    dst_start + len > dst_vma->vm_end)
-		goto out_unlock;
-
 	/*
 	 * If not shared, ensure the dst_vma has a anon_vma.
 	 */


In short there's only the last 4 lines of the above that can be
applied.

__mcopy_atomic_hugetlb in the first pass (i.e. dst_vma not NULL) is
invoked after those checks already have been run in the caller.

	if (dst_start < dst_vma->vm_start ||
	    dst_start + len > dst_vma->vm_end)
		goto out_unlock;

	err = -EINVAL;
	/*
	 * shmem_zero_setup is invoked in mmap for MAP_ANONYMOUS|MAP_SHARED but
	 * it will overwrite vm_ops, so vma_is_anonymous must return false.
	 */
	if (WARN_ON_ONCE(vma_is_anonymous(dst_vma) &&
	    dst_vma->vm_flags & VM_SHARED))
		goto out_unlock;

	/*
	 * If this is a HUGETLB vma, pass off to appropriate routine
	 */
	if (is_vm_hugetlb_page(dst_vma))
		return  __mcopy_atomic_hugetlb(dst_mm, dst_vma, dst_start,
						src_start, len, zeropage);

As usual hugetlbfs takes its own tangent out of the main VM code after
various checks have already been done that applies to hugetlbfs too.

In the "retry" case the dst_vma is set to NULL and the dst_vma is
being searched again and revalidated, and we so we repeat the
check. First time it's not needed, for second time it would be a
repetition and so it's a noop.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
