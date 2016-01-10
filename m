Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id EE7CD828F3
	for <linux-mm@kvack.org>; Sun, 10 Jan 2016 16:10:59 -0500 (EST)
Received: by mail-wm0-f49.google.com with SMTP id l65so190167743wmf.1
        for <linux-mm@kvack.org>; Sun, 10 Jan 2016 13:10:59 -0800 (PST)
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [2002:c35c:fd02::1])
        by mx.google.com with ESMTPS id kz4si7670381wjc.203.2016.01.10.13.10.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 10 Jan 2016 13:10:58 -0800 (PST)
Date: Sun, 10 Jan 2016 21:10:51 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH v6] fs: clear file privilege bits when mmap writing
Message-ID: <20160110211051.GH17997@ZenIV.linux.org.uk>
References: <20160108232727.GA23490@www.outflux.net>
 <CALYGNiOUL7ewU3+5Zoi_9qofYWwF0vpqMy=A0wS=jUFZ11haCg@mail.gmail.com>
 <20160110193044.GG17997@ZenIV.linux.org.uk>
 <CALYGNiOxyXX2dpiPoGQUz0CDsvZtH57CO7gE2rAmTQWLigeL1w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALYGNiOxyXX2dpiPoGQUz0CDsvZtH57CO7gE2rAmTQWLigeL1w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: Kees Cook <keescook@chromium.org>, Andy Lutomirski <luto@amacapital.net>, Jan Kara <jack@suse.cz>, yalin wang <yalin.wang2010@gmail.com>, Willy Tarreau <w@1wt.eu>, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-arch@vger.kernel.org, Linux API <linux-api@vger.kern>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Sun, Jan 10, 2016 at 10:51:52PM +0300, Konstantin Khlebnikov wrote:
> On Sun, Jan 10, 2016 at 10:30 PM, Al Viro <viro@zeniv.linux.org.uk> wrote:
> > On Sun, Jan 10, 2016 at 06:48:32PM +0300, Konstantin Khlebnikov wrote:
> >> I think this should be done in mmap/mprotect. Code in sys_mmap is trivial.
> >>
> >> In sys_mprotect you can check file_needs_remove_privs() and VM_SHARED
> >> under mmap_sem, then if needed grab reference to struct file from vma and
> >> clear suid after unlocking mmap_sem.
> >
> > Which vma?  mprotect(2) can cover more than one mapping...  You'd have to
> > play interesting games to collect the set of affected struct file; it
> > _might_ be doable (e.g. by using task_work_add() to have the damn thing
> > trigger on the way to userland), but it would require some care to avoid
> > hitting the same file more than once - it might, after all, be mmapped
> > in more than one process, so racing mprotect() would need to be taken
> > into account.  Hell knows - might be doable, but I'm not sure it'll be
> > any prettier.
> 
> Ok, I didn't thought about that. mprotect don't have to be atomic for whole
> range -- we could drop mmap_sem, clear suid from one file and restart it
> for next vma and so on.

Won't be fun.  Even aside of the user-visible behaviour changes, you'll have
a lot of new corner cases, starting with the fact that you can't hold onto
vma - virtual address is the best you can do and vma you find after regaining
mmap_sem might start at lower address than one where you are restarting;
getting the splitting-related logics right will be interesting, to put it
mildly.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
