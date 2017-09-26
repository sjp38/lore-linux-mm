Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id D322E6B0069
	for <linux-mm@kvack.org>; Tue, 26 Sep 2017 14:02:52 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id a74so14139684oib.7
        for <linux-mm@kvack.org>; Tue, 26 Sep 2017 11:02:52 -0700 (PDT)
Received: from sandeen.net (sandeen.net. [63.231.237.45])
        by mx.google.com with ESMTP id i190si8140025ioa.296.2017.09.26.11.02.51
        for <linux-mm@kvack.org>;
        Tue, 26 Sep 2017 11:02:51 -0700 (PDT)
Subject: Re: [PATCH 1/7] xfs: always use DAX if mount option is used
References: <20170925231404.32723-1-ross.zwisler@linux.intel.com>
 <20170925231404.32723-2-ross.zwisler@linux.intel.com>
 <20170925233812.GM10955@dastard> <20170926093548.GB13627@quack2.suse.cz>
 <20170926110957.GR10955@dastard>
From: Eric Sandeen <sandeen@sandeen.net>
Message-ID: <6c5375da-882e-2063-8ebf-007d0e6aa7e9@sandeen.net>
Date: Tue, 26 Sep 2017 13:02:50 -0500
MIME-Version: 1.0
In-Reply-To: <20170926110957.GR10955@dastard>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, "Darrick J. Wong" <darrick.wong@oracle.com>, "J. Bruce Fields" <bfields@fieldses.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Jeff Layton <jlayton@poochiereds.net>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org



On 9/26/17 6:09 AM, Dave Chinner wrote:
> On Tue, Sep 26, 2017 at 11:35:48AM +0200, Jan Kara wrote:
>> On Tue 26-09-17 09:38:12, Dave Chinner wrote:
>>> On Mon, Sep 25, 2017 at 05:13:58PM -0600, Ross Zwisler wrote:
>>>> Before support for the per-inode DAX flag was disabled the XFS the code had
>>>> an issue where the user couldn't reliably tell whether or not DAX was being
>>>> used to service page faults and I/O when the DAX mount option was used.  In
>>>> this case each inode within the mounted filesystem started with S_DAX set
>>>> due to the mount option, but it could be cleared if someone touched the
>>>> individual inode flag.
>>>>
>>>> For example (v4.13 and before):
>>>>
>>>>   # mount | grep dax
>>>>   /dev/pmem0 on /mnt type xfs
>>>>   (rw,relatime,seclabel,attr2,dax,inode64,sunit=4096,swidth=4096,noquota)
>>>>
>>>>   # touch /mnt/a /mnt/b   # both files currently use DAX
>>>>
>>>>   # xfs_io -c "lsattr" /mnt/*  # neither has the DAX inode option set
>>>>   ----------e----- /mnt/a
>>>>   ----------e----- /mnt/b
>>>>
>>>>   # xfs_io -c "chattr -x" /mnt/a  # this clears S_DAX for /mnt/a
>>>>
>>>>   # xfs_io -c "lsattr" /mnt/*
>>>>   ----------e----- /mnt/a
>>>>   ----------e----- /mnt/b
>>>
>>> That's really a bug in the lsattr code, yes? If we've cleared the
>>> S_DAX flag for the inode, then why is it being reported in lsattr?
>>> Or if we failed to clear the S_DAX flag in the 'chattr -x' call,
>>> then isn't that the bug that needs fixing?
>>>
>>> Remember, the whole point of the dax inode flag was to be able to
>>> override the mount option setting so that admins could turn off/on
>>> dax for the things that didn't/did work with DAX correctly so they
>>> didn't need multiple filesystems on pmem to segregate the apps that
>>> did/didn't work with DAX...
>>
>> So I think there is some confusion that is created by the fact that whether
>> DAX is used or not is controlled by both a mount option and an inode flag.
>> We could define that "Inode flag always wins" which is what you seem to
>> suggest above but then mount option has no practical effect since on-disk
>> S_DAX flag will always overrule it.
> 
> Well, quite frankly, I never wanted the mount option for XFS. It was
> supposed to be for initial testing only, then we'd /always/ use the
> the inode flags. For a filesystem to default to using DAX, we
> set the DAX flag on the root inode at mkfs time, and then everything
> inode flag based just works.
> 
> But it seems that we're now stuck with the stupid, blunt, brute
> force mount option because that's what the first commit on ext4
> used.  Now we're just about stuck with this silly "but we can't turn
> it off" problem because of the mount option overriding everything.

I don't think the existence of a mount option in ext4 makes us any
more "stuck" than the mount option in xfs does.

fs/xfs/xfs_super.c:		"DAX enabled. Warning: EXPERIMENTAL, use at your own risk");
fs/ext4/super.c:		"DAX enabled. Warning: EXPERIMENTAL, use at your own risk");

so when^wif this argument ever gets settled, I think there is plenty
of latitude to do the right thing, potentially breaking the old thing.

> If we have to keep the mount option, then lets fix it to mean "mount
> option sets inheritable inode flag on directory creation" and
> /maybe/ "mount option sets inode flag on file creation".
> 
> This then allows the inode flag to control everything else. i.e the
> mount option sets the initial flag value rather than the behaviour
> of the inode. The behaviour of the inode should be entirely
> controlled by the inode flag, hence after initial creation the
> chattr +/-x commands do what they advertise regardless of the mount
> option value.
> 
> Yes, it means that existing users are going to have to run chattr -R
> +x on their pmem filesystems to get the inode flags on disk, but
> this is all tagged with EXPERIMENTAL and this is the sort of change
  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
> that is expected from experimental functionality.

Right.

-Eric

> Cheers,
> 
> Dave.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
