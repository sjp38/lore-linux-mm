Date: Tue, 25 Jan 2000 04:27:43 +0100 (CET)
From: Rik van Riel <riel@nl.linux.org>
Subject: 2.2.1{3,4,5pre*} VM bug found
Message-ID: <Pine.LNX.4.10.10001250421090.482-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

Hi Alan,

I've found the bug that makes the VM subsystem in the
latest 2.2 kernels go belly-up (or mess up processes).

Sometimes a process with tsk->state != TASK_RUNNABLE
calls __get_free_pages(). When we're (almost) out of
memory, the process will wake up kswapd and try to
free some memory itself.

In 2.2.15pre4 or when the call to try_to_free_pages()
generates disk I/O, the task will call schedule().
Since the task state != TASK_RUNNABLE, schedule() will
immedately remove it from the run queue ...

The task itself will still be somewhere `in the middle
of' __get_free_pages() and has no chance of ever
returning to whatever it was doing. Of course it still
reacts on signals, so you can easily kill it (unless
it happens to be your X server).

I will prepare a fix for this after I've had some
sleep ... you'll hear back from me tomorrow.

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
