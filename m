Date: Mon, 4 Dec 2000 13:40:45 +0000
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: [RFC] gfp_mask for address_space
Message-ID: <20001204134045.B8700@redhat.com>
References: <20001119114052.B9031@suse.de> <Pine.GSO.4.21.0012011548370.25379-100000@weyl.math.psu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.GSO.4.21.0012011548370.25379-100000@weyl.math.psu.edu>; from viro@math.psu.edu on Fri, Dec 01, 2000 at 03:59:44PM -0500
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alexander Viro <viro@math.psu.edu>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Andrea Arcangeli <andrea@suse.de>, Jens Axboe <axboe@suse.de>, Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Fri, Dec 01, 2000 at 03:59:44PM -0500, Alexander Viro wrote:
> 	Guys, what about adding into address_space a new field - gfp_mask?
> Changes required:
> 	a) new argument for page_cache_alloc() - address_space we want the
> page to go in. NULL for anonymous pages. (9 lines).
> 	b) when we initialize the ->i_data we should set ->i_data.gfp_mask to
> GFP_HIGHUSER (1 line)
> 	c) when we set the loop device we could memorize the current gfp_mask
> of the ->i_mapping of that file and set it to GFP_BUFFER.
> 	d) restore the old value upon losetup -d

There are other things we could do with something like this --- for
example, localising cache allocations on NUMA.

However, it doesn't actually fix all of the problems.  We still have
balance_dirty() deadlocks even if we avoid memory allocation loops.
NBD to localhost shows this up particularly easily, for example.

For 2.5, I think that the NBD problem can only really be laid to rest
by making bdflush fully async, so that things like the nbd server can
still run a balance_dirty() without deadlocking.  

The problem right now is that the balance_dirty() inside the nbd
server can result in it attempting to flush out dirty nbd buffers, so
we have the nbd device blocked on the nbd server, the nbd server
dirtying local disk buffer_heads, and the dirty buffer code blocking
on other dirty nbd buffers.)

The more we can make the VM flush and dirty-balancing code
asynchronous, the more we can both remove these deadlocks, AND cater
cleanly with multiple devices whose IO rates are vastly different.
(Things get really ugly if you start filling memory with dirty buffers
for slow devices like MO or floppies right now.)

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
