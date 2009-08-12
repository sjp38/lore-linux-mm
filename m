Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 613146B0055
	for <linux-mm@kvack.org>; Wed, 12 Aug 2009 08:07:13 -0400 (EDT)
Date: Wed, 12 Aug 2009 15:05:41 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCHv2 0/2] vhost: a kernel-level virtio server
Message-ID: <20090812120541.GA29158@redhat.com>
References: <20090811212743.GA26309@redhat.com> <4A820391.1090404@gmail.com> <20090812071636.GA26847@redhat.com> <4A82ADD5.6040909@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4A82ADD5.6040909@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Gregory Haskins <gregory.haskins@gmail.com>
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, "akpm@linux-foundation.org >> Andrew Morton" <akpm@linux-foundation.org>, hpa@zytor.com, Patrick Mullaney <pmullaney@novell.com>
List-ID: <linux-mm.kvack.org>

On Wed, Aug 12, 2009 at 07:56:05AM -0400, Gregory Haskins wrote:
> Michael S. Tsirkin wrote:
> > On Tue, Aug 11, 2009 at 07:49:37PM -0400, Gregory Haskins wrote:
> >> Michael S. Tsirkin wrote:
> >>> This implements vhost: a kernel-level backend for virtio,
> >>> The main motivation for this work is to reduce virtualization
> >>> overhead for virtio by removing system calls on data path,
> >>> without guest changes. For virtio-net, this removes up to
> >>> 4 system calls per packet: vm exit for kick, reentry for kick,
> >>> iothread wakeup for packet, interrupt injection for packet.
> >>>
> >>> Some more detailed description attached to the patch itself.
> >>>
> >>> The patches are against 2.6.31-rc4.  I'd like them to go into linux-next
> >>> and down the road 2.6.32 if possible.  Please comment.
> >> I will add this series to my benchmark run in the next day or so.  Any
> >> specific instructions on how to set it up and run?
> >>
> >> Regards,
> >> -Greg
> >>
> > 
> > 1. use a dedicated network interface with SRIOV, program mac to match
> >    that of guest (for testing, you can set promisc mode, but that is
> >    bad for performance)
> 
> Are you saying SRIOV is a requirement, and I can either program the
> SRIOV adapter with a mac or use promis?  Or are you saying I can use
> SRIOV+programmed mac OR a regular nic + promisc (with a perf penalty).

SRIOV is not a requirement. And you can also use a dedicated
nic+programmed mac if you are so inclined.

> > 2. disable tso,gso,lro with ethtool
> 
> Out of curiosity, wouldnt you only need to disable LRO on the adapter,
> since the other two (IIUC) are transmit path and are therefore
> influenced by the skb's you generate in vhost?

Hmm, makes sense. I'll check this and let you know.

> 
> > 3. add vhost=ethX
> 
> You mean via "ip link" I assume?

No, that's a new flag for virtio in qemu:

-net nic,model=virtio,vhost=veth0

> Regards,
> -Greg
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
