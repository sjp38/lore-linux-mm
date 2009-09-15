Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 58C5F6B004D
	for <linux-mm@kvack.org>; Tue, 15 Sep 2009 10:30:31 -0400 (EDT)
Date: Tue, 15 Sep 2009 17:28:21 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCHv5 3/3] vhost_net: a kernel-level virtio server
Message-ID: <20090915142821.GA24488@redhat.com>
References: <20090908172035.GB319@ovro.caltech.edu> <4AAA7415.5080204@gmail.com> <20090913120140.GA31218@redhat.com> <4AAE6A97.7090808@gmail.com> <20090914164750.GB3745@redhat.com> <4AAE961B.6020509@gmail.com> <4AAF8A03.5020806@redhat.com> <4AAF909F.9080306@gmail.com> <4AAF95D1.1080600@redhat.com> <4AAF9BAF.3030109@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4AAF9BAF.3030109@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Gregory Haskins <gregory.haskins@gmail.com>
Cc: Avi Kivity <avi@redhat.com>, "Ira W. Snyder" <iws@ovro.caltech.edu>, netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, Rusty Russell <rusty@rustcorp.com.au>, s.hetze@linux-ag.com, alacrityvm-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On Tue, Sep 15, 2009 at 09:50:39AM -0400, Gregory Haskins wrote:
> Avi Kivity wrote:
> > On 09/15/2009 04:03 PM, Gregory Haskins wrote:
> >>
> >>> In this case the x86 is the owner and the ppc boards use translated
> >>> access.  Just switch drivers and device and it falls into place.
> >>>
> >>>      
> >> You could switch vbus roles as well, I suppose.
> > 
> > Right, there's not real difference in this regard.
> > 
> >> Another potential
> >> option is that he can stop mapping host memory on the guest so that it
> >> follows the more traditional model.  As a bus-master device, the ppc
> >> boards should have access to any host memory at least in the GFP_DMA
> >> range, which would include all relevant pointers here.
> >>
> >> I digress:  I was primarily addressing the concern that Ira would need
> >> to manage the "host" side of the link using hvas mapped from userspace
> >> (even if host side is the ppc boards).  vbus abstracts that access so as
> >> to allow something other than userspace/hva mappings.  OTOH, having each
> >> ppc board run a userspace app to do the mapping on its behalf and feed
> >> it to vhost is probably not a huge deal either.  Where vhost might
> >> really fall apart is when any assumptions about pageable memory occur,
> >> if any.
> >>    
> > 
> > Why?  vhost will call get_user_pages() or copy_*_user() which ought to
> > do the right thing.
> 
> I was speaking generally, not specifically to Ira's architecture.  What
> I mean is that vbus was designed to work without assuming that the
> memory is pageable.  There are environments in which the host is not
> capable of mapping hvas/*page, but the memctx->copy_to/copy_from
> paradigm could still work (think rdma, for instance).

rdma interfaces are typically asynchronous, so blocking
copy_from/copy_to can be made to work, but likely won't work
that well. DMA might work better if it is asynchronous as well.

Assuming a synchronous copy is what we need - maybe the issue is that
there aren't good APIs for x86/ppc communication? If so, sticking them in
vhost might not be the best place.  Maybe the specific platform can
redefine copy_to/from_user to do the right thing? Or, maybe add another
API for that ...

> > 
> >> As an aside: a bigger issue is that, iiuc, Ira wants more than a single
> >> ethernet channel in his design (multiple ethernets, consoles, etc).  A
> >> vhost solution in this environment is incomplete.
> >>    
> > 
> > Why?  Instantiate as many vhost-nets as needed.
> 
> a) what about non-ethernets?

vhost-net actually does not care.
the packet is passed on to a socket, we are done.

> b) what do you suppose this protocol to aggregate the connections would
> look like? (hint: this is what a vbus-connector does).

You are talking about management protocol between ppc and x86, right?
One wonders why does it have to be in kernel at all.

> c) how do you manage the configuration, especially on a per-board basis?

not sure what a board is, but configuration is done in userspace.

-- 
MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
