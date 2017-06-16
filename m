Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 34B79832A3
	for <linux-mm@kvack.org>; Fri, 16 Jun 2017 16:19:55 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id w1so42557343qtg.6
        for <linux-mm@kvack.org>; Fri, 16 Jun 2017 13:19:55 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q7si2886620qta.248.2017.06.16.13.19.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Jun 2017 13:19:54 -0700 (PDT)
Date: Fri, 16 Jun 2017 23:19:49 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC] virtio-mem: paravirtualized memory
Message-ID: <20170616231036-mutt-send-email-mst@kernel.org>
References: <547865a9-d6c2-7140-47e2-5af01e7d761d@redhat.com>
 <20170616175748-mutt-send-email-mst@kernel.org>
 <4cdf547c-079b-6b44-484f-e1132e960364@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4cdf547c-079b-6b44-484f-e1132e960364@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: KVM <kvm@vger.kernel.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>

On Fri, Jun 16, 2017 at 05:59:07PM +0200, David Hildenbrand wrote:
> On 16.06.2017 17:04, Michael S. Tsirkin wrote:
> > On Fri, Jun 16, 2017 at 04:20:02PM +0200, David Hildenbrand wrote:
> >> Hi,
> >>
> >> this is an idea that is based on Andrea Arcangeli's original idea to
> >> host enforce guest access to memory given up using virtio-balloon using
> >> userfaultfd in the hypervisor. While looking into the details, I
> >> realized that host-enforcing virtio-balloon would result in way too many
> >> problems (mainly backwards compatibility) and would also have some
> >> conceptual restrictions that I want to avoid. So I developed the idea of
> >> virtio-mem - "paravirtualized memory".
> > 
> > Thanks! I went over this quickly, will read some more in the
> > coming days. I would like to ask for some clarifications
> > on one part meanwhile:
> 
> Thanks for looking into it that fast! :)
> 
> In general, what this section is all about: Why to not simply host
> enforce virtio-balloon.
> > 
> >> Q: Why not reuse virtio-balloon?
> >>
> >> A: virtio-balloon is for cooperative memory management. It has a fixed
> >>    page size
> > 
> > We are fixing that with VIRTIO_BALLOON_F_PAGE_CHUNKS btw.
> > I would appreciate you looking into that patchset.
> 
> Will do, thanks. Problem is that there is no "enforcement" on the page
> size. VIRTIO_BALLOON_F_PAGE_CHUNKS simply allows to send bigger chunks.
> Nobody hinders the guest (especially legacy virtio-balloon drivers) from
> sending 4k pages.
> 
> So this doesn't really fix the issue (we have here), it just allows to
> speed up transfer. Which is a good thing, but does not help for
> enforcement at all. So, yes support for page sizes > 4k, but no way to
> enforce it.
> 
> > 
> >> and will deflate in certain situations.
> > 
> > What does this refer to?
> 
> A Linux guest will deflate the balloon (all or some pages) in the
> following scenarios:
> a) page migration

It inflates it first, doesn't it?

> b) unload virtio-balloon kernel module
> c) hibernate/suspension
> d) (DEFLATE_ON_OOM)

You need to set a flag in the balloon to allow this, right?

> A Linux guest will touch memory without deflating:
> a) During a kexec() dump
> d) On reboots (regular, after kexec(), system_reset)
> > 
> >> Any change we
> >>    introduce will break backwards compatibility.
> > 
> > Why does this have to be the case
> If we suddenly enforce the existing virtio-balloon, we will break legacy
> guests.

Can't we do it with a feature flag?

> Simple example:
> Guest with inflated virtio-balloon reboots. Touches inflated memory.
> Gets killed at some random point.
> 
> Of course, another discussion would be "can't we move virtio-mem
> functionality into virtio-balloon instead of changing virtio-balloon".
> With the current concept this is also not possible (one region per
> device vs. one virtio-balloon device). And I think while similar, these
> are two different concepts.
> 
> > 
> >> virtio-balloon was not
> >>    designed to give guarantees. Nobody can hinder the guest from
> >>    deflating/reusing inflated memory.
> > 
> > Reusing without deflate is forbidden with TELL_HOST, right?
> 
> TELL_HOST just means "please inform me". There is no way to NACK a
> request. It is not a permission to do so, just a "friendly
> notification". And this is exactly not what we want when host enforcing
> memory access.
> 
> 
> > 
> >>    In addition, it might make perfect
> >>    sense to have both, virtio-balloon and virtio-mem at the same time,
> >>    especially looking at the DEFLATE_ON_OOM or STATS features of
> >>    virtio-balloon. While virtio-mem is all about guarantees, virtio-
> >>    balloon is about cooperation.
> > 
> > Thanks, and I intend to look more into this next week.
> > 
> 
> I know that it is tempting to force this concept into virtio-balloon. I
> spent quite some time thinking about this (and possible other techniques
> like implicit memory deflation on reboots) and decided not to do it. We
> just end up trying to hack around all possible things that could go
> wrong, while still not being able to handle all requirements properly.

I agree there's a large # of requirements here not addressed by the balloon.

One other thing that would be helpful here is pointing out the
similarities between virtio-mem and the balloon. I'll ponder it
over the weekend.

The biggest worry for me is inability to support DMA into this memory.
Is this hard to fix?


Thanks!



> -- 
> 
> Thanks,
> 
> David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
