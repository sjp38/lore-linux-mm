Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id C832D6B0254
	for <linux-mm@kvack.org>; Tue,  1 Sep 2015 18:49:38 -0400 (EDT)
Received: by padhy1 with SMTP id hy1so9873870pad.1
        for <linux-mm@kvack.org>; Tue, 01 Sep 2015 15:49:38 -0700 (PDT)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id at5si4382260pbc.108.2015.09.01.15.49.36
        for <linux-mm@kvack.org>;
        Tue, 01 Sep 2015 15:49:38 -0700 (PDT)
Date: Wed, 2 Sep 2015 08:49:22 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH] dax, pmem: add support for msync
Message-ID: <20150901224922.GR3902@dastard>
References: <1441047584-14664-1-git-send-email-ross.zwisler@linux.intel.com>
 <20150831233803.GO3902@dastard>
 <20150901100804.GA7045@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150901100804.GA7045@node.dhcp.inet.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@osdl.org>, Christoph Hellwig <hch@lst.de>, Dave Hansen <dave.hansen@linux.intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, Matthew Wilcox <willy@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, x86@kernel.org

On Tue, Sep 01, 2015 at 01:08:04PM +0300, Kirill A. Shutemov wrote:
> On Tue, Sep 01, 2015 at 09:38:03AM +1000, Dave Chinner wrote:
> > On Mon, Aug 31, 2015 at 12:59:44PM -0600, Ross Zwisler wrote:
> > Even for DAX, msync has to call vfs_fsync_range() for the filesystem to commit
> > the backing store allocations to stable storage, so there's not
> > getting around the fact msync is the wrong place to be flushing
> > DAX mappings to persistent storage.
> 
> Why?
> IIUC, msync() doesn't have any requirements wrt metadata, right?

Of course it does. If the backing store allocation has not been
committed, then after a crash there will be a hole in file and
so it will read as zeroes regardless of what data was written and
flushed.

> > I pointed this out almost 6 months ago (i.e. that fsync was broken)
> > anf hinted at how to solve it. Fix fsync, and msync gets fixed for
> > free:
> > 
> > https://lists.01.org/pipermail/linux-nvdimm/2015-March/000341.html
> > 
> > I've also reported to Willy that DAX write page faults don't work
> > correctly, either. xfstests generic/080 exposes this: a read
> > from a page followed immediately by a write to that page does not
> > result in ->page_mkwrite being called on the write and so
> > backing store is not allocated for the page, nor are the timestamps
> > for the file updated. This will also result in fsync (and msync)
> > not working properly.
> 
> Is that because XFS doesn't provide vm_ops->pfn_mkwrite?

I didn't know that had been committed. I don't recall seeing a pull
request with that in it, none of the XFS DAX patches conflicted
against it and there's been no runtime errors. I'll fix it up.

As such, shouldn't there be a check in the VM (in ->mmap callers)
that if we have the vma is returned with VM_MIXEDMODE enabled that
->pfn_mkwrite is not NULL?  It's now clear to me that any filesystem
that sets VM_MIXEDMODE needs to support both page_mkwrite and
pfn_mkwrite, and such a check would have caught this immediately...

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
