Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 781E66B007E
	for <linux-mm@kvack.org>; Mon, 25 Apr 2016 09:17:25 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id x7so410758742qkd.2
        for <linux-mm@kvack.org>; Mon, 25 Apr 2016 06:17:25 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i107si9307qgf.80.2016.04.25.06.17.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Apr 2016 06:17:24 -0700 (PDT)
Date: Mon, 25 Apr 2016 14:17:18 +0100
From: "Dr. David Alan Gilbert" <dgilbert@redhat.com>
Subject: Re: [PATCH kernel 0/2] speed up live migration by skipping free pages
Message-ID: <20160425131718.GA3381@work-vm>
References: <1461076474-3864-1-git-send-email-liang.z.li@intel.com>
 <20160425060641.GC4735@grmbl.mre>
 <20160425135642-mutt-send-email-mst@redhat.com>
 <20160425120830.GD4735@grmbl.mre>
 <20160425154452-mutt-send-email-mst@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160425154452-mutt-send-email-mst@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Amit Shah <amit.shah@redhat.com>, Liang Li <liang.z.li@intel.com>, viro@zeniv.linux.org.uk, linux-kernel@vger.kernel.org, quintela@redhat.com, pbonzini@redhat.com, linux-mm@kvack.org, kvm@vger.kernel.org, qemu-devel@nongnu.org, agraf@suse.de, borntraeger@de.ibm.com

* Michael S. Tsirkin (mst@redhat.com) wrote:
> On Mon, Apr 25, 2016 at 05:38:30PM +0530, Amit Shah wrote:
> > On (Mon) 25 Apr 2016 [14:04:06], Michael S. Tsirkin wrote:
> > > On Mon, Apr 25, 2016 at 11:36:41AM +0530, Amit Shah wrote:
> > > > On (Tue) 19 Apr 2016 [22:34:32], Liang Li wrote:
> > > > > Current QEMU live migration implementation mark all guest's RAM pages
> > > > > as dirtied in the ram bulk stage, all these pages will be processed
> > > > > and it consumes quite a lot of CPU cycles and network bandwidth.
> > > > > 
> > > > > From guest's point of view, it doesn't care about the content in free
> > > > > page. We can make use of this fact and skip processing the free
> > > > > pages, this can save a lot CPU cycles and reduce the network traffic
> > > > > significantly while speed up the live migration process obviously.
> > > > > 
> > > > > This patch set is the kernel side implementation.
> > > > > 
> > > > > The virtio-balloon driver is extended to send the free page bitmap
> > > > > from guest to QEMU.
> > > > > 
> > > > > After getting the free page bitmap, QEMU can use it to filter out
> > > > > guest's free pages. This make the live migration process much more
> > > > > efficient.
> > > > > 
> > > > > In order to skip more free pages, we add an interface to let the user
> > > > > decide whether dropping the cache in guest during live migration.
> > > > 
> > > > So if virtio-balloon is the way to go (i.e. speed is acceptable), I
> > > > just have one point then.  My main concern with using (or not using)
> > > > virtio-balloon was that a guest admin is going to disable the
> > > > virtio-balloon driver entirely because the admin won't want the guest
> > > > to give away pages to the host, esp. when the guest is to be a
> > > > high-performant one.
> > > 
> > > The result will be the reverse of high-performance.
> > > 
> > > If you don't want to inflate a balloon, don't.
> > > 
> > > If you do but guest doesn't respond to inflate requests,
> > > it's quite reasonable for host to kill it -
> > > there is no way to distinguish between that and
> > > guest being malicious.
> > 
> > With the new command I'm suggesting, the guest will let the host know
> > that it has enabled this option, and it won't free up any RAM for the
> > host.
> > 
> > Also, just because a guest doesn't release some memory (which the
> > guest owns anyway) doesn't make it malicious, and killing such guests
> > is never going to end well for that hosting provider.
> > 
> > > I don't know of management tools doing that but
> > > it's rather reasonable. What does happen is
> > > some random guest memory is pushed it out to swap,
> > > which is likely much worse than dropping unused memory
> > > by moving it into the balloon.
> > 
> > Even if the host (admin) gave a guarantee that there won't be any
> > ballooning activity involved that will slow down the guest, a guest
> > admin can be paranoid enough to disable ballooning.  If, however, this
> > is made known to the host, it's likely a win-win situation because the
> > host knows the guest needs its RAM, and the guest can still use the
> > driver to send stats which the host can use during migration for
> > speedups.
> > 
> > 
> > 		Amit
> 
> We'd need to understand the usecase better to design a good interface
> for this. AFAIK the normal usecase for ballooning is for
> memory overcommit: asking guest to free up memory might work
> better than swap which makes host initiate a bunch of IO.
> How is not inflating in this case a good idea?
> I'm afraid I don't understand why was inflating balloon
> requested if we do not want the guest to inflate the balloon.  What does
> "paranoid" mean in this context?  This seems to imply some kind of
> security concern. Is guest likely to need all of its memory or a
> specific portion of it? Is it likely to be a static configuration or a
> dynamic one? If dynamic, does guest also want to avoid deflating the
> balloon or only inflating it?

The semantics we want here are subtly different from ballooning;

  a) In ballooning the host is asking for the guest to give up some ram;
     that's not quite the case here - although if the guest dropped some
     caches that *might* be helpful.
  b) In ballooning we're interested in just amounts of free memory; here
     we care about _which_ pages are free.
  c) We don't want to make it hard for the guest to start using some of the
     memory again; if it was hard then we suddenly get back into a balancing
     act of needing to quantatively talk about how much free RAM we have,
     and worry about whether we shouldn't tell the host about a small pot
     we keep back etc.

Dave

> -- 
> MST
--
Dr. David Alan Gilbert / dgilbert@redhat.com / Manchester, UK

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
