Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id D3A7E4403DB
	for <linux-mm@kvack.org>; Tue, 12 Jan 2016 04:34:55 -0500 (EST)
Received: by mail-wm0-f54.google.com with SMTP id f206so244475614wmf.0
        for <linux-mm@kvack.org>; Tue, 12 Jan 2016 01:34:55 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y130si29840563wmy.93.2016.01.12.01.34.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 12 Jan 2016 01:34:54 -0800 (PST)
Date: Tue, 12 Jan 2016 10:34:58 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v8 1/9] dax: fix NULL pointer dereference in __dax_dbg()
Message-ID: <20160112093458.GR6262@quack.suse.cz>
References: <1452230879-18117-1-git-send-email-ross.zwisler@linux.intel.com>
 <1452230879-18117-2-git-send-email-ross.zwisler@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1452230879-18117-2-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, "H. Peter Anvin" <hpa@zytor.com>, "J. Bruce Fields" <bfields@fieldses.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Dave Hansen <dave.hansen@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.com>, Jeff Layton <jlayton@poochiereds.net>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Matthew Wilcox <willy@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, x86@kernel.org, xfs@oss.sgi.com

On Thu 07-01-16 22:27:51, Ross Zwisler wrote:
> In __dax_pmd_fault() we currently assume that get_block() will always set
> bh.b_bdev and we unconditionally dereference it in __dax_dbg().  This
> assumption isn't always true - when called for reads of holes
> ext4_dax_mmap_get_block() returns a buffer head where bh->b_bdev is never
> set.  I hit this BUG while testing the DAX PMD fault path.
> 
> Instead, initialize bh.b_bdev before passing bh into get_block().  It is
> possible that the filesystem's get_block() will update bh.b_bdev, and this
> is fine - we just want to initialize bh.b_bdev to something reasonable so
> that the calls to __dax_dbg() work and print something useful.
> 
> Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> Cc: Dan Williams <dan.j.williams@intel.com>

Looks good. But don't you need to do the same for __dax_fault(),
dax_zero_page_range() and similar places passing bh to dax functions?

								Honza
> ---
>  fs/dax.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/fs/dax.c b/fs/dax.c
> index 7af8797..513bba5 100644
> --- a/fs/dax.c
> +++ b/fs/dax.c
> @@ -624,6 +624,7 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
>  	}
>  
>  	memset(&bh, 0, sizeof(bh));
> +	bh.b_bdev = inode->i_sb->s_bdev;
>  	block = (sector_t)pgoff << (PAGE_SHIFT - blkbits);
>  
>  	bh.b_size = PMD_SIZE;
> -- 
> 2.5.0
> 
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
