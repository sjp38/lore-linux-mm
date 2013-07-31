Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id D3FE76B0031
	for <linux-mm@kvack.org>; Wed, 31 Jul 2013 02:33:03 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id g10so375849pdj.26
        for <linux-mm@kvack.org>; Tue, 30 Jul 2013 23:33:03 -0700 (PDT)
Date: Tue, 30 Jul 2013 23:32:50 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm: for shm_open()/mmap() with OVERCOMMIT_NEVER, return
 -1 if no memory avail
In-Reply-To: <1375214187-10740-1-git-send-email-a3at.mail@gmail.com>
Message-ID: <alpine.LNX.2.00.1307302245020.2185@eggly.anvils>
References: <1375214187-10740-1-git-send-email-a3at.mail@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Azat Khuzhin <a3at.mail@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 30 Jul 2013, Azat Khuzhin wrote:

> Otherwize if there is no left space on shmem device, there will be
> "Bus error" when application will try to write to address space that was
> returned by mmap(2)
> 
> This patch also preserve old behaviour if MAP_NORESERVE/VM_NORESERVE
> isset.
> 
> So, with this patch, you will get next:
> 
> a)
> $ echo 2 >| /proc/sys/vm/overcommit_memory
>   ....
>   mmap() = MAP_FAILED;
>   ....
> 
> b)
>   ....
>   mmap(0, length, PROT_READ | PROT_WRITE, MAP_SHARED | MAP_NORESERVE) = !MAP_FAILED;
>   write()
>   killed by SIGBUS
>   ....
> 
> c)
> $ echo 0 >| /proc/sys/vm/overcommit_memory
>   ....
>   mmap() = !MAP_FAILED;
>   write()
>   killed by SIGBUS
>   ....
> 
> Signed-off-by: Azat Khuzhin <a3at.mail@gmail.com>

Thanks for making the patch, but I'm afraid there are a number of
things wrong with it; and even if it were perfect, I would still be
reluctant to change the semantics of shmem_mmap() after all this time.

Some comments on your implementation below; but if getting SIGBUS from
a write to an mmapping, once the underlying filesystem (shmem/tmpfs or
any other) fills up, if that SIGBUS is troublesome for you, then please
try using fallocate() to allocate the space before accessing the mmapping.

> ---
>  mm/shmem.c |   16 ++++++++++++++++
>  1 file changed, 16 insertions(+)
> 
> diff --git a/mm/shmem.c b/mm/shmem.c
> index a87990c..965f4ba 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -32,6 +32,8 @@
>  #include <linux/export.h>
>  #include <linux/swap.h>
>  #include <linux/aio.h>
> +#include <linux/statfs.h>
> +#include <linux/path.h>

I'm surprised you need either of those: vfs.h should have already
included statfs.h, and I don't see what path.h would be for.

>  
>  static struct vfsmount *shm_mnt;
>  
> @@ -1356,6 +1358,20 @@ out_nomem:
>  
>  static int shmem_mmap(struct file *file, struct vm_area_struct *vma)
>  {
> +	if (!(vma->vm_flags & VM_NORESERVE) &&
> +	    sysctl_overcommit_memory == OVERCOMMIT_NEVER) {

So, this would be a new and different usage of sysctl_overcommit_memory:
usually it applies to vm_committed_as accounting, but you're extending
it to affect tmpfs filesystem size accounting.  Hmm.

> +		struct inode *inode = file_inode(file);
> +		struct kstatfs sbuf;
> +		u64 size;
> +
> +		inode->i_sb->s_op->statfs(file->f_dentry, &sbuf);

You don't really need to go through ->statfs(), since that will arrive
at shmem_statfs().  Where you can see there will be a problem in the
case of an unlimited (max_blocks=0) mount - you will fail mmap() of
every file of non-0 size - and mmaps of 0-size files aren't much use!
But moving on from that case...

> +		size = sbuf.f_bfree * sbuf.f_bsize;
> +
> +		if (size < inode->i_size) {
> +			return -ENOMEM;

So, if your filesystem is full, mmap() of any (i_size>0) file in it will
fail?  I don't think that's what you want at all.  You seem to be assuming
that no pages of the file you're mmap()ing have been allocated yet: that
may be the case, but it's very often not so.

> +		}

And if we pass that test, there's stll no assurance that you won't get
SIGBUS from accessing the mmapping: nothing has actually been reserved
here, and other activity on the system can gobble up all the remaining
space in the filesystem, or take vm_committed_as to its maximum.

> +	}
> +
>  	file_accessed(file);
>  	vma->vm_ops = &shmem_vm_ops;
>  	return 0;
> -- 
> 1.7.10.4

Please "man 2 fallocate" and use that instead.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
