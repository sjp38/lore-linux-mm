Date: Tue, 10 Aug 2004 09:54:08 -0500
From: Brent Casavant <bcasavan@sgi.com>
Reply-To: Brent Casavant <bcasavan@sgi.com>
Subject: Re: [PATCH] get_nodes mask miscalculation
In-Reply-To: <m31xifu5pn.fsf@averell.firstfloor.org>
Message-ID: <Pine.SGI.4.58.0408100936220.23966@kzerza.americas.sgi.com>
References: <2rr7U-5xT-11@gated-at.bofh.it> <m31xifu5pn.fsf@averell.firstfloor.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@muc.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 10 Aug 2004, Andi Kleen wrote:

> The idea behind this is was to make it behave like select.
> And select passes highest valid value + 1.

Not that my opinion is worth much, but this seems a very peculiar
interface to mimic.

> In this case
> valid value is not the highest bit number, but the length
> of the bitmap.
>
> For some reason nobody except me seems to get it though,
> probably because the description in the manpages is a bit confusing:
>
> get_mempolicy(2):
>
> "maxnode is the maximum bit number plus one that can be stored into
> nodemask."

Actually, I worked from the following description:

mbind(3)
	. . .
	nodemask is a bit field of nodes that contains up to
	maxnode bits.
	. . .

This very clearly indicates that I should pass the number of bits
in the nodemask field, not the number of bits plus one.

Granted, the man page makes it clear that I should use libnuma, but
in this case I was working on implementing a new MPOL_ROUNDROBIN, and
wanted to go directly to the system call for testing purposes.

And not to make things even more confusing, but the way things are
designed now, the value I need to pass to mbind() is numa_max_node()+2.
Very confusing.

> Problem is that you'll break all existing libnuma binaries
> which pass NUMA_MAX_NODES + 1. In your scheme the kernel
> will access one bit beyond the bitmap that got passed,
> and depending on its random value you may get a failure or not.

Well, again, not that my opinion carries much weight (nor really should
it), but this whole off-by-one (or two) interface seems unnecessarily
confusing.  Is there no way we can get this fixed?  The temporary pain
of breaking the relatively new libnuma seems worth the price of getting
this forever cleaned up.

Brent

-- 
Brent Casavant             bcasavan@sgi.com        Forget bright-eyed and
Operating System Engineer  http://www.sgi.com/     bushy-tailed; I'm red-
Silicon Graphics, Inc.     44.8562N 93.1355W 860F  eyed and bushy-haired.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
