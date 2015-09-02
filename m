Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id D04326B0254
	for <linux-mm@kvack.org>; Wed,  2 Sep 2015 06:27:38 -0400 (EDT)
Received: by wicmc4 with SMTP id mc4so61008495wic.0
        for <linux-mm@kvack.org>; Wed, 02 Sep 2015 03:27:38 -0700 (PDT)
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com. [209.85.212.176])
        by mx.google.com with ESMTPS id b12si38919791wjb.139.2015.09.02.03.27.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Sep 2015 03:27:37 -0700 (PDT)
Received: by wicfx3 with SMTP id fx3so12516129wic.1
        for <linux-mm@kvack.org>; Wed, 02 Sep 2015 03:27:36 -0700 (PDT)
Message-ID: <55E6CF15.4070105@plexistor.com>
Date: Wed, 02 Sep 2015 13:27:33 +0300
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
Subject: Re: [PATCH] dax, pmem: add support for msync
References: <1441047584-14664-1-git-send-email-ross.zwisler@linux.intel.com> <20150831233803.GO3902@dastard> <20150901070608.GA5482@lst.de> <20150901222120.GQ3902@dastard> <20150902031945.GA8916@linux.intel.com> <20150902051711.GS3902@dastard>
In-Reply-To: <20150902051711.GS3902@dastard>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, linux-kernel@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@osdl.org>, Dave Hansen <dave.hansen@linux.intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, Matthew Wilcox <willy@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, x86@kernel.org

On 09/02/2015 08:17 AM, Dave Chinner wrote:
> On Tue, Sep 01, 2015 at 09:19:45PM -0600, Ross Zwisler wrote:
>> On Wed, Sep 02, 2015 at 08:21:20AM +1000, Dave Chinner wrote:
>>> Which means applications that should "just work" without
>>> modification on DAX are now subtly broken and don't actually
>>> guarantee data is safe after a crash. That's a pretty nasty
>>> landmine, and goes against *everything* we've claimed about using
>>> DAX with existing applications.
>>>
>>> That's wrong, and needs fixing.
>>
>> I agree that we need to fix fsync as well, and that the fsync solution could
>> be used to implement msync if we choose to go that route.  I think we might
>> want to consider keeping the msync and fsync implementations separate, though,
>> for two reasons.
>>
>> 1) The current msync implementation is much more efficient than what will be
>> needed for fsync.  Fsync will need to call into the filesystem, traverse all
>> the blocks, get kernel virtual addresses from those and then call
>> wb_cache_pmem() on those kernel addresses.  I think this is a necessary evil
>> for fsync since you don't have a VMA, but for msync we do and we can just
>> flush using the user addresses without any fs lookups.
> 
> Yet you're ignoring the fact that flushing the entire range of the
> relevant VMAs may not be very efficient. It may be a very
> large mapping with only a few pages that need flushing from the
> cache, but you still iterate the mappings flushing GB ranges from
> the cache at a time.
> 

So actually you are wrong about this. We have a working system and as part
of our testing rig we do performance measurements, constantly. Our random
mmap 4k writes test preforms very well and is in par with the random-direct-write
implementation even though on every unmap, we do a VMA->start/end cl_flushing.

The cl_flush operation is a no-op if the cacheline is not dirty and is a
memory bus storm with all the CLs that are dirty. So the only cost
is the iteration of vma->start-to-vma->end i+=64

Let us please agree that we should do the correct thing for now, and let
the complains roll in about the slowness later. You will find that my
proposed solution is not so slow.

> We don't need struct pages to track page dirty state. We already
> have a method for doing this that does not rely on having a struct
> page and can be used for efficient lookup of exact dirty ranges. i.e
> the per-page dirty tag that is kept in the mapping radix tree. It's
> fine grained, and extremely efficient in terms of lookups to find
> dirty pages.
> 

In fact you will find that this solution is actually slower. Because
you need an extra lock on every major-page-fault and you need to
maintain the radix-tree populated. Today with dax the radix-tree is
completely empty, it is only ever used if one reads in holes. But we
found that this is not common at all. Usually mmap applications read
what is really there.

So the extra work per page will be more than actually doing the fast
no-op cl_flush.

> Indeed, the mapping tree tags were specifically designed to avoid
> this "fsync doesn't know what range to flush" problem for normal
> files. That same problem still exists here for msync - these patches
> are just hitting it with a goddamn massive hammer "because it is
> easy" rather than attempting to do the flushing efficiently.
> 

You come from the disk world and every extra synced block is a huge waist.
This is memory, is not what you are used too.

Again we have benchmarks and mmap works very very well. Including that
contraption of cl_flushing vma->start..vma->end

I'll try and open up some time to send a rough draft. My boss will kill me,
but he'll survive.

Thanks
Boaz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
