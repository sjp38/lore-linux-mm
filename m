Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id A1D876B0003
	for <linux-mm@kvack.org>; Mon,  9 Apr 2018 14:50:20 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id z13so5426143pfe.21
        for <linux-mm@kvack.org>; Mon, 09 Apr 2018 11:50:20 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n11-v6sor424830pls.89.2018.04.09.11.50.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 09 Apr 2018 11:50:19 -0700 (PDT)
Date: Mon, 9 Apr 2018 11:50:16 -0700
From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: [PATCH] ipc/shm: fix use-after-free of shm file via
 remap_file_pages()
Message-ID: <20180409185016.GA203367@gmail.com>
References: <94eb2c06f65e5e2467055d036889@google.com>
 <20180409043039.28915-1-ebiggers3@gmail.com>
 <20180409094813.bsjc3u2hnsrdyiuk@black.fi.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180409094813.bsjc3u2hnsrdyiuk@black.fi.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Davidlohr Bueso <dave@stgolabs.net>, Manfred Spraul <manfred@colorfullife.com>, "Eric W . Biederman" <ebiederm@xmission.com>, syzkaller-bugs@googlegroups.com

On Mon, Apr 09, 2018 at 12:48:14PM +0300, Kirill A. Shutemov wrote:
> On Mon, Apr 09, 2018 at 04:30:39AM +0000, Eric Biggers wrote:
> > diff --git a/ipc/shm.c b/ipc/shm.c
> > index acefe44fefefa..c80c5691a9970 100644
> > --- a/ipc/shm.c
> > +++ b/ipc/shm.c
> > @@ -225,6 +225,12 @@ static int __shm_open(struct vm_area_struct *vma)
> >  	if (IS_ERR(shp))
> >  		return PTR_ERR(shp);
> >  
> > +	if (shp->shm_file != sfd->file) {
> > +		/* ID was reused */
> > +		shm_unlock(shp);
> > +		return -EINVAL;
> > +	}
> > +
> >  	shp->shm_atim = ktime_get_real_seconds();
> >  	ipc_update_pid(&shp->shm_lprid, task_tgid(current));
> >  	shp->shm_nattch++;
> > @@ -455,8 +461,9 @@ static int shm_mmap(struct file *file, struct vm_area_struct *vma)
> >  	int ret;
> >  
> >  	/*
> > -	 * In case of remap_file_pages() emulation, the file can represent
> > -	 * removed IPC ID: propogate shm_lock() error to caller.
> > +	 * In case of remap_file_pages() emulation, the file can represent an
> > +	 * IPC ID that was removed, and possibly even reused by another shm
> > +	 * segment already.  Propagate this case as an error to caller.
> >  	 */
> >  	ret = __shm_open(vma);
> >  	if (ret)
> > @@ -480,6 +487,7 @@ static int shm_release(struct inode *ino, struct file *file)
> >  	struct shm_file_data *sfd = shm_file_data(file);
> >  
> >  	put_ipc_ns(sfd->ns);
> > +	fput(sfd->file);
> >  	shm_file_data(file) = NULL;
> >  	kfree(sfd);
> >  	return 0;
> > @@ -1432,7 +1440,7 @@ long do_shmat(int shmid, char __user *shmaddr, int shmflg,
> >  	file->f_mapping = shp->shm_file->f_mapping;
> >  	sfd->id = shp->shm_perm.id;
> >  	sfd->ns = get_ipc_ns(ns);
> > -	sfd->file = shp->shm_file;
> > +	sfd->file = get_file(shp->shm_file);
> >  	sfd->vm_ops = NULL;
> >  
> >  	err = security_mmap_file(file, prot, flags);
> 
> Hm. Why do we need sfd->file refcounting now? It's not obvious to me.
> 
> Looks like it's either a separate bug or an unneeded change.
> 

It's necessary because if we don't hold a reference to sfd->file, then it can be
a stale pointer when we compare it in __shm_open().  In particular, if the new
struct file happened to be allocated at the same address as the old one, then
'sfd->file == shp->shm_file' so the mmap would be allowed.  But, it will be a
different shm segment than was intended.  The caller may not even have
permissions to map it normally, yet it would be done anyway.

In the end it's just broken to have a pointer to something that can be freed out
from under you...

- Eric
