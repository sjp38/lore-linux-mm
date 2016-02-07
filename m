Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f176.google.com (mail-yw0-f176.google.com [209.85.161.176])
	by kanga.kvack.org (Postfix) with ESMTP id A1BA9830AE
	for <linux-mm@kvack.org>; Sun,  7 Feb 2016 13:19:30 -0500 (EST)
Received: by mail-yw0-f176.google.com with SMTP id q190so88161314ywd.3
        for <linux-mm@kvack.org>; Sun, 07 Feb 2016 10:19:30 -0800 (PST)
Received: from mail-yw0-x236.google.com (mail-yw0-x236.google.com. [2607:f8b0:4002:c05::236])
        by mx.google.com with ESMTPS id f126si9391395ywc.329.2016.02.07.10.19.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 07 Feb 2016 10:19:29 -0800 (PST)
Received: by mail-yw0-x236.google.com with SMTP id g127so88032688ywf.2
        for <linux-mm@kvack.org>; Sun, 07 Feb 2016 10:19:29 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1454829553-29499-2-git-send-email-ross.zwisler@linux.intel.com>
References: <1454829553-29499-1-git-send-email-ross.zwisler@linux.intel.com>
	<1454829553-29499-2-git-send-email-ross.zwisler@linux.intel.com>
Date: Sun, 7 Feb 2016 10:19:29 -0800
Message-ID: <CAPcyv4jOAKeTXt0EvZzfxzqcaf+ZWrtsFeN2JFP_sf1HcTpVOw@mail.gmail.com>
Subject: Re: [PATCH 1/2] dax: pass bdev argument to dax_clear_blocks()
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.com>, Matthew Wilcox <willy@linux.intel.com>, linux-ext4 <linux-ext4@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, XFS Developers <xfs@oss.sgi.com>

On Sat, Feb 6, 2016 at 11:19 PM, Ross Zwisler
<ross.zwisler@linux.intel.com> wrote:
> dax_clear_blocks() needs a valid struct block_device and previously it was
> using inode->i_sb->s_bdev in all cases.  This is correct for normal inodes
> on mounted ext2, ext4 and XFS filesystems, but is incorrect for DAX raw
> block devices and for XFS real-time devices.
>
> Instead, have the caller pass in a struct block_device pointer which it
> knows to be correct.
>
> Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> ---
>  fs/dax.c               | 4 ++--
>  fs/ext2/inode.c        | 5 +++--
>  fs/xfs/xfs_aops.c      | 2 +-
>  fs/xfs/xfs_aops.h      | 1 +
>  fs/xfs/xfs_bmap_util.c | 4 +++-
>  include/linux/dax.h    | 3 ++-
>  6 files changed, 12 insertions(+), 7 deletions(-)
>
> diff --git a/fs/dax.c b/fs/dax.c
> index 227974a..4592241 100644
> --- a/fs/dax.c
> +++ b/fs/dax.c
> @@ -83,9 +83,9 @@ struct page *read_dax_sector(struct block_device *bdev, sector_t n)
>   * and hence this means the stack from this point must follow GFP_NOFS
>   * semantics for all operations.
>   */
> -int dax_clear_blocks(struct inode *inode, sector_t block, long _size)
> +int dax_clear_blocks(struct inode *inode, struct block_device *bdev,
> +               sector_t block, long _size)

Since this is a bdev relative routine we should also resolve the
sector, i.e. the signature should drop the inode:

int dax_clear_sectors(struct block_device *bdev, sector_t sector, long _size)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
