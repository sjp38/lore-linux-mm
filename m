Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 03A766B0005
	for <linux-mm@kvack.org>; Tue, 30 Jan 2018 18:44:27 -0500 (EST)
Received: by mail-oi0-f70.google.com with SMTP id u6so8093512oiv.21
        for <linux-mm@kvack.org>; Tue, 30 Jan 2018 15:44:26 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r83si586297oie.203.2018.01.30.15.44.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jan 2018 15:44:25 -0800 (PST)
Date: Wed, 31 Jan 2018 01:44:14 +0200
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [virtio-dev] Re: [PATCH v25 2/2] virtio-balloon:
 VIRTIO_BALLOON_F_FREE_PAGE_HINT
Message-ID: <20180131011423-mutt-send-email-mst@kernel.org>
References: <1516871646-22741-1-git-send-email-wei.w.wang@intel.com>
 <1516871646-22741-3-git-send-email-wei.w.wang@intel.com>
 <20180125154708-mutt-send-email-mst@kernel.org>
 <5A6A871C.6040408@intel.com>
 <20180126042649-mutt-send-email-mst@kernel.org>
 <5A6AA107.3000607@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5A6AA107.3000607@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org, akpm@linux-foundation.org, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, riel@redhat.com

On Fri, Jan 26, 2018 at 11:31:19AM +0800, Wei Wang wrote:
> On 01/26/2018 10:42 AM, Michael S. Tsirkin wrote:
> > On Fri, Jan 26, 2018 at 09:40:44AM +0800, Wei Wang wrote:
> > > On 01/25/2018 09:49 PM, Michael S. Tsirkin wrote:
> > > > On Thu, Jan 25, 2018 at 05:14:06PM +0800, Wei Wang wrote:
> > > > 
> 
> > > The controversy is that the free list is not static
> > > once the lock is dropped, so everything is dynamically changing, including
> > > the state that was recorded. The method we are using is more prudent, IMHO.
> > > How about taking the fundamental solution, and seek to improve incrementally
> > > in the future?
> > > 
> > > 
> > > Best,
> > > Wei
> > I'd like to see kicks happen outside the spinlock. kick with a spinlock
> > taken looks like a scalability issue that won't be easy to
> > reproduce but hurt workloads at random unexpected times.
> > 
> 
> Is that "kick inside the spinlock" the only concern you have? I think we can
> remove the kick actually. If we check how the host side works, it is
> worthwhile to let the host poll the virtqueue after it receives the cmd id
> from the guest (kick for cmd id isn't within the lock).
> 
> 
> Best,
> Wei

So really there are different ways to put free page hints to use.

The current interface requires host to do dirty tracking
for all memory, and it's more or less useless for
things like freeing host memory.

So while your project's needs seem to be addressed, I'm
still a bit disappointed that so little collaboration
happened with e.g. Nitesh's project, to the point where
you don't even CC him on patches.

So I'm kind of trying to bridge this a bit - I would
like the interfaces that we build to at least superficially
look like they might be reusable for other uses of hinting.

Imagine that you don't have dirty tracking on the host.
What would it take to still use hinting information,
e.g. to call MADV_FREE on the pages guest gives us?

I think you need to kick and you need to wait for
host to consume the hint before page is reused.
And we know madvise takes a lot of time sometimes,
so locking out the free list does not sound like a
good idea.

That's why I was talking about kick out of lock,
so that eventually we can reuse that for hinting
and actually wait for an interrupt.

So how about we take a bunch of pages out of the free list, move them to
the balloon, kick (and optionally wait for host to consume), them move
them back? Preferably to end of the list? This will also make things
like sorting them much easier as you can just put them in a binary tree
or something.

For when we need to be careful to make sure we don't
create an OOM situation with this out of thin air,
and for when you can't give everything to host in one go,
you might want some kind of notifier that tells you
that you need to return pages to the free list ASAP.

How'd this sound?

-- 
MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
