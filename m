Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id C84C66B0254
	for <linux-mm@kvack.org>; Tue,  1 Sep 2015 08:18:47 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so10416897wic.0
        for <linux-mm@kvack.org>; Tue, 01 Sep 2015 05:18:47 -0700 (PDT)
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com. [209.85.212.181])
        by mx.google.com with ESMTPS id hs8si2859512wib.89.2015.09.01.05.18.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Sep 2015 05:18:44 -0700 (PDT)
Received: by wicge5 with SMTP id ge5so5068490wic.0
        for <linux-mm@kvack.org>; Tue, 01 Sep 2015 05:18:43 -0700 (PDT)
Message-ID: <55E597A1.9090205@plexistor.com>
Date: Tue, 01 Sep 2015 15:18:41 +0300
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
Subject: Re: [PATCH] dax, pmem: add support for msync
References: <1441047584-14664-1-git-send-email-ross.zwisler@linux.intel.com> <20150831233803.GO3902@dastard> <20150901070608.GA5482@lst.de>
In-Reply-To: <20150901070608.GA5482@lst.de>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>
Cc: Andrew Morton <akpm@osdl.org>, x86@kernel.org, linux-nvdimm@lists.01.org, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@linux.intel.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Alexander Viro <viro@zeniv.linux.org.uk>, "H. Peter Anvin" <hpa@zytor.com>, linux-fsdevel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On 09/01/2015 10:06 AM, Christoph Hellwig wrote:
> On Tue, Sep 01, 2015 at 09:38:03AM +1000, Dave Chinner wrote:
>> On Mon, Aug 31, 2015 at 12:59:44PM -0600, Ross Zwisler wrote:
>>> For DAX msync we just need to flush the given range using
>>> wb_cache_pmem(), which is now a public part of the PMEM API.
>>
>> This is wrong, because it still leaves fsync() broken on dax.
>>
>> Flushing dirty data to stable storage is the responsibility of the
>> writeback infrastructure, not the VMA/mm infrasrtucture. For non-dax
>> configurations, msync defers all that to vfs_fsync_range(), because
>> it has to be implemented there for fsync() to work.
>>
>> Even for DAX, msync has to call vfs_fsync_range() for the filesystem to commit
>> the backing store allocations to stable storage, so there's not
>> getting around the fact msync is the wrong place to be flushing
>> DAX mappings to persistent storage.
> 
> DAX does call ->fsync before and after this patch.  And with all
> the recent fixes we take care to ensure data is written though the
> cache for everything but mmap-access.  With this patch from Ross
> we ensure msync writes back the cache before calling ->fsync so that
> the filesystem can then do it's work like converting unwritten extents.
> 
> The only downside is that previously on Linux you could always use
> fsync as a replaement for msymc, which isn't true anymore for DAX.
> 

Hi Christoph

So the approach we took was a bit different to exactly solve these
problem, and to also not over flush too much. here is what we did.

* At vm_operations_struct we also override the .close vector (say call it dax_vm_close)

* At dax_vm_close() on writable files call ->fsync(,vma->vm_start, vma->vm_end,)
  (We have an inode flag if the file was actually dirtied, but even if not, that will
   not be that bad, so a file was opened for write, mmapped, but actually never
   modified. Not a lot of these, and the do nothing cl_flushing is very fast)

* At ->fsync() do the actual cl_flush for all cases but only iff
	if (mapping_mapped(inode->i_mapping) == 0)
		return 0;

  This is because data written not through mmap is already persistent and we
  do not need the cl_flushing

Apps expect all these to work:
1. open mmap m-write msync ... close
2. open mmap m-write fsync ... close
3. open mmap m-write unmap ... fsync close

4. open mmap m-write sync ...

The first 3 are supported with above, because what happens is that at [3]
the fsync actually happens on unmap and fsync is redundant in that case.

The only broken scenario is [3]. We do not have a list of "dax-dirty" inodes
per sb to iterate on and call inode-sync on. This cause problems mostly in
freeze because with actual [3] scenario the file will be eventually closed
and persistent, but after the call to sync returns.

Its on my TODO to fix [3] based on instructions from Dave.
The mmap call will put the inode on the list and the dax_vm_close will
remove it. One of the regular dirty list should be used as suggested by
Dave.

> But given that we need the virtual address to write back the cache
> I can't see how to do this differently given that clwb() needs the
> user virtual address to flush the cache.

On Intel or any systems that have physical-based caching this is not
a problem you just iterate on all get_block() of the range and flush
the Kernel's virt_addr of the block, this is easy.

With ARCHs with per VM caching you need to go through the i_mapping VMAs list
and flush like that. I guess there is a way to schedule yourself as a process VMA
somehow.
I'm not sure how to solve this split, perhaps two generic functions, that
are selected through the ARCH.

Just my $0.017
Boaz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
