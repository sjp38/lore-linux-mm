Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f170.google.com (mail-lb0-f170.google.com [209.85.217.170])
	by kanga.kvack.org (Postfix) with ESMTP id 53583828F3
	for <linux-mm@kvack.org>; Sun, 10 Jan 2016 14:51:54 -0500 (EST)
Received: by mail-lb0-f170.google.com with SMTP id sv6so237161944lbb.0
        for <linux-mm@kvack.org>; Sun, 10 Jan 2016 11:51:54 -0800 (PST)
Received: from mail-lb0-x242.google.com (mail-lb0-x242.google.com. [2a00:1450:4010:c04::242])
        by mx.google.com with ESMTPS id i69si52366802lfe.150.2016.01.10.11.51.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 10 Jan 2016 11:51:52 -0800 (PST)
Received: by mail-lb0-x242.google.com with SMTP id tz10so23821496lbb.2
        for <linux-mm@kvack.org>; Sun, 10 Jan 2016 11:51:52 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160110193044.GG17997@ZenIV.linux.org.uk>
References: <20160108232727.GA23490@www.outflux.net>
	<CALYGNiOUL7ewU3+5Zoi_9qofYWwF0vpqMy=A0wS=jUFZ11haCg@mail.gmail.com>
	<20160110193044.GG17997@ZenIV.linux.org.uk>
Date: Sun, 10 Jan 2016 22:51:52 +0300
Message-ID: <CALYGNiOxyXX2dpiPoGQUz0CDsvZtH57CO7gE2rAmTQWLigeL1w@mail.gmail.com>
Subject: Re: [PATCH v6] fs: clear file privilege bits when mmap writing
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: Kees Cook <keescook@chromium.org>, Andy Lutomirski <luto@amacapital.net>, Jan Kara <jack@suse.cz>, yalin wang <yalin.wang2010@gmail.com>, Willy Tarreau <w@1wt.eu>, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-arch@vger.kernel.org, Linux API <linux-api@vger.kern>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Sun, Jan 10, 2016 at 10:30 PM, Al Viro <viro@zeniv.linux.org.uk> wrote:
> On Sun, Jan 10, 2016 at 06:48:32PM +0300, Konstantin Khlebnikov wrote:
>> I think this should be done in mmap/mprotect. Code in sys_mmap is trivial.
>>
>> In sys_mprotect you can check file_needs_remove_privs() and VM_SHARED
>> under mmap_sem, then if needed grab reference to struct file from vma and
>> clear suid after unlocking mmap_sem.
>
> Which vma?  mprotect(2) can cover more than one mapping...  You'd have to
> play interesting games to collect the set of affected struct file; it
> _might_ be doable (e.g. by using task_work_add() to have the damn thing
> trigger on the way to userland), but it would require some care to avoid
> hitting the same file more than once - it might, after all, be mmapped
> in more than one process, so racing mprotect() would need to be taken
> into account.  Hell knows - might be doable, but I'm not sure it'll be
> any prettier.

Ok, I didn't thought about that. mprotect don't have to be atomic for whole
range -- we could drop mmap_sem, clear suid from one file and restart it
for next vma and so on.

>
> ->f_u.fu_rcuhead.func would need to be zeroed on struct file allocation,
> and that code would need to
>         * check ->f_u.fu_rcuhead.func; if non-NULL - sod off, nothing to do
>         * lock ->f_lock
>         * recheck (and unlock if we'd lost a race and need to sod off)
>         * get_file()
>         * task_work_add() on ->f_u.fu_rcuhead
>         * drop ->f_lock
> with task_work_add() callback removing SUID, zero ->fu.fu_rcuhead.func (under
> ->f_lock) and finally fput().
>
> In principle, that would work; the primitive would be along the lines of
> "make sure that SUID is removed before return to userland" and both mmap
> and mprotect would use it.  The primitive itself would be in fs/file_table.c,
> encapsulating the messy details in there.  All existing users of ->f_u don't
> touch it until ->f_count drops to 0, so we are OK to use it here.  It obviously
> should _not_ be used for kernel threads (task_work_add() won't do us any
> good in those, but then we are not going to do mmap or mprotect there either).
> Regular writes should *not* use that - they ought to strip SUID directly.
>
> Might be worth trying...  Any takers?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
