Date: Wed, 18 Oct 2006 10:25:12 -0400
From: Chris Mason <chris.mason@oracle.com>
Subject: Re: [patch 6/6] mm: fix pagecache write deadlocks
Message-ID: <20061018142512.GA16570@think.oraclecorp.com>
References: <20061013143516.15438.8802.sendpatchset@linux.site> <20061013143616.15438.77140.sendpatchset@linux.site>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20061013143616.15438.77140.sendpatchset@linux.site>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Memory Management <linux-mm@kvack.org>, Neil Brown <neilb@suse.de>, Andrew Morton <akpm@osdl.org>, Anton Altaparmakov <aia21@cam.ac.uk>, Linux Kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> Index: linux-2.6/fs/buffer.c
> ===================================================================
> --- linux-2.6.orig/fs/buffer.c
> +++ linux-2.6/fs/buffer.c
> @@ -1856,6 +1856,9 @@ static int __block_commit_write(struct i
>  	unsigned blocksize;
>  	struct buffer_head *bh, *head;
>  
> +	if (from == to)
> +		return 0;
> +
>  	blocksize = 1 << inode->i_blkbits;

reiserfs v3 copied the __block_commit_write logic for checking for a
partially updated page, so reiserfs_commit_page will have to be updated
to handle from==to.  Right now it will set the page up to date.

I also used a prepare/commit pare where from==to as a way to trigger
tail conversions in the lilo ioctl.  I'll both for you and make a
patch.

-chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
