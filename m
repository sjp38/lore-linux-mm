Message-ID: <466C3729.7050903@redhat.com>
Date: Sun, 10 Jun 2007 13:38:49 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 02 of 16] avoid oom deadlock in nfs_create_request
References: <d64cb81222748354bf5b.1181332980@v2.random>
In-Reply-To: <d64cb81222748354bf5b.1181332980@v2.random>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrea Arcangeli wrote:

> When sigkill is pending after the oom killer set TIF_MEMDIE, the task
> must go away or the VM will malfunction.

However, if the sigkill is pending against ANOTHER task,
this patch looks like it could introduce an IO error
where the system would recover fine before.

Tasks that do not have a pending SIGKILL should retry
the allocation, shouldn't they?

> diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
> --- a/fs/nfs/pagelist.c
> +++ b/fs/nfs/pagelist.c
> @@ -61,16 +61,20 @@ nfs_create_request(struct nfs_open_conte
>  	struct nfs_server *server = NFS_SERVER(inode);
>  	struct nfs_page		*req;
>  
> -	for (;;) {
> -		/* try to allocate the request struct */
> -		req = nfs_page_alloc();
> -		if (req != NULL)
> -			break;
> -
> -		if (signalled() && (server->flags & NFS_MOUNT_INTR))
> -			return ERR_PTR(-ERESTARTSYS);
> -		yield();
> -	}
> +	/* try to allocate the request struct */
> +	req = nfs_page_alloc();
> +	if (unlikely(!req)) {
> +		/*
> +		 * -ENOMEM will be returned only when TIF_MEMDIE is set
> +		 * so userland shouldn't risk to get confused by a new
> +		 * unhandled ENOMEM errno.
> +		 */
> +		WARN_ON(!test_thread_flag(TIF_MEMDIE));
> +		return ERR_PTR(-ENOMEM);
> +	}
> +
> +	if (signalled() && (server->flags & NFS_MOUNT_INTR))
> +		return ERR_PTR(-ERESTARTSYS);
>  
>  	/* Initialize the request struct. Initially, we assume a
>  	 * long write-back delay. This will be adjusted in
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>


-- 
Politics is the struggle between those who want to make their country
the best in the world, and those who believe it already is.  Each group
calls the other unpatriotic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
