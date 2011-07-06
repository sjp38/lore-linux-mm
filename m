Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id E475D9000C2
	for <linux-mm@kvack.org>; Tue,  5 Jul 2011 21:06:19 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <d19811cc-a722-4d30-8a43-aedb1cd978c9@default>
Date: Tue, 5 Jul 2011 18:05:53 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [RFC] non-preemptible kernel socket for RAMster
References: <4232c4b6-15be-42d8-be42-6e27f9188ce2@default>
 <D3F292ADF945FB49B35E96C94C2061B91257D65C@nsmail.netscout.com>
 <6147447c-ecab-43ea-9b4a-1ff64b2089f0@default>
 <D3F292ADF945FB49B35E96C94C2061B91257D6FD@nsmail.netscout.com>
 <704d094e-7b81-480f-8363-327218d1b0ea@default
 D3F292ADF945FB49B35E96C94C2061B91257DCA8@nsmail.netscout.com>
In-Reply-To: <D3F292ADF945FB49B35E96C94C2061B91257DCA8@nsmail.netscout.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Loke, Chetan" <Chetan.Loke@netscout.com>, netdev@vger.kernel.org
Cc: Konrad Wilk <konrad.wilk@oracle.com>, linux-mm <linux-mm@kvack.org>

> From: Loke, Chetan [mailto:Chetan.Loke@netscout.com]
> Subject: RE: [RFC] non-preemptible kernel socket for RAMster
>=20
> > From: Dan Magenheimer [mailto:dan.magenheimer@oracle.com]
>=20
> > Actually, RAMster is using a much more flexible type of
> > RAM-drive; it is built on top of Transcendent Memory
> > and on top of zcache (and thus on top of cleancache and
> > frontswap).  A RAM-drive is fixed size so is not very suitable
> > for the flexibility required for RAMster.  For example,
> > suppose you have two machines A and B.  At one point in
> > time A is overcommitted and needs to swap and B is relatively
> > idle.  Then later, B is overcommitted and needs to swap and
> > A is relatively idle.  RAMster can handle this entirely
> > dynamically, a RAM-drive cannot.
>=20
> Again, iff NBD works with a ram-drive then you really wouldn't need to
> do anything. How often are you going to re-size your remote-SWAP?  Plus,
> you can make nbd-server listen on multiple ports - Google(Linux NBD)
> returned: http://www.fi.muni.cz/~kripac/orac-nbd/ . Look at the
> nbd-server code to see if it launches multiple kernel-threads for
> servicing different ports. If not, one can enhance it and scale that way
> too. But nbd-server today can service multiple-ports(that is effectively
> servicing multiple clients). So why not add NBD-filesystem-filters to
> make it point to local/remote swap?

Well, we may be talking past each other, but the RAMster answer to:

> How often are you going to re-size your remote-SWAP?

is "as often as the working set changes on any machine in the
cluster", meaning *constantly*, entirely dynamically!  How
about a more specific example:  Suppose you have 2 machines,
each with 8GB of memory.  99% of the time each machine is
chugging along just fine and doesn't really need more than 4GB,
and may even use less than 1GB a large part of the time.
But very now and then, one of the machines randomly needs
9GB, 10GB, maybe even 12GB  of memory.  This would normally
result in swapping.  (Most system administrators won't even
have this much information... they'll just know they are
seeing swapping and decide they need to buy more RAM.)

With NBD to a ram-drive, each machine would need to pre-allocate
4GB of RAM for the RAM-drive, leaving only 4GB of RAM for
the "local" RAM.  The result will actually be MORE swapping
because a fixed amount of RAM has been pre-reserved for the
other machine's swap.   With RAMster, everything is done dynamically,
so all that matters is the maximum of the sum of the RAM
used.  You may even be able to *remove* ~2GB of RAM from each
of the systems and still never see any swapping to disk.

> > Thanks.  Could you provide a pointer for this?  I found
> > the SCST sourceforge page but no obvious references to
> > scst-in-ram-mode.  (But also, since it appears to be
> > SCSI-related, I wonder if it also assumes a fixed size
> > target device, RAM or disk or ??)
>=20
> Yes, it is SCSI. You should be looking for SCST I/O modes. Read some
> docs and then send an email to the scst-mailing-list. If you speak about
> block-IO-performance then FC(in its class of price/performance factor)
> is more than capable of handling any workload. FC is a protocol designed
> for storage. No exotic fabric other than FC is needed.
> Folks who start with ethernet for block-IO, always start with bare
> minimal code and then for squeezing block-IO performance(aka version 2
> of the product), keep hacking repeatedly or go for a link-speed upgrade.
> Start with FC, period.

My point was that block I/O devices (AFAIK) always present a fixed
"size" to the kernel, and if this is also true of scst-in-ram-mode,
the same problem as swap-over-NBD occurs... it's not dynamic.
RAMster does not present a block-I/O storage-like interface;
it's using the Transcendent Memory interface, which is designed
for "slow RAM" of an unknown-and-dynamic size.

I'm not a storage expert either, but I do wonder if "no exotic
fabric other than FC" isn't an oxymoron ;-)  FC is certainly
too exotic for me.

Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
