Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 3FF0A6008F1
	for <linux-mm@kvack.org>; Tue, 25 May 2010 05:01:02 -0400 (EDT)
Received: by iwn39 with SMTP id 39so4828703iwn.14
        for <linux-mm@kvack.org>; Tue, 25 May 2010 02:01:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.00.1005241624130.28773@sister.anvils>
References: <AANLkTik47c6l3y8CdJ-hUCd2h3SRSb3qAtRovWryb8_p@mail.gmail.com>
	<alpine.LSU.2.00.1005211344440.7369@sister.anvils> <AANLkTil7I6q4wdLgmwZdRN6hb9LVVagN_7oGTIVNDhUk@mail.gmail.com>
	<AANLkTilMQjZaUom2h_aFgU6WB83IGH-VVKTg-CJD-_ZZ@mail.gmail.com>
	<20100524110903.72524853@lxorguk.ukuu.org.uk> <alpine.LSU.2.00.1005241624130.28773@sister.anvils>
From: Tharindu Rukshan Bamunuarachchi <btharindu@gmail.com>
Date: Tue, 25 May 2010 10:00:29 +0100
Message-ID: <AANLkTil-gH0k7n_Vb3C1ubn_PioL9LG6xX1tgD1vqgQo@mail.gmail.com>
Subject: Re: TMPFS over NFSv4
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hughd@google.com>
Cc: Greg KH <gregkh@suse.de>, Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, stable@kernel.org
List-ID: <linux-mm.kvack.org>

hope that the 2.6.27.48 or later will be shipped with SP1 :-)

__
tharindu.info

"those that can, do. Those that can=92t, complain." -- Linus



On Tue, May 25, 2010 at 12:46 AM, Hugh Dickins <hughd@google.com> wrote:
> Hi Greg,
>
> On Mon, 24 May 2010, Alan Cox wrote:
>> On Mon, 24 May 2010 02:57:30 -0700
>> Hugh Dickins <hughd@google.com> wrote:
>> > On Mon, May 24, 2010 at 2:26 AM, Tharindu Rukshan Bamunuarachchi
>> > <btharindu@gmail.com> wrote:
>> > > thankx a lot Hugh ... I will try this out ... (bit harder patch
>> > > already patched SLES kernel :-p ) ....
>> >
>> > If patch conflicts are a problem, you really only need to put in the
>> > two-liner patch to mm/mmap.c: Alan was seeking perfection in
>> > the rest of the patch, but you can get away without it.
>> >
>> > >
>> > > BTW, what does Alan means by "strict overcommit" ?
>> >
>> > Ah, that phrase, yes, it's a nonsense, but many of us do say it by mis=
take.
>> > Alan meant to say "strict no-overcommit".
>>
>> No I always meant to say 'strict overcommit'. It avoids excess negatives
>> and "no noovercommit" discussions.
>>
>> I guess 'strict overcommit control' would have been clearer 8)
>>
>> Alan
>
> I see we've just missed 2.6.27.47-rc1, but if there's to be an -rc2,
> please include Alan's 2.6.28 oops fix below: which Tharindu appears
> to be needing - just now discussed on linux-mm and linux-nfs.
> Failing that, please queue it up for 2.6.27.48.
>
> Or if you'd prefer a smaller patch for -stable, then just the mm/mmap.c
> part of it should suffice: I think it's fair to say that the rest of the
> patch was more precautionary - as Alan describes, for catching other bugs=
,
> so good for an ongoing development tree, but not necessarily in -stable.
> (However, Alan may disagree - I've already misrepresented him once here!)
>
> Thanks,
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
