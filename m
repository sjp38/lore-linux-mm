In-reply-to: <E1HIwLJ-0005N4-00@dorka.pomaz.szeredi.hu> (message from Miklos
	Szeredi on Mon, 19 Feb 2007 01:25:21 +0100)
Subject: Re: dirty balancing deadlock
References: <E1HIqlm-0004iZ-00@dorka.pomaz.szeredi.hu>
	<20070218125307.4103c04a.akpm@linux-foundation.org>
	<E1HIurG-0005Bw-00@dorka.pomaz.szeredi.hu>
	<20070218145929.547c21c7.akpm@linux-foundation.org>
	<E1HIvMB-0005Fd-00@dorka.pomaz.szeredi.hu> <20070218155916.0d3c73a9.akpm@linux-foundation.org> <E1HIwLJ-0005N4-00@dorka.pomaz.szeredi.hu>
Message-Id: <E1HIwQG-0005OS-00@dorka.pomaz.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Mon, 19 Feb 2007 01:30:28 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> --- a/fs/fs-writeback.c~a
> +++ a/fs/fs-writeback.c
> @@ -356,7 +356,7 @@ int generic_sync_sb_inodes(struct super_
>  			continue;		/* Skip a congested blockdev */
>  		}
>  
> -		if (wbc->bdi && bdi != wbc->bdi) {
> +		if (wbc->bdi && bdi != wbc->bdi && bdi_write_congested(bdi)) {
>  			if (!sb_is_blkdev_sb(sb))
>  				break;		/* fs has the wrong queue */
>  			list_move(&inode->i_list, &sb->s_dirty);

Checking bdi_write_congested(bdi) is not reliable, since the queue can
become congested _after_ the check is done.

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
