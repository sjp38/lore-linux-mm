Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 83261828F3
	for <linux-mm@kvack.org>; Sun, 10 Jan 2016 14:30:55 -0500 (EST)
Received: by mail-wm0-f54.google.com with SMTP id f206so239871861wmf.0
        for <linux-mm@kvack.org>; Sun, 10 Jan 2016 11:30:55 -0800 (PST)
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [2002:c35c:fd02::1])
        by mx.google.com with ESMTPS id qs3si37371647wjc.230.2016.01.10.11.30.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 10 Jan 2016 11:30:54 -0800 (PST)
Date: Sun, 10 Jan 2016 19:30:44 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH v6] fs: clear file privilege bits when mmap writing
Message-ID: <20160110193044.GG17997@ZenIV.linux.org.uk>
References: <20160108232727.GA23490@www.outflux.net>
 <CALYGNiOUL7ewU3+5Zoi_9qofYWwF0vpqMy=A0wS=jUFZ11haCg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALYGNiOUL7ewU3+5Zoi_9qofYWwF0vpqMy=A0wS=jUFZ11haCg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: Kees Cook <keescook@chromium.org>, Andy Lutomirski <luto@amacapital.net>, Jan Kara <jack@suse.cz>, yalin wang <yalin.wang2010@gmail.com>, Willy Tarreau <w@1wt.eu>, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-arch@vger.kernel.org, Linux API <linux-api@vger.kern>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Sun, Jan 10, 2016 at 06:48:32PM +0300, Konstantin Khlebnikov wrote:
> I think this should be done in mmap/mprotect. Code in sys_mmap is trivial.
> 
> In sys_mprotect you can check file_needs_remove_privs() and VM_SHARED
> under mmap_sem, then if needed grab reference to struct file from vma and
> clear suid after unlocking mmap_sem.

Which vma?  mprotect(2) can cover more than one mapping...  You'd have to
play interesting games to collect the set of affected struct file; it
_might_ be doable (e.g. by using task_work_add() to have the damn thing
trigger on the way to userland), but it would require some care to avoid
hitting the same file more than once - it might, after all, be mmapped
in more than one process, so racing mprotect() would need to be taken
into account.  Hell knows - might be doable, but I'm not sure it'll be
any prettier.

->f_u.fu_rcuhead.func would need to be zeroed on struct file allocation,
and that code would need to
	* check ->f_u.fu_rcuhead.func; if non-NULL - sod off, nothing to do
	* lock ->f_lock
	* recheck (and unlock if we'd lost a race and need to sod off)
	* get_file()
	* task_work_add() on ->f_u.fu_rcuhead
	* drop ->f_lock
with task_work_add() callback removing SUID, zero ->fu.fu_rcuhead.func (under
->f_lock) and finally fput().

In principle, that would work; the primitive would be along the lines of
"make sure that SUID is removed before return to userland" and both mmap
and mprotect would use it.  The primitive itself would be in fs/file_table.c,
encapsulating the messy details in there.  All existing users of ->f_u don't
touch it until ->f_count drops to 0, so we are OK to use it here.  It obviously
should _not_ be used for kernel threads (task_work_add() won't do us any
good in those, but then we are not going to do mmap or mprotect there either).
Regular writes should *not* use that - they ought to strip SUID directly.

Might be worth trying...  Any takers?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
