Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id E5DE66B0254
	for <linux-mm@kvack.org>; Tue,  1 Sep 2015 03:06:10 -0400 (EDT)
Received: by wicjd9 with SMTP id jd9so21994427wic.1
        for <linux-mm@kvack.org>; Tue, 01 Sep 2015 00:06:10 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id em11si1540302wid.64.2015.09.01.00.06.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Sep 2015 00:06:09 -0700 (PDT)
Date: Tue, 1 Sep 2015 09:06:08 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH] dax, pmem: add support for msync
Message-ID: <20150901070608.GA5482@lst.de>
References: <1441047584-14664-1-git-send-email-ross.zwisler@linux.intel.com> <20150831233803.GO3902@dastard>
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
> writeback infrastructure, not the VMA/mm infrasrtucture. For non-dax
> configurations, msync defers all that to vfs_fsync_range(), because
> it has to be implemented there for fsync() to work.
> 
> Even for DAX, msync has to call vfs_fsync_range() for the filesystem to commit
> the backing store allocations to stable storage, so there's not
> getting around the fact msync is the wrong place to be flushing
> DAX mappings to persistent storage.

DAX does call ->fsync before and after this patch.  And with all
the recent fixes we take care to ensure data is written though the
cache for everything but mmap-access.  With this patch from Ross
we ensure msync writes back the cache before calling ->fsync so that
the filesystem can then do it's work like converting unwritten extents.

The only downside is that previously on Linux you could always use
fsync as a replaement for msymc, which isn't true anymore for DAX.

But given that we need the virtual address to write back the cache
I can't see how to do this differently given that clwb() needs the
user virtual address to flush the cache.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
