Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 15ABD6B0254
	for <linux-mm@kvack.org>; Mon, 31 Aug 2015 19:38:09 -0400 (EDT)
Received: by pacdd16 with SMTP id dd16so154253956pac.2
        for <linux-mm@kvack.org>; Mon, 31 Aug 2015 16:38:08 -0700 (PDT)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id bv3si26610315pdb.174.2015.08.31.16.38.06
        for <linux-mm@kvack.org>;
        Mon, 31 Aug 2015 16:38:08 -0700 (PDT)
Date: Tue, 1 Sep 2015 09:38:03 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH] dax, pmem: add support for msync
Message-ID: <20150831233803.GO3902@dastard>
References: <1441047584-14664-1-git-send-email-ross.zwisler@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1441047584-14664-1-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@osdl.org>, Christoph Hellwig <hch@lst.de>, Dave Hansen <dave.hansen@linux.intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, Matthew Wilcox <willy@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, x86@kernel.org

On Mon, Aug 31, 2015 at 12:59:44PM -0600, Ross Zwisler wrote:
> For DAX msync we just need to flush the given range using
> wb_cache_pmem(), which is now a public part of the PMEM API.

This is wrong, because it still leaves fsync() broken on dax.

Flushing dirty data to stable storage is the responsibility of the
writeback infrastructure, not the VMA/mm infrasrtucture. For non-dax
configurations, msync defers all that to vfs_fsync_range(), because
it has to be implemented there for fsync() to work.

Even for DAX, msync has to call vfs_fsync_range() for the filesystem to commit
the backing store allocations to stable storage, so there's not
getting around the fact msync is the wrong place to be flushing
DAX mappings to persistent storage.

I pointed this out almost 6 months ago (i.e. that fsync was broken)
anf hinted at how to solve it. Fix fsync, and msync gets fixed for
free:

https://lists.01.org/pipermail/linux-nvdimm/2015-March/000341.html

I've also reported to Willy that DAX write page faults don't work
correctly, either. xfstests generic/080 exposes this: a read
from a page followed immediately by a write to that page does not
result in ->page_mkwrite being called on the write and so
backing store is not allocated for the page, nor are the timestamps
for the file updated. This will also result in fsync (and msync)
not working properly.

Fix fsync first - if fsync works then msync will work.

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
