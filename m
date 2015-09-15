Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f177.google.com (mail-yk0-f177.google.com [209.85.160.177])
	by kanga.kvack.org (Postfix) with ESMTP id 633EC6B0255
	for <linux-mm@kvack.org>; Tue, 15 Sep 2015 11:20:12 -0400 (EDT)
Received: by ykft14 with SMTP id t14so37016272ykf.0
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 08:20:12 -0700 (PDT)
Received: from mail-yk0-x22f.google.com (mail-yk0-x22f.google.com. [2607:f8b0:4002:c07::22f])
        by mx.google.com with ESMTPS id k16si3794103ykk.11.2015.09.15.08.20.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Sep 2015 08:20:11 -0700 (PDT)
Received: by ykdu9 with SMTP id u9so189641751ykd.2
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 08:20:11 -0700 (PDT)
Date: Tue, 15 Sep 2015 11:20:06 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 1/1] fs: global sync to not clear error status of
 individual inodes
Message-ID: <20150915152006.GD2905@mtj.duckdns.org>
References: <20150915094638.GA13399@xzibit.linux.bs1.fc.nec.co.jp>
 <20150915095412.GD13399@xzibit.linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150915095412.GD13399@xzibit.linux.bs1.fc.nec.co.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Junichi Nomura <j-nomura@ce.jp.nec.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "andi@firstfloor.org" <andi@firstfloor.org>, "fengguang.wu@intel.com" <fengguang.wu@intel.com>, "tony.luck@intel.com" <tony.luck@intel.com>, "liwanp@linux.vnet.ibm.com" <liwanp@linux.vnet.ibm.com>, "david@fromorbit.com" <david@fromorbit.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Hello, Junichi.

On Tue, Sep 15, 2015 at 09:54:13AM +0000, Junichi Nomura wrote:
> filemap_fdatawait() is a function to wait for on-going writeback
> to complete but also consume and clear error status of the mapping
> set during writeback.
> The latter functionality is critical for applications to detect
> writeback error with system calls like fsync(2)/fdatasync(2).
> 
> However filemap_fdatawait() is also used by sync(2) or FIFREEZE
> ioctl, which don't check error status of individual mappings.
> 
> As a result, fsync() may not be able to detect writeback error
> if events happen in the following order:
> 
>    Application                    System admin
>    ----------------------------------------------------------
>    write data on page cache
>                                   Run sync command
>                                   writeback completes with error
>                                   filemap_fdatawait() clears error
>    fsync returns success
>    (but the data is not on disk)
> 
> This patch adds filemap_fdatawait_keep_errors() for call sites where
> writeback error is not handled so that they don't clear error status.

Is this an actual problem?  Write errors usually indicate that the
underlying device is completely hosed and the kernel tends to make a
lot of noise throughout the different layers and it often pretty
quickly leads to failures of metadata IOs which which results in
damage-control actions like RO remounts, so in most cases the
specifics of failure handling don't end up mattering all that much.

That said, no reason to not improve upon it.

> @@ -2121,7 +2121,13 @@ static void wait_sb_inodes(struct super_block *sb)
>  		iput(old_inode);
>  		old_inode = inode;
>  
> -		filemap_fdatawait(mapping);
> +		/*
> +		 * Wait for on-going writeback to complete
> +		 * but not consume error status on this mapping.
                       ^don't

> +		 * Otherwise application may fail to catch writeback error

                   mapping; otherwise,

> +		 * using fsync(2).
> +		 */

Can you please re-flow the comment so that it's filling up to, say, 72
or 76 or whatever column?

> +		filemap_fdatawait_keep_errors(mapping);
>  
>  		cond_resched();
>  
> diff --git a/fs/sync.c b/fs/sync.c
> index fbc98ee..e2b7a77 100644
> --- a/fs/sync.c
> +++ b/fs/sync.c
> @@ -86,7 +86,7 @@ static void fdatawrite_one_bdev(struct block_device *bdev, void *arg)
>  
>  static void fdatawait_one_bdev(struct block_device *bdev, void *arg)
>  {
> -	filemap_fdatawait(bdev->bd_inode->i_mapping);
> +	filemap_fdatawait_keep_errors(bdev->bd_inode->i_mapping);

Maybe it'd be better to describe what's going on in detail in the
function comment of filemat_fdatawait_keep_errors() and refer to that
from its callers?

> @@ -382,6 +391,26 @@ out:
>  }
>  EXPORT_SYMBOL(filemap_fdatawait_range);
>  
> +/*
> + * As filemap_check_errors() consumes and clears error status of mapping,
> + * filemap_fdatawait() should be used only when the caller is responsible
> + * for handling the error.

Please make this a proper function comment.

> + *
> + * Use filemap_fdatawait_keep_errors() if callers just want to wait for
> + * witeback and don't handle errors themselves.
      writeback

> + * Expected call sites are system-wide / filesystem-wide data flushers:
> + * e.g. sync(2), fsfreeze(8)

Ditto, please either break up paragraphs or reflow to column
consistently.

> + */
> +void filemap_fdatawait_keep_errors(struct address_space *mapping)
> +{
> +	loff_t i_size = i_size_read(mapping->host);
> +
> +	if (i_size == 0)
> +		return;
> +
> +	__filemap_fdatawait_range(mapping, 0, i_size - 1);
> +}

Generally looks good to me.  We may end up deferring writeback error
from way earlier to later fsync callers but given that sync(2) doesn't
even have a return value, it looks like that's the best we can do.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
