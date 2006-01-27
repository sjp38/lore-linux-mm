Received: by uproxy.gmail.com with SMTP id q2so290717uge
        for <linux-mm@kvack.org>; Fri, 27 Jan 2006 07:36:39 -0800 (PST)
Message-ID: <58d0dbf10601270736o3381d4fbt@mail.gmail.com>
Date: Fri, 27 Jan 2006 16:36:39 +0100
From: Jan Kiszka <jan.kiszka@googlemail.com>
Subject: Re: [patch 0/9] Critical Mempools
In-Reply-To: <43D968E4.5020300@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
References: <1138217992.2092.0.camel@localhost.localdomain>
	 <Pine.LNX.4.62.0601260954540.15128@schroedinger.engr.sgi.com>
	 <43D954D8.2050305@us.ibm.com>
	 <Pine.LNX.4.62.0601261516160.18716@schroedinger.engr.sgi.com>
	 <43D95BFE.4010705@us.ibm.com> <20060127000304.GG10409@kvack.org>
	 <43D968E4.5020300@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Dobson <colpatch@us.ibm.com>
Cc: Benjamin LaHaise <bcrl@kvack.org>, Christoph Lameter <clameter@engr.sgi.com>, linux-kernel@vger.kernel.org, sri@us.ibm.com, andrea@suse.de, pavel@suse.cz, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

2006/1/27, Matthew Dobson <colpatch@us.ibm.com>:

> The impetus for this work was getting this functionality into the
> networking stack, to keep the network alive under periods of extreme VM
> pressure.  Keeping track of 'criticalness' on a per-socket basis is good,
> but the problem is the receive side.  Networking packets are received and
> put into skbuffs before there is any concept of what socket they belong to.
>  So to really handle incoming traffic under extreme memory pressure would
> require something beyond just a per-socket flag.

Maybe as an interesting lecture you want study how we handle this in
the deterministic network stack RTnet (www.rtnet.org): exchange full
with empty (rt-)skbs between per-user packet pools. Every packet
producer or consumer (socket, NIC, in-kernel networking service) has
its own pool of pre-allocated, fixed-sized packets. Incoming packets
are first stored at the expense of the NIC. But as soon as the real
receiver is known, that one has to pass over an empty buffer in order
to get the full one. Otherwise, the packet is dropped. Kind of hard
policy, but it prevents any local user from starving the system with
respect to skbs. Additionally for full determinism, remote users have
to be controlled via bandwidth management (to avoid exhausting the
NIC's pool), in our case a TDMA mechanism.

I'm not suggesting that this is something easy to adopt into a general
purpose networking stack (this is /one/ reason why we maintain a
separate project for it). But maybe the concept can inspire something
in this direction. Would be funny to have "native" RTnet in the kernel
one day :). Separate memory pools for critical allocations is an
interesting step that may help us as well.

Jan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
