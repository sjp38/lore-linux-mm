Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id 1A1476B0036
	for <linux-mm@kvack.org>; Mon, 19 May 2014 22:17:34 -0400 (EDT)
Received: by mail-pb0-f49.google.com with SMTP id jt11so6560554pbb.36
        for <linux-mm@kvack.org>; Mon, 19 May 2014 19:17:33 -0700 (PDT)
Received: from mail-pa0-x22f.google.com (mail-pa0-x22f.google.com [2607:f8b0:400e:c03::22f])
        by mx.google.com with ESMTPS id x10si6582004pas.51.2014.05.19.19.17.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 19 May 2014 19:17:33 -0700 (PDT)
Received: by mail-pa0-f47.google.com with SMTP id lf10so6548461pab.6
        for <linux-mm@kvack.org>; Mon, 19 May 2014 19:17:32 -0700 (PDT)
Date: Mon, 19 May 2014 19:16:15 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH v2 1/3] shm: add sealing API
In-Reply-To: <1397587118-1214-2-git-send-email-dh.herrmann@gmail.com>
Message-ID: <alpine.LSU.2.11.1405191911050.2970@eggly.anvils>
References: <1397587118-1214-1-git-send-email-dh.herrmann@gmail.com> <1397587118-1214-2-git-send-email-dh.herrmann@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Herrmann <dh.herrmann@gmail.com>
Cc: Tony Battersby <tonyb@cybernetics.com>, Andy Lutomirski <luto@amacapital.net>, Jan Kara <jack@suse.cz>, Michael Kerrisk <mtk.manpages@gmail.com>, Ryan Lortie <desrt@desrt.ca>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Greg Kroah-Hartman <greg@kroah.com>, john.stultz@linaro.org, Kristian Hogsberg <krh@bitplanet.net>, Lennart Poettering <lennart@poettering.net>, Daniel Mack <zonque@gmail.com>, Kay Sievers <kay@vrfy.org>

On Tue, 15 Apr 2014, David Herrmann wrote:

> If two processes share a common memory region, they usually want some
> guarantees to allow safe access. This often includes:
>   - one side cannot overwrite data while the other reads it
>   - one side cannot shrink the buffer while the other accesses it
>   - one side cannot grow the buffer beyond previously set boundaries
> 
> If there is a trust-relationship between both parties, there is no need
> for policy enforcement. However, if there's no trust relationship (eg.,
> for general-purpose IPC) sharing memory-regions is highly fragile and
> often not possible without local copies. Look at the following two
> use-cases:
>   1) A graphics client wants to share its rendering-buffer with a
>      graphics-server. The memory-region is allocated by the client for
>      read/write access and a second FD is passed to the server. While
>      scanning out from the memory region, the server has no guarantee that
>      the client doesn't shrink the buffer at any time, requiring rather
>      cumbersome SIGBUS handling.
>   2) A process wants to perform an RPC on another process. To avoid huge
>      bandwidth consumption, zero-copy is preferred. After a message is
>      assembled in-memory and a FD is passed to the remote side, both sides
>      want to be sure that neither modifies this shared copy, anymore. The
>      source may have put sensible data into the message without a separate
>      copy and the target may want to parse the message inline, to avoid a
>      local copy.
> 
> While SIGBUS handling, POSIX mandatory locking and MAP_DENYWRITE provide
> ways to achieve most of this, the first one is unproportionally ugly to
> use in libraries and the latter two are broken/racy or even disabled due
> to denial of service attacks.
> 
> This patch introduces the concept of SEALING. If you seal a file, a
> specific set of operations is blocked on that file forever.
> Unlike locks, seals can only be set, never removed. Hence, once you
> verified a specific set of seals is set, you're guaranteed that no-one can
> perform the blocked operations on this file, anymore.
> 
> An initial set of SEALS is introduced by this patch:
>   - SHRINK: If SEAL_SHRINK is set, the file in question cannot be reduced
>             in size. This affects ftruncate() and open(O_TRUNC).
>   - GROW: If SEAL_GROW is set, the file in question cannot be increased
>           in size. This affects ftruncate(), fallocate() and write().
>   - WRITE: If SEAL_WRITE is set, no write operations (besides resizing)
>            are possible. This affects fallocate(PUNCH_HOLE), mmap() and
>            write().
>   - SEAL: If SEAL_SEAL is set, no further seals can be added to a file.
>           This basically prevents the F_ADD_SEAL operation on a file and
>           can be set to prevent others from adding further seals that you
>           don't want.
> 
> The described use-cases can easily use these seals to provide safe use
> without any trust-relationship:
>   1) The graphics server can verify that a passed file-descriptor has
>      SEAL_SHRINK set. This allows safe scanout, while the client is
>      allowed to increase buffer size for window-resizing on-the-fly.
>      Concurrent writes are explicitly allowed.
>   2) For general-purpose IPC, both processes can verify that SEAL_SHRINK,
>      SEAL_GROW and SEAL_WRITE are set. This guarantees that neither
>      process can modify the data while the other side parses it.
>      Furthermore, it guarantees that even with writable FDs passed to the
>      peer, it cannot increase the size to hit memory-limits of the source
>      process (in case the file-storage is accounted to the source).
> 
> The new API is an extension to fcntl(), adding two new commands:
>   F_GET_SEALS: Return a bitset describing the seals on the file. This
>                can be called on any FD if the underlying file supports
>                sealing.
>   F_ADD_SEALS: Change the seals of a given file. This requires WRITE
>                access to the file and F_SEAL_SEAL may not already be set.
>                Furthermore, the underlying file must support sealing and
>                there may not be any existing shared mapping of that file.
>                Otherwise, EBADF/EPERM is returned.
>                The given seals are _added_ to the existing set of seals
>                on the file. You cannot remove seals again.
> 
> The fcntl() handler is currently specific to shmem and disabled on all
> files. A file needs to explicitly support sealing for this interface to
> work. A separate syscall is added in a follow-up, which creates files that
> support sealing. There is no intention to support this on other
> file-systems. Semantics are unclear for non-volatile files and we lack any
> use-case right now. Therefore, the implementation is specific to shmem.

Yes, I think you've struck the right balance, by making it a general
fcntl interface, but implementing it only in shmem.

> 
> Signed-off-by: David Herrmann <dh.herrmann@gmail.com>
> ---
>  fs/fcntl.c                 |   5 ++
>  include/linux/shmem_fs.h   |  20 ++++++
>  include/uapi/linux/fcntl.h |  15 +++++
>  mm/shmem.c                 | 162 ++++++++++++++++++++++++++++++++++++++++++++-
>  4 files changed, 199 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/fcntl.c b/fs/fcntl.c
> index 9ead159..1a7a722 100644
> --- a/fs/fcntl.c
> +++ b/fs/fcntl.c
> @@ -21,6 +21,7 @@
>  #include <linux/rcupdate.h>
>  #include <linux/pid_namespace.h>
>  #include <linux/user_namespace.h>
> +#include <linux/shmem_fs.h>
>  
>  #include <asm/poll.h>
>  #include <asm/siginfo.h>
> @@ -336,6 +337,10 @@ static long do_fcntl(int fd, unsigned int cmd, unsigned long arg,
>  	case F_GETPIPE_SZ:
>  		err = pipe_fcntl(filp, cmd, arg);
>  		break;
> +	case F_ADD_SEALS:
> +	case F_GET_SEALS:
> +		err = shmem_fcntl(filp, cmd, arg);

Okay.  I agree that fcntl() is the best interface to use; and although
we always feel a bit dirty exporting a function from shmem.c for use
outside, you are following what's already done with pipe_fcntl(); and
it seems overkill to add an fcntl method to file_operations without any
wider usage.

> +		break;
>  	default:
>  		break;
>  	}
> diff --git a/include/linux/shmem_fs.h b/include/linux/shmem_fs.h
> index 4d1771c..c043d67 100644
> --- a/include/linux/shmem_fs.h
> +++ b/include/linux/shmem_fs.h
> @@ -1,6 +1,7 @@
>  #ifndef __SHMEM_FS_H
>  #define __SHMEM_FS_H
>  
> +#include <linux/file.h>
>  #include <linux/swap.h>
>  #include <linux/mempolicy.h>
>  #include <linux/pagemap.h>
> @@ -20,6 +21,7 @@ struct shmem_inode_info {
>  	struct shared_policy	policy;		/* NUMA memory alloc policy */
>  	struct list_head	swaplist;	/* chain of maybes on swap */
>  	struct simple_xattrs	xattrs;		/* list of xattrs */
> +	u32			seals;		/* shmem seals */

Okay.  I do wonder why you chose "u32" where I would have chosen
"unsigned int": probably just our different backgrounds - kernel
internals most often use the basic types, whereas you are thinking
about explicit interfaces.  Even syscalls tend to have "int" args,
but perhaps that's just a historic mistake.  I have no good reason
to disagree with your use of "u32", but draw attention to it in
case someone else feels more strongly.

Oh, how about you move "seals" up between "lock" and "flags":
on many configurations, it will then occupy what used to be padding.

>  	struct inode		vfs_inode;
>  };
>  
> @@ -65,4 +67,22 @@ static inline struct page *shmem_read_mapping_page(
>  					mapping_gfp_mask(mapping));
>  }
>  
> +/* marks inode to support sealing */
> +#define SHMEM_ALLOW_SEALING (1U << 31)

This feels unnecessary to me: see comment on shmem_add_seals.

> +
> +#ifdef CONFIG_SHMEM

Should that rather be CONFIG_TMPFS?  I think you have placed
shmem_fcntl() and its supporting functions in the CONFIG_TMPFS
part of mm/shmem.c (and CONFIG_TMPFS depends on CONFIG_SHMEM).

It's almost certainly true that "CONFIG_TMPFS" has outlived its v2.4
usefulness, and serves as more of a confusion than a help nowadays:
particularly since !CONFIG_SHMEM gives you the ramfs filesystem, but
CONFIG_SHMEM without CONFIG_TMPFS does not give you a filesystem.

Blame me for leaving CONFIG_TMPFS around; but for now,
I think it's CONFIG_TMPFS you want there (please check).

> +
> +extern int shmem_add_seals(struct file *file, u32 seals);
> +extern int shmem_get_seals(struct file *file);
> +extern long shmem_fcntl(struct file *file, unsigned int cmd, unsigned long arg);
> +
> +#else
> +

Are you sure you want to generate a link error rather than a runtime
fallback if there's a driver using shmem_add_seals() or shmem_get_seals()
in a !CONFIG_SHMEM kernel?  That might be the right decision, but it
surprises me a little.

> +static inline long shmem_fcntl(struct file *f, unsigned int c, unsigned long a)
> +{
> +	return -EINVAL;

Should be -EBADF to match what you get in the CONFIG_SHMEM case.

> +}
> +
> +#endif
> +
>  #endif
> diff --git a/include/uapi/linux/fcntl.h b/include/uapi/linux/fcntl.h
> index 074b886..1b9b9f4 100644
> --- a/include/uapi/linux/fcntl.h
> +++ b/include/uapi/linux/fcntl.h
> @@ -28,6 +28,21 @@
>  #define F_GETPIPE_SZ	(F_LINUX_SPECIFIC_BASE + 8)
>  
>  /*
> + * Set/Get seals
> + */
> +#define F_ADD_SEALS	(F_LINUX_SPECIFIC_BASE + 9)
> +#define F_GET_SEALS	(F_LINUX_SPECIFIC_BASE + 10)
> +
> +/*
> + * Types of seals
> + */
> +#define F_SEAL_SEAL	0x0001	/* prevent further seals from being set */
> +#define F_SEAL_SHRINK	0x0002	/* prevent file from shrinking */
> +#define F_SEAL_GROW	0x0004	/* prevent file from growing */
> +#define F_SEAL_WRITE	0x0008	/* prevent writes */
> +/* (1U << 31) is reserved for internal use */

I question the need to reserve that: see comment on shmem_add_seals.

> +
> +/*
>   * Types of directory notifications that may be requested.
>   */
>  #define DN_ACCESS	0x00000001	/* File accessed */
> diff --git a/mm/shmem.c b/mm/shmem.c
> index 9f70e02..175a5b8 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -66,6 +66,7 @@ static struct vfsmount *shm_mnt;
>  #include <linux/highmem.h>
>  #include <linux/seq_file.h>
>  #include <linux/magic.h>
> +#include <linux/fcntl.h>
>  
>  #include <asm/uaccess.h>
>  #include <asm/pgtable.h>
> @@ -531,16 +532,23 @@ EXPORT_SYMBOL_GPL(shmem_truncate_range);
>  static int shmem_setattr(struct dentry *dentry, struct iattr *attr)
>  {
>  	struct inode *inode = dentry->d_inode;
> +	struct shmem_inode_info *info = SHMEM_I(inode);
> +	loff_t oldsize = inode->i_size;
> +	loff_t newsize = attr->ia_size;
>  	int error;
>  
>  	error = inode_change_ok(inode, attr);
>  	if (error)
>  		return error;
>  
> -	if (S_ISREG(inode->i_mode) && (attr->ia_valid & ATTR_SIZE)) {
> -		loff_t oldsize = inode->i_size;
> -		loff_t newsize = attr->ia_size;
> +	/* protected by i_mutex */
> +	if (attr->ia_valid & ATTR_SIZE) {
> +		if ((newsize < oldsize && (info->seals & F_SEAL_SHRINK)) ||
> +		    (newsize > oldsize && (info->seals & F_SEAL_GROW)))
> +			return -EPERM;
> +	}
>  
> +	if (S_ISREG(inode->i_mode) && (attr->ia_valid & ATTR_SIZE)) {
>  		if (newsize != oldsize) {
>  			i_size_write(inode, newsize);
>  			inode->i_ctime = inode->i_mtime = CURRENT_TIME;
> @@ -1289,6 +1297,13 @@ out_nomem:
>  
>  static int shmem_mmap(struct file *file, struct vm_area_struct *vma)
>  {
> +	struct inode *inode = file_inode(file);
> +	struct shmem_inode_info *info = SHMEM_I(inode);
> +
> +	/* protected by mmap_sem */
> +	if ((info->seals & F_SEAL_WRITE) && (vma->vm_flags & VM_SHARED))
> +		return -EPERM;
> +
>  	file_accessed(file);
>  	vma->vm_ops = &shmem_vm_ops;
>  	return 0;
> @@ -1373,7 +1388,15 @@ shmem_write_begin(struct file *file, struct address_space *mapping,
>  			struct page **pagep, void **fsdata)
>  {
>  	struct inode *inode = mapping->host;
> +	struct shmem_inode_info *info = SHMEM_I(inode);
>  	pgoff_t index = pos >> PAGE_CACHE_SHIFT;
> +
> +	/* i_mutex is held by caller */
> +	if (info->seals & F_SEAL_WRITE)
> +		return -EPERM;
> +	if ((info->seals & F_SEAL_GROW) && pos + len > inode->i_size)
> +		return -EPERM;
> +
>  	return shmem_getpage(inode, index, pagep, SGP_WRITE, NULL);
>  }
>  
> @@ -1719,11 +1742,133 @@ static loff_t shmem_file_llseek(struct file *file, loff_t offset, int whence)
>  	return offset;
>  }
>  
> +#define F_ALL_SEALS (F_SEAL_SEAL | \
> +		     F_SEAL_SHRINK | \
> +		     F_SEAL_GROW | \
> +		     F_SEAL_WRITE)
> +
> +int shmem_add_seals(struct file *file, u32 seals)
> +{
> +	struct dentry *dentry = file->f_path.dentry;
> +	struct inode *inode = dentry->d_inode;
> +	struct shmem_inode_info *info = SHMEM_I(inode);
> +	int r;

mm/shmem.c is currently using "int error", "int err", "int ret" or
"int retval" for this (maybe more!): I'd prefer you not to add "r"
to the menagerie, "error" or "err" would be good here.

> +
> +	/* SHMEM_ALLOW_SEALING is a private, unused bit */
> +	BUILD_BUG_ON(F_ALL_SEALS & SHMEM_ALLOW_SEALING);

I see no need for SHMEM_ALLOW_SEALING.
Now that you have added F_SEAL_SEAL, why don't you just make
shmem_get_inode() initialize info->seals with F_SEAL_SEAL,
then clear that in the one place you need to in the next patch?

> +
> +	/*
> +	 * SEALING
> +	 * Sealing allows multiple parties to share a shmem-file but restrict
> +	 * access to a specific subset of file operations. Seals can only be
> +	 * added, but never removed. This way, mutually untrusted parties can
> +	 * share common memory regions with a well-defined policy. A malicious
> +	 * peer can thus never perform unwanted operations on a shared object.
> +	 *
> +	 * Seals are only supported on special shmem-files and always affect
> +	 * the whole underlying inode. Once a seal is set, it may prevent some
> +	 * kinds of access to the file. Currently, the following seals are
> +	 * defined:
> +	 *   SEAL_SEAL: Prevent further seals from being set on this file
> +	 *   SEAL_SHRINK: Prevent the file from shrinking
> +	 *   SEAL_GROW: Prevent the file from growing
> +	 *   SEAL_WRITE: Prevent write access to the file
> +	 *
> +	 * As we don't require any trust relationship between two parties, we
> +	 * must prevent seals from being removed. Therefore, sealing a file
> +	 * only adds a given set of seals to the file, it never touches
> +	 * existing seals. Furthermore, the "setting seals"-operation can be
> +	 * sealed itself, which basically prevents any further seal from being
> +	 * added.
> +	 *
> +	 * Semantics of sealing are only defined on volatile files. Only
> +	 * anonymous shmem files support sealing. More importantly, seals are
> +	 * never written to disk. Therefore, there's no plan to support it on
> +	 * other file types.
> +	 */
> +
> +	if (file->f_op != &shmem_file_operations)
> +		return -EBADF;

Okay: that's not what I expect -EBADF to mean, but it does follow
the precedent set by pipe_fcntl().

> +	if (!(info->seals & SHMEM_ALLOW_SEALING))
> +		return -EBADF;
> +	if (!(file->f_mode & FMODE_WRITE))
> +		return -EPERM;
> +	if (seals & ~(u32)F_ALL_SEALS)
> +		return -EINVAL;
> +
> +	/*
> +	 * - i_mutex prevents racing write/ftruncate/fallocate/..
> +	 * - mmap_sem prevents racing mmap() calls
> +	 */
> +
> +	mutex_lock(&inode->i_mutex);
> +	down_read(&current->mm->mmap_sem);

I don't think that use of current->mm->mmap_sem can be correct:
it guards against races with other threads of this process, but
what if another process has this object open and races to mmap it?

I imagine you have to use i_mmap_mutex, and plumb an error return
into __vma_link_file() etc in mm/mmap.c, if the file is found already
sealed against writing - which may prove irritating, especially with
knowledge of sealing being private to mm/shmem.c.

But I have not stopped to work it out properly: the answer may depend
on the answer to the major issue of outstanding async I/O.  As I
mentioned last week, that's an issue I think we cannot overlook.
Tony's copy-raised-pagecount-pages suggestion is a good one, but
not so attractive that I'll give up hope for a better solution.

> +
> +	/* you cannot seal while shared mappings exist */
> +	if (file->f_mapping->i_mmap_writable > 0) {
> +		r = -EPERM;
> +		goto unlock;
> +	}
> +
> +	if (info->seals & F_SEAL_SEAL) {
> +		r = -EPERM;
> +		goto unlock;
> +	}
> +
> +	info->seals |= seals;
> +	r = 0;
> +
> +unlock:
> +	up_read(&current->mm->mmap_sem);
> +	mutex_unlock(&inode->i_mutex);
> +	return r;
> +}
> +EXPORT_SYMBOL(shmem_add_seals);

EXPORT_SYMBOL_GPL(shmem_add_seals).

We don't see an example of its use, but I certainly don't want to see
drivers/gpu changes as part of this patchset, so I think that's okay.

> +
> +int shmem_get_seals(struct file *file)
> +{
> +	struct shmem_inode_info *info;
> +
> +	if (file->f_op != &shmem_file_operations)
> +		return -EBADF;
> +
> +	info = SHMEM_I(file_inode(file));
> +	if (!(info->seals & SHMEM_ALLOW_SEALING))
> +		return -EBADF;

Hmm, so the F_SEAL_SEAL change I suggest would remove that -EBADF,
and instead return F_SEAL_SEAL on any shmem object.  I think that's
fine, but you may see a reason why not?

> +
> +	return info->seals & F_ALL_SEALS;
> +}
> +EXPORT_SYMBOL(shmem_get_seals);

EXPORT_SYMBOL_GPL(shmem_get_seals).

> +
> +long shmem_fcntl(struct file *file, unsigned int cmd, unsigned long arg)
> +{
> +	long r;

long ret or retval please.

> +
> +	switch (cmd) {
> +	case F_ADD_SEALS:
> +		/* disallow upper 32bit */
> +		if (arg >> 32)
> +			return -EINVAL;
> +
> +		r = shmem_add_seals(file, arg);
> +		break;
> +	case F_GET_SEALS:
> +		r = shmem_get_seals(file);
> +		break;
> +	default:
> +		r = -EINVAL;
> +		break;
> +	}
> +
> +	return r;
> +}
> +
>  static long shmem_fallocate(struct file *file, int mode, loff_t offset,
>  							 loff_t len)
>  {
>  	struct inode *inode = file_inode(file);
>  	struct shmem_sb_info *sbinfo = SHMEM_SB(inode->i_sb);
> +	struct shmem_inode_info *info = SHMEM_I(inode);
>  	struct shmem_falloc shmem_falloc;
>  	pgoff_t start, index, end;
>  	int error;
> @@ -1735,6 +1880,12 @@ static long shmem_fallocate(struct file *file, int mode, loff_t offset,
>  		loff_t unmap_start = round_up(offset, PAGE_SIZE);
>  		loff_t unmap_end = round_down(offset + len, PAGE_SIZE) - 1;
>  
> +		/* protected by i_mutex */
> +		if (info->seals & F_SEAL_WRITE) {
> +			error = -EPERM;
> +			goto out;
> +		}
> +
>  		if ((u64)unmap_end > (u64)unmap_start)
>  			unmap_mapping_range(mapping, unmap_start,
>  					    1 + unmap_end - unmap_start, 0);
> @@ -1749,6 +1900,11 @@ static long shmem_fallocate(struct file *file, int mode, loff_t offset,
>  	if (error)
>  		goto out;
>  
> +	if ((info->seals & F_SEAL_GROW) && offset + len > inode->i_size) {

Okay.  I don't think it needs a comment, but I note in passing that we
*could* permit a FALLOC_FL_KEEP_SIZE change there, since it will make
no difference to what data is accessible; but it would also serve no
useful purpose, so fine to stick with the simpler test you have.

> +		error = -EPERM;
> +		goto out;
> +	}
> +
>  	start = offset >> PAGE_CACHE_SHIFT;
>  	end = (offset + len + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
>  	/* Try to avoid a swapstorm if len is impossible to satisfy */
> -- 
> 1.9.2

There is also, or may be, a small issue of sparse (holey) files.
I do have a question on that in comments on your next patch, and
the answer here may depend on what you want in memfd_create().

What I'm thinking of here is that once a sparse file is sealed
against writing, we must be sure not to give an error when reading
its holes: whereas there are a few unlikely ways in which reading
the holes of a sparse tmpfs file can give -ENOMEM or -ENOSPC.

Most of the memory allocations here can in fact only fail when the
allocating process has already been selected for OOM-kill: that is
not guaranteed forever, but it is how __alloc_pages_slowpath()
currently behaves on ordinary low-order allocations, and will be
hard to change if we ever do so.  Though I dislike relying upon
this, I think we can allow reading holes to fail, if the process
is going to be forcibly killed before it returns to userspace.

But there might still be an issue with vm_enough_memory(),
and there might still be an issue with memcg limits.

We do already use the ZERO_PAGE instead of allocating when it's a
simple read; and on the face of it, we could extend that to mmap
once the file is sealed.  But I am rather afraid to do so - for
many years there was an mmap /dev/zero case which did that, but
it was an easily forgotten case which caught us out at least
once, so I'm reluctant to reintroduce it now for sealing.

Anyway, I don't expect you to resolve the issue of sealed holes:
that's very much my territory, to give you support on.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
