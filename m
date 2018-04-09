Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id CCF006B0003
	for <linux-mm@kvack.org>; Mon,  9 Apr 2018 05:48:19 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id k2so4820919pfi.23
        for <linux-mm@kvack.org>; Mon, 09 Apr 2018 02:48:19 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id 135si12331522pfc.21.2018.04.09.02.48.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Apr 2018 02:48:18 -0700 (PDT)
Date: Mon, 9 Apr 2018 12:48:14 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH] ipc/shm: fix use-after-free of shm file via
 remap_file_pages()
Message-ID: <20180409094813.bsjc3u2hnsrdyiuk@black.fi.intel.com>
References: <94eb2c06f65e5e2467055d036889@google.com>
 <20180409043039.28915-1-ebiggers3@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180409043039.28915-1-ebiggers3@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Biggers <ebiggers3@gmail.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Davidlohr Bueso <dave@stgolabs.net>, Manfred Spraul <manfred@colorfullife.com>, "Eric W . Biederman" <ebiederm@xmission.com>, syzkaller-bugs@googlegroups.com

On Mon, Apr 09, 2018 at 04:30:39AM +0000, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> syzbot reported a use-after-free of shm_file_data(file)->file->f_op in
> shm_get_unmapped_area(), called via sys_remap_file_pages().
> Unfortunately it couldn't generate a reproducer, but I found a bug which
> I think caused it.  When remap_file_pages() is passed a full System V
> shared memory segment, the memory is first unmapped, then a new map is
> created using the ->vm_file.  Between these steps, the shm ID can be
> removed and reused for a new shm segment.  But, shm_mmap() only checks
> whether the ID is currently valid before calling the underlying file's
> ->mmap(); it doesn't check whether it was reused.  Thus it can use the
> wrong underlying file, one that was already freed.
> 
> Fix this by making the "outer" shm file (the one that gets put in
> ->vm_file) hold a reference to the real shm file, and by making
> __shm_open() require that the file associated with the shm ID matches
> the one associated with the "outer" file.
> 
> Commit 1ac0b6dec656 ("ipc/shm: handle removed segments gracefully in
> shm_mmap()") almost fixed this bug, but it didn't go far enough because
> it didn't consider the case where the shm ID is reused.

Right. Thanks for catching this.

> The following program usually reproduces this bug:
> 
> 	#include <stdlib.h>
> 	#include <sys/shm.h>
> 	#include <sys/syscall.h>
> 	#include <unistd.h>
> 
> 	int main()
> 	{
> 		int is_parent = (fork() != 0);
> 		srand(getpid());
> 		for (;;) {
> 			int id = shmget(0xF00F, 4096, IPC_CREAT|0700);
> 			if (is_parent) {
> 				void *addr = shmat(id, NULL, 0);
> 				usleep(rand() % 50);
> 				while (!syscall(__NR_remap_file_pages, addr, 4096, 0, 0, 0));
> 			} else {
> 				usleep(rand() % 50);
> 				shmctl(id, IPC_RMID, NULL);
> 			}
> 		}
> 	}
> 
> It causes the following NULL pointer dereference due to a 'struct file'
> being used while it's being freed.  (I couldn't actually get a KASAN
> use-after-free splat like in the syzbot report.  But I think it's
> possible with this bug; it would just take a more extraordinary race...)
> 
> 	BUG: unable to handle kernel NULL pointer dereference at 0000000000000058
> 	PGD 0 P4D 0
> 	Oops: 0000 [#1] SMP NOPTI
> 	CPU: 9 PID: 258 Comm: syz_ipc Not tainted 4.16.0-05140-gf8cf2f16a7c95 #189
> 	Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.11.0-20171110_100015-anatol 04/01/2014
> 	RIP: 0010:d_inode include/linux/dcache.h:519 [inline]
> 	RIP: 0010:touch_atime+0x25/0xd0 fs/inode.c:1724
> 	[...]
> 	Call Trace:
> 	 file_accessed include/linux/fs.h:2063 [inline]
> 	 shmem_mmap+0x25/0x40 mm/shmem.c:2149
> 	 call_mmap include/linux/fs.h:1789 [inline]
> 	 shm_mmap+0x34/0x80 ipc/shm.c:465
> 	 call_mmap include/linux/fs.h:1789 [inline]
> 	 mmap_region+0x309/0x5b0 mm/mmap.c:1712
> 	 do_mmap+0x294/0x4a0 mm/mmap.c:1483
> 	 do_mmap_pgoff include/linux/mm.h:2235 [inline]
> 	 SYSC_remap_file_pages mm/mmap.c:2853 [inline]
> 	 SyS_remap_file_pages+0x232/0x310 mm/mmap.c:2769
> 	 do_syscall_64+0x64/0x1a0 arch/x86/entry/common.c:287
> 	 entry_SYSCALL_64_after_hwframe+0x42/0xb7
> 
> Reported-by: syzbot+d11f321e7f1923157eac80aa990b446596f46439@syzkaller.appspotmail.com
> Fixes: c8d78c1823f4 ("mm: replace remap_file_pages() syscall with emulation")
> Cc: stable@vger.kernel.org
> Signed-off-by: Eric Biggers <ebiggers@google.com>
> ---
>  ipc/shm.c | 14 +++++++++++---
>  1 file changed, 11 insertions(+), 3 deletions(-)
> 
> diff --git a/ipc/shm.c b/ipc/shm.c
> index acefe44fefefa..c80c5691a9970 100644
> --- a/ipc/shm.c
> +++ b/ipc/shm.c
> @@ -225,6 +225,12 @@ static int __shm_open(struct vm_area_struct *vma)
>  	if (IS_ERR(shp))
>  		return PTR_ERR(shp);
>  
> +	if (shp->shm_file != sfd->file) {
> +		/* ID was reused */
> +		shm_unlock(shp);
> +		return -EINVAL;
> +	}
> +
>  	shp->shm_atim = ktime_get_real_seconds();
>  	ipc_update_pid(&shp->shm_lprid, task_tgid(current));
>  	shp->shm_nattch++;
> @@ -455,8 +461,9 @@ static int shm_mmap(struct file *file, struct vm_area_struct *vma)
>  	int ret;
>  
>  	/*
> -	 * In case of remap_file_pages() emulation, the file can represent
> -	 * removed IPC ID: propogate shm_lock() error to caller.
> +	 * In case of remap_file_pages() emulation, the file can represent an
> +	 * IPC ID that was removed, and possibly even reused by another shm
> +	 * segment already.  Propagate this case as an error to caller.
>  	 */
>  	ret = __shm_open(vma);
>  	if (ret)
> @@ -480,6 +487,7 @@ static int shm_release(struct inode *ino, struct file *file)
>  	struct shm_file_data *sfd = shm_file_data(file);
>  
>  	put_ipc_ns(sfd->ns);
> +	fput(sfd->file);
>  	shm_file_data(file) = NULL;
>  	kfree(sfd);
>  	return 0;
> @@ -1432,7 +1440,7 @@ long do_shmat(int shmid, char __user *shmaddr, int shmflg,
>  	file->f_mapping = shp->shm_file->f_mapping;
>  	sfd->id = shp->shm_perm.id;
>  	sfd->ns = get_ipc_ns(ns);
> -	sfd->file = shp->shm_file;
> +	sfd->file = get_file(shp->shm_file);
>  	sfd->vm_ops = NULL;
>  
>  	err = security_mmap_file(file, prot, flags);

Hm. Why do we need sfd->file refcounting now? It's not obvious to me.

Looks like it's either a separate bug or an unneeded change.

-- 
 Kirill A. Shutemov
