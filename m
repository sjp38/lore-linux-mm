Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f177.google.com (mail-ig0-f177.google.com [209.85.213.177])
	by kanga.kvack.org (Postfix) with ESMTP id 7E391828DF
	for <linux-mm@kvack.org>; Wed, 13 Jan 2016 15:33:23 -0500 (EST)
Received: by mail-ig0-f177.google.com with SMTP id z14so160241451igp.1
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 12:33:23 -0800 (PST)
Received: from mail-ig0-x229.google.com (mail-ig0-x229.google.com. [2607:f8b0:4001:c05::229])
        by mx.google.com with ESMTPS id x8si7247359igl.25.2016.01.13.12.33.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jan 2016 12:33:22 -0800 (PST)
Received: by mail-ig0-x229.google.com with SMTP id h5so116014263igh.0
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 12:33:22 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CALYGNiMg73Zs7eNHvnaqYbW9kbk_r-kmSJj6mqwdhuTbZXSsfw@mail.gmail.com>
References: <20160112190903.GA9421@www.outflux.net>
	<20160113090330.GA14630@quack.suse.cz>
	<CAGXu5jLWk5ymWKYAaW+uQX-5SWQkFmCjesH_H=LPKwX=UVL5oQ@mail.gmail.com>
	<CALYGNiMg73Zs7eNHvnaqYbW9kbk_r-kmSJj6mqwdhuTbZXSsfw@mail.gmail.com>
Date: Wed, 13 Jan 2016 12:33:22 -0800
Message-ID: <CAGXu5jKt4GmOcC9WJyV9sDVOPDG+ViUDWd5PDOjm7Pe0RSLgEg@mail.gmail.com>
Subject: Re: [PATCH v8] fs: clear file privilege bits when mmap writing
From: Kees Cook <keescook@chromium.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: Jan Kara <jack@suse.cz>, Alexander Viro <viro@zeniv.linux.org.uk>, Andy Lutomirski <luto@amacapital.net>, yalin wang <yalin.wang2010@gmail.com>, Willy Tarreau <w@1wt.eu>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Jan 13, 2016 at 12:23 PM, Konstantin Khlebnikov
<koct9i@gmail.com> wrote:
> On Wed, Jan 13, 2016 at 7:09 PM, Kees Cook <keescook@chromium.org> wrote:
>> On Wed, Jan 13, 2016 at 1:03 AM, Jan Kara <jack@suse.cz> wrote:
>>> On Tue 12-01-16 11:09:04, Kees Cook wrote:
>>>> Normally, when a user can modify a file that has setuid or setgid bits,
>>>> those bits are cleared when they are not the file owner or a member
>>>> of the group. This is enforced when using write and truncate but not
>>>> when writing to a shared mmap on the file. This could allow the file
>>>> writer to gain privileges by changing a binary without losing the
>>>> setuid/setgid/caps bits.
>>>>
>>>> Changing the bits requires holding inode->i_mutex, so it cannot be done
>>>> during the page fault (due to mmap_sem being held during the fault).
>>>> Instead, clear the bits if PROT_WRITE is being used at mmap open time,
>>>> or added at mprotect time.
>>>>
>>>> Since we can't do the check in the right place inside mmap (due to
>>>> holding mmap_sem), we have to do it before holding mmap_sem, which
>>>> means duplicating some checks, which have to be available to the non-MMU
>>>> builds too.
>>>>
>>>> When walking VMAs during mprotect, we need to drop mmap_sem (while
>>>> holding a file reference) and restart the walk after clearing privileges.
>>>
>>> ...
>>>
>>>> @@ -375,6 +376,7 @@ SYSCALL_DEFINE3(mprotect, unsigned long, start, size_t, len,
>>>>
>>>>       vm_flags = calc_vm_prot_bits(prot);
>>>>
>>>> +restart:
>>>>       down_write(&current->mm->mmap_sem);
>>>>
>>>>       vma = find_vma(current->mm, start);
>>>> @@ -416,6 +418,28 @@ SYSCALL_DEFINE3(mprotect, unsigned long, start, size_t, len,
>>>>                       goto out;
>>>>               }
>>>>
>>>> +             /*
>>>> +              * If we're adding write permissions to a shared file,
>>>> +              * we must clear privileges (like done at mmap time),
>>>> +              * but we have to juggle the locks to avoid holding
>>>> +              * mmap_sem while holding i_mutex.
>>>> +              */
>>>> +             if ((vma->vm_flags & VM_SHARED) && vma->vm_file &&
>>>> +                 (newflags & VM_WRITE) && !(vma->vm_flags & VM_WRITE) &&
>>>> +                 !IS_NOSEC(file_inode(vma->vm_file))) {
>>>
>>> This code assumes that IS_NOSEC gets set for inode once file_remove_privs()
>>> is called. However that is not true for two reasons:
>>>
>>> 1) When you are root, SUID bit doesn't get cleared and thus you cannot set
>>> IS_NOSEC.
>>>
>>> 2) Some filesystems do not have MS_NOSEC set and for those IS_NOSEC is
>>> never true.
>>>
>>> So in these cases you'll loop forever.
>>
>> UUuugh.
>>
>>>
>>> You can check SUID bits without i_mutex so that could be done without
>>> dropping mmap_sem but you cannot easily call security_inode_need_killpriv()
>>> without i_mutex as that checks extended attributes (IMA) and that needs
>>> i_mutex to be held to avoid races with someone else changing the attributes
>>> under you.
>>
>> Yeah, that's why I changed this from Konstantin's original suggestion.
>>
>>> Honestly, I don't see a way of implementing this in mprotect() which would
>>> be reasonably elegant.
>>
>> Konstantin, any thoughts here?
>
> Getxattr works fine without i_mutex: sys_getxattr/vfs_getxattr doesn't lock it.
> If somebody changes xattrs under us we'll end up in race anyway.
> But this still safe: setxattrs are sychronized.

So I can swap my IS_NOSEC for your original file_needs_remove_privs()?
Are the LSM hooks expecting to be called under mm_sem? (Looks like
only common_caps implements that, though.)

-Kees

-- 
Kees Cook
Chrome OS & Brillo Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
