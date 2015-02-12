Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	by kanga.kvack.org (Postfix) with ESMTP id A2C5C6B006E
	for <linux-mm@kvack.org>; Thu, 12 Feb 2015 16:59:24 -0500 (EST)
Received: by mail-ig0-f171.google.com with SMTP id h15so6820397igd.4
        for <linux-mm@kvack.org>; Thu, 12 Feb 2015 13:59:24 -0800 (PST)
Received: from mail-ig0-x22c.google.com (mail-ig0-x22c.google.com. [2607:f8b0:4001:c05::22c])
        by mx.google.com with ESMTPS id x10si2283135igl.26.2015.02.12.13.59.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Feb 2015 13:59:24 -0800 (PST)
Received: by mail-ig0-f172.google.com with SMTP id l13so6809624iga.5
        for <linux-mm@kvack.org>; Thu, 12 Feb 2015 13:59:24 -0800 (PST)
Date: Thu, 12 Feb 2015 13:59:22 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/4] mm: rename __mlock_vma_pages_range() to
 populate_vma_page_range()
In-Reply-To: <20150212110318.GA15658@node.dhcp.inet.fi>
Message-ID: <alpine.DEB.2.10.1502121358150.30164@chino.kir.corp.google.com>
References: <1423674728-214192-1-git-send-email-kirill.shutemov@linux.intel.com> <1423674728-214192-3-git-send-email-kirill.shutemov@linux.intel.com> <alpine.DEB.2.10.1502111150400.9656@chino.kir.corp.google.com> <20150212110318.GA15658@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>

On Thu, 12 Feb 2015, Kirill A. Shutemov wrote:

> > I think it makes sense to drop the references about "downgrading" 
> > mm->mmap_sem in the documentation since populate_vma_page_range() can be 
> > called with it held either for read or write depending on the context.
> 
> I'm not sure what references you're talking about.
> 
> Is it about this part:
> 
>  * If @nonblocking is non-NULL, it must held for read only and may be
>  * released.  If it's released, *@nonblocking will be set to 0.
> 
> ?
> 

No, I was agreeing with your removal from the documentation:

@@ -463,21 +463,11 @@ populate the page table.
 
 To mlock a range of memory under the unevictable/mlock infrastructure, the
 mmap() handler and task address space expansion functions call
-mlock_vma_pages_range() specifying the vma and the address range to mlock.
-mlock_vma_pages_range() filters VMAs like mlock_fixup(), as described above in
-"Filtering Special VMAs".  It will clear the VM_LOCKED flag, which will have
-already been set by the caller, in filtered VMAs.  Thus these VMA's need not be
-visited for munlock when the region is unmapped.
-
-For "normal" VMAs, mlock_vma_pages_range() calls __mlock_vma_pages_range() to
-fault/allocate the pages and mlock them.  Again, like mlock_fixup(),
-mlock_vma_pages_range() downgrades the mmap semaphore to read mode before
-attempting to fault/allocate and mlock the pages and "upgrades" the semaphore
-back to write mode before returning.
-
-The callers of mlock_vma_pages_range() will have already added the memory range
+populate_vma_page_range() specifying the vma and the address range to mlock.
+
+The callers of populate_vma_page_range() will have already added the memory range
 to be mlocked to the task's "locked_vm".  To account for filtered VMAs,
-mlock_vma_pages_range() returns the number of pages NOT mlocked.  All of the
+populate_vma_page_range() returns the number of pages NOT mlocked.  All of the
 callers then subtract a non-negative return value from the task's locked_vm.  A
 negative return value represent an error - for example, from get_user_pages()
 attempting to fault in a VMA with PROT_NONE access.  In this case, we leave the

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
