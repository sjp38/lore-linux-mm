Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id 20CBC6B788E
	for <linux-mm@kvack.org>; Thu,  6 Sep 2018 08:02:17 -0400 (EDT)
Received: by mail-lj1-f197.google.com with SMTP id m21-v6so2222061ljh.2
        for <linux-mm@kvack.org>; Thu, 06 Sep 2018 05:02:17 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o71-v6sor1884312lff.55.2018.09.06.05.02.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 06 Sep 2018 05:02:15 -0700 (PDT)
MIME-Version: 1.0
References: <0000000000004f6b5805751a8189@google.com> <20180905085545.GD24902@quack2.suse.cz>
 <CAFqt6zaeOzrzMCqtnv=3gF4+K9HGtbB0C7bOeE+6YmBvvxBaxQ@mail.gmail.com> <20180906081253.GB19319@quack2.suse.cz>
In-Reply-To: <20180906081253.GB19319@quack2.suse.cz>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Thu, 6 Sep 2018 17:32:02 +0530
Message-ID: <CAFqt6zbVRV7Zsr2icJLZ+hX1RXObMJ5Zgf31ZAZTyjQyzAnuqw@mail.gmail.com>
Subject: Re: linux-next test error
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: syzbot+87a05ae4accd500f5242@syzkaller.appspotmail.com, ak@linux.intel.com, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, mawilcox@microsoft.com, mgorman@techsingularity.net, syzkaller-bugs@googlegroups.com, tim.c.chen@linux.intel.com, zwisler@kernel.org

On Thu, Sep 6, 2018 at 1:42 PM Jan Kara <jack@suse.cz> wrote:
>
> On Thu 06-09-18 00:37:06, Souptick Joarder wrote:
> > On Wed, Sep 5, 2018 at 2:25 PM Jan Kara <jack@suse.cz> wrote:
> > >
> > > On Wed 05-09-18 00:13:02, syzbot wrote:
> > > > Hello,
> > > >
> > > > syzbot found the following crash on:
> > > >
> > > > HEAD commit:    387ac6229ecf Add linux-next specific files for 20180905
> > > > git tree:       linux-next
> > > > console output: https://syzkaller.appspot.com/x/log.txt?x=149c67a6400000
> > > > kernel config:  https://syzkaller.appspot.com/x/.config?x=ad5163873ecfbc32
> > > > dashboard link: https://syzkaller.appspot.com/bug?extid=87a05ae4accd500f5242
> > > > compiler:       gcc (GCC) 8.0.1 20180413 (experimental)
> > > >
> > > > Unfortunately, I don't have any reproducer for this crash yet.
> > > >
> > > > IMPORTANT: if you fix the bug, please add the following tag to the commit:
> > > > Reported-by: syzbot+87a05ae4accd500f5242@syzkaller.appspotmail.com
> > > >
> > > > INFO: task hung in do_page_mkwriteINFO: task syz-fuzzer:4876 blocked for
> > > > more than 140 seconds.
> > > >       Not tainted 4.19.0-rc2-next-20180905+ #56
> > > > "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> > > > syz-fuzzer      D21704  4876   4871 0x00000000
> > > > Call Trace:
> > > >  context_switch kernel/sched/core.c:2825 [inline]
> > > >  __schedule+0x87c/0x1df0 kernel/sched/core.c:3473
> > > >  schedule+0xfb/0x450 kernel/sched/core.c:3517
> > > >  io_schedule+0x1c/0x70 kernel/sched/core.c:5140
> > > >  wait_on_page_bit_common mm/filemap.c:1100 [inline]
> > > >  __lock_page+0x5b7/0x7a0 mm/filemap.c:1273
> > > >  lock_page include/linux/pagemap.h:483 [inline]
> > > >  do_page_mkwrite+0x429/0x520 mm/memory.c:2391
> > >
> > > Waiting for page lock after ->page_mkwrite callback. Which means
> > > ->page_mkwrite did not return VM_FAULT_LOCKED but 0. Looking into
> > > linux-next... indeed "fs: convert return type int to vm_fault_t" has busted
> > > block_page_mkwrite(). It has to return VM_FAULT_LOCKED and not 0 now.
> > > Souptick, can I ask you to run 'fstests' for at least common filesystems
> > > like ext4, xfs, btrfs when you change generic filesystem code please? That
> > > would catch a bug like this immediately. Thanks.
> >
> > Looking into existing code block_page_mkwrite() returns 0, not VM_FAULT_LOCKED
> > in true path and this patch doesn't change any existing behaviour of
> > block_page_mkwrite()
> > except adding one new input parameter to return err value to caller function.
>
> Yeah, you are right and this confused me. In your version
> block_page_mkwrite() returns block_page_mkwrite_return(err1) in case of
> error but 0 in case of success and the caller - ext4_page_mkwrite() - then
> uses block_page_mkwrite_return() again if block_page_mkwrite() returned 0.
> So I agree the code path I pointed out won't result in returning 0 instead
> of VM_FAULT_LOCKED but the calling convention is really very confusing.
>
> > -int ext4_page_mkwrite(struct vm_fault *vmf)
> > +vm_fault_t ext4_page_mkwrite(struct vm_fault *vmf)
> >
> > +       err = 0;
> > +       ret = block_page_mkwrite(vma, vmf, get_block, &err);
> >         if (!ret && ext4_should_journal_data(inode)) {
> >                 if (ext4_walk_page_buffers(handle, page_buffers(page), 0,
> >                           PAGE_SIZE, NULL, do_journal_get_write_access)) {
> >                         unlock_page(page);
> > -                       ret = VM_FAULT_SIGBUS;
> >
> > I think, this part has created problem where page_mkwrite()
> > end up with returning 0.
>
> So this branch is definitely wrong but I somewhat doubt it's the one we've
> taken - this can happen only in case of IO error.

Looking into the patch, this is only part of code where page_mkwrite()
end up with returning 0.
