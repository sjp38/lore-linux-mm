Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id C069B6B0038
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 04:31:28 -0400 (EDT)
Received: by wixw10 with SMTP id w10so68773874wix.0
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 01:31:28 -0700 (PDT)
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com. [74.125.82.45])
        by mx.google.com with ESMTPS id p12si3026079wjr.195.2015.03.25.01.31.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Mar 2015 01:31:25 -0700 (PDT)
Received: by wgra20 with SMTP id a20so18411321wgr.3
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 01:31:25 -0700 (PDT)
Message-ID: <5512725A.1010905@plexistor.com>
Date: Wed, 25 Mar 2015 10:31:22 +0200
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3] RFC: dax: dax_prepare_freeze
References: <55100B78.501@plexistor.com> <55100D10.6090902@plexistor.com> <55115A99.40705@plexistor.com> <20150325022633.GB31342@dastard>
In-Reply-To: <20150325022633.GB31342@dastard>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-nvdimm <linux-nvdimm@ml01.01.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Eryu Guan <eguan@redhat.com>

On 03/25/2015 04:26 AM, Dave Chinner wrote:
<>
>>> +	/* TODO: each DAX fs has some private mount option to enable DAX. If
>>> +	 * We made that option a generic MS_DAX_ENABLE super_block flag we could
>>> +	 * Avoid the 95% extra unneeded loop-on-all-inodes every freeze.
>>> +	 * if (!(sb->s_flags & MS_DAX_ENABLE))
>>> +	 *	return 0;
>>> +	 */
>>> +
>>> +	list_for_each_entry(inode, &sb->s_inodes, i_sb_list) {
> 
> missing locking.
> 

I will please need help here. This is very deep inside the freeze process
we area already holding bunch of locks. We know that nothing can be modified
at this stage. We are completely read-only.

Only thing I can see that can happen is inode eviction do to oom. So
do I need an iget. But how do I know the iget is allowed here?

OK I do not have a clue what locks do I need, this deep in the freeze?

>>> +		/* TODO: For freezing we can actually do with write-protecting
>>> +		 * the page. But I cannot find a ready made function that does
>>> +		 * that for a giving mapping (with all the proper locking).
>>> +		 * How performance sensitive is the all sb_freeze API?
>>> +		 * For now we can just unmap the all mapping, and pay extra
>>> +		 * on read faults.
>>> +		 */
>>> +		/* NOTE: Do not unmap private COW mapped pages it will not
>>> +		 * modify the FS.
>>> +		 */
>>> +		if (IS_DAX(inode))
>>> +			unmap_mapping_range(inode->i_mapping, 0, 0, 0);
>>
>> So what happens here is that we loop on all sb->s_inodes every freeze
>> and in the not DAX case just do nothing.
> 
> Which is real bad and known to be a performance issue. See Josef's
> recent sync scalability patchset posting that only tracks and walks
> dirty inodes...
> 

Sure but how hot is freeze? Josef's fixed the very hot sync path,
but freeze happens once in a blue moon. Do we care?

>> It could be nice to have a flag at the sb level to tel us if we need
>> to expect IS_DAX() inodes at all, for example when we are mounted on
>> an harddisk it should not be set.
>>
>> All of ext2/4 and now Dave's xfs have their own
>> 	XFS_MOUNT_DAX / EXT2_MOUNT_DAX / EXT4_MOUNT_DAX
>>
>> Is it OK if I unify all this on sb->s_flags |= MS_MOUNT_DAX so I can check it
>> here in Generic code? The option parsing will be done by each FS but
>> the flag be global?
> 
> No, because as I mentioned in another thread we're going to end up
> with filesystems that don't have "mount wide" DAX behaviour, and we
> have to check every dirty inode anyway. And....
> 

Sure! but let us contract with the FS, that please set the MS_MOUNT_DAX
if there is any chance at all that IS_DAX() comes out true, so we loop
here. 

OK You know what, I will change this check to be:
	if (sb->s_bdev->bd_disk->fops->direct_access)

BTW: We must loop this way on every sb inode because we do not have
dirty inodes. There is no "dirty"ing going on in dax, not of inodes
and not of pages.

>>> diff --git a/fs/super.c b/fs/super.c
>>> index 2b7dc90..9ef490c 100644
>>> --- a/fs/super.c
>>> +++ b/fs/super.c
>>> @@ -1329,6 +1329,9 @@ int freeze_super(struct super_block *sb)
>>>  	/* All writers are done so after syncing there won't be dirty data */
>>>  	sync_filesystem(sb);
>>>  
>>> +	/* Need to take care of DAX mmaped inodes */
>>> +	dax_prepare_freeze(sb);
>>> +
>>
>> So if CONFIG_FS_DAX is not set this will not compile I need to
>> define an empty one if not set
> 
> ... it's the wrong approach - sync_filesystem(sb) shoul dbe handling
> this problem, so that sync and fsync work correctly, and then you
> don't care about whether DAX is supported or not...
> 

sync and fsync should and will work correctly, but this does not
solve our problem. because what turns pages to read-only is the
writeback. And we do not have this in dax. Therefore we need to
do this here as a special case.

> Cheers,
> Dave.
> 

I have a new patchset with all this, I will send it once it is fully
tested, I have problems testing both freeze and splice there are not
any good tests that I could find that do what I want, so still working.

Thanks
Boaz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
