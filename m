Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f170.google.com (mail-ie0-f170.google.com [209.85.223.170])
	by kanga.kvack.org (Postfix) with ESMTP id 164346B007D
	for <linux-mm@kvack.org>; Sun, 14 Dec 2014 17:13:32 -0500 (EST)
Received: by mail-ie0-f170.google.com with SMTP id rd18so9829279iec.15
        for <linux-mm@kvack.org>; Sun, 14 Dec 2014 14:13:31 -0800 (PST)
Date: Sun, 14 Dec 2014 14:13:36 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [GIT PULL] aio: changes for 3.19
Message-Id: <20141214141336.a0267e95.akpm@linux-foundation.org>
In-Reply-To: <20141214215221.GI2672@kvack.org>
References: <20141214202224.GH2672@kvack.org>
	<CA+55aFxV2h1NrE87Zt7U8bsrXgeO=Tf-DyQO8wBYZ=M7WEjxKg@mail.gmail.com>
	<20141214215221.GI2672@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin LaHaise <bcrl@kvack.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-aio@kvack.org, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

On Sun, 14 Dec 2014 16:52:21 -0500 Benjamin LaHaise <bcrl@kvack.org> wrote:

> On Sun, Dec 14, 2014 at 01:47:32PM -0800, Linus Torvalds wrote:
> > On Sun, Dec 14, 2014 at 12:22 PM, Benjamin LaHaise <bcrl@kvack.org> wrote:
> > >
> > > Pavel Emelyanov (1):
> > >       aio: Make it possible to remap aio ring
> > 
> > So quite frankly, I think this should have had more acks from VM
> > people. The patch looks ok to me, but it took me by surprise, and I
> > don't see much any discussion about it on linux-mm either..
> 
> Sadly, nobody responded.  Maybe akpm can chime in on this change (included 
> below for ease of review and akpm added to the To:)?
> 
> 		-ben
> -- 
> "Thought is the essence of where you are now."
> 
> commit e4a0d3e720e7e508749c1439b5ba3aff56c92976
> Author: Pavel Emelyanov <xemul@parallels.com>
> Date:   Thu Sep 18 19:56:17 2014 +0400
> 
>     aio: Make it possible to remap aio ring

The patch appears to be a bugfix which coincidentally helps CRIU?

If it weren't for the bugfix part, I'd be asking "why not pass the
desired virtual address into io_setup()?".

>     There are actually two issues this patch addresses. Let me start with
>     the one I tried to solve in the beginning.
>     
>     So, in the checkpoint-restore project (criu) we try to dump tasks'
>     state and restore one back exactly as it was. One of the tasks' state
>     bits is rings set up with io_setup() call. There's (almost) no problems
>     in dumping them, there's a problem restoring them -- if I dump a task
>     with aio ring originally mapped at address A, I want to restore one
>     back at exactly the same address A. Unfortunately, the io_setup() does
>     not allow for that -- it mmaps the ring at whatever place mm finds
>     appropriate (it calls do_mmap_pgoff() with zero address and without
>     the MAP_FIXED flag).
>     
>     To make restore possible I'm going to mremap() the freshly created ring
>     into the address A (under which it was seen before dump). The problem is
>     that the ring's virtual address is passed back to the user-space as the
>     context ID and this ID is then used as search key by all the other io_foo()
>     calls. Reworking this ID to be just some integer doesn't seem to work, as
>     this value is already used by libaio as a pointer using which this library
>     accesses memory for aio meta-data.
>     
>     So, to make restore work we need to make sure that
>     
>     a) ring is mapped at desired virtual address
>     b) kioctx->user_id matches this value
>     
>     Having said that, the patch makes mremap() on aio region update the
>     kioctx's user_id and mmap_base values.
>     
>     Here appears the 2nd issue I mentioned in the beginning of this mail.
>     If (regardless of the C/R dances I do) someone creates an io context
>     with io_setup(), then mremap()-s the ring and then destroys the context,
>     the kill_ioctx() routine will call munmap() on wrong (old) address.
>     This will result in a) aio ring remaining in memory and b) some other
>     vma get unexpectedly unmapped.
>     
>     What do you think?
>     
> ...
>
> --- a/fs/aio.c
> +++ b/fs/aio.c
> @@ -286,12 +286,37 @@ static void aio_free_ring(struct kioctx *ctx)
>  
>  static int aio_ring_mmap(struct file *file, struct vm_area_struct *vma)
>  {
> +	vma->vm_flags |= VM_DONTEXPAND;

I don't think this was changelogged?  A comment here would be best.

>  	vma->vm_ops = &generic_file_vm_ops;
>  	return 0;
>  }
>  
> +static void aio_ring_remap(struct file *file, struct vm_area_struct *vma)
> +{
> +	struct mm_struct *mm = vma->vm_mm;
> +	struct kioctx_table *table;
> +	int i;
> +
> +	spin_lock(&mm->ioctx_lock);
> +	rcu_read_lock();
> +	table = rcu_dereference(mm->ioctx_table);
> +	for (i = 0; i < table->nr; i++) {
> +		struct kioctx *ctx;
> +
> +		ctx = table->table[i];
> +		if (ctx && ctx->aio_ring_file == file) {
> +			ctx->user_id = ctx->mmap_base = vma->vm_start;
> +			break;
> +		}
> +	}
> +
> +	rcu_read_unlock();
> +	spin_unlock(&mm->ioctx_lock);
> +}

Looks simple enough.  Possibly so simple that it doesn't need commenting ;)

>  static const struct file_operations aio_ring_fops = {
>  	.mmap = aio_ring_mmap,
> +	.mremap = aio_ring_remap,
>  };
>  
>  #if IS_ENABLED(CONFIG_MIGRATION)
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 9ab779e..85f378c 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -1497,6 +1497,7 @@ struct file_operations {
>  	long (*unlocked_ioctl) (struct file *, unsigned int, unsigned long);
>  	long (*compat_ioctl) (struct file *, unsigned int, unsigned long);
>  	int (*mmap) (struct file *, struct vm_area_struct *);
> +	void (*mremap)(struct file *, struct vm_area_struct *);

Documentation/filesystems/vfs.txt needs updating.  Note that it says
"all methods are called without any locks being held, unless otherwise
noted", but ->mremap() is called under mmap_sem (at least) so otherwise
noting will be needed.

It might make sense for ->mremap() to return an errno, but we can
change that later if needed.

>  	int (*open) (struct inode *, struct file *);
>  	int (*flush) (struct file *, fl_owner_t id);
>  	int (*release) (struct inode *, struct file *);
> diff --git a/mm/mremap.c b/mm/mremap.c
> index b147f66..c855922 100644
> --- a/mm/mremap.c
> +++ b/mm/mremap.c
> @@ -288,7 +288,8 @@ static unsigned long move_vma(struct vm_area_struct *vma,
>  		old_len = new_len;
>  		old_addr = new_addr;
>  		new_addr = -ENOMEM;
> -	}
> +	} else if (vma->vm_file && vma->vm_file->f_op->mremap)
> +		vma->vm_file->f_op->mremap(vma->vm_file, new_vma);
>  

The patch overall is a no-op from an MM perspective and seems OK to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
