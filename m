Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 484286B0003
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 08:21:38 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id z21-v6so7257035plo.13
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 05:21:38 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z9-v6sor6245626pln.119.2018.07.11.05.21.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 11 Jul 2018 05:21:37 -0700 (PDT)
Date: Wed, 11 Jul 2018 15:15:21 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 1/2] mm: Fix vma_is_anonymous() false-positives
Message-ID: <20180711121521.omugjfpuuyxscjjf@kshutemo-mobl1>
References: <20180710134821.84709-1-kirill.shutemov@linux.intel.com>
 <20180710134821.84709-2-kirill.shutemov@linux.intel.com>
 <20180710134858.3506f097104859b533c81bf3@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180710134858.3506f097104859b533c81bf3@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Dmitry Vyukov <dvyukov@google.com>, Oleg Nesterov <oleg@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org

On Tue, Jul 10, 2018 at 01:48:58PM -0700, Andrew Morton wrote:
> On Tue, 10 Jul 2018 16:48:20 +0300 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:
> 
> > vma_is_anonymous() relies on ->vm_ops being NULL to detect anonymous
> > VMA. This is unreliable as ->mmap may not set ->vm_ops.
> > 
> > False-positive vma_is_anonymous() may lead to crashes:
> > 
> > ...
> > 
> > This can be fixed by assigning anonymous VMAs own vm_ops and not relying
> > on it being NULL.
> > 
> > If ->mmap() failed to set ->vm_ops, mmap_region() will set it to
> > dummy_vm_ops. This way we will have non-NULL ->vm_ops for all VMAs.
> 
> Is there a smaller, simpler fix which we can use for backporting
> purposes and save the larger rework for development kernels?

I've tried to move dummy_vm_ops stuff into a separate patch, but it didn't
workaround.

In some cases (like in create_huge_pmd()/wp_huge_pmd()) we rely on
vma_is_anonymous() to guarantee that ->vm_ops is non-NULL. But with new
implementation of the helper there's no such guarantee. And I see crash in
create_huge_pmd().

We can add explicit ->vm_ops check in such places. But it's more risky.
I may miss some instances. dummy_vm_ops should be safer here.

I think it's better to backport whole patch.

> 
> >
> > ...
> >
> > --- a/mm/mmap.c
> > +++ b/mm/mmap.c
> > @@ -71,6 +71,9 @@ int mmap_rnd_compat_bits __read_mostly = CONFIG_ARCH_MMAP_RND_COMPAT_BITS;
> >  static bool ignore_rlimit_data;
> >  core_param(ignore_rlimit_data, ignore_rlimit_data, bool, 0644);
> >  
> > +const struct vm_operations_struct anon_vm_ops = {};
> > +const struct vm_operations_struct dummy_vm_ops = {};
> 
> Some nice comments here would be useful.  Especially for dummy_vm_ops. 
> Why does it exist, what is its role, etc.

Fixup is below.

> >  static void unmap_region(struct mm_struct *mm,
> >  		struct vm_area_struct *vma, struct vm_area_struct *prev,
> >  		unsigned long start, unsigned long end);
> > @@ -561,6 +564,8 @@ static unsigned long count_vma_pages_range(struct mm_struct *mm,
> >  void __vma_link_rb(struct mm_struct *mm, struct vm_area_struct *vma,
> >  		struct rb_node **rb_link, struct rb_node *rb_parent)
> >  {
> > +	WARN_ONCE(!vma->vm_ops, "missing vma->vm_ops");
> > +
> >  	/* Update tracking information for the gap following the new vma. */
> >  	if (vma->vm_next)
> >  		vma_gap_update(vma->vm_next);
> > @@ -1774,12 +1779,19 @@ unsigned long mmap_region(struct file *file, unsigned long addr,
> >  		 */
> >  		WARN_ON_ONCE(addr != vma->vm_start);
> >  
> > +		/* All mappings must have ->vm_ops set */
> > +		if (!vma->vm_ops)
> > +			vma->vm_ops = &dummy_vm_ops;
> 
> Can this happen?  Can we make it a rule that file_operations.mmap(vma)
> must initialize vma->vm_ops?  Should we have a WARN here to detect when
> the fs implementation failed to do that?

Yes, it can happen. KCOV doesn't set it now. And I'm pretty sure some
drivers do not set it too.

We can add warning here. But I'm not sure what value it would have.
It's perfectly fine to have no need in any of vm operations. Silently set
it to dummy_vm_ops should be good enough here.

> >  		addr = vma->vm_start;
> >  		vm_flags = vma->vm_flags;
> >  	} else if (vm_flags & VM_SHARED) {
> >  		error = shmem_zero_setup(vma);
> >  		if (error)
> >  			goto free_vma;
> > +	} else {
> > +		/* vma_is_anonymous() relies on this. */
> +		vma->vm_ops = &anon_vm_ops;
> >  	}
> >  
> >  	vma_link(mm, vma, prev, rb_link, rb_parent);
> > ...
> >
> 

diff --git a/mm/mmap.c b/mm/mmap.c
index 0729ed06b01c..6f59ade58fa7 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -71,7 +71,16 @@ int mmap_rnd_compat_bits __read_mostly = CONFIG_ARCH_MMAP_RND_COMPAT_BITS;
 static bool ignore_rlimit_data;
 core_param(ignore_rlimit_data, ignore_rlimit_data, bool, 0644);
 
+/*
+ * All anonymous VMAs have ->vm_ops set to anon_vm_ops.
+ * vma_is_anonymous() reiles on anon_vm_ops to detect anonymous VMA.
+ */
 const struct vm_operations_struct anon_vm_ops = {};
+
+/*
+ * All VMAs have to have ->vm_ops set. dummy_vm_ops can be used if the VMA
+ * doesn't need to handle any of the operations.
+ */
 const struct vm_operations_struct dummy_vm_ops = {};
 
 static void unmap_region(struct mm_struct *mm,
-- 
 Kirill A. Shutemov
