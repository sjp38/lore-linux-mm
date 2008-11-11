Message-ID: <491A1AF3.20609@cs.columbia.edu>
Date: Tue, 11 Nov 2008 18:53:23 -0500
From: Oren Laadan <orenl@cs.columbia.edu>
MIME-Version: 1.0
Subject: Re: [RFC v9][PATCH 05/13] Dump memory address space
References: <1226335060-7061-1-git-send-email-orenl@cs.columbia.edu> <1226335060-7061-6-git-send-email-orenl@cs.columbia.edu> <20081111164517.GA15999@us.ibm.com>
In-Reply-To: <20081111164517.GA15999@us.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Serge E. Hallyn" <serue@us.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Dave Hansen <dave@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Alexander Viro <viro@zeniv.linux.org.uk>
List-ID: <linux-mm.kvack.org>


Serge E. Hallyn wrote:
> Quoting Oren Laadan (orenl@cs.columbia.edu):
>> +/**
>> + * cr_fill_fname - return pathname of a given file
>> + * @path: path name
>> + * @root: relative root
>> + * @buf: buffer for pathname
>> + * @n: buffer length (in) and pathname length (out)
>> + */
>> +static char *
>> +cr_fill_fname(struct path *path, struct path *root, char *buf, int *n)
>> +{
>> +	struct path tmp = *root;
>> +	char *fname;
>> +
>> +	BUG_ON(!buf);
>> +	fname = __d_path(path, &tmp, buf, *n);
>> +	if (!IS_ERR(fname))
>> +		*n = (buf + (*n) - fname);
>> +	/*
>> +	 * FIXME: if __d_path() changed these, it must have stepped out of
>> +	 * init's namespace. Since currently we require a unified namespace
>> +	 * within the container: simply fail.
>> +	 */
>> +	if (tmp.mnt != root->mnt || tmp.dentry != root->dentry)
>> +		fname = ERR_PTR(-EBADF);
> 
> ...
> 
>> +static int cr_ctx_checkpoint(struct cr_ctx *ctx, pid_t pid)
>> +{
>> +	ctx->root_pid = pid;
>> +
>> +	/*
>> +	 * assume checkpointer is in container's root vfs
>> +	 * FIXME: this works for now, but will change with real containers
>> +	 */
>> +	ctx->vfsroot = &current->fs->root;
>> +	path_get(ctx->vfsroot);
> 
> Hi Oren,
> 
> Is there really any good reason to use current->fs->root rather
> than ctx->root_task->fs->root here?

Oops, that's a leftover from before supporting external checkpoint.
Will fix.

> 
> The way I'm testing, the checkpointer is in fact in a different
> container, so the root passed into cr_fill_fname() is different
> from the container's root, so cr_fill_fname() always returns me
> -EBADF.
> 

Thanks,

Oren.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
