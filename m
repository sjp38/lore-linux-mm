Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 2563D6B01B0
	for <linux-mm@kvack.org>; Mon, 24 May 2010 05:27:12 -0400 (EDT)
Received: by iwn39 with SMTP id 39so3546513iwn.14
        for <linux-mm@kvack.org>; Mon, 24 May 2010 02:27:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.00.1005211344440.7369@sister.anvils>
References: <AANLkTik47c6l3y8CdJ-hUCd2h3SRSb3qAtRovWryb8_p@mail.gmail.com>
	<alpine.LSU.2.00.1005211344440.7369@sister.anvils>
From: Tharindu Rukshan Bamunuarachchi <btharindu@gmail.com>
Date: Mon, 24 May 2010 10:26:39 +0100
Message-ID: <AANLkTil7I6q4wdLgmwZdRN6hb9LVVagN_7oGTIVNDhUk@mail.gmail.com>
Subject: Re: TMPFS over NFSv4
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org, linux-nfs@vger.kernel.org, Alan Cox <alan@lxorguk.ukuu.org.uk>
List-ID: <linux-mm.kvack.org>

thankx a lot Hugh ... I will try this out ... (bit harder patch
already patched SLES kernel :-p ) ....

BTW, what does Alan means by "strict overcommit" ?

e.g.
i did not see this issues with "0 > /proc/sys/vm/overcommit_accounting"
But this happened several times with "2 > /proc/sys/vm/overcommit_accountin=
g"

any clue ?

we are suffering everyday ..... :-|

__
tharindu.info

"those that can, do. Those that can=92t, complain." -- Linus



On Fri, May 21, 2010 at 9:55 PM, Hugh Dickins <hughd@google.com> wrote:
> On Fri, 21 May 2010, Tharindu Rukshan Bamunuarachchi wrote:
>>
>> I tried to export tmpfs file system over NFS and got followin oops ....
>> this kernel is provided with SLES 11 and tainted due to OFED installatio=
n.
>>
>> I am using NFSv4. Please help me to find the root cause if you feel free=
 ....
>>
>>
>> BUG: unable to handle kernel NULL pointer dereference at 00000000000000b=
0
>> IP: __vm_enough_memory+0xf9/0x14e
>> PGD 0
>> Oops: 0000 [1] SMP
>> last sysfs file:
>> /sys/devices/pci0000:00/0000:00:09.0/0000:24:00.0/infiniband/mlx4_1/node=
_desc
>> CPU 0
>> Modules linked in: blah blah blah
>> Supported: No, Unsupported modules are loaded
>> Pid: 8855, comm: nfsd Tainted: G 2.6.27.45-0.1-default #1
>> RIP: 0010: __vm_enough_memory+0xf9/0x14e
> ...
>> Process nfsd (pid: 8855, threadinfo ffff8803642cc000, task ffff88036f140=
380)
>> Stack: ffff88037b93b668 ffff88037009de40 ffff88037b93b668 00000000000000=
00
>> ffff88037b93b601 ffffffff802a8573 ffffffff80a33680 ffffffff80a30730
>> 0000000000000000 0000000300000002 ffff8803642cd930 0000000000000000
>> Call Trace:
>> shmem_getpage+0x4d8/0x764
>> generic_perform_write+0xae/0x1b5
>> generic_file_buffered_write+0x80/0x130
>> __generic_file_aio_write_nolock+0x349/0x37d
>> generic_file_aio_write+0x64/0xc4
>> do_sync_readv_writev+0xc0/0x107
>> do_readv_writev+0xb2/0x18b
>> nfsd_vfs_write+0x10a/0x328 [nfsd]
>> nfsd_write+0x79/0xe2 [nfsd]
>> nfsd4_write+0xd9/0x10d [nfsd]
>> nfsd4_proc_compound+0x1bd/0x2c7 [nfsd]
>> nfsd_dispatch+0xdd/0x1b9 [nfsd]
>> svc_process+0x3d8/0x700 [sunrpc]
>> nfsd+0x1b1/0x27e [nfsd]
>> kthread+0x47/0x73
>> child_rip+0xa/0x11
>
> I believe that was fixed in 2.6.28 by the patch below:
> please would you try it, and if it works for you, then
> I'll ask for it to be included in the next 2.6.27-stable,
> which I expect SLES 11 will include in an update later.
> Strange that more people haven't suffered from it...
>
> Hugh
>
> commit 731572d39fcd3498702eda4600db4c43d51e0b26
> Author: Alan Cox <alan@redhat.com>
> Date: =A0 Wed Oct 29 14:01:20 2008 -0700
>
> =A0 =A0nfsd: fix vm overcommit crash
>
> =A0 =A0Junjiro R. =A0Okajima reported a problem where knfsd crashes if yo=
u are
> =A0 =A0using it to export shmemfs objects and run strict overcommit. =A0I=
n this
> =A0 =A0situation the current->mm based modifier to the overcommit goes th=
rough a
> =A0 =A0NULL pointer.
>
> =A0 =A0We could simply check for NULL and skip the modifier but we've cau=
ght
> =A0 =A0other real bugs in the past from mm being NULL here - cases where =
we did
> =A0 =A0need a valid mm set up (eg the exec bug about a year ago).
>
> =A0 =A0To preserve the checks and get the logic we want shuffle the check=
ing
> =A0 =A0around and add a new helper to the vm_ security wrappers
>
> =A0 =A0Also fix a current->mm reference in nommu that should use the pass=
ed mm
>
> =A0 =A0[akpm@linux-foundation.org: coding-style fixes]
> =A0 =A0[akpm@linux-foundation.org: fix build]
> =A0 =A0Reported-by: Junjiro R. Okajima <hooanon05@yahoo.co.jp>
> =A0 =A0Acked-by: James Morris <jmorris@namei.org>
> =A0 =A0Signed-off-by: Alan Cox <alan@redhat.com>
> =A0 =A0Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> =A0 =A0Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
>
> diff --git a/include/linux/security.h b/include/linux/security.h
> index f5c4a51..c13f1ce 100644
> --- a/include/linux/security.h
> +++ b/include/linux/security.h
> @@ -1585,6 +1585,7 @@ int security_syslog(int type);
> =A0int security_settime(struct timespec *ts, struct timezone *tz);
> =A0int security_vm_enough_memory(long pages);
> =A0int security_vm_enough_memory_mm(struct mm_struct *mm, long pages);
> +int security_vm_enough_memory_kern(long pages);
> =A0int security_bprm_alloc(struct linux_binprm *bprm);
> =A0void security_bprm_free(struct linux_binprm *bprm);
> =A0void security_bprm_apply_creds(struct linux_binprm *bprm, int unsafe);
> @@ -1820,6 +1821,11 @@ static inline int security_vm_enough_memory(long p=
ages)
> =A0 =A0 =A0 =A0return cap_vm_enough_memory(current->mm, pages);
> =A0}
>
> +static inline int security_vm_enough_memory_kern(long pages)
> +{
> + =A0 =A0 =A0 return cap_vm_enough_memory(current->mm, pages);
> +}
> +
> =A0static inline int security_vm_enough_memory_mm(struct mm_struct *mm, l=
ong pages)
> =A0{
> =A0 =A0 =A0 =A0return cap_vm_enough_memory(mm, pages);
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 74f4d15..de14ac2 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -175,7 +175,8 @@ int __vm_enough_memory(struct mm_struct *mm, long pag=
es, int cap_sys_admin)
>
> =A0 =A0 =A0 =A0/* Don't let a single process grow too big:
> =A0 =A0 =A0 =A0 =A0 leave 3% of the size of this process for other proces=
ses */
> - =A0 =A0 =A0 allowed -=3D mm->total_vm / 32;
> + =A0 =A0 =A0 if (mm)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 allowed -=3D mm->total_vm / 32;
>
> =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 * cast `allowed' as a signed long because vm_committed_sp=
ace
> diff --git a/mm/nommu.c b/mm/nommu.c
> index 2696b24..7695dc8 100644
> --- a/mm/nommu.c
> +++ b/mm/nommu.c
> @@ -1454,7 +1454,8 @@ int __vm_enough_memory(struct mm_struct *mm, long p=
ages, int cap_sys_admin)
>
> =A0 =A0 =A0 =A0/* Don't let a single process grow too big:
> =A0 =A0 =A0 =A0 =A0 leave 3% of the size of this process for other proces=
ses */
> - =A0 =A0 =A0 allowed -=3D current->mm->total_vm / 32;
> + =A0 =A0 =A0 if (mm)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 allowed -=3D mm->total_vm / 32;
>
> =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 * cast `allowed' as a signed long because vm_committed_sp=
ace
> diff --git a/mm/shmem.c b/mm/shmem.c
> index d38d7e6..0ed0752 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -161,8 +161,8 @@ static inline struct shmem_sb_info *SHMEM_SB(struct s=
uper_block *sb)
> =A0*/
> =A0static inline int shmem_acct_size(unsigned long flags, loff_t size)
> =A0{
> - =A0 =A0 =A0 return (flags & VM_ACCOUNT)?
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 security_vm_enough_memory(VM_ACCT(size)): 0=
;
> + =A0 =A0 =A0 return (flags & VM_ACCOUNT) ?
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 security_vm_enough_memory_kern(VM_ACCT(size=
)) : 0;
> =A0}
>
> =A0static inline void shmem_unacct_size(unsigned long flags, loff_t size)
> @@ -179,8 +179,8 @@ static inline void shmem_unacct_size(unsigned long fl=
ags, loff_t size)
> =A0*/
> =A0static inline int shmem_acct_block(unsigned long flags)
> =A0{
> - =A0 =A0 =A0 return (flags & VM_ACCOUNT)?
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 0: security_vm_enough_memory(VM_ACCT(PAGE_C=
ACHE_SIZE));
> + =A0 =A0 =A0 return (flags & VM_ACCOUNT) ?
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 0 : security_vm_enough_memory_kern(VM_ACCT(=
PAGE_CACHE_SIZE));
> =A0}
>
> =A0static inline void shmem_unacct_blocks(unsigned long flags, long pages=
)
> diff --git a/security/security.c b/security/security.c
> index 255b085..c0acfa7 100644
> --- a/security/security.c
> +++ b/security/security.c
> @@ -198,14 +198,23 @@ int security_settime(struct timespec *ts, struct ti=
mezone *tz)
>
> =A0int security_vm_enough_memory(long pages)
> =A0{
> + =A0 =A0 =A0 WARN_ON(current->mm =3D=3D NULL);
> =A0 =A0 =A0 =A0return security_ops->vm_enough_memory(current->mm, pages);
> =A0}
>
> =A0int security_vm_enough_memory_mm(struct mm_struct *mm, long pages)
> =A0{
> + =A0 =A0 =A0 WARN_ON(mm =3D=3D NULL);
> =A0 =A0 =A0 =A0return security_ops->vm_enough_memory(mm, pages);
> =A0}
>
> +int security_vm_enough_memory_kern(long pages)
> +{
> + =A0 =A0 =A0 /* If current->mm is a kernel thread then we will pass NULL=
,
> + =A0 =A0 =A0 =A0 =A0for this specific case that is fine */
> + =A0 =A0 =A0 return security_ops->vm_enough_memory(current->mm, pages);
> +}
> +
> =A0int security_bprm_alloc(struct linux_binprm *bprm)
> =A0{
> =A0 =A0 =A0 =A0return security_ops->bprm_alloc_security(bprm);
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
