Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 82F996B006E
	for <linux-mm@kvack.org>; Thu, 26 Mar 2015 04:02:13 -0400 (EDT)
Received: by wibg7 with SMTP id g7so10417896wib.1
        for <linux-mm@kvack.org>; Thu, 26 Mar 2015 01:02:13 -0700 (PDT)
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com. [209.85.212.178])
        by mx.google.com with ESMTPS id p12si8554546wjr.195.2015.03.26.01.02.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Mar 2015 01:02:12 -0700 (PDT)
Received: by wiaa2 with SMTP id a2so10576627wia.0
        for <linux-mm@kvack.org>; Thu, 26 Mar 2015 01:02:11 -0700 (PDT)
Message-ID: <5513BD01.5080603@plexistor.com>
Date: Thu, 26 Mar 2015 10:02:09 +0200
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3] RFC: dax: dax_prepare_freeze
References: <55100B78.501@plexistor.com> <55100D10.6090902@plexistor.com> <20150323224047.GQ28621@dastard> <551100E3.9010007@plexistor.com> <20150325022221.GA31342@dastard> <55126D77.7040105@plexistor.com> <20150325092922.GH31342@dastard> <55128BC6.7090105@plexistor.com> <20150325200024.GJ31342@dastard>
In-Reply-To: <20150325200024.GJ31342@dastard>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-nvdimm <linux-nvdimm@ml01.01.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Eryu Guan <eguan@redhat.com>

On 03/25/2015 10:00 PM, Dave Chinner wrote:
> On Wed, Mar 25, 2015 at 12:19:50PM +0200, Boaz Harrosh wrote:
>> On 03/25/2015 11:29 AM, Dave Chinner wrote:
>>> On Wed, Mar 25, 2015 at 10:10:31AM +0200, Boaz Harrosh wrote:
>>>> On 03/25/2015 04:22 AM, Dave Chinner wrote:
>>>>> On Tue, Mar 24, 2015 at 08:14:59AM +0200, Boaz Harrosh wrote:
>>>> <>
>> <>
>>>> The sync does happen, .fsync of the FS is called on each
>>>> file just as if the user called it. If this is broken it just
>>>> needs to be fixed there at the .fsync vector. POSIX mandate
>>>> persistence at .fsync so at the vfs layer we rely on that.
>>>
>>> right now, the filesystems will see that there are no dirty pages
>>> on the inode, and then just sync the inode metadata. They will do
>>> nothing else as filesystems are not aware of CPU cachelines at all.
>>>
>>
>> Sigh yes. There is this bug. And I am sitting on a wide fix for this.
>>
>> The strategy is. All Kernel writes are done with a new copy_user_nt.
>> NT stands for none-temporal. This shows 20% improvements since cachelines
>> need not be fetched when written too.
> 
> That's unenforcable for mmap writes from userspace. And those are
> the writes that will trigger the dirty write mapping problem.
> 

So for them I was thinking of just doing the .fsync on every
unmap (ie vm_operations_struct->close)

So now we know that only inodes that have an active vm mapping
are in need of sync.

>>>> And because of that nothing turned the
>>>> user mappings to read only. This is what I do here but
>>>> instead of write-protecting I just unmap because it is
>>>> easier for me to code it.
>>>
>>> That doesn't mean it is the correct solution.
>>
>> Please note that even if we properly .fsync cachlines the page-faults
>> are orthogonal to this. There is no point in making mmapped dax pages
>> read-only after every .fsync and pay a page-fault. We should leave them
>> mapped has is. The only place that we need page protection is at freeze
>> time.
> 
> Actually, current behaviour of filesystems is that fsync cleans all
> the pages in the range, and means all the mappings are marked
> read-only and so we get new calls into .page_mkwrite when write
> faults occur. We need that .page_mkwrite call to be able to a)
> update the mtime of the inode, and b) mark the inode "data dirty" so
> that fsync knows it needs to do something....
> 
> Hence I'd much prefer we start with identical behaviour to normal
> files, then we can optimise from a sane start point when write page
> faults show up as a performance problem. i.e. Correctness first,
> performance second.
> 

OK, (you see when you speak slow I understand fast ;-)). I agree then
I'll see if I can schedule some time for this. My boss will be very
angry with me about this. But I will need help please, and some hands
holding. Unless someone else volunteers to work on this ?

> Cheers,
> Dave.
> 

Thanks
Boaz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
