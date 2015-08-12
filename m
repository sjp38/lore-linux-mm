Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id A9F726B0038
	for <linux-mm@kvack.org>; Wed, 12 Aug 2015 04:51:10 -0400 (EDT)
Received: by wicne3 with SMTP id ne3so208862831wic.1
        for <linux-mm@kvack.org>; Wed, 12 Aug 2015 01:51:10 -0700 (PDT)
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com. [209.85.212.171])
        by mx.google.com with ESMTPS id op3si9367798wjc.25.2015.08.12.01.51.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Aug 2015 01:51:08 -0700 (PDT)
Received: by wicne3 with SMTP id ne3so208861722wic.1
        for <linux-mm@kvack.org>; Wed, 12 Aug 2015 01:51:08 -0700 (PDT)
Message-ID: <55CB08F9.6030901@plexistor.com>
Date: Wed, 12 Aug 2015 11:51:05 +0300
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
Subject: Re: [PATCH, RFC 2/2] dax: use range_lock instead of i_mmap_lock
References: <1439219664-88088-1-git-send-email-kirill.shutemov@linux.intel.com> <1439219664-88088-3-git-send-email-kirill.shutemov@linux.intel.com> <20150811081909.GD2650@quack.suse.cz> <20150811093708.GB906@dastard> <20150811135004.GC2659@quack.suse.cz> <55CA0728.7060001@plexistor.com> <100D68C7BA14664A8938383216E40DE040914C3E@FMSMSX114.amr.corp.intel.com> <20150811214822.GA20596@dastard>
In-Reply-To: <20150811214822.GA20596@dastard>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>, "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>
Cc: Boaz Harrosh <boaz@plexistor.com>, Jan Kara <jack@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Davidlohr Bueso <dbueso@suse.de>

On 08/12/2015 12:48 AM, Dave Chinner wrote:
> On Tue, Aug 11, 2015 at 04:51:22PM +0000, Wilcox, Matthew R wrote:
>> The race that you're not seeing is page fault vs page fault.  Two
>> threads each attempt to store a byte to different locations on the
>> same page.  With a read-mutex to exclude truncates, each thread
>> calls ->get_block.  One of the threads gets back a buffer marked
>> as BH_New and calls memset() to clear the page.  The other thread
>> gets back a buffer which isn't marked as BH_New and simply inserts
>> the mapping, returning to userspace, which stores the byte ...
>> just in time for the other thread's memset() to write a zero over
>> the top of it.
> 
> So, this is not a truncate race that the XFS MMAPLOCK solves.
> 
> However, that doesn't mean that the DAX code needs to add locking to
> solve it. The race here is caused by block initialisation being
> unserialised after a ->get_block call allocates the block (which the
> filesystem serialises via internal locking). Hence two simultaneous
> ->get_block calls to the same block is guaranteed to have the DAX
> block initialisation race with the second ->get_block call that says
> the block is already allocated.
> 
> IOWs, the way to handle this is to have the ->get_block call handle
> the block zeroing for new blocks instead of doing it after the fact
> in the generic DAX code where there is no fine-grained serialisation
> object available. By calling dax_clear_blocks() in the ->get_block
> callback, the filesystem can ensure that the second racing call will
> only make progress once the block has been fully initialised by the
> first call.
> 
> IMO the fix is - again - to move the functionality into the
> filesystem where we already have the necessary exclusion in place to
> avoid this race condition entirely.
> 

Exactly, thanks

> Cheers,
> 
> Dave.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
