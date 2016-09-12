Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5AB506B0038
	for <linux-mm@kvack.org>; Mon, 12 Sep 2016 10:24:21 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id g202so363331266pfb.3
        for <linux-mm@kvack.org>; Mon, 12 Sep 2016 07:24:21 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id o1si21874120pfb.295.2016.09.12.07.24.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Sep 2016 07:24:20 -0700 (PDT)
Subject: Re: [PATCH 2/3] writeback: allow for dirty metadata accounting
References: <1471887302-12730-1-git-send-email-jbacik@fb.com>
 <1471887302-12730-3-git-send-email-jbacik@fb.com>
 <20160909081743.GC22777@quack2.suse.cz> <20160912004656.GA30497@dastard>
 <20160912073418.GA23870@quack2.suse.cz>
From: Josef Bacik <jbacik@fb.com>
Message-ID: <fc294980-dad2-512b-7768-165f4c7460f8@fb.com>
Date: Mon, 12 Sep 2016 10:24:12 -0400
MIME-Version: 1.0
In-Reply-To: <20160912073418.GA23870@quack2.suse.cz>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>
Cc: linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, kernel-team@fb.com, jack@suse.com, viro@zeniv.linux.org.uk, dchinner@redhat.com, hch@lst.de, linux-mm@kvack.org

Dave your reply got eaten somewhere along the way for me, so all i have is this 
email.  I'm going to respond to your stuff here.

On 09/12/2016 03:34 AM, Jan Kara wrote:
> On Mon 12-09-16 10:46:56, Dave Chinner wrote:
>> On Fri, Sep 09, 2016 at 10:17:43AM +0200, Jan Kara wrote:
>>> On Mon 22-08-16 13:35:01, Josef Bacik wrote:
>>>> Provide a mechanism for file systems to indicate how much dirty metadata they
>>>> are holding.  This introduces a few things
>>>>
>>>> 1) Zone stats for dirty metadata, which is the same as the NR_FILE_DIRTY.
>>>> 2) WB stat for dirty metadata.  This way we know if we need to try and call into
>>>> the file system to write out metadata.  This could potentially be used in the
>>>> future to make balancing of dirty pages smarter.
>>>
>>> So I'm curious about one thing: In the previous posting you have mentioned
>>> that the main motivation for this work is to have a simple support for
>>> sub-pagesize dirty metadata blocks that need tracking in btrfs. However you
>>> do the dirty accounting at page granularity. What are your plans to handle
>>> this mismatch?
>>>
>>> The thing is you actually shouldn't miscount by too much as that could
>>> upset some checks in mm checking how much dirty pages a node has directing
>>> how reclaim should be done... But it's a question whether NR_METADATA_DIRTY
>>> should be actually used in the checks in node_limits_ok() or in
>>> node_pagecache_reclaimable() at all because once you start accounting dirty
>>> slab objects, you are really on a thin ice...
>>
>> The other thing I'm concerned about is that it's a btrfs-only thing,
>> which means having dirty btrfs metadata on a system with different
>> filesystems (e.g. btrfs root/home, XFS data) is going to affect how
>> memory balance and throttling is run on other filesystems. i.e. it's
>> going ot make a filesystem specific issue into a problem that
>> affects global behaviour.
>
> Umm, I don't think it will be different than currently. Currently btrfs
> dirty metadata is accounted as dirty page cache because they have this
> virtual fs inode which owns all metadata pages. It is pretty similar to
> e.g. ext2 where you have bdev inode which effectively owns all metadata
> pages and these dirty pages account towards the dirty limits. For ext4
> things are more complicated due to journaling and thus ext4 hides the fact
> that a metadata page is dirty until the corresponding transaction is
> committed.  But from that moment on dirty metadata is again just a dirty
> pagecache page in the bdev inode.
>
> So current Josef's patch just splits the counter in which btrfs metadata
> pages would be accounted but effectively there should be no change in the
> behavior. It is just a question whether this approach is workable in the
> future when they'd like to track different objects than just pages in the
> counter.

+1 to what Jan said.  Btrfs's dirty metadata is always going to affect any other 
file systems in the system, no matter how we deal with it.  In fact it's worse 
with our btree_inode approach as the dirtied_when thing will likely screw 
somebody and make us skip writing out dirty metadata when we want to.  At least 
with this framework in place we can start to make the throttling smarter, so say 
make us flush metadata if that is the bigger % of the dirty pages in the system. 
  All I do now is move the status quo around, we are no worse, and arguably 
better with these patches than we were without them.

>
>>>> diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
>>>> index 56c8fda..d329f89 100644
>>>> --- a/fs/fs-writeback.c
>>>> +++ b/fs/fs-writeback.c
>>>> @@ -1809,6 +1809,7 @@ static unsigned long get_nr_dirty_pages(void)
>>>>  {
>>>>  	return global_node_page_state(NR_FILE_DIRTY) +
>>>>  		global_node_page_state(NR_UNSTABLE_NFS) +
>>>> +		global_node_page_state(NR_METADATA_DIRTY) +
>>>>  		get_nr_dirty_inodes();
>>>
>>> With my question is also connected this - when we have NR_METADATA_DIRTY,
>>> we could just account dirty inodes there and get rid of this
>>> get_nr_dirty_inodes() hack...
>>
>> Accounting of dirty inodes would have to applied to every
>> filesystem before that could be done, but....
>
> Well, this particular hack of adding get_nr_dirty_inodes() into the result
> of get_nr_dirty_pages() is there only so that we do writeback even if there
> are only dirty inodes without dirty pages. Since XFS doesn't care about
> writeback for dirty inodes, it would be fine regardless what we do here,
> won't it?
>
>>> But actually getting this to work right to be able to track dirty inodes would
>>> be useful on its own - some throlling of creation of dirty inodes would be
>>> useful for several filesystems (ext4, xfs, ...).
>>
>> ... this relies on the VFS being able to track and control all
>> dirtying of inodes and metadata.
>>
>> Which, it should be noted, cannot be done unconditionally because
>> some filesystems /explicitly avoid/ dirtying VFS inodes for anything
>> other than dirty data and provide no mechanism to the VFS for
>> writeback inodes or their related metadata. e.g. XFS, where all
>> metadata changes are transactional and so all dirty inode tracking
>> and writeback control is internal the to the XFS transaction
>> subsystem.
>>
>> Adding an external throttle to dirtying of metadata doesn't make any
>> sense in this sort of architecture - in XFS we already have all the
>> throttles and expedited writeback triggers integrated into the
>> transaction subsystem (e.g transaction reservation limits, log space
>> limits, periodic background writeback, memory reclaim triggers,
>> etc). It's all so tightly integrated around the physical structure
>> of the filesystem I can't see any way to sanely abstract it to work
>> with a generic "dirty list" accounting and writeback engine at this
>> point...
>
> OK, thanks for providing the details about XFS. So my idea was (and Josef's
> patches seem to be working towards this), that filesystems that decide to
> use the generic throttling, would just account the dirty metadata in some
> counter. That counter would be included in the limits checked by
> balance_dirty_pages(). Filesystem that don't want to use generic throttling
> would have the counter 0 and thus for them there'd be no difference. And in
> appropriate points after metadata was dirtied, filesystems that care could
> call balance_dirty_pages() to throttle the process creating dirty
> metadata.
>
>> I can see how tracking of information such as the global amount of
>> dirty metadata is useful for diagnostics, but I'm not convinced we
>> should be using it for globally scoped external control of deeply
>> integrated and highly specific internal filesystem functionality.
>
> You are right that when journalling comes in, things get more complex. But
> btrfs already uses a scheme similar to the above and I believe ext4 could
> be made to use a similar scheme as well. If you have something better for
> XFS, then that's good for you and we should make sure we don't interfere
> with that. Currently I don't think we will.

XFS doesn't have the problem that btrfs has, so I don't expect it to take 
advantage of this.  Your writeback throttling is tied to your journal 
transactions, which are already limited in size.  Btrfs on the other hand is 
only limited by the amount of memory in the system, which is why I want to 
leverage the global throttling code.  I went down this path years ago and tried 
to build the throttling intelligence into btrfs itself and that way lies 
dragons.  I cycled between OOM'ing the box and duplicating a bunch of the global 
counters inside btrfs.

Btrfs doesn't have the benefit of a arbitrary journal size constraint on it's 
dirty metadata, so we have to rely on the global limits to make sure we're kept 
in check.  The only thing my patches do is allow us to account for this 
separately and trigger writeback specifically.  Thanks,

Josef

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
