Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id F1DE58D0039
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 18:02:03 -0500 (EST)
Date: Wed, 9 Mar 2011 15:01:55 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] shmem: using goto to replace several return
Message-Id: <20110309150155.b0c006d7.akpm@linux-foundation.org>
In-Reply-To: <1299575700-6901-2-git-send-email-lliubbo@gmail.com>
References: <1299575700-6901-1-git-send-email-lliubbo@gmail.com>
	<1299575700-6901-2-git-send-email-lliubbo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: linux-mm@kvack.org, viro@zeniv.linux.org.uk, hch@lst.de, hughd@google.com, npiggin@kernel.dk

On Tue, 8 Mar 2011 17:15:00 +0800
Bob Liu <lliubbo@gmail.com> wrote:

> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -1847,17 +1847,13 @@ shmem_mknod(struct inode *dir, struct dentry *dentry, int mode, dev_t dev)
>  						     &dentry->d_name, NULL,
>  						     NULL, NULL);
>  		if (error) {
> -			if (error != -EOPNOTSUPP) {
> -				iput(inode);
> -				return error;
> -			}
> +			if (error != -EOPNOTSUPP)
> +				goto failed_iput;
>  		}
>  #ifdef CONFIG_TMPFS_POSIX_ACL
>  		error = generic_acl_init(inode, dir);
> -		if (error) {
> -			iput(inode);
> -			return error;
> -		}
> +		if (error)
> +			goto failed_iput;
>  #else
>  		error = 0;
>  #endif
> @@ -1866,6 +1862,9 @@ shmem_mknod(struct inode *dir, struct dentry *dentry, int mode, dev_t dev)
>  		d_instantiate(dentry, inode);
>  		dget(dentry); /* Extra count - pin the dentry in core */
>  	}
> +
> +failed_iput:
> +	iput(inode);
>  	return error;
>  }

This adds a big bug: we newly do iput() on the non-error path.

Please, we need much more care and testing than this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
