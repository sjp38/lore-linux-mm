Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by postfix.conectiva.com.br (Postfix) with SMTP id 6BE9E16B14
	for <linux-mm@kvack.org>; Thu, 15 Mar 2001 09:56:14 -0300 (EST)
Date: Thu, 15 Mar 2001 09:24:59 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: changing mm->mmap_sem  (was: Re: system call for process information?)
In-Reply-To: <Pine.LNX.4.33.0103141618320.21132-100000@duckman.distro.conectiva>
Message-ID: <Pine.LNX.4.21.0103150919260.4165-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: george anzinger <george@mvista.com>
Cc: Alexander Viro <viro@math.psu.edu>, linux-mm@kvack.org, bcrl@redhat.com, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 14 Mar 2001, Rik van Riel wrote:
> On Wed, 14 Mar 2001, george anzinger wrote:
> 
> > Is it REALLY necessary to prevent them from seeing an
> > inconsistent state?  Seems to me that in the total picture (i.e.
> > system wide) they will never see a consistent state, so why be
> > concerned with a small corner of the system.
> 
> You're right.

Mmmm, I've looked at the code today and it turned out that
we're NOT right ;)

The mmap_sem is used in procfs to prevent the list of VMAs
from changing. In the page fault code it seems to be used
to prevent other page faults to happen at the same time with
the current page fault (and to prevent VMAs from changing
while a page fault is underway).

Maybe we should change the mmap_sem into a R/W semaphore ?

Since page faults seem to be the "common cause" of blocking
procfs access *and* since both page faults and procfs only
need to prevent the VMA list from changing, a read lock would
help here.

Write locks would be used in the code where we actually want
to change the VMA list and page faults would use an extra lock
to protect against each other (possibly a per-pagetable lock so
multithreaded apps can pagefault in different memory regions at
the same time ???).

regards,

Rik
--
Virtual memory is like a game you can't win;
However, without VM there's truly nothing to lose...

		http://www.surriel.com/
http://www.conectiva.com/	http://distro.conectiva.com.br/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
