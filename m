Received: from newsguy.com (thparkth@localhost [127.0.0.1])
	by newsguy.com (8.12.9/8.12.8) with ESMTP id i4CEBtXm011777
	for <linux-mm@kvack.org>; Wed, 12 May 2004 07:11:55 -0700 (PDT)
	(envelope-from thparkth@newsguy.com)
Received: (from thparkth@localhost)
	by newsguy.com (8.12.9/8.12.8/Submit) id i4CEBt6b011774
	for linux-mm@kvack.org; Wed, 12 May 2004 07:11:55 -0700 (PDT)
	(envelope-from thparkth)
Date: Wed, 12 May 2004 07:11:55 -0700 (PDT)
Message-Id: <200405121411.i4CEBt6b011774@newsguy.com>
From: Andrew Crawford <acrawford@ieee.org>
Subject: The long, long life of an inactive_dirty page
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Please forgive this beginner-level question, but I am trying to understand the
process by which dirty pages become clean when there is no memory pressure. I
have been unable to find any useful answers in a very thorough Google session.

All of these questions are based on 2.4.21 (-9.ELhugemem).

Imagine that I have a process which writes a large amount of data to a file,
then exits. It is clear and demonstrable that those pages, as yet unwritten to
disk, end up on the inactive_dirty list.

Nothing else is running on the box. There are several GBs of free RAM.

It is my understanding that the next thing that should happen is that
page_launder(), which is invoked when memory gets low, should come along and
get those pages written, and then, on its next pass mark them inactive_clean.

But in thise case, we have plenty of memory available and absolutely nothing
using it. So there's never any memory pressure, page_launder is never called,
and the data is never written to disk. This is arguably a bad thing; an
entirely idle system should not be sitting for hours or days with uncommitted
data in RAM for the obvious reason.

Now my understanding might be naive, out of date, or just plain wrong, but
nevertheless this is happening in real life on our servers. I can produce what
appears to be the same behaviour at will.

After I create a large file with dd, I find that the size of inactive_dirty
reduces at a steady rate - exactly 260K per two seconds - until it reaches a
level where it remains indefinitely.

> grep Inact_dirty /proc/meminfo
Inact_dirty:       480 kB
> dd if=/dev/zero of=/tmp/ac1 bs=1048576 count=500
500+0 records in
500+0 records out
> grep Inact_dirty /proc/meminfo
Inact_dirty:    510684 kB
> grep MemFree /proc/meminfo
MemFree:       7065484 kB

[ ~5 minutes later ]

> grep Inact_dirty /proc/meminfo
Inact_dirty:    492240 kB

[ ~5 minutes later ]

>  grep Inact_dirty /proc/meminfo
Inact_dirty:    463680 kB

[ ~1 hr later ]

> grep Inact_dirty /proc/meminfo
Inact_dirty:    463688 kB

[ ~5 hrs later ]

>  grep Inact_dirty /proc/meminfo
Inact_dirty:    463682 kB


.. and indeed, the next day the number is basically the same, as long as
updatedb and similar aren't run overnight.

That's 460MB of uncommitted data hanging around on a completely idle machine.

Are there any proc/sysctl parameters that can influence this behaviour?

With thanks for any insights,

Yours,

Andrew

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
