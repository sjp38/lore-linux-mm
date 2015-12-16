Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f47.google.com (mail-lf0-f47.google.com [209.85.215.47])
	by kanga.kvack.org (Postfix) with ESMTP id 2208A6B0255
	for <linux-mm@kvack.org>; Wed, 16 Dec 2015 14:23:14 -0500 (EST)
Received: by mail-lf0-f47.google.com with SMTP id l133so36428857lfd.2
        for <linux-mm@kvack.org>; Wed, 16 Dec 2015 11:23:14 -0800 (PST)
Received: from mail02.iobjects.de (static.68.134.40.188.clients.your-server.de. [188.40.134.68])
        by mx.google.com with ESMTPS id i3si4967769lbj.10.2015.12.16.11.23.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Dec 2015 11:23:12 -0800 (PST)
Subject: Re: WARNING in shmem_evict_inode
References: <CACT4Y+btGx7QKUjQdniRpczMof28V243Yo=Haj_G3acj0=smrg@mail.gmail.com>
 <CACT4Y+ZeOE7QNRTW1sN3_Op9c_ALohMG+fD=UUh5-KJN2PjQ3w@mail.gmail.com>
 <alpine.LSU.2.11.1512020118310.32078@eggly.anvils>
From: =?UTF-8?Q?Holger_Hoffst=c3=a4tte?= <holger.hoffstaette@googlemail.com>
Message-ID: <5671BA1F.7070201@googlemail.com>
Date: Wed, 16 Dec 2015 20:23:11 +0100
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1512020118310.32078@eggly.anvils>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Dmitry Vyukov <dvyukov@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Sasha Levin <sasha.levin@oracle.com>, syzkaller <syzkaller@googlegroups.com>, Kostya Serebryany <kcc@google.com>, Alexander Potapenko <glider@google.com>, Eric Dumazet <edumazet@google.com>, Greg Thelen <gthelen@google.com>

On 12/02/15 10:29, Hugh Dickins wrote:
> On Mon, 23 Nov 2015, Dmitry Vyukov wrote:
>> On Mon, Nov 9, 2015 at 9:55 AM, Dmitry Vyukov <dvyukov@google.com> wrote:
[snip]
>>> triggers WARNING in shmem_evict_inode:
>>>
>>> ------------[ cut here ]------------
>>> WARNING: CPU: 0 PID: 10442 at mm/shmem.c:625 shmem_evict_inode+0x335/0x480()
>>> Modules linked in:
>>> CPU: 1 PID: 8944 Comm: executor Not tainted 4.3.0+ #39
>>> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
>>>  00000000ffffffff ffff88006c6afab8 ffffffff81aad406 0000000000000000
>>>  ffff88006e39ac80 ffffffff83091660 ffff88006c6afaf8 ffffffff81100829
>>>  ffffffff814192e5 ffffffff83091660 0000000000000271 ffff88003d075aa8
>>> Call Trace:
>>>  [<ffffffff81100a59>] warn_slowpath_null+0x29/0x30 kernel/panic.c:480
>>>  [<ffffffff814192e5>] shmem_evict_inode+0x335/0x480 mm/shmem.c:625
>>>  [<ffffffff8151560e>] evict+0x26e/0x580 fs/inode.c:542
>>>  [<     inline     >] iput_final fs/inode.c:1477
[snip]
> It was more interesting than I expected, thanks.
> I believe you will find that this fixes it.
> 
> [PATCH] tmpfs: fix shmem_evict_inode warnings on i_blocks

Since I just saw this in Linus' tree, here's another retrospective bug
report and Thank You for fixing it. :-)

The problem is quite real, even though I'm probably the only other person
to ever report it, see: http://www.spinics.net/lists/linux-fsdevel/msg83567.html

> Cc stable?  I don't think that's necessary, but might be proved wrong:
> along with the warning, the bug does allow one page beyond the limit
> to be allocated from a size-limited tmpfs mount.

It applies and works fine, so it probably wouldn't hurt. I'm using it in my
4.1++ tree as we speak, no problems.

-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
