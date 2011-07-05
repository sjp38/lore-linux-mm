Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id B76579000C2
	for <linux-mm@kvack.org>; Tue,  5 Jul 2011 15:19:00 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <704d094e-7b81-480f-8363-327218d1b0ea@default>
Date: Tue, 5 Jul 2011 12:18:36 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [RFC] non-preemptible kernel socket for RAMster
References: <4232c4b6-15be-42d8-be42-6e27f9188ce2@default>
 <D3F292ADF945FB49B35E96C94C2061B91257D65C@nsmail.netscout.com>
 <6147447c-ecab-43ea-9b4a-1ff64b2089f0@default
 D3F292ADF945FB49B35E96C94C2061B91257D6FD@nsmail.netscout.com>
In-Reply-To: <D3F292ADF945FB49B35E96C94C2061B91257D6FD@nsmail.netscout.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Loke, Chetan" <Chetan.Loke@netscout.com>, netdev@vger.kernel.org
Cc: Konrad Wilk <konrad.wilk@oracle.com>, linux-mm <linux-mm@kvack.org>

> From: Loke, Chetan [mailto:Chetan.Loke@netscout.com]
> > From: Dan Magenheimer [mailto:dan.magenheimer@oracle.com]
> > Subject: RE: [RFC] non-preemptible kernel socket for RAMster
> >
> > > From: Loke, Chetan [mailto:Chetan.Loke@netscout.com]
> > > Sent: Tuesday, July 05, 2011 10:37 AM
> > > To: Dan Magenheimer; netdev@vger.kernel.org
> > > Cc: Konrad Wilk; linux-mm
> > > Subject: RE: [RFC] non-preemptible kernel socket for RAMster
> > >
> > > > In working on a kernel project called RAMster* (where RAM on a
> > > > remote system may be used for clean page cache pages and for swap
> > > > pages), I found I have need for a kernel socket to be used when
> > >
> > > How is RAMster+swap different than NBD's (pending etc?)support for
> > > SWAP over NBD?
> >
> > I may be ignorant of details about NBD, but did some quick
> > research using google.  If I understand correctly, swap over
> > NBD is still writing to a configured swap disk on the remote
>=20
> Hi - I thought NBD-server needs a backing store(a file).
> Now the file itself could reside on a RAM-drive or disk-drive etc.
> And so a remote NBD(disk or RAM) can be mounted locally as a swap
> device.
> The local client should still see it as a block device.
>=20
> I haven't used the RAM-drive feature myself but you may want to check if
> it
> works or even borrow that logic in your code.

Actually, RAMster is using a much more flexible type of
RAM-drive; it is built on top of Transcendent Memory
and on top of zcache (and thus on top of cleancache and
frontswap).  A RAM-drive is fixed size so is not very suitable
for the flexibility required for RAMster.  For example,
suppose you have two machines A and B.  At one point in
time A is overcommitted and needs to swap and B is relatively
idle.  Then later, B is overcommitted and needs to swap and
A is relatively idle.  RAMster can handle this entirely
dynamically, a RAM-drive cannot.

> > machine.  RAMster is swapping to *RAM* on the remote machine.
> > The idea is that most machines are very overprovisioned in
> > RAM, and are rarely using all of their RAM, especially when
> > a machine is (mostly) idle.  In other words, the "max of
> > the sums" of RAM usage on a group of machines is much lower
> > than the "sum of the max" of RAM usage.
> >
> > So if the network is sufficiently faster than disk for
> > moving a page of data, RAMster provides a significant
> > performance improvement.  OR RAMster may allow a significant
> > reduction in the total amount of RAM across a data center.
> >
> > The version of RAMster I am working on now is really
> > a proof-of-concept that works over sockets, using the
> > ocfs2 cluster layer.  One can easily envision a future
> > "exo-fabric" which allows one machine to write to the
> > RAM of another machine... for this future hardware,
> > RAMster becomes much more interesting.
>=20
> Or you can also try scst-in-RAM mode(if you want to experiment with
> different fabrics).

Thanks.  Could you provide a pointer for this?  I found
the SCST sourceforge page but no obvious references to
scst-in-ram-mode.  (But also, since it appears to be
SCSI-related, I wonder if it also assumes a fixed size
target device, RAM or disk or ??)

Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
