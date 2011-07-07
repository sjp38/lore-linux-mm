Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id DAB889000C2
	for <linux-mm@kvack.org>; Thu,  7 Jul 2011 11:34:36 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <61fd635c-d01c-46c1-ba89-2915a6ddb9f1@default>
Date: Thu, 7 Jul 2011 08:34:09 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [RFC] non-preemptible kernel socket for RAMster
References: <4232c4b6-15be-42d8-be42-6e27f9188ce2@default>
 <D3F292ADF945FB49B35E96C94C2061B91257D65C@nsmail.netscout.com>
 <6147447c-ecab-43ea-9b4a-1ff64b2089f0@default>
 <D3F292ADF945FB49B35E96C94C2061B91257D6FD@nsmail.netscout.com>
 <704d094e-7b81-480f-8363-327218d1b0ea@default>
 <D3F292ADF945FB49B35E96C94C2061B91257DCA8@nsmail.netscout.com>
 <d19811cc-a722-4d30-8a43-aedb1cd978c9@default
 D3F292ADF945FB49B35E96C94C2061B912622709@nsmail.netscout.com>
In-Reply-To: <D3F292ADF945FB49B35E96C94C2061B912622709@nsmail.netscout.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Loke, Chetan" <Chetan.Loke@netscout.com>, netdev@vger.kernel.org
Cc: Konrad Wilk <konrad.wilk@oracle.com>, linux-mm <linux-mm@kvack.org>

> From: Loke, Chetan [mailto:Chetan.Loke@netscout.com]
> Subject: RE: [RFC] non-preemptible kernel socket for RAMster
>=20
> > -----Original Message-----
> > From: Dan Magenheimer [mailto:dan.magenheimer@oracle.com]
> >
> > > From: Loke, Chetan [mailto:Chetan.Loke@netscout.com]
> > >
> > > > From: Dan Magenheimer [mailto:dan.magenheimer@oracle.com]
> >
> > > How often are you going to re-size your remote-SWAP?
> >
> > is "as often as the working set changes on any machine in the
> > cluster", meaning *constantly*, entirely dynamically!  How
> > about a more specific example:  Suppose you have 2 machines,
> > each with 8GB of memory.  99% of the time each machine is
> > chugging along just fine and doesn't really need more than 4GB,
> > and may even use less than 1GB a large part of the time.
> > But very now and then, one of the machines randomly needs
> > 9GB, 10GB, maybe even 12GB  of memory.  This would normally
> > result in swapping.  (Most system administrators won't even
> > have this much information... they'll just know they are
> > seeing swapping and decide they need to buy more RAM.)
> >
>=20
> Ok, I understand there is interest in implementing
> 'remote-volatile-ballooning-variant' but how do you pick a remote
> candidate(hypervisor)? Let's say, memory could be available on remote
> system but what if the remote-p{NIC,CPU} is overloaded? Sure, sysadmins
> won't have this info because this so dynamic(and it's quite possible as
> you mentioned above). But does the trans-remote-API know about this
> resource-availability before opening a remote-channel?
>=20
> Stressing the remote-p{NIC/CPU} might trick hypervisor-vmotion-plugin to
> vmotion VM[s] to another hypervisor. How is trans-remote-API integrating
> with remote/global vmotion policies to avoid this false vmotion?

Hi Chetan --

Thanks for the continued discussion.

First, let me clarify that RAMster does not depend on virtualization.
At some time in the future, it may be a nice addition for KVM*,
but the version I am developing currently only works on a
cluster of physical machines.  So vmotion/migration is not
an issue right now


As for choosing the remote machine, another key feature of
the Transcendent Memory mechanism is that any and every page
can be rejected.  If rejected, the page remains local.  In
essence, on *every* page-to-be-swapped, machine A *asks*
machine B, "can you take this page"?  If the answer is no,
machine A can choose another machine (C), or may choose to
swap the page to its own slow swap disk.  (Currently,
only the latter is implemented, but more complicated
policy could certainly be implemented.)

Dan

* Xen doesn't have drivers so RAMster-over-network is not an option
for Xen.  A future RAMster-over-exofabric might work with Xen though.)
And, by the way, the Transcendent Memory implementation on Xen
does handle vmotion/migration so it is a solvable problem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
