Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 672B66B0070
	for <linux-mm@kvack.org>; Fri, 21 Nov 2014 12:29:13 -0500 (EST)
Received: by mail-wi0-f177.google.com with SMTP id l15so9570325wiw.4
        for <linux-mm@kvack.org>; Fri, 21 Nov 2014 09:29:12 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id vm10si10641980wjc.57.2014.11.21.09.29.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 21 Nov 2014 09:29:10 -0800 (PST)
Date: Fri, 21 Nov 2014 18:29:08 +0100
From: David Sterba <dsterba@suse.cz>
Subject: Re: [PATCH v2 4/5] btrfs: don't allow -C or +c chattrs on a swap file
Message-ID: <20141121172908.GE8568@twin.jikos.cz>
Reply-To: dsterba@suse.cz
References: <cover.1416563833.git.osandov@osandov.com>
 <a422e8d7ce252474b998eeca3af5f1e2964c5c50.1416563833.git.osandov@osandov.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a422e8d7ce252474b998eeca3af5f1e2964c5c50.1416563833.git.osandov@osandov.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Omar Sandoval <osandov@osandov.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-nfs@vger.kernel.org, Trond Myklebust <trond.myklebust@primarydata.com>, Mel Gorman <mgorman@suse.de>

On Fri, Nov 21, 2014 at 02:08:30AM -0800, Omar Sandoval wrote:
> @@ -293,14 +293,21 @@ static int btrfs_ioctl_setflags(struct file *file, void __user *arg)
>  		}
>  	} else {

You can put the condition here, instead of shifting the nested block.

	} else if (!IS_SWAPFILE(inode)) {

>  		/*
> -		 * Revert back under same assuptions as above
> +		 * swap_activate checks that we don't swapon a copy-on-write
> +		 * file, but we must also make sure that it doesn't become
> +		 * copy-on-write.
>  		 */
> -		if (S_ISREG(mode)) {
> -			if (inode->i_size == 0)
> -				ip->flags &= ~(BTRFS_INODE_NODATACOW
> -				             | BTRFS_INODE_NODATASUM);
> -		} else {
> -			ip->flags &= ~BTRFS_INODE_NODATACOW;
> +		if (!IS_SWAPFILE(inode)) {
> +			/*
> +			 * Revert back under same assumptions as above
> +			 */
> +			if (S_ISREG(mode)) {
> +				if (inode->i_size == 0)
> +					ip->flags &= ~(BTRFS_INODE_NODATACOW |
> +						       BTRFS_INODE_NODATASUM);
> +			} else {
> +				ip->flags &= ~BTRFS_INODE_NODATACOW;
> +			}
>  		}
>  	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
