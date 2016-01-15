Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f175.google.com (mail-ob0-f175.google.com [209.85.214.175])
	by kanga.kvack.org (Postfix) with ESMTP id 03B616B026D
	for <linux-mm@kvack.org>; Fri, 15 Jan 2016 01:18:57 -0500 (EST)
Received: by mail-ob0-f175.google.com with SMTP id ba1so513314149obb.3
        for <linux-mm@kvack.org>; Thu, 14 Jan 2016 22:18:56 -0800 (PST)
Received: from mail-ob0-x229.google.com (mail-ob0-x229.google.com. [2607:f8b0:4003:c01::229])
        by mx.google.com with ESMTPS id w7si11448331obv.26.2016.01.14.22.18.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Jan 2016 22:18:56 -0800 (PST)
Received: by mail-ob0-x229.google.com with SMTP id ba1so513313963obb.3
        for <linux-mm@kvack.org>; Thu, 14 Jan 2016 22:18:56 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CALYGNiNN+QYpd-FhM+4WXd=-1UYrhR7kpefbN8mpjh4gSbDO4A@mail.gmail.com>
References: <20160114212201.GA28910@www.outflux.net> <CALYGNiNN+QYpd-FhM+4WXd=-1UYrhR7kpefbN8mpjh4gSbDO4A@mail.gmail.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Thu, 14 Jan 2016 22:18:36 -0800
Message-ID: <CALCETrVtCvLgtC2E9r2gRikdivxDC_GkHKVjPF=tYg+6SVyYoQ@mail.gmail.com>
Subject: Re: [PATCH v9] fs: clear file privilege bits when mmap writing
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Jan Kara <jack@suse.cz>, yalin wang <yalin.wang2010@gmail.com>, Willy Tarreau <w@1wt.eu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu, Jan 14, 2016 at 9:55 PM, Konstantin Khlebnikov <koct9i@gmail.com> wrote:
> On Fri, Jan 15, 2016 at 12:22 AM, Kees Cook <keescook@chromium.org> wrote:
>> Normally, when a user can modify a file that has setuid or setgid bits,
>> those bits are cleared when they are not the file owner or a member
>> of the group. This is enforced when using write and truncate but not
>> when writing to a shared mmap on the file. This could allow the file
>> writer to gain privileges by changing a binary without losing the
>> setuid/setgid/caps bits.
>>
>> Changing the bits requires holding inode->i_mutex, so it cannot be done
>> during the page fault (due to mmap_sem being held during the fault).
>> Instead, clear the bits if PROT_WRITE is being used at mmap open time,
>> or added at mprotect tLooks good to me.ime.
>>
>> Since we can't do the check in the right place inside mmap (due to
>> holding mmap_sem), we have to do it before holding mmap_sem, which
>> means duplicating some checks, which have to be available to the non-MMU
>> builds too.
>>
>> When walking VMAs during mprotect, we need to drop mmap_sem (while
>> holding a file reference) and restart the walk after clearing privileges.
>>
>> Signed-off-by: Kees Cook <keescook@chromium.org>
>
> Looks good. Ack.

While we're at it:

int should_remove_suid(struct dentry *dentry)
{
        umode_t mode = d_inode(dentry)->i_mode;
        int kill = 0;

        /* suid always must be killed */
        if (unlikely(mode & S_ISUID))
                kill = ATTR_KILL_SUID;

        /*
         * sgid without any exec bits is just a mandatory locking mark; leave
         * it alone.  If some exec bits are set, it's a real sgid; kill it.
         */
        if (unlikely((mode & S_ISGID) && (mode & S_IXGRP)))
                kill |= ATTR_KILL_SGID;

        if (unlikely(kill && !capable(CAP_FSETID) && S_ISREG(mode)))
                return kill;

        return 0;
}
EXPORT_SYMBOL(should_remove_suid);

Oh wait, is that an implicit use of current_cred in vfs_write?  No, it
couldn't be.  Kernel developers *never* make that mistake.

This is, of course, totally fucked because this function doesn't have
access to a struct file and therefore can't see f_cred.  I'm not going
to look in to this right now, but I swear I saw an exploit that took
advantage of this bug recently.  Anyone want to try to fix it?

FWIW, posix says (man 3p write):

       Upon  successful  completion,  where  nbyte  is greater than 0, write()
       shall mark for update the last data modification and last  file  status
       change  timestamps  of the file, and if the file is a regular file, the
       S_ISUID and S_ISGID bits of the file mode may be cleared.

so maybe the thing to do is just drop the capable check entirely and
cross our fingers that nothing was relying on it.

--Andy

>
>> ---
>> v9:
>> - use file_needs_remove_privs, jack & koct9i
>> v8:
>> - use mmap/mprotect method, with mprotect walk restart, thanks to koct9i
>> v7:
>> - document and avoid arch-specific O_* values, viro
>> v6:
>> - clarify ETXTBSY situation in comments, luto
>> v5:
>> - add to f_flags instead, viro
>> - add i_mutex during __fput, jack
>> v4:
>> - delay removal instead of still needing mmap_sem for mprotect, yalin
>> v3:
>> - move outside of mmap_sem for real now, fengguang
>> - check return code of file_remove_privs, akpm
>> v2:
>> - move to mmap from fault handler, jack
>> ---
>>  include/linux/mm.h |  1 +
>>  mm/mmap.c          | 20 ++++----------------
>>  mm/mprotect.c      | 24 ++++++++++++++++++++++++
>>  mm/util.c          | 50 ++++++++++++++++++++++++++++++++++++++++++++++++++
>>  4 files changed, 79 insertions(+), 16 deletions(-)
>>
>> diff --git a/include/linux/mm.h b/include/linux/mm.h
>> index 00bad7793788..b264c8be7114 100644
>> --- a/include/linux/mm.h
>> +++ b/include/linux/mm.h
>> @@ -1912,6 +1912,7 @@ extern unsigned long get_unmapped_area(struct file *, unsigned long, unsigned lo
>>
>>  extern unsigned long mmap_region(struct file *file, unsigned long addr,
>>         unsigned long len, vm_flags_t vm_flags, unsigned long pgoff);
>> +extern int do_mmap_shared_checks(struct file *file, unsigned long prot);
>>  extern unsigned long do_mmap(struct file *file, unsigned long addr,
>>         unsigned long len, unsigned long prot, unsigned long flags,
>>         vm_flags_t vm_flags, unsigned long pgoff, unsigned long *populate);
>> diff --git a/mm/mmap.c b/mm/mmap.c
>> index 2ce04a649f6b..b3424db0a29e 100644
>> --- a/mm/mmap.c
>> +++ b/mm/mmap.c
>> @@ -1320,25 +1320,13 @@ unsigned long do_mmap(struct file *file, unsigned long addr,
>>                 return -EAGAIN;
>>
>>         if (file) {
>> -               struct inode *inode = file_inode(file);
>> +               int err;
>>
>>                 switch (flags & MAP_TYPE) {
>>                 case MAP_SHARED:
>> -                       if ((prot&PROT_WRITE) && !(file->f_mode&FMODE_WRITE))
>> -                               return -EACCES;
>> -
>> -                       /*
>> -                        * Make sure we don't allow writing to an append-only
>> -                        * file..
>> -                        */
>> -                       if (IS_APPEND(inode) && (file->f_mode & FMODE_WRITE))
>> -                               return -EACCES;
>> -
>> -                       /*
>> -                        * Make sure there are no mandatory locks on the file.
>> -                        */
>> -                       if (locks_verify_locked(file))
>> -                               return -EAGAIN;
>> +                       err = do_mmap_shared_checks(file, prot);
>> +                       if (err)
>> +                               return err;
>>
>>                         vm_flags |= VM_SHARED | VM_MAYSHARE;
>>                         if (!(file->f_mode & FMODE_WRITE))
>> diff --git a/mm/mprotect.c b/mm/mprotect.c
>> index ef5be8eaab00..57cb81c11668 100644
>> --- a/mm/mprotect.c
>> +++ b/mm/mprotect.c
>> @@ -12,6 +12,7 @@
>>  #include <linux/hugetlb.h>
>>  #include <linux/shm.h>
>>  #include <linux/mman.h>
>> +#include <linux/file.h>
>>  #include <linux/fs.h>
>>  #include <linux/highmem.h>
>>  #include <linux/security.h>
>> @@ -375,6 +376,7 @@ SYSCALL_DEFINE3(mprotect, unsigned long, start, size_t, len,
>>
>>         vm_flags = calc_vm_prot_bits(prot);
>>
>> +restart:
>>         down_write(&current->mm->mmap_sem);
>>
>>         vma = find_vma(current->mm, start);
>> @@ -416,6 +418,28 @@ SYSCALL_DEFINE3(mprotect, unsigned long, start, size_t, len,
>>                         goto out;
>>                 }
>>
>> +               /*
>> +                * If we're adding write permissions to a shared file,
>> +                * we must clear privileges (like done at mmap time),
>> +                * but we have to juggle the locks to avoid holding
>> +                * mmap_sem while holding i_mutex.
>> +                */
>> +               if ((vma->vm_flags & VM_SHARED) && vma->vm_file &&
>> +                   (newflags & VM_WRITE) && !(vma->vm_flags & VM_WRITE) &&
>> +                   file_needs_remove_privs(vma->vm_file)) {
>> +                       struct file *file = get_file(vma->vm_file);
>> +
>> +                       start = vma->vm_start;
>> +                       up_write(&current->mm->mmap_sem);
>> +                       mutex_lock(&file_inode(file)->i_mutex);
>> +                       error = file_remove_privs(file);
>> +                       mutex_unlock(&file_inode(file)->i_mutex);
>> +                       fput(file);
>> +                       if (error)
>> +                               return error;
>> +                       goto restart;
>> +               }
>> +
>>                 error = security_file_mprotect(vma, reqprot, prot);
>>                 if (error)
>>                         goto out;
>> diff --git a/mm/util.c b/mm/util.c
>> index 9af1c12b310c..1882eaf33a37 100644
>> --- a/mm/util.c
>> +++ b/mm/util.c
>> @@ -283,6 +283,29 @@ int __weak get_user_pages_fast(unsigned long start,
>>  }
>>  EXPORT_SYMBOL_GPL(get_user_pages_fast);
>>
>> +int do_mmap_shared_checks(struct file *file, unsigned long prot)
>> +{
>> +       struct inode *inode = file_inode(file);
>> +
>> +       if ((prot & PROT_WRITE) && !(file->f_mode & FMODE_WRITE))
>> +               return -EACCES;
>> +
>> +       /*
>> +        * Make sure we don't allow writing to an append-only
>> +        * file..
>> +        */
>> +       if (IS_APPEND(inode) && (file->f_mode & FMODE_WRITE))
>> +               return -EACCES;
>> +
>> +       /*
>> +        * Make sure there are no mandatory locks on the file.
>> +        */
>> +       if (locks_verify_locked(file))
>> +               return -EAGAIN;
>> +
>> +       return 0;
>> +}
>> +
>>  unsigned long vm_mmap_pgoff(struct file *file, unsigned long addr,
>>         unsigned long len, unsigned long prot,
>>         unsigned long flag, unsigned long pgoff)
>> @@ -291,6 +314,33 @@ unsigned long vm_mmap_pgoff(struct file *file, unsigned long addr,
>>         struct mm_struct *mm = current->mm;
>>         unsigned long populate;
>>
>> +       /*
>> +        * If we must remove privs, we do it here since doing it during
>> +        * page fault may be expensive and cannot hold inode->i_mutex,
>> +        * since mm->mmap_sem is already held.
>> +        */
>> +       if (file && (flag & MAP_TYPE) == MAP_SHARED && (prot & PROT_WRITE)) {
>> +               struct inode *inode = file_inode(file);
>> +               int err;
>> +
>> +               if (!IS_NOSEC(inode)) {
>> +                       /*
>> +                        * Make sure we can't strip privs from a file that
>> +                        * wouldn't otherwise be allowed to be mmapped.
>> +                        */
>> +                       err = do_mmap_shared_checks(file, prot);
>> +                       if (err)
>> +                               return err;
>> +
>> +                       mutex_lock(&inode->i_mutex);
>> +                       err = file_remove_privs(file);
>> +                       mutex_unlock(&inode->i_mutex);
>> +
>> +                       if (err)
>> +                               return err;
>> +               }
>> +       }
>> +
>>         ret = security_mmap_file(file, prot, flag);
>>         if (!ret) {
>>                 down_write(&mm->mmap_sem);
>> --
>> 2.6.3
>>
>>
>> --
>> Kees Cook
>> Chrome OS & Brillo Security



-- 
Andy Lutomirski
AMA Capital Management, LLC

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
