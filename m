Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id A3B946B009E
	for <linux-mm@kvack.org>; Fri, 21 Aug 2009 11:39:50 -0400 (EDT)
Received: from int-mx04.intmail.prod.int.phx2.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.17])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id n7LFdqO9013924
	for <linux-mm@kvack.org>; Fri, 21 Aug 2009 11:39:52 -0400
Date: Fri, 21 Aug 2009 16:20:22 +0300
From: Gleb Natapov <gleb@redhat.com>
Subject: Re: [PATCHv3 2/2] vhost_net: a kernel-level virtio server
Message-ID: <20090821132022.GA6966@redhat.com>
References: <cover.1250187913.git.mst@redhat.com>
 <200908191727.07681.arnd@arndb.de>
 <20090820083155.GB5448@redhat.com>
 <200908201510.54482.arnd@arndb.de>
 <20090820133817.GA7834@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090820133817.GA7834@redhat.com>
Sender: owner-linux-mm@kvack.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Arnd Bergmann <arnd@arndb.de>, virtualization@lists.linux-foundation.org, netdev@vger.kernel.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, gregory.haskins@gmail.com, Or Gerlitz <ogerlitz@voltaire.com>
List-ID: <linux-mm.kvack.org>

On Thu, Aug 20, 2009 at 04:38:17PM +0300, Michael S. Tsirkin wrote:
> On Thu, Aug 20, 2009 at 03:10:54PM +0200, Arnd Bergmann wrote:
> > On Thursday 20 August 2009, Michael S. Tsirkin wrote:
> > > On Wed, Aug 19, 2009 at 05:27:07PM +0200, Arnd Bergmann wrote:
> > > > On Wednesday 19 August 2009, Michael S. Tsirkin wrote:
> > > > > On Wed, Aug 19, 2009 at 03:46:44PM +0200, Arnd Bergmann wrote:
> > > > > > On Wednesday 19 August 2009, Michael S. Tsirkin wrote:
> > > > > >
> > > > > > Leaving that aside for now, you could replace VHOST_NET_SET_SOCKET,
> > > > > > VHOST_SET_OWNER, VHOST_RESET_OWNER
> > > > > 
> > > > > SET/RESET OWNER is still needed: otherwise if you share a descriptor
> > > > > with another process, it can corrupt your memory.
> > > > 
> > > > How? The point of using user threads is that you only ever access the
> > > > address space of the thread that called the ioctl.
> > > 
> > > Think about this example with processes A and B sharing an fd:
> > > A does SET_USED_ADDRESS
> > > B does SET_USED_ADDRESS
> > > A does VHOST_NET_SPLICE
> > > See how stuff gets written into a random place in memory of A?
> > 
> > Yes, I didn't think of that. It doesn't seem like a big problem
> > though, because it's a clear misuse of the API (I guess your
> > current code returns an error for one of the SET_USED_ADDRESS
> > ioctls), so I would see it as a classic garbage-in garbage-out
> > case.
> > 
> > It may even work in the case that the sharing of the fd resulted
> > from a fork, where the address contains the same buffer in both
> > processes. I can't think of a reason why you would want to use
> > it like that though.
> 
> It doesn't matter that I don't want this: allowing 1 process corrupt
> another's memory is a security issue.  Once you get an fd, you want to
> be able to use it without worrying that a bug in another process will
> crash yours.
> 
If B's SET_USED_ADDRESS fails how one process can corrupt a memory of
other process?

--
			Gleb.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
