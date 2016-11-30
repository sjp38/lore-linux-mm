Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id BB1456B0260
	for <linux-mm@kvack.org>; Wed, 30 Nov 2016 12:47:22 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id j92so27161508ioi.2
        for <linux-mm@kvack.org>; Wed, 30 Nov 2016 09:47:22 -0800 (PST)
Received: from mail1.merlins.org (magic.merlins.org. [209.81.13.136])
        by mx.google.com with ESMTPS id c134si48582945ioe.243.2016.11.30.09.47.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 30 Nov 2016 09:47:22 -0800 (PST)
Date: Wed, 30 Nov 2016 09:47:13 -0800
From: Marc MERLIN <marc@merlins.org>
Message-ID: <20161130174713.lhvqgophhiupzwrm@merlins.org>
References: <48061a22-0203-de54-5a44-89773bff1e63@suse.cz>
 <CA+55aFweND3KoV=00onz0Y5W9ViFedd-nvfCuB+phorc=75tpQ@mail.gmail.com>
 <20161123063410.GB2864@dhcp22.suse.cz>
 <20161128072315.GC14788@dhcp22.suse.cz>
 <20161129155537.f6qgnfmnoljwnx6j@merlins.org>
 <20161129160751.GC9796@dhcp22.suse.cz>
 <20161129163406.treuewaqgt4fy4kh@merlins.org>
 <CA+55aFzNe=3e=cDig+vEzZS5jm2c6apPV4s5NKG4eYL4_jxQjQ@mail.gmail.com>
 <20161129174019.fywddwo5h4pyix7r@merlins.org>
 <CA+55aFz04aMBurHuME5A1NuhumMECD5iROhn06GB4=ceA+s6mw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFz04aMBurHuME5A1NuhumMECD5iROhn06GB4=ceA+s6mw@mail.gmail.com>
Subject: Re: 4.8.8 kernel trigger OOM killer repeatedly when I have lots of
 RAM that should be free
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Tejun Heo <tj@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

On Tue, Nov 29, 2016 at 10:01:10AM -0800, Linus Torvalds wrote:
> On Tue, Nov 29, 2016 at 9:40 AM, Marc MERLIN <marc@merlins.org> wrote:
> >
> > In my case, it is a 5x 4TB HDD with
> > software raid 5 < bcache < dmcrypt < btrfs
> 
> It doesn't sound like the nasty situations I have seen (particularly
> with large USB flash storage - often high momentary speed for
> benchmarks, but slows down to a crawl after you've written a bit to
> it, and doesn't have the smart garbage collection that modern "real"
> SSDs have).

I gave it a thought again, I think it is exactly the nasty situation you
described.
bcache takes I/O quickly while sending to SSD cache. SSD fills up, now
bcache can't handle IO as quickly and has to hang until the SSD has been
flushed to spinning rust drives.
This actually is exactly the same as filling up the cache on a USB key
and now you're waiting for slow writes to flash, is it not?

With your dirty ratio workaround, I was able to re-enable bcache and
have it not fall over, but only barely. I recorded over a hundred
workqueues in flight during the copy at some point (just not enough
to actually kill the kernel this time).

I've started a bcache followp on this here:
http://marc.info/?l=linux-bcache&m=148052441423532&w=2
http://marc.info/?l=linux-bcache&m=148052620524162&w=2

This message shows the huge pileup of workqueeues in bcache
just before the kernel dies with
Hardware name: System manufacturer System Product Name/P8H67-M PRO, BIOS 3904 04/27/2013
task: ffff9ee0c2fa4180 task.stack: ffff9ee0c2fa8000
RIP: 0010:[<ffffffffbb57a128>]  [<ffffffffbb57a128>] cpuidle_enter_state+0x119/0x171
RSP: 0000:ffff9ee0c2fabea0  EFLAGS: 00000246
RAX: ffff9ee0de3d90c0 RBX: 0000000000000004 RCX: 000000000000001f
RDX: 0000000000000000 RSI: 0000000000000007 RDI: 0000000000000000
RBP: ffff9ee0c2fabed0 R08: 0000000000000f92 R09: 0000000000000f42
R10: ffff9ee0c2fabe50 R11: 071c71c71c71c71c R12: ffffe047bfdcb200
R13: 00000af626899577 R14: 0000000000000004 R15: 00000af6264cc557
FS:  0000000000000000(0000) GS:ffff9ee0de3c0000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 000000000898b000 CR3: 000000045cc06000 CR4: 00000000001406e0
Stack:
 0000000000000f40 ffffe047bfdcb200 ffffffffbbccc060 ffff9ee0c2fac000
 ffff9ee0c2fa8000 ffff9ee0c2fac000 ffff9ee0c2fabee0 ffffffffbb57a1ac
 ffff9ee0c2fabf30 ffffffffbb09238d ffff9ee0c2fa8000 0000000700000004
Call Trace:
 [<ffffffffbb57a1ac>] cpuidle_enter+0x17/0x19
 [<ffffffffbb09238d>] cpu_startup_entry+0x210/0x28b
 [<ffffffffbb03de22>] start_secondary+0x13e/0x140
Code: 00 00 00 48 c7 c7 cd ae b2 bb c6 05 4b 8e 7a 00 01 e8 17 6c ae ff fa 66 0f 1f 44 00 00 31 ff e8 75 60 b4
44 00 00 <4c> 89 e8 b9 e8 03 00 00 4c 29 f8 48 99 48 f7 f9 ba ff ff ff 7f
Kernel panic - not syncing: Hard LOCKUP

A full traceback showing the pilup of requests is here:
http://marc.info/?l=linux-bcache&m=147949497808483&w=2

and there:
http://pastebin.com/rJ5RKUVm
(2 different ones but mostly the same result)

We can probably follow up on the bcache thread I Cc'ed you on since I'm
not sure if the fault here lies with bcache or the VM subsystem anymore.

Thanks.
Marc
-- 
"A mouse is a device used to point at the xterm you want to type in" - A.S.R.
Microsoft is to operating systems ....
                                      .... what McDonalds is to gourmet cooking
Home page: http://marc.merlins.org/                         | PGP 1024R/763BE901

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
