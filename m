Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id A9D236B00B0
	for <linux-mm@kvack.org>; Tue, 22 Sep 2009 10:36:07 -0400 (EDT)
Date: Tue, 22 Sep 2009 15:36:04 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH 5/7] ext4: Convert filesystem to the new truncate
	calling convention
Message-ID: <20090922143604.GA2183@ZenIV.linux.org.uk>
References: <1253200907-31392-1-git-send-email-jack@suse.cz> <1253200907-31392-6-git-send-email-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1253200907-31392-6-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
To: Jan Kara <jack@suse.cz>
Cc: linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-ext4@vger.kernel.org, linux-mm@kvack.org, npiggin@suse.de, tytso@mit.edu
List-ID: <linux-mm.kvack.org>

On Thu, Sep 17, 2009 at 05:21:45PM +0200, Jan Kara wrote:
> CC: linux-ext4@vger.kernel.org
> CC: tytso@mit.edu
> Signed-off-by: Jan Kara <jack@suse.cz>
> ---
>  fs/ext4/file.c  |    2 +-
>  fs/ext4/inode.c |  166 ++++++++++++++++++++++++++++++++----------------------
>  2 files changed, 99 insertions(+), 69 deletions(-)
> 
> diff --git a/fs/ext4/file.c b/fs/ext4/file.c
> index 3f1873f..22f49d7 100644
> --- a/fs/ext4/file.c
> +++ b/fs/ext4/file.c
> @@ -198,7 +198,7 @@ const struct file_operations ext4_file_operations = {
>  };
>  
>  const struct inode_operations ext4_file_inode_operations = {
> -	.truncate	= ext4_truncate,
> +	.new_truncate	= 1,
>  	.setattr	= ext4_setattr,
>  	.getattr	= ext4_getattr,
>  #ifdef CONFIG_EXT4_FS_XATTR
> diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
> index 58492ab..be25874 100644
> --- a/fs/ext4/inode.c
> +++ b/fs/ext4/inode.c
> @@ -3354,6 +3354,7 @@ static int ext4_journalled_set_page_dirty(struct page *page)
>  }
>  
>  static const struct address_space_operations ext4_ordered_aops = {
> +	.new_writepage		= 1,

No.  We already have one half-finished series here; mixing it with another
one is not going to happen.  Such flags are tolerable only as bisectability
helpers.  They *must* disappear by the end of series.  Before it can be
submitted for merge.

In effect, you are mixing truncate switchover with your writepage one.
Please, split and reorder.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
