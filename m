Date: Fri, 8 Sep 2000 20:29:43 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: test8-vmpatch performs great here!
In-Reply-To: <20000908192042.A31685@tentacle.dhs.org>
Message-ID: <Pine.LNX.4.21.0009082027060.1049-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: deprogrammer <ttb@tentacle.dhs.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 8 Sep 2000, deprogrammer wrote:

> The box remained somewhat interactive, but a few times during
> the tar zxvf the box would stop responding for a few seconds
> during which there would be alot of disk activity, same for the
> tar xvf.

This seems to be due to kflushd (bdflush) waking up
tasks in LIFO order ...

>From fs/buffer.c:

in wakeup_bdflush()
   2435         __set_current_state(TASK_UNINTERRUPTIBLE);
   2436         add_wait_queue(&bdflush_done, &wait);
   2437 
   2438         wake_up_process(bdflush_tsk);
   2439         schedule();

(which adds our task to the front of the wait queue)

and in kflushd()
   2622                 wake_up(&bdflush_done);

(which wakes up the first task on the wait queue)

This results in LIFO ordering for the wakeup. I've
fixed this in my local tree (doing a wake_up_all()
instead) and will release a new patch after tweaking
things a bit more.

regards,

Rik
--
"What you're running that piece of shit Gnome?!?!"
       -- Miguel de Icaza, UKUUG 2000

http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
