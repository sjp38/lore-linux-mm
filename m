Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 1ABC16B004D
	for <linux-mm@kvack.org>; Thu, 24 Sep 2009 15:27:48 -0400 (EDT)
Date: Thu, 24 Sep 2009 12:27:54 -0700
From: "Ira W. Snyder" <iws@ovro.caltech.edu>
Subject: Re: [PATCHv5 3/3] vhost_net: a kernel-level virtio server
Message-ID: <20090924192754.GA14341@ovro.caltech.edu>
References: <4AB1A8FD.2010805@gmail.com>
 <20090921214312.GJ7182@ovro.caltech.edu>
 <4AB89C48.4020903@redhat.com>
 <4ABA3005.60905@gmail.com>
 <4ABA32AF.50602@redhat.com>
 <4ABA3A73.5090508@gmail.com>
 <4ABA61D1.80703@gmail.com>
 <4ABA78DC.7070604@redhat.com>
 <4ABA8FDC.5010008@gmail.com>
 <4ABB1D44.5000007@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4ABB1D44.5000007@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: Gregory Haskins <gregory.haskins@gmail.com>, "Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, Rusty Russell <rusty@rustcorp.com.au>, s.hetze@linux-ag.com, alacrityvm-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On Thu, Sep 24, 2009 at 10:18:28AM +0300, Avi Kivity wrote:
> On 09/24/2009 12:15 AM, Gregory Haskins wrote:
> >
> >>> There are various aspects about designing high-performance virtual
> >>> devices such as providing the shortest paths possible between the
> >>> physical resources and the consumers.  Conversely, we also need to
> >>> ensure that we meet proper isolation/protection guarantees at the same
> >>> time.  What this means is there are various aspects to any
> >>> high-performance PV design that require to be placed in-kernel to
> >>> maximize the performance yet properly isolate the guest.
> >>>
> >>> For instance, you are required to have your signal-path (interrupts and
> >>> hypercalls), your memory-path (gpa translation), and
> >>> addressing/isolation model in-kernel to maximize performance.
> >>>
> >>>        
> >> Exactly.  That's what vhost puts into the kernel and nothing more.
> >>      
> > Actually, no.  Generally, _KVM_ puts those things into the kernel, and
> > vhost consumes them.  Without KVM (or something equivalent), vhost is
> > incomplete.  One of my goals with vbus is to generalize the "something
> > equivalent" part here.
> >    
> 
> I don't really see how vhost and vbus are different here.  vhost expects 
> signalling to happen through a couple of eventfds and requires someone 
> to supply them and implement kernel support (if needed).  vbus requires 
> someone to write a connector to provide the signalling implementation.  
> Neither will work out-of-the-box when implementing virtio-net over 
> falling dominos, for example.
> 
> >>> Vbus accomplishes its in-kernel isolation model by providing a
> >>> "container" concept, where objects are placed into this container by
> >>> userspace.  The host kernel enforces isolation/protection by using a
> >>> namespace to identify objects that is only relevant within a specific
> >>> container's context (namely, a "u32 dev-id").  The guest addresses the
> >>> objects by its dev-id, and the kernel ensures that the guest can't
> >>> access objects outside of its dev-id namespace.
> >>>
> >>>        
> >> vhost manages to accomplish this without any kernel support.
> >>      
> > No, vhost manages to accomplish this because of KVMs kernel support
> > (ioeventfd, etc).   Without a KVM-like in-kernel support, vhost is a
> > merely a kind of "tuntap"-like clone signalled by eventfds.
> >    
> 
> Without a vbus-connector-falling-dominos, vbus-venet can't do anything 
> either.  Both vhost and vbus need an interface, vhost's is just narrower 
> since it doesn't do configuration or enumeration.
> 
> > This goes directly to my rebuttal of your claim that vbus places too
> > much in the kernel.  I state that, one way or the other, address decode
> > and isolation _must_ be in the kernel for performance.  Vbus does this
> > with a devid/container scheme.  vhost+virtio-pci+kvm does it with
> > pci+pio+ioeventfd.
> >    
> 
> vbus doesn't do kvm guest address decoding for the fast path.  It's 
> still done by ioeventfd.
> 
> >>   The guest
> >> simply has not access to any vhost resources other than the guest->host
> >> doorbell, which is handed to the guest outside vhost (so it's somebody
> >> else's problem, in userspace).
> >>      
> > You mean _controlled_ by userspace, right?  Obviously, the other side of
> > the kernel still needs to be programmed (ioeventfd, etc).  Otherwise,
> > vhost would be pointless: e.g. just use vanilla tuntap if you don't need
> > fast in-kernel decoding.
> >    
> 
> Yes (though for something like level-triggered interrupts we're probably 
> keeping it in userspace, enjoying the benefits of vhost data path while 
> paying more for signalling).
> 
> >>> All that is required is a way to transport a message with a "devid"
> >>> attribute as an address (such as DEVCALL(devid)) and the framework
> >>> provides the rest of the decode+execute function.
> >>>
> >>>        
> >> vhost avoids that.
> >>      
> > No, it doesn't avoid it.  It just doesn't specify how its done, and
> > relies on something else to do it on its behalf.
> >    
> 
> That someone else can be in userspace, apart from the actual fast path.
> 
> > Conversely, vbus specifies how its done, but not how to transport the
> > verb "across the wire".  That is the role of the vbus-connector abstraction.
> >    
> 
> So again, vbus does everything in the kernel (since it's so easy and 
> cheap) but expects a vbus-connector.  vhost does configuration in 
> userspace (since it's so clunky and fragile) but expects a couple of 
> eventfds.
> 
> >>> Contrast this to vhost+virtio-pci (called simply "vhost" from here).
> >>>
> >>>        
> >> It's the wrong name.  vhost implements only the data path.
> >>      
> > Understood, but vhost+virtio-pci is what I am contrasting, and I use
> > "vhost" for short from that point on because I am too lazy to type the
> > whole name over and over ;)
> >    
> 
> If you #define A A+B+C don't expect intelligent conversation afterwards.
> 
> >>> It is not immune to requiring in-kernel addressing support either, but
> >>> rather it just does it differently (and its not as you might expect via
> >>> qemu).
> >>>
> >>> Vhost relies on QEMU to render PCI objects to the guest, which the guest
> >>> assigns resources (such as BARs, interrupts, etc).
> >>>        
> >> vhost does not rely on qemu.  It relies on its user to handle
> >> configuration.  In one important case it's qemu+pci.  It could just as
> >> well be the lguest launcher.
> >>      
> > I meant vhost=vhost+virtio-pci here.  Sorry for the confusion.
> >
> > The point I am making specifically is that vhost in general relies on
> > other in-kernel components to function.  I.e. It cannot function without
> > having something like the PCI model to build an IO namespace.  That
> > namespace (in this case, pio addresses+data tuples) are used for the
> > in-kernel addressing function under KVM + virtio-pci.
> >
> > The case of the lguest launcher is a good one to highlight.  Yes, you
> > can presumably also use lguest with vhost, if the requisite facilities
> > are exposed to lguest-bus, and some eventfd based thing like ioeventfd
> > is written for the host (if it doesnt exist already).
> >
> > And when the next virt design "foo" comes out, it can make a "foo-bus"
> > model, and implement foo-eventfd on the backend, etc, etc.
> >    
> 
> It's exactly the same with vbus needing additional connectors for 
> additional transports.
> 
> > Ira can make ira-bus, and ira-eventfd, etc, etc.
> >
> > Each iteration will invariably introduce duplicated parts of the stack.
> >    
> 
> Invariably?  Use libraries (virtio-shmem.ko, libvhost.so).
> 

Referencing libraries that don't yet exist doesn't seem like a good
argument against vbus from my point of view. I'm not speficially
advocating for vbus; I'm just letting you know how it looks to another
developer in the trenches.

If you'd like to see the amount of duplication present, look at the code
I'm currently working on. It mostly works at this point, though I
haven't finished my userspace, nor figured out how to actually transfer
data.

The current question I have (just to let you know where I am in
development) is:

I have the physical address of the remote data, but how do I get it into
a userspace buffer, so I can pass it to tun?

http://www.mmarray.org/~iws/virtio-phys/

Ira

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
