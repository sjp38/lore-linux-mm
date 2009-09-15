Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id A50A86B004D
	for <linux-mm@kvack.org>; Tue, 15 Sep 2009 11:03:30 -0400 (EDT)
Message-ID: <4AAFACB5.9050808@redhat.com>
Date: Tue, 15 Sep 2009 18:03:17 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCHv5 3/3] vhost_net: a kernel-level virtio server
References: <cover.1251388414.git.mst@redhat.com> <20090827160750.GD23722@redhat.com> <20090903183945.GF28651@ovro.caltech.edu> <20090907101537.GH3031@redhat.com> <20090908172035.GB319@ovro.caltech.edu> <4AAA7415.5080204@gmail.com> <20090913120140.GA31218@redhat.com> <4AAE6A97.7090808@gmail.com> <20090914164750.GB3745@redhat.com> <4AAE961B.6020509@gmail.com> <4AAF8A03.5020806@redhat.com> <4AAF909F.9080306@gmail.com> <4AAF95D1.1080600@redhat.com> <4AAF9BAF.3030109@gmail.com>
In-Reply-To: <4AAF9BAF.3030109@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Gregory Haskins <gregory.haskins@gmail.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, "Ira W. Snyder" <iws@ovro.caltech.edu>, netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, Rusty Russell <rusty@rustcorp.com.au>, s.hetze@linux-ag.com, alacrityvm-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On 09/15/2009 04:50 PM, Gregory Haskins wrote:
>> Why?  vhost will call get_user_pages() or copy_*_user() which ought to
>> do the right thing.
>>      
> I was speaking generally, not specifically to Ira's architecture.  What
> I mean is that vbus was designed to work without assuming that the
> memory is pageable.  There are environments in which the host is not
> capable of mapping hvas/*page, but the memctx->copy_to/copy_from
> paradigm could still work (think rdma, for instance).
>    

Sure, vbus is more flexible here.

>>> As an aside: a bigger issue is that, iiuc, Ira wants more than a single
>>> ethernet channel in his design (multiple ethernets, consoles, etc).  A
>>> vhost solution in this environment is incomplete.
>>>
>>>        
>> Why?  Instantiate as many vhost-nets as needed.
>>      
> a) what about non-ethernets?
>    

There's virtio-console, virtio-blk etc.  None of these have kernel-mode 
servers, but these could be implemented if/when needed.

> b) what do you suppose this protocol to aggregate the connections would
> look like? (hint: this is what a vbus-connector does).
>    

You mean multilink?  You expose the device as a multiqueue.

> c) how do you manage the configuration, especially on a per-board basis?
>    

pci (for kvm/x86).

> Actually I have patches queued to allow vbus to be managed via ioctls as
> well, per your feedback (and it solves the permissions/lifetime
> critisims in alacrityvm-v0.1).
>    

That will make qemu integration easier.

>>   The only difference is the implementation.  vhost-net
>> leaves much more to userspace, that's the main difference.
>>      
> Also,
>
> *) vhost is virtio-net specific, whereas vbus is a more generic device
> model where thing like virtio-net or venet ride on top.
>    

I think vhost-net is separated into vhost and vhost-net.

> *) vhost is only designed to work with environments that look very
> similar to a KVM guest (slot/hva translatable).  vbus can bridge various
> environments by abstracting the key components (such as memory access).
>    

Yes.  virtio is really virtualization oriented.

> *) vhost requires an active userspace management daemon, whereas vbus
> can be driven by transient components, like scripts (ala udev)
>    

vhost by design leaves configuration and handshaking to userspace.  I 
see it as an advantage.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
