Date: Sat, 14 Oct 2000 14:36:04 +0200 (MET DST)
From: Roman Zippel <zippel@fh-brandenburg.de>
Subject: Re: Updated Linux 2.4 Status/TODO List (from the ALS show)
In-Reply-To: <20001013155750.B29761@twiddle.net>
Message-ID: <Pine.GSO.4.10.10010140214260.29723-100000@zeus.fh-brandenburg.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Richard Henderson <rth@twiddle.net>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, "David S. Miller" <davem@redhat.com>, davej@suse.de, tytso@mit.edu, torvalds@transmeta.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Fri, 13 Oct 2000, Richard Henderson wrote:

> Either that or adjust how we do atomic operations.  I can do
> 64-bit atomic widgetry, but not with the code as written.

It's probably more something for 2.5, but what about adding a lock
argument to the atomic operations, then sparc could use that explicit lock
and everyone else simply optimizes that away. That would allow us to use
the full 32/64 bit. What we could get is a nice generic atomic exchange
command like:

	atomic_exchange(lock, ptr, old, new);

Where new can be a (simple) expression which can include old. Especially
for risc system every atomic operation in atomic.h can be replaced with
this. Or if you need more flexibility the same can be written as:

	atomic_enter(lock);
	__atomic_init(ptr, old);
	do {
		__atomic_reserve(ptr, old);
	} while (!__atomic_update(ptr, old, new));
	atomic_leave(lock);

atomic_enter/atomic_enter are either normal spinlocks or (in most cases)
dummys. The other macros are either using RMW instructions or special
load/store instructions.

Using a lock makes it a bit more difficult to use and especially the last
construction must never be required in normal drivers. On the other hand
it gets way more flexible as we are not limited to a single atomic_t
anymore. If anyone is interested how it could look like, I've put an
example at http://zeus.fh-brandenburg.de/~zippel/linux/bin/atomic.tar.gz
(It also includes a bit more documentation and some (a bit outdated)
examples). Somewhere I also have a patch where I use this to write a
spinlock free printk implementation, which is still interrupt and SMP
safe.
There are still some issues open (like ordering), but I'd like to know if
there is a general interest in this.

bye, Roman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
