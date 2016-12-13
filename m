Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 064FE6B0038
	for <linux-mm@kvack.org>; Tue, 13 Dec 2016 11:10:38 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id h201so110450249qke.7
        for <linux-mm@kvack.org>; Tue, 13 Dec 2016 08:10:38 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j68si28355236qte.13.2016.12.13.08.10.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Dec 2016 08:10:37 -0800 (PST)
Date: Tue, 13 Dec 2016 17:10:28 +0100
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: Designing a safe RX-zero-copy Memory Model for Networking
Message-ID: <20161213171028.24dbf519@redhat.com>
In-Reply-To: <alpine.DEB.2.20.1612121200280.13607@east.gentwo.org>
References: <20161205153132.283fcb0e@redhat.com>
	<20161212083812.GA19987@rapoport-lnx>
	<20161212104042.0a011212@redhat.com>
	<20161212141433.GB19987@rapoport-lnx>
	<584EB8DF.8000308@gmail.com>
	<20161212181344.3ddfa9c3@redhat.com>
	<alpine.DEB.2.20.1612121200280.13607@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: John Fastabend <john.fastabend@gmail.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Willem de Bruijn <willemdebruijn.kernel@gmail.com>, =?UTF-8?B?QmrDtnJuIFTDtnBlbA==?= <bjorn.topel@intel.com>, "Karlsson, Magnus" <magnus.karlsson@intel.com>, Alexander Duyck <alexander.duyck@gmail.com>, Mel Gorman <mgorman@techsingularity.net>, Tom Herbert <tom@herbertland.com>, Brenden Blanco <bblanco@plumgrid.com>, Tariq Toukan <tariqt@mellanox.com>, Saeed Mahameed <saeedm@mellanox.com>, Jesse Brandeburg <jesse.brandeburg@intel.com>, Kalman Meth <METH@il.ibm.com>, Vladislav Yasevich <vyasevich@gmail.com>, brouer@redhat.com


On Mon, 12 Dec 2016 12:06:59 -0600 (CST) Christoph Lameter <cl@linux.com> w=
rote:
> On Mon, 12 Dec 2016, Jesper Dangaard Brouer wrote:
>=20
> > Hmmm. If you can rely on hardware setup to give you steering and
> > dedicated access to the RX rings.  In those cases, I guess, the "push"
> > model could be a more direct API approach. =20
>=20
> If the hardware does not support steering then one should be able to
> provide those services in software.

This is the early demux problem.  With the push-mode of registering
memory, you need hardware steering support, for zero-copy support, as
the software step happens after DMA engine have written into the memory.

My model pre-VMA map all the pages in the RX ring (if zero-copy gets
enabled, by a single user).  The software step can filter and zero-copy
send packet-pages to the application/socket that requested this. The
disadvantage is all zero-copy application need to share this VMA
mapping.  This is solved by configuring HW filters into a RX-queue, and
then only attach your zero-copy application to that queue.


> > I was shooting for a model that worked without hardware support.
> > And then transparently benefit from HW support by configuring a HW
> > filter into a specific RX queue and attaching/using to that queue. =20
>=20
> The discussion here is a bit amusing since these issues have been
> resolved a long time ago with the design of the RDMA subsystem. Zero
> copy is already in wide use. Memory registration is used to pin down
> memory areas. Work requests can be filed with the RDMA subsystem that
> then send and receive packets from the registered memory regions.
> This is not strictly remote memory access but this is a basic mode of
> operations supported  by the RDMA subsystem. The mlx5 driver quoted
> here supports all of that.

I hear what you are saying.  I will look into a push-model, as it might
be a better solution.
 I will read up on RDMA + verbs and learn more about their API model.  I
even plan to write a small sample program to get a feeling for the API,
and maybe we can use that as a baseline for the performance target we
can obtain on the same HW. (Thanks to Bj=C3=B6rn for already giving me some
pointer here)


> What is bad about RDMA is that it is a separate kernel subsystem.
> What I would like to see is a deeper integration with the network
> stack so that memory regions can be registred with a network socket
> and work requests then can be submitted and processed that directly
> read and write in these regions. The network stack should provide the
> services that the hardware of the NIC does not suppport as usual.

Interesting.  So you even imagine sockets registering memory regions
with the NIC.  If we had a proper NIC HW filter API across the drivers,
to register the steering rule (like ibv_create_flow), this would be
doable, but we don't (DPDK actually have an interesting proposal[1])

=20
> The RX/TX ring in user space should be an additional mode of
> operation of the socket layer. Once that is in place the "Remote
> memory acces" can be trivially implemented on top of that and the
> ugly RDMA sidecar subsystem can go away.
=20
I cannot follow that 100%, but I guess you are saying we also need a
more efficient mode of handing over pages/packet to userspace (than
going through the normal socket API calls).


Appreciate your input, it challenged my thinking.
--=20
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer

[1] https://rawgit.com/6WIND/rte_flow/master/rte_flow.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
