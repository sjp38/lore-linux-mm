Date: Fri, 28 Nov 2008 10:53:51 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [RFC v10][PATCH 05/13] Dump memory address space
Message-ID: <20081128105351.GQ28946@ZenIV.linux.org.uk>
References: <1227747884-14150-1-git-send-email-orenl@cs.columbia.edu> <1227747884-14150-6-git-send-email-orenl@cs.columbia.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1227747884-14150-6-git-send-email-orenl@cs.columbia.edu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Oren Laadan <orenl@cs.columbia.edu>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Serge Hallyn <serue@us.ibm.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>
List-ID: <linux-mm.kvack.org>

On Wed, Nov 26, 2008 at 08:04:36PM -0500, Oren Laadan wrote:
> For each VMA, there is a 'struct cr_vma'; if the VMA is file-mapped,
> it will be followed by the file name. Then comes the actual contents,
> in one or more chunk: each chunk begins with a header that specifies
> how many pages it holds, then the virtual addresses of all the dumped
> pages in that chunk, followed by the actual contents of all dumped
> pages. A header with zero number of pages marks the end of the contents.
> Then comes the next VMA and so on.
> 
> Changelog[v10]:
>   - Acquire dcache_lock around call to __d_path() in cr_fill_name()
> 
> Changelog[v9]:
>   - Introduce cr_ctx_checkpoint() for checkpoint-specific ctx setup
>   - Test if __d_path() changes mnt/dentry (when crossing filesystem
>     namespace boundary). for now cr_fill_fname() fails the checkpoint.
> 
> Changelog[v7]:
>   - Fix argument given to kunmap_atomic() in memory dump/restore
> 
> Changelog[v6]:
>   - Balance all calls to cr_hbuf_get() with matching cr_hbuf_put()
>     (even though it's not really needed)
> 
> Changelog[v5]:
>   - Improve memory dump code (following Dave Hansen's comments)
>   - Change dump format (and code) to allow chunks of <vaddrs, pages>
>     instead of one long list of each
>   - Fix use of follow_page() to avoid faulting in non-present pages
> 
> Changelog[v4]:
>   - Use standard list_... for cr_pgarr
> 
> Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
> Acked-by: Serge Hallyn <serue@us.ibm.com>
> Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>
> ---
>  arch/x86/include/asm/checkpoint_hdr.h |    5 +
>  arch/x86/mm/checkpoint.c              |   31 ++
>  checkpoint/Makefile                   |    3 +-
>  checkpoint/checkpoint.c               |   81 ++++++
>  checkpoint/checkpoint_arch.h          |    2 +
>  checkpoint/checkpoint_mem.h           |   41 +++
>  checkpoint/ckpt_mem.c                 |  500 +++++++++++++++++++++++++++++++++
>  checkpoint/sys.c                      |   11 +
>  include/linux/checkpoint.h            |   12 +
>  include/linux/checkpoint_hdr.h        |   32 ++
>  10 files changed, 717 insertions(+), 1 deletions(-)
>  create mode 100644 checkpoint/checkpoint_mem.h
>  create mode 100644 checkpoint/ckpt_mem.c
> 
> diff --git a/arch/x86/include/asm/checkpoint_hdr.h b/arch/x86/include/asm/checkpoint_hdr.h
> index 6325062..33f4c70 100644
> --- a/arch/x86/include/asm/checkpoint_hdr.h
> +++ b/arch/x86/include/asm/checkpoint_hdr.h
> @@ -82,4 +82,9 @@ struct cr_hdr_cpu {
>  	/* thread_xstate contents follow (if used_math) */
>  } __attribute__((aligned(8)));
>  
> +struct cr_hdr_mm_context {
> +	__s16 ldt_entry_size;
> +	__s16 nldt;
> +} __attribute__((aligned(8)));
> +
>  #endif /* __ASM_X86_CKPT_HDR__H */
> diff --git a/arch/x86/mm/checkpoint.c b/arch/x86/mm/checkpoint.c
> index 8dd6d2d..757936e 100644
> --- a/arch/x86/mm/checkpoint.c
> +++ b/arch/x86/mm/checkpoint.c
> @@ -221,3 +221,34 @@ int cr_write_head_arch(struct cr_ctx *ctx)
>  
>  	return ret;
>  }
> +
> +/* dump the mm->context state */
> +int cr_write_mm_context(struct cr_ctx *ctx, struct mm_struct *mm, int parent)
> +{
> +	struct cr_hdr h;
> +	struct cr_hdr_mm_context *hh = cr_hbuf_get(ctx, sizeof(*hh));
> +	int ret;
> +
> +	h.type = CR_HDR_MM_CONTEXT;
> +	h.len = sizeof(*hh);
> +	h.parent = parent;
> +
> +	mutex_lock(&mm->context.lock);
> +
> +	hh->ldt_entry_size = LDT_ENTRY_SIZE;
> +	hh->nldt = mm->context.size;
> +
> +	cr_debug("nldt %d\n", hh->nldt);
> +
> +	ret = cr_write_obj(ctx, &h, hh);
> +	cr_hbuf_put(ctx, sizeof(*hh));
> +	if (ret < 0)
> +		goto out;
> +
> +	ret = cr_kwrite(ctx, mm->context.ldt,
> +			mm->context.size * LDT_ENTRY_SIZE);
> +
> + out:
> +	mutex_unlock(&mm->context.lock);
> +	return ret;
> +}
> diff --git a/checkpoint/Makefile b/checkpoint/Makefile
> index d2df68c..3a0df6d 100644
> --- a/checkpoint/Makefile
> +++ b/checkpoint/Makefile
> @@ -2,4 +2,5 @@
>  # Makefile for linux checkpoint/restart.
>  #
>  
> -obj-$(CONFIG_CHECKPOINT_RESTART) += sys.o checkpoint.o restart.o
> +obj-$(CONFIG_CHECKPOINT_RESTART) += sys.o checkpoint.o restart.o \
> +		ckpt_mem.o
> diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
> index 17cc8d2..6a8f810 100644
> --- a/checkpoint/checkpoint.c
> +++ b/checkpoint/checkpoint.c
> @@ -75,6 +75,66 @@ int cr_write_string(struct cr_ctx *ctx, char *str, int len)
>  	return cr_write_obj(ctx, &h, str);
>  }
>  
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
> +	spin_lock(&dcache_lock);
> +	fname = __d_path(path, &tmp, buf, *n);
> +	spin_unlock(&dcache_lock);
> +	if (!IS_ERR(fname))
> +		*n = (buf + (*n) - fname);
> +	/*
> +	 * FIXME: if __d_path() changed these, it must have stepped out of
> +	 * init's namespace. Since currently we require a unified namespace
> +	 * within the container: simply fail.
> +	 */
> +	if (tmp.mnt != root->mnt || tmp.dentry != root->dentry)
> +		fname = ERR_PTR(-EBADF);
> +
> +	return fname;
> +}
> +
> +/**
> + * cr_write_fname - write a file name
> + * @ctx: checkpoint context
> + * @path: path name
> + * @root: relative root
> + */
> +int cr_write_fname(struct cr_ctx *ctx, struct path *path, struct path *root)
> +{
> +	struct cr_hdr h;
> +	char *buf, *fname;
> +	int ret, flen;
> +
> +	flen = PATH_MAX;
> +	buf = kmalloc(flen, GFP_KERNEL);
> +	if (!buf)
> +		return -ENOMEM;
> +
> +	fname = cr_fill_fname(path, root, buf, &flen);
> +	if (!IS_ERR(fname)) {
> +		h.type = CR_HDR_FNAME;
> +		h.len = flen;
> +		h.parent = 0;
> +		ret = cr_write_obj(ctx, &h, fname);
> +	} else
> +		ret = PTR_ERR(fname);
> +
> +	kfree(buf);
> +	return ret;
> +}
> +
>  /* write the checkpoint header */
>  static int cr_write_head(struct cr_ctx *ctx)
>  {
> @@ -168,6 +228,10 @@ static int cr_write_task(struct cr_ctx *ctx, struct task_struct *t)
>  	cr_debug("task_struct: ret %d\n", ret);
>  	if (ret < 0)
>  		goto out;
> +	ret = cr_write_mm(ctx, t);
> +	cr_debug("memory: ret %d\n", ret);
> +	if (ret < 0)
> +		goto out;
>  	ret = cr_write_thread(ctx, t);
>  	cr_debug("thread: ret %d\n", ret);
>  	if (ret < 0)
> @@ -178,10 +242,27 @@ static int cr_write_task(struct cr_ctx *ctx, struct task_struct *t)
>  	return ret;
>  }
>  
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

This is going to break as soon as you get another thread doing e.g. chroot(2)
while you are in there.  And it's a really, _really_ bad idea to take a
pointer to shared object, increment refcount on the current *contents* of
said object and assume that dropping refcount on the later contents of the
same will balance out.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
