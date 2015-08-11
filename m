Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 8B6706B0038
	for <linux-mm@kvack.org>; Tue, 11 Aug 2015 07:09:49 -0400 (EDT)
Received: by wijp15 with SMTP id p15so171462200wij.0
        for <linux-mm@kvack.org>; Tue, 11 Aug 2015 04:09:49 -0700 (PDT)
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com. [209.85.212.177])
        by mx.google.com with ESMTPS id gm12si2964434wjc.83.2015.08.11.04.09.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Aug 2015 04:09:47 -0700 (PDT)
Received: by wicja10 with SMTP id ja10so63941457wic.1
        for <linux-mm@kvack.org>; Tue, 11 Aug 2015 04:09:47 -0700 (PDT)
Message-ID: <55C9D7F7.20008@plexistor.com>
Date: Tue, 11 Aug 2015 14:09:43 +0300
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
Subject: Re: [PATCH, RFC 2/2] dax: use range_lock instead of i_mmap_lock
References: <1439219664-88088-1-git-send-email-kirill.shutemov@linux.intel.com> <1439219664-88088-3-git-send-email-kirill.shutemov@linux.intel.com> <20150811081909.GD2650@quack.suse.cz> <20150811093708.GB906@dastard>
In-Reply-To: <20150811093708.GB906@dastard>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Davidlohr Bueso <dbueso@suse.de>

On 08/11/2015 12:37 PM, Dave Chinner wrote:
> On Tue, Aug 11, 2015 at 10:19:09AM +0200, Jan Kara wrote:
>> On Mon 10-08-15 18:14:24, Kirill A. Shutemov wrote:
>>> As we don't have struct pages for DAX memory, Matthew had to find an
>>> replacement for lock_page() to avoid fault vs. truncate races.
>>> i_mmap_lock was used for that.
>>>
>>> Recently, Matthew had to convert locking to exclusive to address fault
>>> vs. fault races. And this kills scalability completely.
> 
> I'm assuming this locking change is in a for-next git tree branch
> somewhere as there isn't anything that I can see in a 4.2-rc6
> tree. Can you point me to the git tree that has these changes in it?
> 
>>> The patch below tries to recover some scalability for DAX by introducing
>>> per-mapping range lock.
>>
>> So this grows noticeably (3 longs if I'm right) struct address_space and
>> thus struct inode just for DAX. That looks like a waste but I don't see an
>> easy solution.
>>
>> OTOH filesystems in normal mode might want to use the range lock as well to
>> provide truncate / punch hole vs page fault exclusion (XFS already has a
>> private rwsem for this and ext4 needs something as well) and at that point
>> growing generic struct inode would be acceptable for me.
> 
> It sounds to me like the way DAX has tried to solve this race is the
> wrong direction. We really need to drive the truncate/page fault
> serialisation higher up the stack towards the filesystem, not deeper
> into the mm subsystem where locking is greatly limited.
> 
> As Jan mentions, we already have this serialisation in XFS, and I
> think it would be better first step to replicate that locking model
> in each filesystem that is supports DAX. I think this is a better
> direction because it moves towards solving a whole class of problems
> fileystem face with page fault serialisation, not just for DAX.
> 
>> My grand plan was to use the range lock to also simplify locking
>> rules for read, write and esp. direct IO but that has issues with
>> mmap_sem ordering because filesystems get called under mmap_sem in
>> page fault path. So probably just fixing the worst issue with
>> punch hole vs page fault would be good for now.
> 
> Right, I think adding a rwsem to the ext4 inode to handle the
> fault/truncate serialisation similar to XFS would be sufficient to
> allow DAX to remove the i_mmap_lock serialisation...
> 
>> Also for a patch set like this, it would be good to show some numbers - how
>> big hit do you take in the single-threaded case (the lock is more
>> expensive) and how much scalability do you get in the multithreaded case?
> 
> And also, if you remove the serialisation and run the test on XFS,
> what do you get in terms of performance and correctness?
> 
> Cheers,
> 

Cheers indeed

It is very easy to serialise at the FS level which has control over the
truncate path as well. Is much harder and uglier on the mm side.

Currently there is DAX for xfs, and  ext2, ext4. With xfs's implementation
I think removing the lock completely will just work. If I read the code
correctly.

With ext2/4 you can at worse add the struct range_lock_tree to its private
inode structure and again only if dax is configured. And use that at the
fault wrappers. But I suspect there should be an easier way once at the
ext2/4 code level, and no need for generalization.

I think the xfs case, of "no locks needed at all", calls for removing the
locks at the mm/dax level and moving them up to the FS.

> Dave.
> 

Thanks
Boaz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
