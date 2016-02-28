Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id E09096B0005
	for <linux-mm@kvack.org>; Sun, 28 Feb 2016 18:47:10 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id bj10so11735857pad.2
        for <linux-mm@kvack.org>; Sun, 28 Feb 2016 15:47:10 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id m87si11947057pfi.166.2016.02.28.15.47.10
        for <linux-mm@kvack.org>;
        Sun, 28 Feb 2016 15:47:10 -0800 (PST)
Date: Sun, 28 Feb 2016 23:47:00 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: tty: memory leak in tty_register_driver
Message-ID: <20160228234657.GA28225@MBP.local>
References: <CACT4Y+bZticikTpnc0djxRBLCWhj=2DqQk=KRf5zDvrLdHzEbQ@mail.gmail.com>
 <CACT4Y+a+L3+VUEV7c2Q6c7tb8A57dpsitM=P6KVSHV=WYrpahw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACT4Y+a+L3+VUEV7c2Q6c7tb8A57dpsitM=P6KVSHV=WYrpahw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Jiri Slaby <jslaby@suse.com>, LKML <linux-kernel@vger.kernel.org>, Peter Hurley <peter@hurleysoftware.com>, One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>, J Freyensee <james_p_freyensee@linux.intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Paul Bolle <pebolle@tiscali.nl>, Alexander Potapenko <glider@google.com>, Kostya Serebryany <kcc@google.com>, Sasha Levin <sasha.levin@oracle.com>, syzkaller <syzkaller@googlegroups.com>

On Sun, Feb 28, 2016 at 05:42:24PM +0100, Dmitry Vyukov wrote:
> On Mon, Feb 15, 2016 at 11:42 AM, Dmitry Vyukov <dvyukov@google.com> wrote:
> > When I am running the following program in a parallel loop, kmemleak
> > starts reporting memory leaks of objects allocated in
> > tty_register_driver during boot. These leaks start popping up
> > chaotically and as you can see they originate in different drivers
> > (synclinkmp_init, isdn_init, chr_dev_init, sysfs_init).
> >
> > On commit 388f7b1d6e8ca06762e2454d28d6c3c55ad0fe95 (4.5-rc3).
[...]
> > unreferenced object 0xffff88006708dc20 (size 8):
> >   comm "swapper/0", pid 1, jiffies 4294672590 (age 930.839s)
> >   hex dump (first 8 bytes):
> >     74 74 79 53 4c 4d 38 00                          ttySLM8.
> >   backtrace:
> >     [<ffffffff81765d10>] __kmalloc_track_caller+0x1b0/0x320 mm/slub.c:4068
> >     [<ffffffff816b37a9>] kstrdup+0x39/0x70 mm/util.c:53
> >     [<ffffffff816b3826>] kstrdup_const+0x46/0x60 mm/util.c:74
> >     [<ffffffff8194e5bb>] __kernfs_new_node+0x2b/0x2b0 fs/kernfs/dir.c:536
> >     [<ffffffff81951c70>] kernfs_new_node+0x80/0xe0 fs/kernfs/dir.c:572
> >     [<ffffffff81957223>] kernfs_create_link+0x33/0x150 fs/kernfs/symlink.c:32
> >     [<ffffffff81959c4b>] sysfs_do_create_link_sd.isra.2+0x8b/0x120
[...]
> +Catalin (kmemleak maintainer)
> 
> I am noticed a weird thing. I am not 100% sure but it seems that the
> leaks are reported iff I run leak checking concurrently with the
> programs running. And if I run the program several thousand times and
> then run leak checking, then no leaks reported.
> 
> Catalin, it is possible that it is a kmemleak false positive?

Yes, it's possible. If you run kmemleak scanning continuously (or at
very short intervals) and especially in parallel with some intensive
tasks, it will miss pointers that may be stored in registers (on other
CPUs) or moved between task stacks, other memory locations. Linked lists
are especially prone to such false positives.

Kmemleak tries to work around this by checksumming each object, so it
will only be reported if it hasn't changed on two consecutive scans.
Since the default scanning is 10min, it is very unlikely to trigger
false positives in such scenarios. However, if you reduce the scanning
time (or trigger it manually in a loop), you can hit this condition.

> I see that kmemleak just scans thread stacks one-by-one. I would
> expect that kmemleak should stop all threads, then scan all stacks and
> all registers of all threads, and then restart threads. If it does not
> scan registers or does not stop threads, then I think it should be
> possible that a pointer value can sneak off kmemleak. Does it make
> sense?

Given how long it takes to scan the memory, stopping the threads is not
really feasible. You could do something like stop_machine() only for
scanning the current stack on all CPUs but it still wouldn't catch
pointers being moved around in memory unless you stop the system
completely for a full scan. The heuristic about periodic scanning and
checksumming seems to work fine in normal usage scenarios.

For your tests, I would recommend that you run the tests for a long(ish)
time and only do two kmemleak scans at the end after they finished (and
with a few seconds delay between them). Continuous scanning is less
reliable.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
