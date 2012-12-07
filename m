Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 4F69E6B0080
	for <linux-mm@kvack.org>; Fri,  7 Dec 2012 16:31:41 -0500 (EST)
MIME-Version: 1.0
Message-ID: <bec77f0e-ff96-45df-b090-70120185f560@default>
Date: Fri, 7 Dec 2012 13:31:35 -0800 (PST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: zcache+zram working together?
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luigi Semenzato <semenzato@google.com>, Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, Konrad Wilk <konrad.wilk@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>

Last summer, during the great(?) zcache-vs-zcache2 debate,
I wondered if there might be some way to obtain the strengths
of both.  While following Luigi's recent efforts toward
using zram for ChromeOS "swap", I thought of an interesting
interposition of zram and zcache that, at first blush, makes
almost no sense at all, but after more thought, may serve as a
foundation for moving towards a more optimal solution for use
of "adaptive compression" in the kernel, at least for
embedded systems.

To quickly review:

Zram (when used for swap) compresses only anonymous pages and
only when they are swapped but uses the high-density zsmalloc
allocator and eliminates the need for a true swap device, thus
making zram a good fit for embedded systems.  But, because zram
appears to the kernel as a swap device, zram data must traverse
the block I/O subsystem and is somewhat difficult to monitor and
control without significant changes to the swap and/or block
I/O subsystem, which are designed to handle fixed block-sized
data.

Zcache (zcache2) compresses BOTH clean page cache pages that
would otherwise be evicted, and anonymous pages that would
otherwise be sent to a swap device.  Both paths use in-kernel
hooks (cleancache and frontswap respectively) which avoid
most or all of the block I/O subsystem and the swap subsystem.
Because of this and since it is designed using transcendent
memory ("tmem") principles, zcache has a great deal more
flexibility in control and monitoring.  Zcache uses the simpler,
more predictable "zbud" allocator which achieves lower density
but provides greater flexibility under high pressure.
But zcache requires a swap device as a "backup" so seems
unsuitable for embedded systems.

(Minchan, I know at one point you were working on some
documentation to contrast zram and zcache so you may
have something more to add here...)

What if one were to enable both?  This is possible today with
no kernel change at all by configuring both zram and zcache2
into the kernel and then configuring zram at boottime.

When memory pressure is dominated by file pages, zcache (via
the cleancache hooks) provides compression to optimize memory
utilization.  As more pressure is exerted by anonymous pages,
"swapping" occurs but the frontswap hooks route the data to
zcache which, as necessary, reclaims physical pages used by
compressed file pages to use for compressed anonymous pages.
At this point, any compressions unsuitable for zbud are rejected
by zcache and passed through to the "backup" swap device...
which is zram!  Under high pressure from anonymous pages,
zcache can also be configured to "unuse" pages to zram (though
this functionality is still not merged).

I've plugged zcache and zram together and watched them
work/cooperate, via their respective debugfs statistics.
While I don't have benchmarking results and may not have
time anytime soon to do much work on this, it seems like
there is some potential here, so I thought I'd publish the
idea so that others can give it a go and/or look at
other ways (including kernel changes) to combine the two.

Feedback welcome and (early) happy holidays!
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
