Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 7F0F86B0254
	for <linux-mm@kvack.org>; Wed,  2 Sep 2015 05:13:25 -0400 (EDT)
Received: by wicge5 with SMTP id ge5so33193979wic.0
        for <linux-mm@kvack.org>; Wed, 02 Sep 2015 02:13:24 -0700 (PDT)
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com. [209.85.212.169])
        by mx.google.com with ESMTPS id fx1si3214106wic.87.2015.09.02.02.13.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Sep 2015 02:13:24 -0700 (PDT)
Received: by wicfx3 with SMTP id fx3so10373209wic.1
        for <linux-mm@kvack.org>; Wed, 02 Sep 2015 02:13:23 -0700 (PDT)
Date: Wed, 2 Sep 2015 12:13:21 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] dax, pmem: add support for msync
Message-ID: <20150902091321.GA2323@node.dhcp.inet.fi>
References: <1441047584-14664-1-git-send-email-ross.zwisler@linux.intel.com>
 <20150831233803.GO3902@dastard>
 <20150901100804.GA7045@node.dhcp.inet.fi>
 <20150901224922.GR3902@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150901224922.GR3902@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@osdl.org>, Christoph Hellwig <hch@lst.de>, Dave Hansen <dave.hansen@linux.intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, Matthew Wilcox <willy@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, x86@kernel.org

On Wed, Sep 02, 2015 at 08:49:22AM +1000, Dave Chinner wrote:
> On Tue, Sep 01, 2015 at 01:08:04PM +0300, Kirill A. Shutemov wrote:
> > On Tue, Sep 01, 2015 at 09:38:03AM +1000, Dave Chinner wrote:
> > > On Mon, Aug 31, 2015 at 12:59:44PM -0600, Ross Zwisler wrote:
> > > Even for DAX, msync has to call vfs_fsync_range() for the filesystem to commit
> > > the backing store allocations to stable storage, so there's not
> > > getting around the fact msync is the wrong place to be flushing
> > > DAX mappings to persistent storage.
> > 
> > Why?
> > IIUC, msync() doesn't have any requirements wrt metadata, right?
> 
> Of course it does. If the backing store allocation has not been
> committed, then after a crash there will be a hole in file and
> so it will read as zeroes regardless of what data was written and
> flushed.

Any reason why backing store allocation cannot be committed on *_mkwrite?

> > > I pointed this out almost 6 months ago (i.e. that fsync was broken)
> > > anf hinted at how to solve it. Fix fsync, and msync gets fixed for
> > > free:
> > > 
> > > https://lists.01.org/pipermail/linux-nvdimm/2015-March/000341.html
> > > 
> > > I've also reported to Willy that DAX write page faults don't work
> > > correctly, either. xfstests generic/080 exposes this: a read
> > > from a page followed immediately by a write to that page does not
> > > result in ->page_mkwrite being called on the write and so
> > > backing store is not allocated for the page, nor are the timestamps
> > > for the file updated. This will also result in fsync (and msync)
> > > not working properly.
> > 
> > Is that because XFS doesn't provide vm_ops->pfn_mkwrite?
> 
> I didn't know that had been committed. I don't recall seeing a pull
> request with that in it

It went though -mm tree.

> none of the XFS DAX patches conflicted
> against it and there's been no runtime errors. I'll fix it up.
> 
> As such, shouldn't there be a check in the VM (in ->mmap callers)
> that if we have the vma is returned with VM_MIXEDMODE enabled that
> ->pfn_mkwrite is not NULL?  It's now clear to me that any filesystem
> that sets VM_MIXEDMODE needs to support both page_mkwrite and
> pfn_mkwrite, and such a check would have caught this immediately...

I guess it's "both or none" case. We have VM_MIXEDMAP users who don't care
about *_mkwrite.

I'm not yet sure it would be always correct, but something like this will
catch the XFS case, without false-positive on other stuff in my KVM setup:

diff --git a/mm/mmap.c b/mm/mmap.c
index 3f78bceefe5a..f2e29a541e14 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1645,6 +1645,15 @@ unsigned long mmap_region(struct file *file, unsigned long addr,
                        vma->vm_ops = &dummy_ops;
                }
 
+               /*
+                * Make sure that for VM_MIXEDMAP VMA has both
+                * vm_ops->page_mkwrite and vm_ops->pfn_mkwrite or has none.
+                */
+               if ((vma->vm_ops->page_mkwrite || vma->vm_ops->pfn_mkwrite) &&
+                               vma->vm_flags & VM_MIXEDMAP) {
+                       VM_BUG_ON_VMA(!vma->vm_ops->page_mkwrite, vma);
+                       VM_BUG_ON_VMA(!vma->vm_ops->pfn_mkwrite, vma);
+               }
                addr = vma->vm_start;
                vm_flags = vma->vm_flags;
        } else if (vm_flags & VM_SHARED) {
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
