Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 2A24C6B0031
	for <linux-mm@kvack.org>; Fri, 27 Dec 2013 14:20:46 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id fa1so9628068pad.10
        for <linux-mm@kvack.org>; Fri, 27 Dec 2013 11:20:45 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id m8si17801253pbq.179.2013.12.27.11.20.44
        for <linux-mm@kvack.org>;
        Fri, 27 Dec 2013 11:20:44 -0800 (PST)
Date: Fri, 27 Dec 2013 14:20:41 -0500
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCH] remap_file_pages needs to check for cache coherency
Message-ID: <20131227192041.GD4945@linux.intel.com>
References: <20131227180018.GC4945@linux.intel.com>
 <20131227.134814.345379118522548543.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131227.134814.345379118522548543.davem@davemloft.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: linux-mm@kvack.org, sparclinux@vger.kernel.org, linux-parisc@vger.kernel.org, linux-mips@linux-mips.org

On Fri, Dec 27, 2013 at 01:48:14PM -0500, David Miller wrote:
> From: Matthew Wilcox <willy@linux.intel.com>
> Date: Fri, 27 Dec 2013 13:00:18 -0500
> 
> > It seems to me that while (for example) on SPARC, it's not possible to
> > create a non-coherent mapping with mmap(), after we've done an mmap,
> > we can then use remap_file_pages() to create a mapping that no longer
> > aliases in the D-cache.
> > 
> > I have only compile-tested this patch.  I don't have any SPARC hardware,
> > and my PA-RISC hardware hasn't been turned on in six years ... I noticed
> > this while wandering around looking at some other stuff.
> 
> I suppose this is needed, but only in the case where the mapping is
> shared and writable, right?  I don't see you testing those conditions,
> but with them I'd be OK with this change.

VM_SHARED is checked a few lines above; too far to be visible in the
original context diff:

        if (!vma || !(vma->vm_flags & VM_SHARED))
                goto out;
 
        if (!vma->vm_ops || !vma->vm_ops->remap_pages)
                goto out;
 
        if (start < vma->vm_start || start + size > vma->vm_end)
                goto out;
 
+#ifdef __ARCH_FORCE_SHMLBA
+       /* Is the mapping cache-coherent? */
+       if ((pgoff ^ linear_page_index(vma, start)) &
+           ((SHMLBA-1) >> PAGE_SHIFT))
+               goto out;
+#endif

I don't understand why we need to check for writable here.  We don't
seem to check VM_WRITE in arch_get_unmapped_area(), so I don't see why
we should be checking it here.  Put it another way; if I mmap() a file
with PROT_READ only, should I be able to see stale data after another
thread has written to it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
