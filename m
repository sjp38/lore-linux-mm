Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 5BCB96B0038
	for <linux-mm@kvack.org>; Wed,  2 Sep 2015 12:00:05 -0400 (EDT)
Received: by wicge5 with SMTP id ge5so46082543wic.0
        for <linux-mm@kvack.org>; Wed, 02 Sep 2015 09:00:04 -0700 (PDT)
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com. [209.85.212.171])
        by mx.google.com with ESMTPS id u2si40465911wjz.147.2015.09.02.09.00.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Sep 2015 09:00:04 -0700 (PDT)
Received: by wicfx3 with SMTP id fx3so24119356wic.0
        for <linux-mm@kvack.org>; Wed, 02 Sep 2015 09:00:03 -0700 (PDT)
Message-ID: <55E71D00.4050103@plexistor.com>
Date: Wed, 02 Sep 2015 19:00:00 +0300
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
Subject: Re: [PATCH] dax, pmem: add support for msync
References: <1441047584-14664-1-git-send-email-ross.zwisler@linux.intel.com> <20150831233803.GO3902@dastard> <20150901070608.GA5482@lst.de> <20150901222120.GQ3902@dastard> <20150902031945.GA8916@linux.intel.com> <20150902051711.GS3902@dastard> <55E6CF15.4070105@plexistor.com> <55E70653.4090302@linux.intel.com> <55E7132E.104@plexistor.com> <55E7184B.3020104@linux.intel.com>
In-Reply-To: <55E7184B.3020104@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>, Dave Chinner <david@fromorbit.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, linux-kernel@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@osdl.org>, "H. Peter Anvin" <hpa@zytor.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, Matthew Wilcox <willy@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, x86@kernel.org

On 09/02/2015 06:39 PM, Dave Hansen wrote:
> On 09/02/2015 08:18 AM, Boaz Harrosh wrote:
>> On 09/02/2015 05:23 PM, Dave Hansen wrote:
>>>> I'd be curious what the cost is in practice.  Do you have any actual
>>>> numbers of the cost of doing it this way?
>>>>
>>>> Even if the instruction is a "noop", I'd really expect the overhead to
>>>> really add up for a tens-of-gigabytes mapping, no matter how much the
>>>> CPU optimizes it.
>> What tens-of-gigabytes mapping? I have yet to encounter an application
>> that does that. Our tests show that usually the mmaps are small.
> 
> We are going to have 2-socket systems with 6TB of persistent memory in
> them.  I think it's important to design this mechanism so that it scales
> to memory sizes like that and supports large mmap()s.
> 
> I'm not sure the application you've seen thus far are very
> representative of what we want to design for.
> 

We have a patch pending to introduce a new mmap flag that pmem aware
applications can set to eliminate any kind of flushing. MMAP_PMEM_AWARE.

This is good for the like of libnvdimm that does one large mmap of the
all 6T and does not want the clflush penalty on unmap.

>> I can send you a micro benchmark results of an mmap vs direct-io random
>> write. Our code will jump over holes in the file BTW, but I'll ask to also
>> run it with falloc that will make all blocks allocated.
> 
> I'm really just more curious about actual clflush performance on large
> ranges.  I'm curious how good the CPU is at optimizing it.
> 

Again our test does not do this, because it will only flush written-extents
of the file. the most we have in one machine is 64G of pmem, so even on a
very large mmap the most that can be is 64G of data, and the actual modify
of 64G of data will be much slower then the added clflush to each cache_line.

Thanks
Boaz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
