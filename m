From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14480.38782.751251.577294@dukat.scot.redhat.com>
Date: Thu, 27 Jan 2000 19:07:42 +0000 (GMT)
Subject: Re: 2.2.1{3,4,5pre*} VM bug found
In-Reply-To: <Pine.LNX.4.10.10001250421090.482-100000@mirkwood.dummy.home>
References: <Pine.LNX.4.10.10001250421090.482-100000@mirkwood.dummy.home>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@nl.linux.org>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Linux MM <linux-mm@kvack.org>, Stephen Tweedie <sct@redhat.com>, Linux Kernel <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, 25 Jan 2000 04:27:43 +0100 (CET), Rik van Riel
<riel@nl.linux.org> said:

> Sometimes a process with tsk->state != TASK_RUNNABLE
> calls __get_free_pages(). When we're (almost) out of
> memory, the process will wake up kswapd and try to
> free some memory itself.

> In 2.2.15pre4 or when the call to try_to_free_pages()
> generates disk I/O, the task will call schedule().
> Since the task state != TASK_RUNNABLE, schedule() will
> immedately remove it from the run queue ...

Shouldn't be a problem.  Anywhere that we stall in try_to_free_pages()
to wait for disk IO, we obviously have to set task->state to
TASK_UNINTERRUPTIBLE, as we're about to block.  If we do that as a
result of disk IO, then we have necessarily already scheduled a wakeup
event which will set the task state back to runnable.

So, the only risk is that the call to try_to_free_pages() has the
unexpected side effect of setting the task state to TASK_RUNNABLE.  That
isn't a problem: the only effect it will have on the caller is to make a
call schedule() return sooner than expected.  

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
