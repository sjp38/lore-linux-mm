From: Russell King <rmk@arm.linux.org.uk>
Message-Id: <200005050843.JAA25160@flint.arm.linux.org.uk>
Subject: Re: classzone-VM + mapped pages out of lru_cache
Date: Fri, 5 May 2000 09:43:26 +0100 (BST)
In-Reply-To: <200005050304.UAA03317@pizda.ninka.net> from "David S. Miller" at May 04, 2000 08:04:09 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@redhat.com>
Cc: andrea@suse.de, shrybman@sympatico.ca, quintela@fi.udc.es, gandalf@wlug.westbo.se, joerg.stroettchen@arcormail.de, linux-kernel@vger.rutgers.edu, axboe@suse.de, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

David S. Miller writes:
> Andrea, please do not pass IRQ state "flags" to another function
> and try to restore them in this way, it breaks Sparc and any other
> cpu which keeps "stack frame" state in the flags value.  "flags" must
> be obtained and restored in the same function.

On some of the older (obsolete) ARMs, this is also not possible - the
IRQ state is restored each time a function exits in kernel mode.
(I'm not too concerned with these today).

I've seen this done somewhere else in the kernel as well.  How about
changing flags to an architecture-defined struct, and doing something
like:

extern inline void save_flags(struct flags *flg)
{
#ifdef CATCH_BAD_FLAGS
	flg->ret = __builtin_return_address(0);
#endif
	__save_flags(flg->flag);
}

extern inline void restore_flags(struct flags *flg)
{
#ifdef CATCH_BAD_FLAGS
	if (flg->ret != __builtin_return_address(0))
		BUG();
#endif
	__restore_flags(flg->flag);
}

Of course, CATCH_BAD_FLAGS would be turned off for the stable series to
reduce the impact of the check, but at least we could catch bad usage on
development kernels easily.

Of course, the above is dependent on __builtin_return_address() returning
the return address of the function that these were inlined into.

I'm just wondering - what about spinlocks?  There are a couple of instances
where a spinlock is taken in a parent function and temporarily released in
one of its child functions.  I'm not happy with this usage, but if this is
a legal usage of the spinlocks, then the above may bite when it shouldn't.
   _____
  |_____| ------------------------------------------------- ---+---+-
  |   |         Russell King        rmk@arm.linux.org.uk      --- ---
  | | | |   http://www.arm.linux.org.uk/~rmk/aboutme.html    /  /  |
  | +-+-+                                                     --- -+-
  /   |               THE developer of ARM Linux              |+| /|\
 /  | | |                                                     ---  |
    +-+-+ -------------------------------------------------  /\\\  |
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
