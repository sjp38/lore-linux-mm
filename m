Date: Tue, 25 Jan 2000 19:15:43 +0100 (CET)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: 2.2.1{3,4,5pre*} VM bug found
In-Reply-To: <Pine.LNX.4.10.10001250421090.482-100000@mirkwood.dummy.home>
Message-ID: <Pine.LNX.4.10.10001251906370.14600-100000@d251.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

On Tue, 25 Jan 2000, Rik van Riel wrote:

>calls __get_free_pages(). When we're (almost) out of
>memory, the process will wake up kswapd and try to

You'll block also before to go out of memory if the allocation rate is
high enough.

>In 2.2.15pre4 or when the call to try_to_free_pages()
>generates disk I/O, the task will call schedule().
>Since the task state != TASK_RUNNABLE, schedule() will
>immedately remove it from the run queue ...

Before calling schedule() you always gets registered in a waitqueue so
you can't deadlock or wait too much.

If something there is the opposite problem. If you do:

	__set_current_state(TASK_UNINTERRUPTIBLE);
	get_page(GFP_KERNEL);
	XXXXXXXXXXXXXXXXXXXX
	schedule();

then at point XXXXXXX you may become a task running and you don't block
anymore.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
