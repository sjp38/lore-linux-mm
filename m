Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id D5AAC6B7379
	for <linux-mm@kvack.org>; Wed,  5 Sep 2018 09:55:37 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id a8-v6so3822445pla.10
        for <linux-mm@kvack.org>; Wed, 05 Sep 2018 06:55:37 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e7-v6si2129441pgm.649.2018.09.05.06.55.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Sep 2018 06:55:36 -0700 (PDT)
Date: Wed, 5 Sep 2018 15:55:32 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: linux-next test error
Message-ID: <20180905135532.GE24902@quack2.suse.cz>
References: <0000000000004f6b5805751a8189@google.com>
 <20180905085545.GD24902@quack2.suse.cz>
 <CAFqt6zZtjPFdfAGxp43oqN3=z9+vAGzdOvDcgFaU+05ffCGu7A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAFqt6zZtjPFdfAGxp43oqN3=z9+vAGzdOvDcgFaU+05ffCGu7A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Souptick Joarder <jrdr.linux@gmail.com>
Cc: Jan Kara <jack@suse.cz>, syzbot+87a05ae4accd500f5242@syzkaller.appspotmail.com, ak@linux.intel.com, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, mawilcox@microsoft.com, mgorman@techsingularity.net, syzkaller-bugs@googlegroups.com, tim.c.chen@linux.intel.com, zwisler@kernel.org

On Wed 05-09-18 15:20:16, Souptick Joarder wrote:
> On Wed, Sep 5, 2018 at 2:25 PM Jan Kara <jack@suse.cz> wrote:
> >
> > On Wed 05-09-18 00:13:02, syzbot wrote:
> > > Hello,
> > >
> > > syzbot found the following crash on:
> > >
> > > HEAD commit:    387ac6229ecf Add linux-next specific files for 20180905
> > > git tree:       linux-next
> > > console output: https://syzkaller.appspot.com/x/log.txt?x=149c67a6400000
> > > kernel config:  https://syzkaller.appspot.com/x/.config?x=ad5163873ecfbc32
> > > dashboard link: https://syzkaller.appspot.com/bug?extid=87a05ae4accd500f5242
> > > compiler:       gcc (GCC) 8.0.1 20180413 (experimental)
> > >
> > > Unfortunately, I don't have any reproducer for this crash yet.
> > >
> > > IMPORTANT: if you fix the bug, please add the following tag to the commit:
> > > Reported-by: syzbot+87a05ae4accd500f5242@syzkaller.appspotmail.com
> > >
> > > INFO: task hung in do_page_mkwriteINFO: task syz-fuzzer:4876 blocked for
> > > more than 140 seconds.
> > >       Not tainted 4.19.0-rc2-next-20180905+ #56
> > > "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> > > syz-fuzzer      D21704  4876   4871 0x00000000
> > > Call Trace:
> > >  context_switch kernel/sched/core.c:2825 [inline]
> > >  __schedule+0x87c/0x1df0 kernel/sched/core.c:3473
> > >  schedule+0xfb/0x450 kernel/sched/core.c:3517
> > >  io_schedule+0x1c/0x70 kernel/sched/core.c:5140
> > >  wait_on_page_bit_common mm/filemap.c:1100 [inline]
> > >  __lock_page+0x5b7/0x7a0 mm/filemap.c:1273
> > >  lock_page include/linux/pagemap.h:483 [inline]
> > >  do_page_mkwrite+0x429/0x520 mm/memory.c:2391
> >
> > Waiting for page lock after ->page_mkwrite callback. Which means
> > ->page_mkwrite did not return VM_FAULT_LOCKED but 0. Looking into
> > linux-next... indeed "fs: convert return type int to vm_fault_t" has busted
> > block_page_mkwrite(). It has to return VM_FAULT_LOCKED and not 0 now.
> > Souptick, can I ask you to run 'fstests' for at least common filesystems
> > like ext4, xfs, btrfs when you change generic filesystem code please? That
> > would catch a bug like this immediately. Thanks.
> >
> 
> "fs: convert return type int to vm_fault_t" is still under
> review/discusson and not yet merge
> into linux-next. I am not seeing it into linux-next tree.Can you
> please share the commit id ?

As Ted wrote, it is currently commit
83c0adddcc6ed128168e7b87eaed0c21eac908e4, and it came from mm tree. But the
commit ID is going to change tomorrow since linux-next is rebuilt every
day... I'm not sure how that patch got to mm tree. That's a question for
Andrew but you should have been notified about that by his mailing
machinery.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
