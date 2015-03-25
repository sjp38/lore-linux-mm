Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id AA1036B0038
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 06:19:54 -0400 (EDT)
Received: by wibg7 with SMTP id g7so103532235wib.1
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 03:19:54 -0700 (PDT)
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com. [209.85.212.172])
        by mx.google.com with ESMTPS id h9si3502497wjy.213.2015.03.25.03.19.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Mar 2015 03:19:53 -0700 (PDT)
Received: by wixw10 with SMTP id w10so31414889wix.0
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 03:19:52 -0700 (PDT)
Message-ID: <55128BC6.7090105@plexistor.com>
Date: Wed, 25 Mar 2015 12:19:50 +0200
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3] RFC: dax: dax_prepare_freeze
References: <55100B78.501@plexistor.com> <55100D10.6090902@plexistor.com> <20150323224047.GQ28621@dastard> <551100E3.9010007@plexistor.com> <20150325022221.GA31342@dastard> <55126D77.7040105@plexistor.com> <20150325092922.GH31342@dastard>
In-Reply-To: <20150325092922.GH31342@dastard>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-nvdimm <linux-nvdimm@ml01.01.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Eryu Guan <eguan@redhat.com>

On 03/25/2015 11:29 AM, Dave Chinner wrote:
> On Wed, Mar 25, 2015 at 10:10:31AM +0200, Boaz Harrosh wrote:
>> On 03/25/2015 04:22 AM, Dave Chinner wrote:
>>> On Tue, Mar 24, 2015 at 08:14:59AM +0200, Boaz Harrosh wrote:
>> <>
<>
>> The sync does happen, .fsync of the FS is called on each
>> file just as if the user called it. If this is broken it just
>> needs to be fixed there at the .fsync vector. POSIX mandate
>> persistence at .fsync so at the vfs layer we rely on that.
> 
> right now, the filesystems will see that there are no dirty pages
> on the inode, and then just sync the inode metadata. They will do
> nothing else as filesystems are not aware of CPU cachelines at all.
> 

Sigh yes. There is this bug. And I am sitting on a wide fix for this.

The strategy is. All Kernel writes are done with a new copy_user_nt.
NT stands for none-temporal. This shows 20% improvements since cachelines
need not be fetched when written too.

The arches that do not have NT instructions, will use a generic
copy_user_nt that does a copy_user and then flush cashes.
Same flush cashes we do before DMA IO. (effectively every 4k)
[Its more complicated with the edges and all, by I have solved
 all this. Will post in a week or two]

So what is left is the mmaped inodes. The logic here is that
at .fsync vector dax inodes will do a cl_flush only if mapping_mapped()
is true. Also .msync is the same as .fsync

And one last thing we also call .fsync at vm_operations_struct->close
because it is allowed for an app to do mmap, munmap, .fsync so we just
call dax .fsync at munmap always.

So by now we should be covered for fsync guaranty.

>> So everything at this stage should be synced to real media.
> 
> Actually no. This is what intel are introducing new CPU instructions
> for - so fsync can flush the cpu caches and commit them to th
> persistence domain correctly.
> 

The new intel instructions are for an optimization, and they will
fit in the picture for the CPUs that have it. But there are already
NT instructions for existing CPUs. (Just not as fast and precise)

Every ARCH will do its best under a small API
	copy_user_nt	- data is at media
	memset_nt	- data is at media
	cl_flush	- partial written cachelines flushed to media 
	sfence		- New data seen by all CPUs

>> What does not happen is writeback. since dax does not have
>> any writeback.
> 
> Which is precisely the problem we need to address - we don't need
> writeback to a block device, but we do need the dirty CPU cachelines
> flushed and the mappings cleaned.
> 

I see what you mean. Since nothing dirtied the inode then above
.fsync will not be called and we have not pushed mmap data to
media.

Again here we only need to do this for mmaped inodes, because
Kernel written data is (will be) written NT style.

>> And because of that nothing turned the
>> user mappings to read only. This is what I do here but
>> instead of write-protecting I just unmap because it is
>> easier for me to code it.
> 
> That doesn't mean it is the correct solution.

Please note that even if we properly .fsync cachlines the page-faults
are orthogonal to this. There is no point in making mmapped dax pages
read-only after every .fsync and pay a page-fault. We should leave them
mapped has is. The only place that we need page protection is at freeze
time.

But I see that we might have a problem with .fsync not being called.
I see that you sent a second mail. I'll try to answer there.

> Cheers,
> Dave.

Thanks
Boaz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
