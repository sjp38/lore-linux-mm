Date: Thu, 8 Jun 2000 19:07:19 -0400 (EDT)
From: Alexander Viro <viro@math.psu.edu>
Subject: Re: Contention on ->i_shared_lock in dup_mmap()
In-Reply-To: <393FC7F4.C8E4B4B6@colorfullife.com>
Message-ID: <Pine.GSO.4.10.10006081855220.10800-100000@weyl.math.psu.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Manfred Spraul <manfreds@colorfullife.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Thu, 8 Jun 2000, Manfred Spraul wrote:

> Alexander Viro wrote:
> > 
> > OK, do_syslog() is just plain silly - it's resetting the buffer and code
> > in question looks so:
> >                 spin_lock_irq(&console_lock);
> >                 logged_chars = 0;
> >                 spin_unlock_irq(&console_lock);
> > ... which is for all purposes equivalent to
> >                 if (logged_chars) {
> >                         ...
> >                 }
> > so this one is easy (looks like a klogd silliness).
> > 
> cpu0: do_syslog
> 	logged_chars = 0;
> 
> cpu1: printk()
> 	logged_chars++;
> 
> We really need the spinlock :-(

And? With the current code:

cpu0:					cpu1:
	spin_lock_irq
	logged_chars = 0
	spin_unlock_irq
					spin_lock_irq
					...
					logged_chars++;
	break;

IOW, you have no warranty that upon the exit from do_syslog() you will
have logged_chars == 0 and that's precisely the same as you will get if
you replace the code with
	if (logged_chars) {
		spin_lock_irq(&console_lock);
		logged_chars = 0;
		spin_unlock_irq(&console_lock);
	}
- if logged_chars was non-zero we are getting the same result anyway and
if it was and something was in the middle of a changing it to non-zero -
fine, we just act as if do_syslog() happened before that.

As for the source of contention... beats me. _Probably_ weird mutated
klogd, but I didn't look at the patches RH slapped on it. syslog(5,...) is
damn silly anyway - it's an unavoidable race.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
