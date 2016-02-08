Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f174.google.com (mail-ob0-f174.google.com [209.85.214.174])
	by kanga.kvack.org (Postfix) with ESMTP id 445FA8309E
	for <linux-mm@kvack.org>; Sun,  7 Feb 2016 23:29:41 -0500 (EST)
Received: by mail-ob0-f174.google.com with SMTP id wb13so139750946obb.1
        for <linux-mm@kvack.org>; Sun, 07 Feb 2016 20:29:41 -0800 (PST)
Received: from mail-ob0-x244.google.com (mail-ob0-x244.google.com. [2607:f8b0:4003:c01::244])
        by mx.google.com with ESMTPS id q7si14196041obf.0.2016.02.07.20.29.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 07 Feb 2016 20:29:40 -0800 (PST)
Received: by mail-ob0-x244.google.com with SMTP id wg8so7338134obc.3
        for <linux-mm@kvack.org>; Sun, 07 Feb 2016 20:29:40 -0800 (PST)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (1.0)
Subject: Re: [PATCH 1/2] dax: pass bdev argument to dax_clear_blocks()
From: Ross Zwisler <zwisler@gmail.com>
In-Reply-To: <20160208014601.GB2343@linux.intel.com>
Date: Sun, 7 Feb 2016 21:29:38 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <00FE872A-9B2A-4492-A83C-59025ACB1F4A@gmail.com>
References: <1454829553-29499-1-git-send-email-ross.zwisler@linux.intel.com> <1454829553-29499-2-git-send-email-ross.zwisler@linux.intel.com> <CAPcyv4jOAKeTXt0EvZzfxzqcaf+ZWrtsFeN2JFP_sf1HcTpVOw@mail.gmail.com> <20160208014601.GB2343@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Dan Williams <dan.j.williams@intel.com>, Theodore Ts'o <tytso@mit.edu>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Dave Chinner <david@fromorbit.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, XFS Developers <xfs@oss.sgi.com>, Linux MM <linux-mm@kvack.org>, Andreas Dilger <adilger.kernel@dilger.ca>, Alexander Viro <viro@zeniv.linux.org.uk>, Jan Kara <jack@suse.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>

> On Feb 7, 2016, at 6:46 PM, Ross Zwisler <ross.zwisler@linux.intel.com> wr=
ote:
>=20
>> On Sun, Feb 07, 2016 at 10:19:29AM -0800, Dan Williams wrote:
>> On Sat, Feb 6, 2016 at 11:19 PM, Ross Zwisler
>> <ross.zwisler@linux.intel.com> wrote:
>>> dax_clear_blocks() needs a valid struct block_device and previously it w=
as
>>> using inode->i_sb->s_bdev in all cases.  This is correct for normal inod=
es
>>> on mounted ext2, ext4 and XFS filesystems, but is incorrect for DAX raw
>>> block devices and for XFS real-time devices.
>>>=20
>>> Instead, have the caller pass in a struct block_device pointer which it
>>> knows to be correct.
>>>=20
>>> Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
>>> ---
>>> fs/dax.c               | 4 ++--
>>> fs/ext2/inode.c        | 5 +++--
>>> fs/xfs/xfs_aops.c      | 2 +-
>>> fs/xfs/xfs_aops.h      | 1 +
>>> fs/xfs/xfs_bmap_util.c | 4 +++-
>>> include/linux/dax.h    | 3 ++-
>>> 6 files changed, 12 insertions(+), 7 deletions(-)
>>>=20
>>> diff --git a/fs/dax.c b/fs/dax.c
>>> index 227974a..4592241 100644
>>> --- a/fs/dax.c
>>> +++ b/fs/dax.c
>>> @@ -83,9 +83,9 @@ struct page *read_dax_sector(struct block_device *bdev=
, sector_t n)
>>>  * and hence this means the stack from this point must follow GFP_NOFS
>>>  * semantics for all operations.
>>>  */
>>> -int dax_clear_blocks(struct inode *inode, sector_t block, long _size)
>>> +int dax_clear_blocks(struct inode *inode, struct block_device *bdev,
>>> +               sector_t block, long _size)
>>=20
>> Since this is a bdev relative routine we should also resolve the
>> sector, i.e. the signature should drop the inode:
>>=20
>> int dax_clear_sectors(struct block_device *bdev, sector_t sector, long _s=
ize)
>=20
> The inode is still needed because dax_clear_blocks() needs inode->i_blkbit=
s.
> Unless there is some easy way to get this from the bdev that I'm not seein=
g?

Never mind, you are passing in the sector, not the block.  Sure, this seems b=
etter - I'll fix this for v2.=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
