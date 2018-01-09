Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 07BB66B026A
	for <linux-mm@kvack.org>; Tue,  9 Jan 2018 16:59:45 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id 207so12555180iti.5
        for <linux-mm@kvack.org>; Tue, 09 Jan 2018 13:59:45 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w76sor6656455iod.174.2018.01.09.13.59.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 09 Jan 2018 13:59:43 -0800 (PST)
Date: Tue, 9 Jan 2018 13:59:39 -0800
From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: KASAN: use-after-free Read in handle_userfault
Message-ID: <20180109215939.GA127462@gmail.com>
References: <001a114c9224e34a49055c842032@google.com>
 <CACT4Y+ZrYTNHDN71ZO1-vhFuCE=sRhfXeLbLom=9XodT7TJtog@mail.gmail.com>
 <20171127061517.GA26341@zzz.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171127061517.GA26341@zzz.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: syzbot <bot+998c483ca801a50e3ce5b63a845216588ada5e2a@syzkaller.appspotmail.com>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, syzkaller-bugs@googlegroups.com, Al Viro <viro@zeniv.linux.org.uk>, Andrea Arcangeli <aarcange@redhat.com>, Pavel Emelyanov <xemul@parallels.com>, linux-mm@kvack.org

On Sun, Nov 26, 2017 at 10:15:17PM -0800, Eric Biggers wrote:
> +Cc aarcange@redhat.com, xemul@parallels.com, linux-mm@kvack.org
> 
> On Fri, Oct 27, 2017 at 11:46:13AM +0200, Dmitry Vyukov wrote:
> > On Fri, Oct 27, 2017 at 11:44 AM, syzbot
> > <bot+998c483ca801a50e3ce5b63a845216588ada5e2a@syzkaller.appspotmail.com>
> > wrote:
> > > Hello,
> > >
> > > syzkaller hit the following crash on
> > > a31cc455c512f3f1dd5f79cac8e29a7c8a617af8
> > > git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git/master
> > > compiler: gcc (GCC) 7.1.1 20170620
> > > .config is attached
> > > Raw console output is attached.
> > > C reproducer is attached
> > > syzkaller reproducer is attached. See https://goo.gl/kgGztJ
> > > for information about syzkaller reproducers
> > 
> 
> Andrea or Pavel, can one of you please fix this?  It's another use-after-free
> related to userfaultfd "fork events", and it can easily be triggered by an
> unprivileged user.  It was reported a month ago already; the original report is
> here: https://groups.google.com/forum/#!topic/syzkaller-bugs/sS99S-Z-9No.
> (Please consider adding yourself and/or linux-mm to the MAINTAINERS file for
> fs/userfaultfd.c, so that you are Cc'ed on userfaultfd bug reports.)  In
> userfaultfd_event_wait_completion(), called from dup_fctx(), the kernel is
> freeing the the new userfaultfd_ctx because the old one had all its fd's closed,
> but actually the new one is still in use by the new mm_struct.
> 

Fixed now:

#syz fix: userfaultfd: clear the vma->vm_userfaultfd_ctx if UFFD_EVENT_FORK fails

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
