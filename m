Message-ID: <393FC7F4.C8E4B4B6@colorfullife.com>
Date: Thu, 08 Jun 2000 18:21:08 +0200
From: Manfred Spraul <manfreds@colorfullife.com>
MIME-Version: 1.0
Subject: Re: Contention on ->i_shared_lock in dup_mmap()
References: <Pine.GSO.4.10.10006072235360.10800-100000@weyl.math.psu.edu>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alexander Viro <viro@math.psu.edu>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Alexander Viro wrote:
> 
> OK, do_syslog() is just plain silly - it's resetting the buffer and code
> in question looks so:
>                 spin_lock_irq(&console_lock);
>                 logged_chars = 0;
>                 spin_unlock_irq(&console_lock);
> ... which is for all purposes equivalent to
>                 if (logged_chars) {
>                         ...
>                 }
> so this one is easy (looks like a klogd silliness).
> 
cpu0: do_syslog
	logged_chars = 0;

cpu1: printk()
	logged_chars++;

We really need the spinlock :-(

How many cpu's? How did you measure the contention?
I cannot imagine that do_syslog is really the source for the contention,
perhaps cpu0 was executing a slow console switch, and cpu1 called
do_syslog?

--
	Manfred
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
