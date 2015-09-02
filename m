Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id E39896B0254
	for <linux-mm@kvack.org>; Wed,  2 Sep 2015 10:23:33 -0400 (EDT)
Received: by pacfv12 with SMTP id fv12so13517484pac.2
        for <linux-mm@kvack.org>; Wed, 02 Sep 2015 07:23:33 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id ik2si18774095pbb.38.2015.09.02.07.23.32
        for <linux-mm@kvack.org>;
        Wed, 02 Sep 2015 07:23:32 -0700 (PDT)
Subject: Re: [PATCH] dax, pmem: add support for msync
References: <1441047584-14664-1-git-send-email-ross.zwisler@linux.intel.com>
 <20150831233803.GO3902@dastard> <20150901070608.GA5482@lst.de>
 <20150901222120.GQ3902@dastard> <20150902031945.GA8916@linux.intel.com>
 <20150902051711.GS3902@dastard> <55E6CF15.4070105@plexistor.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <55E70653.4090302@linux.intel.com>
Date: Wed, 2 Sep 2015 07:23:15 -0700
MIME-Version: 1.0
In-Reply-To: <55E6CF15.4070105@plexistor.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boaz Harrosh <boaz@plexistor.com>, Dave Chinner <david@fromorbit.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, linux-kernel@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@osdl.org>, "H. Peter Anvin" <hpa@zytor.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, Matthew Wilcox <willy@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, x86@kernel.org

On 09/02/2015 03:27 AM, Boaz Harrosh wrote:
>> > Yet you're ignoring the fact that flushing the entire range of the
>> > relevant VMAs may not be very efficient. It may be a very
>> > large mapping with only a few pages that need flushing from the
>> > cache, but you still iterate the mappings flushing GB ranges from
>> > the cache at a time.
>> > 
> So actually you are wrong about this. We have a working system and as part
> of our testing rig we do performance measurements, constantly. Our random
> mmap 4k writes test preforms very well and is in par with the random-direct-write
> implementation even though on every unmap, we do a VMA->start/end cl_flushing.
> 
> The cl_flush operation is a no-op if the cacheline is not dirty and is a
> memory bus storm with all the CLs that are dirty. So the only cost
> is the iteration of vma->start-to-vma->end i+=64

I'd be curious what the cost is in practice.  Do you have any actual
numbers of the cost of doing it this way?

Even if the instruction is a "noop", I'd really expect the overhead to
really add up for a tens-of-gigabytes mapping, no matter how much the
CPU optimizes it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
