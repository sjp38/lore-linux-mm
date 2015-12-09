Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id D02E26B0038
	for <linux-mm@kvack.org>; Wed,  9 Dec 2015 03:26:47 -0500 (EST)
Received: by wmec201 with SMTP id c201so62194432wme.1
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 00:26:47 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v129si10598761wma.12.2015.12.09.00.26.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 09 Dec 2015 00:26:46 -0800 (PST)
Date: Wed, 9 Dec 2015 09:26:38 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v2] clear file privilege bits when mmap writing
Message-ID: <20151209082638.GA3137@quack.suse.cz>
References: <20151203000342.GA30015@www.outflux.net>
 <B4520E53-6DD9-44D7-A064-9F405FBAA793@gmail.com>
 <CAGXu5jJaY9WeR-NiZXfAu=hM6U7DaPD_d8ZZTAdo_EkS3WDxCw@mail.gmail.com>
 <CAGXu5jKtj89bgyLaYt6hMBXc+rWD9CWxE2nZP9xbSWyXBvf5qw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAGXu5jKtj89bgyLaYt6hMBXc+rWD9CWxE2nZP9xbSWyXBvf5qw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: yalin wang <yalin.wang2010@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Willy Tarreau <w@1wt.eu>, "Eric W. Biederman" <ebiederm@xmission.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Oleg Nesterov <oleg@redhat.com>, Rik van Riel <riel@redhat.com>, Chen Gang <gang.chen.5i5j@gmail.com>, Davidlohr Bueso <dave@stgolabs.net>, Andrea Arcangeli <aarcange@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Al Viro <viro@ZenIV.linux.org.uk>

On Mon 07-12-15 16:40:14, Kees Cook wrote:
> On Mon, Dec 7, 2015 at 2:42 PM, Kees Cook <keescook@chromium.org> wrote:
> > On Thu, Dec 3, 2015 at 5:45 PM, yalin wang <yalin.wang2010@gmail.com> wrote:
> >>
> >>> On Dec 2, 2015, at 16:03, Kees Cook <keescook@chromium.org> wrote:
> >>>
> >>> Normally, when a user can modify a file that has setuid or setgid bits,
> >>> those bits are cleared when they are not the file owner or a member
> >>> of the group. This is enforced when using write and truncate but not
> >>> when writing to a shared mmap on the file. This could allow the file
> >>> writer to gain privileges by changing a binary without losing the
> >>> setuid/setgid/caps bits.
> >>>
> >>> Changing the bits requires holding inode->i_mutex, so it cannot be done
> >>> during the page fault (due to mmap_sem being held during the fault).
> >>> Instead, clear the bits if PROT_WRITE is being used at mmap time.
> >>>
> >>> Signed-off-by: Kees Cook <keescook@chromium.org>
> >>> Cc: stable@vger.kernel.org
> >>> a??
> >>
> >> is this means mprotect() sys call also need add this check?
> >> mprotect() can change to PROT_WRITE, then it can write to a
> >> read only map again , also a secure hole here .
> >
> > Yes, good point. This needs to be added. I will send a new patch. Thanks!
> 
> This continues to look worse and worse.
> 
> So... to check this at mprotect time, I have to know it's MAP_SHARED,
> but that's in the vma_flags, which I can only see after holding
> mmap_sem.
> 
> The best I can think of now is to strip the bits at munmap time, since
> you can't execute an mmapped file until it closes.
> 
> Jan, thoughts on this?

Umm, so we actually refuse to execute a file while someone has it open for
writing (deny_write_access() in do_open_execat()). So dropping the suid /
sgid bits when closing file for writing could be plausible. Grabbing
i_mutex from __fput() context is safe (it gets called from task_work
context when returning to userspace).

That way we could actually remove the checks done for each write. To avoid
unexpected removal of suid/sgid bits when someone just opens & closes the
file, we could mark the file as needing suid/sgid treatment by a flag in
inode->i_flags when file gets written to or mmaped and then check for this
in __fput().

I've added Al Viro to CC just in case he is aware of some issues with
this...

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
