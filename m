Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 1FED26B0254
	for <linux-mm@kvack.org>; Wed,  2 Sep 2015 20:57:42 -0400 (EDT)
Received: by pacfv12 with SMTP id fv12so28438478pac.2
        for <linux-mm@kvack.org>; Wed, 02 Sep 2015 17:57:41 -0700 (PDT)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id en10si38484358pac.97.2015.09.02.17.57.40
        for <linux-mm@kvack.org>;
        Wed, 02 Sep 2015 17:57:41 -0700 (PDT)
Date: Thu, 3 Sep 2015 10:57:25 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH] dax, pmem: add support for msync
Message-ID: <20150903005725.GU3902@dastard>
References: <1441047584-14664-1-git-send-email-ross.zwisler@linux.intel.com>
 <20150831233803.GO3902@dastard>
 <20150901100804.GA7045@node.dhcp.inet.fi>
 <20150901224922.GR3902@dastard>
 <20150902091321.GA2323@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150902091321.GA2323@node.dhcp.inet.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@osdl.org>, Christoph Hellwig <hch@lst.de>, Dave Hansen <dave.hansen@linux.intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, Matthew Wilcox <willy@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, x86@kernel.org

On Wed, Sep 02, 2015 at 12:13:21PM +0300, Kirill A. Shutemov wrote:
> On Wed, Sep 02, 2015 at 08:49:22AM +1000, Dave Chinner wrote:
> > On Tue, Sep 01, 2015 at 01:08:04PM +0300, Kirill A. Shutemov wrote:
> > > On Tue, Sep 01, 2015 at 09:38:03AM +1000, Dave Chinner wrote:
> > > > On Mon, Aug 31, 2015 at 12:59:44PM -0600, Ross Zwisler wrote:
> > > > Even for DAX, msync has to call vfs_fsync_range() for the filesystem to commit
> > > > the backing store allocations to stable storage, so there's not
> > > > getting around the fact msync is the wrong place to be flushing
> > > > DAX mappings to persistent storage.
> > > 
> > > Why?
> > > IIUC, msync() doesn't have any requirements wrt metadata, right?
> > 
> > Of course it does. If the backing store allocation has not been
> > committed, then after a crash there will be a hole in file and
> > so it will read as zeroes regardless of what data was written and
> > flushed.
> 
> Any reason why backing store allocation cannot be committed on *_mkwrite?

Oh, I could change that if you want, it'll just be ridiculously
slow because it requires journal flushes on every page fault that
needs to change the filesytsem block map (i.e. every allocation and/or
every unwritten extent conversion).

Sycnhronous journalling requires flushing the log on every
transaction commit. That involves switching to a work queue, copying
the changes into a log buffer, issuing IO to flush the journal,
waiting for that to complete, etc. i.e.  synchronous journalling
incurs a minimum overhead of 4 context switches per page fault that
needs to allocate/convert backing store, along with all the CPU time
needed to process the journal commit.

> diff --git a/mm/mmap.c b/mm/mmap.c
> index 3f78bceefe5a..f2e29a541e14 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -1645,6 +1645,15 @@ unsigned long mmap_region(struct file *file, unsigned long addr,
>                         vma->vm_ops = &dummy_ops;
>                 }
>  
> +               /*
> +                * Make sure that for VM_MIXEDMAP VMA has both
> +                * vm_ops->page_mkwrite and vm_ops->pfn_mkwrite or has none.
> +                */
> +               if ((vma->vm_ops->page_mkwrite || vma->vm_ops->pfn_mkwrite) &&
> +                               vma->vm_flags & VM_MIXEDMAP) {
> +                       VM_BUG_ON_VMA(!vma->vm_ops->page_mkwrite, vma);
> +                       VM_BUG_ON_VMA(!vma->vm_ops->pfn_mkwrite, vma);
> +               }

Doesn't really help developers that don't use CONFIG_DEBUG_VM. i.e
it's the FS developers that you need to warn, not VM developers -
in this case a "WARN_ON_ONCE" is probably more appropriate.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
