Date: Thu, 27 Apr 2000 14:24:18 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [patch] 2.3.99-pre6-3 VM fixed
In-Reply-To: <200004272020.NAA00247@google.engr.sgi.com>
Message-ID: <Pine.LNX.4.10.10004271420480.1162-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: riel@nl.linux.org, "Stephen C. Tweedie" <sct@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>


On Thu, 27 Apr 2000, Kanoj Sarcar wrote:
> 
> I really need to learn the locking rules for the kernel. As far as
> I can see, lock_kernel is a spinning monitor, so any intr code should
> be able to grab lock_kernel.

No.

Interrupts must NOT grab the kernel lock. 

It's not because of the regular dead-lock concerns (an interrupt could
just increment the lock counter), but because of more subtle issues: the
counter maintenance is not atomic, and should not be atomic. For example,
during re-schedules we drop the kernel lock flag ("kernel_flag", but we
still maintain the lock counter), so an interrupt that came in at that
time would _think_ that it got the kernel lock (because the counter is
non-zero), but it really doesn't get it.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
