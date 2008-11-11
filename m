Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e36.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id mABGj0vu006534
	for <linux-mm@kvack.org>; Tue, 11 Nov 2008 09:45:00 -0700
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mABGjNjc153090
	for <linux-mm@kvack.org>; Tue, 11 Nov 2008 09:45:32 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mABGineW000960
	for <linux-mm@kvack.org>; Tue, 11 Nov 2008 09:44:50 -0700
Date: Tue, 11 Nov 2008 10:45:17 -0600
From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [RFC v9][PATCH 05/13] Dump memory address space
Message-ID: <20081111164517.GA15999@us.ibm.com>
References: <1226335060-7061-1-git-send-email-orenl@cs.columbia.edu> <1226335060-7061-6-git-send-email-orenl@cs.columbia.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1226335060-7061-6-git-send-email-orenl@cs.columbia.edu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Oren Laadan <orenl@cs.columbia.edu>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Dave Hansen <dave@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Alexander Viro <viro@zeniv.linux.org.uk>
List-ID: <linux-mm.kvack.org>

Quoting Oren Laadan (orenl@cs.columbia.edu):
> +/**
> + * cr_fill_fname - return pathname of a given file
> + * @path: path name
> + * @root: relative root
> + * @buf: buffer for pathname
> + * @n: buffer length (in) and pathname length (out)
> + */
> +static char *
> +cr_fill_fname(struct path *path, struct path *root, char *buf, int *n)
> +{
> +	struct path tmp = *root;
> +	char *fname;
> +
> +	BUG_ON(!buf);
> +	fname = __d_path(path, &tmp, buf, *n);
> +	if (!IS_ERR(fname))
> +		*n = (buf + (*n) - fname);
> +	/*
> +	 * FIXME: if __d_path() changed these, it must have stepped out of
> +	 * init's namespace. Since currently we require a unified namespace
> +	 * within the container: simply fail.
> +	 */
> +	if (tmp.mnt != root->mnt || tmp.dentry != root->dentry)
> +		fname = ERR_PTR(-EBADF);

...

> +static int cr_ctx_checkpoint(struct cr_ctx *ctx, pid_t pid)
> +{
> +	ctx->root_pid = pid;
> +
> +	/*
> +	 * assume checkpointer is in container's root vfs
> +	 * FIXME: this works for now, but will change with real containers
> +	 */
> +	ctx->vfsroot = &current->fs->root;
> +	path_get(ctx->vfsroot);

Hi Oren,

Is there really any good reason to use current->fs->root rather
than ctx->root_task->fs->root here?

The way I'm testing, the checkpointer is in fact in a different
container, so the root passed into cr_fill_fname() is different
from the container's root, so cr_fill_fname() always returns me
-EBADF.

thanks,
-serge

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
