Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 6A13F60021B
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 02:10:03 -0500 (EST)
In-reply-to: <20091203195917.8925.84203.stgit@paris.rdu.redhat.com> (message
	from Eric Paris on Thu, 03 Dec 2009 14:59:17 -0500)
Subject: Re: [RFC PATCH 4/6] networking: rework socket to fd mapping using
	alloc-file
References: <20091203195851.8925.30926.stgit@paris.rdu.redhat.com> <20091203195917.8925.84203.stgit@paris.rdu.redhat.com>
Message-Id: <E1NGSIQ-0004nz-Lo@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Fri, 04 Dec 2009 08:09:42 +0100
Sender: owner-linux-mm@kvack.org
To: Eric Paris <eparis@redhat.com>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, viro@zeniv.linux.org.uk, jmorris@namei.org, npiggin@suse.de, zohar@us.ibm.com, jack@suse.cz, jmalicki@metacarta.com, dsmith@redhat.com, serue@us.ibm.com, hch@lst.de, john@johnmccutchan.com, rlove@rlove.org, ebiederm@xmission.com, heiko.carstens@de.ibm.com, penguin-kernel@I-love.SAKURA.ne.jp, mszeredi@suse.cz, jens.axboe@oracle.com, akpm@linux-foundation.org, matthew@wil.cx, hugh.dickins@tiscali.co.uk, kamezawa.hiroyu@jp.fujitsu.com, nishimura@mxp.nes.nec.co.jp, davem@davemloft.net, arnd@arndb.de, eric.dumazet@gmail.com
List-ID: <linux-mm.kvack.org>

On Thu, 03 Dec 2009, Eric Paris wrote:
> @@ -391,32 +383,37 @@ static int sock_attach_fd(struct socket *sock, struct file *file, int flags)
>  	dentry->d_flags &= ~DCACHE_UNHASHED;
>  	d_instantiate(dentry, SOCK_INODE(sock));
>  
> +	file = alloc_file(sock_mnt, dentry, FMODE_READ | FMODE_WRITE,
> +			  &socket_file_ops);
> +	if (unlikely(!file)) {
> +		rc = -ENFILE;
> +		goto out_err;
> +	}
> +
>  	sock->file = file;
> -	init_file(file, sock_mnt, dentry, FMODE_READ | FMODE_WRITE,
> -		  &socket_file_ops);
>  	SOCK_INODE(sock)->i_fop = &socket_file_ops;
>  	file->f_flags = O_RDWR | (flags & O_NONBLOCK);
> -	file->f_pos = 0;
>  	file->private_data = sock;
>  
> -	return 0;
> +	return fd;
> +out_err:
> +	if (fd >= 0)
> +		put_unused_fd(fd);
> +	if (dentry)
> +		dput(dentry);

Could you please use separate labels intead of conditionals here?

Thanks,
Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
