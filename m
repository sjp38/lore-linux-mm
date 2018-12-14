Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id 516168E01DC
	for <linux-mm@kvack.org>; Fri, 14 Dec 2018 08:42:46 -0500 (EST)
Received: by mail-it1-f198.google.com with SMTP id x3so5741259itb.6
        for <linux-mm@kvack.org>; Fri, 14 Dec 2018 05:42:46 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t8sor2378662iod.22.2018.12.14.05.42.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 14 Dec 2018 05:42:45 -0800 (PST)
MIME-Version: 1.0
References: <0000000000004ea80b057cfae21e@google.com> <CACT4Y+Z+AhQxf6=ecOkX1bOU5h7kMHYnR6CAhBv9eO5jQVeG3g@mail.gmail.com>
 <20181214132836.GE5343@dhcp22.suse.cz>
In-Reply-To: <20181214132836.GE5343@dhcp22.suse.cz>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Fri, 14 Dec 2018 14:42:33 +0100
Message-ID: <CACT4Y+aXFXnObgC-7NVe87-1bbqs2oNBBXe2mrfshLKnFqkTGA@mail.gmail.com>
Subject: Re: general protection fault in watchdog
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: syzbot <syzbot+7713f3aa67be76b1552c@syzkaller.appspotmail.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, rafael.j.wysocki@intel.com, syzkaller-bugs <syzkaller-bugs@googlegroups.com>, vkuznets@redhat.com, Linux-MM <linux-mm@kvack.org>

On Fri, Dec 14, 2018 at 2:28 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Fri 14-12-18 14:11:05, Dmitry Vyukov wrote:
> > On Fri, Dec 14, 2018 at 1:51 PM syzbot
> > <syzbot+7713f3aa67be76b1552c@syzkaller.appspotmail.com> wrote:
> > >
> > > Hello,
> > >
> > > syzbot found the following crash on:
> > >
> > > HEAD commit:    f5d582777bcb Merge branch 'for-linus' of git://git.kernel...
> > > git tree:       upstream
> > > console output: https://syzkaller.appspot.com/x/log.txt?x=16aca143400000
> > > kernel config:  https://syzkaller.appspot.com/x/.config?x=c8970c89a0efbb23
> > > dashboard link: https://syzkaller.appspot.com/bug?extid=7713f3aa67be76b1552c
> > > compiler:       gcc (GCC) 8.0.1 20180413 (experimental)
> > > syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=1131381b400000
> > > C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=13bae593400000
> > >
> > > IMPORTANT: if you fix the bug, please add the following tag to the commit:
> > > Reported-by: syzbot+7713f3aa67be76b1552c@syzkaller.appspotmail.com
> >
> > +linux-mm for memcg question
> >
> > What the repro does is effectively just
> > setsockopt(EBT_SO_SET_ENTRIES). This eats all machine memory and
> > causes OOMs. Somehow it also caused the GPF in watchdog when it
> > iterates over task list, perhaps some scheduler code leaves a dangling
> > pointer on OOM failures.
> >
> > But what bothers me is a different thing. syzkaller test processes are
> > sandboxed with a restrictive memcg which should prevent them from
> > eating all memory. do_replace_finish calls vmalloc, which uses
> > GFP_KERNEL, which does not include GFP_ACCOUNT (GFP_KERNEL_ACCOUNT
> > does). And page alloc seems to change memory against memcg iff
> > GFP_ACCOUNT is provided.
> > Am I missing something or vmalloc is indeed not accounted (DoS)? I see
> > some explicit uses of GFP_KERNEL_ACCOUNT, e.g. the one below, but they
> > seem to be very sparse.
> >
> > static void *seq_buf_alloc(unsigned long size)
> > {
> >      return kvmalloc(size, GFP_KERNEL_ACCOUNT);
> > }
> >
> > Now looking at the code I also don't see how kmalloc(GFP_KERNEL) is
> > accounted... Which makes me think I am still missing something.
>
> You are not missing anything. We do not account all allocations and you
> have to explicitly opt-in by __GFP_ACCOUNT. This is a deliberate
> decision. If the allocation is directly controlable by an untrusted user
> and the memory is associated with a process life time then this looks
> like a good usecase for __GFP_ACCOUNT. If an allocation outlives a
> process then there the flag should be considered with a great care
> because oom killer is not able to resolve the memcg pressure and so the
> limit enforcement is not effective.

Interesting.
I understand that namespaces, memcg's and processes (maybe even
threads) can have arbitrary overlapping. But I naively thought that in
canonical hierarchical cases it should all somehow work.
Question 1: is there some other, stricter sandboxing mechanism? We try
to sandbox syzkaller processes with everything available , because
these OOMs usually leads either to dead machines or hang/stall false
positives, which are nasty.
Question 2: this is a simple DoS vector, right? If I put a container
into a 1MB memcg, it can still eat arbitrary amount of non-pagable
kernel memory?
