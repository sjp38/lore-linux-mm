Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 74EF26B0255
	for <linux-mm@kvack.org>; Mon, 13 Jul 2015 11:02:38 -0400 (EDT)
Received: by pdbep18 with SMTP id ep18so227002962pdb.1
        for <linux-mm@kvack.org>; Mon, 13 Jul 2015 08:02:38 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id d6si28906897pas.51.2015.07.13.08.02.37
        for <linux-mm@kvack.org>;
        Mon, 13 Jul 2015 08:02:37 -0700 (PDT)
Date: Mon, 13 Jul 2015 11:02:35 -0400
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCH 06/10] mm: Add vmf_insert_pfn_pmd()
Message-ID: <20150713150235.GG13681@linux.intel.com>
References: <1436560165-8943-1-git-send-email-matthew.r.wilcox@intel.com>
 <1436560165-8943-7-git-send-email-matthew.r.wilcox@intel.com>
 <x49r3oc6vj6.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <x49r3oc6vj6.fsf@segfault.boston.devel.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Moyer <jmoyer@redhat.com>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Jul 13, 2015 at 09:23:41AM -0400, Jeff Moyer wrote:
> Matthew Wilcox <matthew.r.wilcox@intel.com> writes:
> 
> > +static int insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
> > +		pmd_t *pmd, unsigned long pfn, pgprot_t prot, bool write)
> > +{
> > +	return VM_FAULT_NOPAGE;
> > +}
> 
> What's the point of the return value?

Good point.  Originally, it paralleled insert_pfn() in mm/memory.c, but it
became apparent that the return code of 0 or -Exxx was useless, and in converting insert_pfn_pmd over to VM_FAULT_ codes, all possible return codes were
going to be VM_FAULT_NOPAGE.  It didn't occur to me to take it one step further and make the function return void.

It doesn't make much difference either way:

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 26d0fc1..5ffdcaa 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -837,7 +837,7 @@ int do_huge_pmd_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	return 0;
 }
 
-static int insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
+static void insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
 		pmd_t *pmd, unsigned long pfn, pgprot_t prot, bool write)
 {
 	struct mm_struct *mm = vma->vm_mm;
@@ -855,7 +855,6 @@ static int insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
 		update_mmu_cache_pmd(vma, addr, pmd);
 	}
 	spin_unlock(ptl);
-	return VM_FAULT_NOPAGE;
 }
 
 int vmf_insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
@@ -877,7 +876,8 @@ int vmf_insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
 		return VM_FAULT_SIGBUS;
 	if (track_pfn_insert(vma, &pgprot, pfn))
 		return VM_FAULT_SIGBUS;
-	return insert_pfn_pmd(vma, addr, pmd, pfn, pgprot, write);
+	insert_pfn_pmd(vma, addr, pmd, pfn, pgprot, write);
+	return VM_FAULT_NOPAGE;
 }
 
 int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,


I suppose it's slightly cleaner.  I'll integrate this for the next release.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
