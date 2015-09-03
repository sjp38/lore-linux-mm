Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 9AD8E6B0254
	for <linux-mm@kvack.org>; Thu,  3 Sep 2015 02:32:07 -0400 (EDT)
Received: by wicmc4 with SMTP id mc4so8355839wic.0
        for <linux-mm@kvack.org>; Wed, 02 Sep 2015 23:32:07 -0700 (PDT)
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com. [209.85.212.175])
        by mx.google.com with ESMTPS id bs13si44483879wjb.207.2015.09.02.23.32.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Sep 2015 23:32:06 -0700 (PDT)
Received: by wiclp12 with SMTP id lp12so40517396wic.1
        for <linux-mm@kvack.org>; Wed, 02 Sep 2015 23:32:05 -0700 (PDT)
Message-ID: <55E7E962.2000607@plexistor.com>
Date: Thu, 03 Sep 2015 09:32:02 +0300
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
Subject: Re: [PATCH] dax, pmem: add support for msync
References: <1441047584-14664-1-git-send-email-ross.zwisler@linux.intel.com> <20150831233803.GO3902@dastard> <20150901070608.GA5482@lst.de> <55E597A1.9090205@plexistor.com> <20150902190401.GC32255@linux.intel.com>
In-Reply-To: <20150902190401.GC32255@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Andrew Morton <akpm@osdl.org>, Dave Hansen <dave.hansen@linux.intel.com>, linux-nvdimm@lists.01.org, Peter Zijlstra <peterz@infradead.org>, x86@kernel.org, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Alexander Viro <viro@zeniv.linux.org.uk>, "H. Peter Anvin" <hpa@zytor.com>, linux-fsdevel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On 09/02/2015 10:04 PM, Ross Zwisler wrote:
> On Tue, Sep 01, 2015 at 03:18:41PM +0300, Boaz Harrosh wrote:
<>
>> Apps expect all these to work:
>> 1. open mmap m-write msync ... close
>> 2. open mmap m-write fsync ... close
>> 3. open mmap m-write unmap ... fsync close
>>
>> 4. open mmap m-write sync ...
> 
> So basically you made close have an implicit fsync?  What about the flow that
> looks like this:
> 
> 5. open mmap close m-write
> 

What? no, close means ummap because you need a file* attached to your vma

And you miss-understood me, the vm_opts->close is the *unmap* operation not
the file::close() operation.

I meant memory-cl_flush on unmap before the vma goes away.

> This guy definitely needs an msync/fsync at the end to make sure that the
> m-write becomes durable.  
> 

Exactly done at unmap time.

> Also, the CLOSE(2) man page specifically says that a flush does not occur at
> close:
> 	A successful close does not guarantee that the data has been
> 	successfully  saved  to  disk,  as  the  kernel defers  writes.   It
> 	is not common for a filesystem to flush the buffers when the stream is
> 	closed.  If you need to be sure that the data is physically stored,
> 	use fsync(2).  (It will depend on the disk  hardware  at this point.)
> 
> I don't think that adding an implicit fsync to close is the right solution -
> we just need to get msync and fsync correctly working.
> 

So above is not relevant, and we are doing that. taking care of cpu-cache flushing.
This is not disk-flushing, on a long memcpy from usermode most of the data is
already durable, is only the leftover margins. Like the dax_io in the kernel
dax implies direct_io always, all we are trying is to have the least
performance hit in memory-cache-flushing.

IS nothing to do with the text above.

>> The first 3 are supported with above, because what happens is that at [3]
>> the fsync actually happens on unmap and fsync is redundant in that case.
>>
>> The only broken scenario is [3]. We do not have a list of "dax-dirty" inodes
>> per sb to iterate on and call inode-sync on. This cause problems mostly in
>> freeze because with actual [3] scenario the file will be eventually closed
>> and persistent, but after the call to sync returns.
>>
>> Its on my TODO to fix [3] based on instructions from Dave.
>> The mmap call will put the inode on the list and the dax_vm_close will
>> remove it. One of the regular dirty list should be used as suggested by
>> Dave.
> 
> I believe in the above two paragraphs you meant [4], so the 
> 
> 4. open mmap m-write sync ...
> 
> case needs to be fixed so that we can detect DAX-dirty inodes?
> 

Yes I'll be working on sync (DAX-dirty-i_list) soon but it needs a working
fsync to be in place (eg: dax_fsync(inode))

Thanks
Boaz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
