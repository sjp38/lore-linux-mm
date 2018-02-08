Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 334B76B0006
	for <linux-mm@kvack.org>; Thu,  8 Feb 2018 09:18:34 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id b34-v6so1721310plc.2
        for <linux-mm@kvack.org>; Thu, 08 Feb 2018 06:18:34 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id a3sor22630pfe.133.2018.02.08.06.18.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 08 Feb 2018 06:18:33 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180208140833.lpr4yjn7g3v3cdy3@quack2.suse.cz>
References: <001a11447070ac6fcb0564a08cb1@google.com> <20180207155229.GC10945@tassilo.jf.intel.com>
 <20180208092839.ebe5rk6mtvkk5da4@quack2.suse.cz> <CACT4Y+ZTNDhEhAAP2PYRH5WxEeEM0xHdp4UKqtNaWhU6w4sj_g@mail.gmail.com>
 <20180208140833.lpr4yjn7g3v3cdy3@quack2.suse.cz>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Thu, 8 Feb 2018 15:18:11 +0100
Message-ID: <CACT4Y+bwnyFmgTNMTa1p8WKecH=OU5Za_hboY7Q=V2Aq+DOsKQ@mail.gmail.com>
Subject: Re: INFO: task hung in sync_blockdev
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Andi Kleen <ak@linux.intel.com>, syzbot <syzbot+283c3c447181741aea28@syzkaller.appspotmail.com>, Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, jlayton@redhat.com, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>, Ingo Molnar <mingo@kernel.org>, rgoldwyn@suse.com, syzkaller-bugs@googlegroups.com, linux-fsdevel@vger.kernel.org

On Thu, Feb 8, 2018 at 3:08 PM, Jan Kara <jack@suse.cz> wrote:
> On Thu 08-02-18 14:28:08, Dmitry Vyukov wrote:
>> On Thu, Feb 8, 2018 at 10:28 AM, Jan Kara <jack@suse.cz> wrote:
>> > On Wed 07-02-18 07:52:29, Andi Kleen wrote:
>> >> >  #0:  (&bdev->bd_mutex){+.+.}, at: [<0000000040269370>]
>> >> > __blkdev_put+0xbc/0x7f0 fs/block_dev.c:1757
>> >> > 1 lock held by blkid/19199:
>> >> >  #0:  (&bdev->bd_mutex){+.+.}, at: [<00000000b4dcaa18>]
>> >> > __blkdev_get+0x158/0x10e0 fs/block_dev.c:1439
>> >> >  #1:  (&ldata->atomic_read_lock){+.+.}, at: [<0000000033edf9f2>]
>> >> > n_tty_read+0x2ef/0x1a00 drivers/tty/n_tty.c:2131
>> >> > 1 lock held by syz-executor5/19330:
>> >> >  #0:  (&bdev->bd_mutex){+.+.}, at: [<00000000b4dcaa18>]
>> >> > __blkdev_get+0x158/0x10e0 fs/block_dev.c:1439
>> >> > 1 lock held by syz-executor5/19331:
>> >> >  #0:  (&bdev->bd_mutex){+.+.}, at: [<00000000b4dcaa18>]
>> >> > __blkdev_get+0x158/0x10e0 fs/block_dev.c:1439
>> >>
>> >> It seems multiple processes deadlocked on the bd_mutex.
>> >> Unfortunately there's no backtrace for the lock acquisitions,
>> >> so it's hard to see the exact sequence.
>> >
>> > Well, all in the report points to a situation where some IO was submitted
>> > to the block device and never completed (more exactly it took longer than
>> > those 120s to complete that IO). It would need more digging into the
>> > syzkaller program to find out what kind of device that was and possibly why
>> > the IO took so long to complete...
>>
>>
>> Would a traceback of all task stacks help in this case?
>> What I've seen in several "task hung" reports is that the CPU
>> traceback is not showing anything useful. So perhaps it should be
>> changed to task traceback? Or it would not help either?
>
> Task stack traceback for all tasks (usually only tasks in D state - i.e.
> sysrq-w - are enough actually) would definitely help for debugging
> deadlocks on sleeping locks. For this particular case I'm not sure if it
> would help or not since it is quite possible the IO is just sitting in some
> queue never getting processed

That's what I was afraid of.

> due to some racing syzkaller process tearing
> down the device in the wrong moment or something like that... Such case is
> very difficult to debug without full kernel crashdump of the hung kernel
> (or a reproducer for that matter) and even with that it is usually rather
> time consuming. But for the deadlocks which do occur more frequently it
> would be probably worth the time so it would be nice if such option was
> eventually available.

By "full kernel crashdump" you mean kdump thing, or something else?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
