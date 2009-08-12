Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 151D86B005A
	for <linux-mm@kvack.org>; Wed, 12 Aug 2009 10:03:55 -0400 (EDT)
Date: Wed, 12 Aug 2009 17:02:24 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCHv2 0/2] vhost: a kernel-level virtio server
Message-ID: <20090812140224.GA29345@redhat.com>
References: <20090811212743.GA26309@redhat.com> <200908121452.01802.arnd@arndb.de> <20090812130612.GC29200@redhat.com> <200908121540.44928.arnd@arndb.de> <4A82C8F1.4030703@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4A82C8F1.4030703@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Gregory Haskins <gregory.haskins@gmail.com>
Cc: Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, hpa@zytor.com, Patrick Mullaney <pmullaney@novell.com>
List-ID: <linux-mm.kvack.org>

On Wed, Aug 12, 2009 at 09:51:45AM -0400, Gregory Haskins wrote:
> Arnd Bergmann wrote:
> > On Wednesday 12 August 2009, Michael S. Tsirkin wrote:
> >>> If I understand it correctly, you can at least connect a veth pair
> >>> to a bridge, right? Something like
> >>>
> >>>            veth0 - veth1 - vhost - guest 1 
> >>> eth0 - br0-|
> >>>            veth2 - veth3 - vhost - guest 2
> >>>            
> >> Heh, you don't need a bridge in this picture:
> >>
> >> guest 1 - vhost - veth0 - veth1 - vhost guest 2
> > 
> > Sure, but the setup I described is the one that I would expect
> > to see in practice because it gives you external connectivity.
> > 
> > Measuring two guests communicating over a veth pair is
> > interesting for finding the bottlenecks, but of little
> > practical relevance.
> > 
> > 	Arnd <><
> 
> Yeah, this would be the config I would be interested in.

Hmm, this wouldn't be the config to use for the benchmark though: there
are just too many variables.  If you want both guest to guest and guest
to host, create 2 nics in the guest.

Here's one way to do this:

	-net nic,model=virtio,vlan=0 -net user,vlan=0
	-net nic,vlan=1,model=virtio,vhost=veth0
	-redir tcp:8022::22

	-net nic,model=virtio,vlan=0 -net user,vlan=0
	 -net nic,vlan=1,model=virtio,vhost=veth1
	-redir tcp:8023::22

In guests, for simplicity, configure eth1 and eth0
to use separate subnets.

Long term, I hope macvlan will be extended to support
guest to guest.

> Regards,
> -Greg
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
