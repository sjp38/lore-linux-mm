Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 516DE6B0254
	for <linux-mm@kvack.org>; Tue,  1 Sep 2015 06:08:08 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so6680195wic.0
        for <linux-mm@kvack.org>; Tue, 01 Sep 2015 03:08:08 -0700 (PDT)
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com. [209.85.212.174])
        by mx.google.com with ESMTPS id y7si32391646wju.76.2015.09.01.03.08.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Sep 2015 03:08:07 -0700 (PDT)
Received: by wiclp12 with SMTP id lp12so24958805wic.1
        for <linux-mm@kvack.org>; Tue, 01 Sep 2015 03:08:06 -0700 (PDT)
Date: Tue, 1 Sep 2015 13:08:04 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] dax, pmem: add support for msync
Message-ID: <20150901100804.GA7045@node.dhcp.inet.fi>
References: <1441047584-14664-1-git-send-email-ross.zwisler@linux.intel.com>
 <20150831233803.GO3902@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150831233803.GO3902@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@osdl.org>, Christoph Hellwig <hch@lst.de>, Dave Hansen <dave.hansen@linux.intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, Matthew Wilcox <willy@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, x86@kernel.org

On Tue, Sep 01, 2015 at 09:38:03AM +1000, Dave Chinner wrote:
> On Mon, Aug 31, 2015 at 12:59:44PM -0600, Ross Zwisler wrote:
> > For DAX msync we just need to flush the given range using
> > wb_cache_pmem(), which is now a public part of the PMEM API.
> 
> This is wrong, because it still leaves fsync() broken on dax.
> 
> Flushing dirty data to stable storage is the responsibility of the
> writeback infrastructure, not the VMA/mm infrasrtucture.

Writeback infrastructure is non-existent for DAX. Without struct page we
don't have anything to transfer pte_ditry() to. And I'm not sure we need
to invent some. For DAX flushing in-place can be cheaper than dirty
tracking beyond page tables.

> For non-dax configurations, msync defers all that to vfs_fsync_range(),
> because it has to be implemented there for fsync() to work.

Not necessary. I think fsync() for DAX can be implemented with rmap over
all file's VMA and msync() them with commiting metadata afterwards.

But we also need to commit to persistent on zap_page_range() to make it
work.

> Even for DAX, msync has to call vfs_fsync_range() for the filesystem to commit
> the backing store allocations to stable storage, so there's not
> getting around the fact msync is the wrong place to be flushing
> DAX mappings to persistent storage.

Why?
IIUC, msync() doesn't have any requirements wrt metadata, right?

> I pointed this out almost 6 months ago (i.e. that fsync was broken)
> anf hinted at how to solve it. Fix fsync, and msync gets fixed for
> free:
> 
> https://lists.01.org/pipermail/linux-nvdimm/2015-March/000341.html
> 
> I've also reported to Willy that DAX write page faults don't work
> correctly, either. xfstests generic/080 exposes this: a read
> from a page followed immediately by a write to that page does not
> result in ->page_mkwrite being called on the write and so
> backing store is not allocated for the page, nor are the timestamps
> for the file updated. This will also result in fsync (and msync)
> not working properly.

Is that because XFS doesn't provide vm_ops->pfn_mkwrite?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
