Date: Sat, 9 Sep 2000 10:06:33 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: test8-vmpatch performs great here!
Message-ID: <20000909100633.A8526@redhat.com>
References: <20000908192042.A31685@tentacle.dhs.org> <Pine.LNX.4.21.0009082027060.1049-100000@duckman.distro.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0009082027060.1049-100000@duckman.distro.conectiva>; from riel@conectiva.com.br on Fri, Sep 08, 2000 at 08:29:43PM -0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: deprogrammer <ttb@tentacle.dhs.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Fri, Sep 08, 2000 at 08:29:43PM -0300, Rik van Riel wrote:

> This seems to be due to kflushd (bdflush) waking up
> tasks in LIFO order ...

Hmm??

> >From fs/buffer.c:
> 
> in wakeup_bdflush()
>    2435         __set_current_state(TASK_UNINTERRUPTIBLE);
>    2436         add_wait_queue(&bdflush_done, &wait);

> (which adds our task to the front of the wait queue)

Right, but it is TASK_UNINTERRUPTIBLE, not TASK_EXCLUSIVE.

> and in kflushd()
>    2622                 wake_up(&bdflush_done);
> 
> (which wakes up the first task on the wait queue)

No.  That might be true if we were TASK_EXCLUSIVE, but we are not ---
*all_ processes on the wait queue will be woken, and the scheduler
doesn't care in the slightest about which order they get woken in.  It
will just schedule the best process next time.
 
wake_up_all() is only different from wake_up() when you encounter
TASK_EXCLUSIVE processes.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
