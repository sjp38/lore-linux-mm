Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 94F9A828DF
	for <linux-mm@kvack.org>; Wed, 13 Jan 2016 04:03:24 -0500 (EST)
Received: by mail-wm0-f45.google.com with SMTP id f206so284841040wmf.0
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 01:03:24 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 71si37430381wmk.60.2016.01.13.01.03.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 13 Jan 2016 01:03:23 -0800 (PST)
Date: Wed, 13 Jan 2016 10:03:30 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v8] fs: clear file privilege bits when mmap writing
Message-ID: <20160113090330.GA14630@quack.suse.cz>
References: <20160112190903.GA9421@www.outflux.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160112190903.GA9421@www.outflux.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Konstantin Khlebnikov <koct9i@gmail.com>, Andy Lutomirski <luto@amacapital.net>, Jan Kara <jack@suse.cz>, yalin wang <yalin.wang2010@gmail.com>, Willy Tarreau <w@1wt.eu>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 12-01-16 11:09:04, Kees Cook wrote:
> Normally, when a user can modify a file that has setuid or setgid bits,
> those bits are cleared when they are not the file owner or a member
> of the group. This is enforced when using write and truncate but not
> when writing to a shared mmap on the file. This could allow the file
> writer to gain privileges by changing a binary without losing the
> setuid/setgid/caps bits.
> 
> Changing the bits requires holding inode->i_mutex, so it cannot be done
> during the page fault (due to mmap_sem being held during the fault).
> Instead, clear the bits if PROT_WRITE is being used at mmap open time,
> or added at mprotect time.
> 
> Since we can't do the check in the right place inside mmap (due to
> holding mmap_sem), we have to do it before holding mmap_sem, which
> means duplicating some checks, which have to be available to the non-MMU
> builds too.
> 
> When walking VMAs during mprotect, we need to drop mmap_sem (while
> holding a file reference) and restart the walk after clearing privileges.

...

> @@ -375,6 +376,7 @@ SYSCALL_DEFINE3(mprotect, unsigned long, start, size_t, len,
>  
>  	vm_flags = calc_vm_prot_bits(prot);
>  
> +restart:
>  	down_write(&current->mm->mmap_sem);
>  
>  	vma = find_vma(current->mm, start);
> @@ -416,6 +418,28 @@ SYSCALL_DEFINE3(mprotect, unsigned long, start, size_t, len,
>  			goto out;
>  		}
>  
> +		/*
> +		 * If we're adding write permissions to a shared file,
> +		 * we must clear privileges (like done at mmap time),
> +		 * but we have to juggle the locks to avoid holding
> +		 * mmap_sem while holding i_mutex.
> +		 */
> +		if ((vma->vm_flags & VM_SHARED) && vma->vm_file &&
> +		    (newflags & VM_WRITE) && !(vma->vm_flags & VM_WRITE) &&
> +		    !IS_NOSEC(file_inode(vma->vm_file))) {

This code assumes that IS_NOSEC gets set for inode once file_remove_privs()
is called. However that is not true for two reasons:

1) When you are root, SUID bit doesn't get cleared and thus you cannot set
IS_NOSEC.

2) Some filesystems do not have MS_NOSEC set and for those IS_NOSEC is
never true.

So in these cases you'll loop forever.

You can check SUID bits without i_mutex so that could be done without
dropping mmap_sem but you cannot easily call security_inode_need_killpriv()
without i_mutex as that checks extended attributes (IMA) and that needs
i_mutex to be held to avoid races with someone else changing the attributes
under you.

Honestly, I don't see a way of implementing this in mprotect() which would
be reasonably elegant.

								Honza

-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
