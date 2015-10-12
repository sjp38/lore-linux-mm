Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 3019E6B0253
	for <linux-mm@kvack.org>; Mon, 12 Oct 2015 14:10:46 -0400 (EDT)
Received: by wicgb1 with SMTP id gb1so159051280wic.1
        for <linux-mm@kvack.org>; Mon, 12 Oct 2015 11:10:44 -0700 (PDT)
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com. [209.85.212.177])
        by mx.google.com with ESMTPS id u2si17565057wiz.21.2015.10.12.11.10.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Oct 2015 11:10:43 -0700 (PDT)
Received: by wicge5 with SMTP id ge5so27723740wic.0
        for <linux-mm@kvack.org>; Mon, 12 Oct 2015 11:10:42 -0700 (PDT)
Date: Mon, 12 Oct 2015 21:10:40 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: GPF in shm_lock ipc
Message-ID: <20151012181040.GC6447@node>
References: <CACT4Y+aqaR8QYk2nyN1n1iaSZWofBEkWuffvsfcqpvmGGQyMAw@mail.gmail.com>
 <20151012122702.GC2544@node>
 <20151012174945.GC3170@linux-uzut.site>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151012174945.GC3170@linux-uzut.site>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, dave.hansen@linux.intel.com, Hugh Dickins <hughd@google.com>, Joe Perches <joe@perches.com>, sds@tycho.nsa.gov, Oleg Nesterov <oleg@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, mhocko@suse.cz, gang.chen.5i5j@gmail.com, Peter Feiner <pfeiner@google.com>, aarcange@redhat.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, syzkaller@googlegroups.com, Kostya Serebryany <kcc@google.com>, Alexander Potapenko <glider@google.com>, Andrey Konovalov <andreyknvl@google.com>, Sasha Levin <sasha.levin@oracle.com>

On Mon, Oct 12, 2015 at 10:49:45AM -0700, Davidlohr Bueso wrote:
> On Mon, 12 Oct 2015, Kirill A. Shutemov wrote:
> 
> >On Mon, Oct 12, 2015 at 11:55:44AM +0200, Dmitry Vyukov wrote:
> >Here's slightly simplified and more human readable reproducer:
> >
> >#define _GNU_SOURCE
> >#include <stdlib.h>
> >#include <sys/ipc.h>
> >#include <sys/mman.h>
> >#include <sys/shm.h>
> >
> >#define PAGE_SIZE 4096
> >
> >int main()
> >{
> >	int id;
> >	void *p;
> >
> >	id = shmget(IPC_PRIVATE, 3 * PAGE_SIZE, 0);
> >	p = shmat(id, NULL, 0);
> >	shmctl(id, IPC_RMID, NULL);
> >	remap_file_pages(p, 3 * PAGE_SIZE, 0, 7, 0);
> >
> >       return 0;
> >}
> 
> Thanks!
> 
> >>
> >>On commit dd36d7393d6310b0c1adefb22fba79c3cf8a577c
> >>(git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git)
> >>
> >>------------[ cut here ]------------
> >>WARNING: CPU: 2 PID: 2636 at ipc/shm.c:162 shm_open+0x74/0x80()
> >>Modules linked in:
> >>CPU: 2 PID: 2636 Comm: a.out Not tainted 4.3.0-rc3+ #37
> >>Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
> >> ffffffff81bcb43c ffff88081bf0bd70 ffffffff812fe8d6 0000000000000000
> >> ffff88081bf0bda8 ffffffff81051ff1 ffffffffffffffea ffff88081b896ca8
> >> ffff880819b81620 ffff8800bbaa6d00 ffff880819b81600 ffff88081bf0bdb8
> >>Call Trace:
> >> [<     inline     >] __dump_stack lib/dump_stack.c:15
> >> [<ffffffff812fe8d6>] dump_stack+0x44/0x5e lib/dump_stack.c:50
> >> [<ffffffff81051ff1>] warn_slowpath_common+0x81/0xc0 kernel/panic.c:447
> >> [<ffffffff810520e5>] warn_slowpath_null+0x15/0x20 kernel/panic.c:480
> >> [<     inline     >] shm_lock ipc/shm.c:162
> >> [<ffffffff81295c64>] shm_open+0x74/0x80 ipc/shm.c:196
> >> [<ffffffff81295cbe>] shm_mmap+0x4e/0x80 ipc/shm.c:399 (discriminator 2)
> >> [<ffffffff81142d14>] mmap_region+0x3c4/0x5e0 mm/mmap.c:1627
> >> [<ffffffff81143227>] do_mmap+0x2f7/0x3d0 mm/mmap.c:1402
> >> [<     inline     >] do_mmap_pgoff include/linux/mm.h:1930
> >> [<     inline     >] SYSC_remap_file_pages mm/mmap.c:2694
> >> [<ffffffff811434a9>] SyS_remap_file_pages+0x179/0x240 mm/mmap.c:2641
> >> [<ffffffff81859a97>] entry_SYSCALL_64_fastpath+0x12/0x6a
> >>arch/x86/entry/entry_64.S:185
> >>---[ end trace 0873e743fc645a8c ]---
> >
> >Okay. The problem is that SysV IPC SHM doesn't expect the memory region to
> >be mmap'ed after IPC_RMID, but remap_file_pages() manages to create new
> >VMA using existing one.
> 
> Indeed, naughty users should not be mapping/(re)attaching after IPC_RMID.
> This is common to all things ipc, not only to shm. And while Linux nowadays
> does enforce that nothing touch a segment marked for deletion[1], we have
> contradictory scenarios where the resource is only freed once the last attached
> process exits.
> 
> [1] https://lkml.org/lkml/2015/10/12/483
> 
> So this warning used to in fact be a full BUG_ON, but ultimately the ipc
> subsystem acknowledges that this situation is possible but fully blames the
> user responsible, and therefore we only warn about bogus usage.
> 
> >I'm not sure what the right way to fix it. The SysV SHM VMA is pretty
> >normal from mm POV (no special flags, etc.) and it meats remap_file_pages
> >criteria (shared mapping). Every fix I can think of on mm side is ugly.
> >
> >Probably better to teach shm_mmap() to fall off gracefully in case of
> >non-existing shmid? I'm not familiar with IPC code.
> >Could anyone look into it?
> 
> Yeah, this was my approach as well. Very little tested other than it solves
> the above warning. Basically we don't want to be doing mmap if the segment
> was deleted, thus return a corresponding error instead of triggering the
> same error later on after mmaping, via shm_open(). I still need to think
> a bit more about this, but seems legit if we don't hurt userspace while
> at it (at least the idea, not considering any overhead in doing the idr
> lookup). Thoughts?
> 
> Thanks,
> Davidlohr
> 
> diff --git a/ipc/shm.c b/ipc/shm.c
> index 4178727..9615f19 100644
> --- a/ipc/shm.c
> +++ b/ipc/shm.c
> @@ -385,9 +385,25 @@ static struct mempolicy *shm_get_policy(struct vm_area_struct *vma,
>  static int shm_mmap(struct file *file, struct vm_area_struct *vma)
>  {
> -	struct shm_file_data *sfd = shm_file_data(file);
> +	struct file *vma_file = vma->vm_file;
> +	struct shm_file_data *sfd = shm_file_data(vma_file);
> +	struct ipc_ids *ids = &shm_ids(sfd->ns);
> +	struct kern_ipc_perm *shp;
>  	int ret;
> +	rcu_read_lock();
> +	shp = ipc_obtain_object_check(ids, sfd->id);
> +	if (IS_ERR(shp)) {
> +		ret = -EINVAL;
> +		goto err;
> +	}
> +
> +	if (!ipc_valid_object(shp)) {
> +		ret = -EIDRM;
> +		goto err;
> +	}
> +	rcu_read_unlock();
> +

Hm. Isn't it racy? What prevents IPC_RMID from happening after this point?
Shouldn't we bump shm_nattch here? Or some other refcount?


>  	ret = sfd->file->f_op->mmap(sfd->file, vma);
>  	if (ret != 0)
>  		return ret;
> @@ -399,6 +415,9 @@ static int shm_mmap(struct file *file, struct vm_area_struct *vma)
>  	shm_open(vma);
>  	return ret;
> +err:
> +	rcu_read_unlock();
> +	return ret;
>  }
>  static int shm_release(struct inode *ino, struct file *file)
> 
> 
> 
> 
> 
> 

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
