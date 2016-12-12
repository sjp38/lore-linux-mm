Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 015836B0267
	for <linux-mm@kvack.org>; Mon, 12 Dec 2016 13:08:08 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id 81so199609360iog.0
        for <linux-mm@kvack.org>; Mon, 12 Dec 2016 10:08:07 -0800 (PST)
Received: from resqmta-ch2-03v.sys.comcast.net (resqmta-ch2-03v.sys.comcast.net. [69.252.207.35])
        by mx.google.com with ESMTPS id u63si31560155ioi.37.2016.12.12.10.08.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Dec 2016 10:08:07 -0800 (PST)
Date: Mon, 12 Dec 2016 12:06:59 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Designing a safe RX-zero-copy Memory Model for Networking
In-Reply-To: <20161212181344.3ddfa9c3@redhat.com>
Message-ID: <alpine.DEB.2.20.1612121200280.13607@east.gentwo.org>
References: <20161205153132.283fcb0e@redhat.com> <20161212083812.GA19987@rapoport-lnx> <20161212104042.0a011212@redhat.com> <20161212141433.GB19987@rapoport-lnx> <584EB8DF.8000308@gmail.com> <20161212181344.3ddfa9c3@redhat.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: John Fastabend <john.fastabend@gmail.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Willem de Bruijn <willemdebruijn.kernel@gmail.com>, =?ISO-8859-15?Q?Bj=F6rn_T=F6pel?= <bjorn.topel@intel.com>, "Karlsson, Magnus" <magnus.karlsson@intel.com>, Alexander Duyck <alexander.duyck@gmail.com>, Mel Gorman <mgorman@techsingularity.net>, Tom Herbert <tom@herbertland.com>, Brenden Blanco <bblanco@plumgrid.com>, Tariq Toukan <tariqt@mellanox.com>, Saeed Mahameed <saeedm@mellanox.com>, Jesse Brandeburg <jesse.brandeburg@intel.com>, Kalman Meth <METH@il.ibm.com>, Vladislav Yasevich <vyasevich@gmail.com>

On Mon, 12 Dec 2016, Jesper Dangaard Brouer wrote:

> Hmmm. If you can rely on hardware setup to give you steering and
> dedicated access to the RX rings.  In those cases, I guess, the "push"
> model could be a more direct API approach.

If the hardware does not support steering then one should be able to
provide those services in software.

> I was shooting for a model that worked without hardware support.  And
> then transparently benefit from HW support by configuring a HW filter
> into a specific RX queue and attaching/using to that queue.

The discussion here is a bit amusing since these issues have been resolved
a long time ago with the design of the RDMA subsystem. Zero copy is
already in wide use. Memory registration is used to pin down memory areas.
Work requests can be filed with the RDMA subsystem that then send and
receive packets from the registered memory regions. This is not strictly
remote memory access but this is a basic mode of operations supported  by
the RDMA subsystem. The mlx5 driver quoted here supports all of that.

What is bad about RDMA is that it is a separate kernel subsystem. What I
would like to see is a deeper integration with the network stack so that
memory regions can be registred with a network socket and work requests
then can be submitted and processed that directly read and write in these
regions. The network stack should provide the services that the hardware
of the NIC does not suppport as usual.

The RX/TX ring in user space should be an additional mode of operation of
the socket layer. Once that is in place the "Remote memory acces" can be
trivially implemented on top of that and the ugly RDMA sidecar subsystem
can go away.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
