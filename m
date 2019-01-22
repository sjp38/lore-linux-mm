Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 866BF8E0001
	for <linux-mm@kvack.org>; Tue, 22 Jan 2019 08:54:40 -0500 (EST)
Received: by mail-io1-f70.google.com with SMTP id u2so19268034iob.7
        for <linux-mm@kvack.org>; Tue, 22 Jan 2019 05:54:40 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f193sor39699437jaf.2.2019.01.22.05.54.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 22 Jan 2019 05:54:39 -0800 (PST)
MIME-Version: 1.0
References: <000000000000f7a28e057653dc6e@google.com> <20180920141058.4ed467594761e073606eafe2@linux-foundation.org>
 <CAHRSSEzX5HOUEQ6DgEF76OLGrwS1isWMdtvneBLOEEnwoMxVrA@mail.gmail.com>
 <CAEXW_YSot+3AMQ=jmDRowmqoOmQmujp9r8Dh18KJJN1EDmyHOw@mail.gmail.com>
 <20180921162110.e22d09a9e281d194db3c8359@linux-foundation.org>
 <4b0a5f8c-2be2-db38-a70d-8d497cb67665@I-love.SAKURA.ne.jp>
 <CACT4Y+ZTjCGd9XYUCUoqv+AqXrPwX4OqWMC0jFgjNxZRFkNYXw@mail.gmail.com>
 <c56d4d0b-8ecc-059d-69cb-4f3e91f9410c@i-love.sakura.ne.jp> <CACT4Y+YA38BfnByA_jrocbhbbqg7NWRe4-5UAp5Q-iKFi9hGQA@mail.gmail.com>
In-Reply-To: <CACT4Y+YA38BfnByA_jrocbhbbqg7NWRe4-5UAp5Q-iKFi9hGQA@mail.gmail.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Tue, 22 Jan 2019 14:54:28 +0100
Message-ID: <CACT4Y+b7KhMECUF01fz0+1LJOiqzJhTRHOvezN4baPNd02om0Q@mail.gmail.com>
Subject: Re: possible deadlock in __do_page_fault
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, Joel Fernandes <joel@joelfernandes.org>, Todd Kjos <tkjos@google.com>, Joel Fernandes <joelaf@google.com>, syzbot+a76129f18c89f3e2ddd4@syzkaller.appspotmail.com, Andi Kleen <ak@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Souptick Joarder <jrdr.linux@gmail.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>, =?UTF-8?B?QXJ2ZSBIasO4bm5ldsOlZw==?= <arve@android.com>, Todd Kjos <tkjos@android.com>, Martijn Coenen <maco@android.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

On Tue, Jan 22, 2019 at 2:52 PM Dmitry Vyukov <dvyukov@google.com> wrote:
>
> On Tue, Jan 22, 2019 at 11:32 AM Tetsuo Handa
> <penguin-kernel@i-love.sakura.ne.jp> wrote:
> >
> > On 2019/01/22 19:12, Dmitry Vyukov wrote:
> > > On Tue, Jan 22, 2019 at 11:02 AM Tetsuo Handa
> > > <penguin-kernel@i-love.sakura.ne.jp> wrote:
> > >>
> > >> On 2018/09/22 8:21, Andrew Morton wrote:
> > >>> On Thu, 20 Sep 2018 19:33:15 -0400 Joel Fernandes <joel@joelfernandes.org> wrote:
> > >>>
> > >>>> On Thu, Sep 20, 2018 at 5:12 PM Todd Kjos <tkjos@google.com> wrote:
> > >>>>>
> > >>>>> +Joel Fernandes
> > >>>>>
> > >>>>> On Thu, Sep 20, 2018 at 2:11 PM Andrew Morton <akpm@linux-foundation.org> wrote:
> > >>>>>>
> > >>>>>>
> > >>>>>> Thanks.  Let's cc the ashmem folks.
> > >>>>>>
> > >>>>
> > >>>> This should be fixed by https://patchwork.kernel.org/patch/10572477/
> > >>>>
> > >>>> It has Neil Brown's Reviewed-by but looks like didn't yet appear in
> > >>>> anyone's tree, could Greg take this patch?
> > >>>
> > >>> All is well.  That went into mainline yesterday, with a cc:stable.
> > >>>
> > >>
> > >> This problem was not fixed at all.
> > >
> > > There are at least 2 other open deadlocks involving ashmem:
> >
> > Yes, they involve ashmem_shrink_scan() => {shmem|vfs}_fallocate() sequence.
> > This approach tries to eliminate this sequence.
> >
> > >
> > > https://syzkaller.appspot.com/bug?extid=148c2885d71194f18d28
> > > https://syzkaller.appspot.com/bug?extid=4b8b031b89e6b96c4b2e
> > >
> > > Does this fix any of these too?
> >
> > I need checks from ashmem folks whether this approach is possible/correct.
> > But you can ask syzbot to test this patch before ashmem folks respond.
>
> Right. Let's do this.
>
> As with any kernel changes only you really know how to apply it, git
> tree/base commit info is missing, so let's do guessing and
> finger-crossing as usual:
>
> #syz fix: git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
> master

This of course should be:

#syz test: git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
master
