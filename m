From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <200004272020.NAA00247@google.engr.sgi.com>
Subject: Re: [patch] 2.3.99-pre6-3 VM fixed
Date: Thu, 27 Apr 2000 13:20:24 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.21.0004271647461.3919-100000@duckman.conectiva> from "Rik van Riel" at Apr 27, 2000 04:56:11 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@nl.linux.org
Cc: "Stephen C. Tweedie" <sct@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu, torvalds@transmeta.com
List-ID: <linux-mm.kvack.org>

> 
> This suggests a locking issue. Is there any place in the kernel
> where we take a write lock on tasklist_lock and do a lock_kernel()
> afterwards?
> 
> Alternatively, the mm->lock, kernel_lock and/or tasklist_lock could
> be in play all three... Could the changes to ptrace.c be involved
> here?
>

I really need to learn the locking rules for the kernel. As far as
I can see, lock_kernel is a spinning monitor, so any intr code should
be able to grab lock_kernel. Hence, code that is bracketed with a 
read_lock(tasklist_lock) .... read_unlock(tasklist_lock) can take an
intr and be trying to get lock_kernel.

Coming to your question, the above does not seem to be the case 
for write lock on tasklist_lock, since the irq level is raised.

[kanoj@entity linux]$ gid tasklist_lock | grep -v unlock | grep write | grep -v ar
ch
include/linux/sched.h:844:      write_lock_irq(&tasklist_lock);
kernel/exit.c:365:      write_lock_irq(&tasklist_lock);
kernel/exit.c:394:                      write_lock_irq(&tasklist_lock);
kernel/exit.c:515:                                      write_lock_irq(&tasklist_lock);
kernel/fork.c:741:      write_lock_irq(&tasklist_lock);

And I don't _think_ that any of this code takes the kernel_lock either
in the straightline execution path.

Kanoj
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
