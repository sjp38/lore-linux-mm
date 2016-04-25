Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id BBA6C6B007E
	for <linux-mm@kvack.org>; Mon, 25 Apr 2016 06:43:38 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id n83so261406629qkn.0
        for <linux-mm@kvack.org>; Mon, 25 Apr 2016 03:43:38 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f203si10352047qhf.75.2016.04.25.03.43.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Apr 2016 03:43:37 -0700 (PDT)
Date: Mon, 25 Apr 2016 13:43:27 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH kernel 1/2] mm: add the related functions to build the
 free page bitmap
Message-ID: <20160425104327.GA28009@redhat.com>
References: <1461076474-3864-1-git-send-email-liang.z.li@intel.com>
 <1461076474-3864-2-git-send-email-liang.z.li@intel.com>
 <1461077659.3200.8.camel@redhat.com>
 <F2CBF3009FA73547804AE4C663CAB28E04182594@shsmsx102.ccr.corp.intel.com>
 <20160419191111-mutt-send-email-mst@redhat.com>
 <20160422094837.GC2239@work-vm>
 <20160422164936-mutt-send-email-mst@redhat.com>
 <F2CBF3009FA73547804AE4C663CAB28E04185611@shsmsx102.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <F2CBF3009FA73547804AE4C663CAB28E04185611@shsmsx102.ccr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Li, Liang Z" <liang.z.li@intel.com>
Cc: "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Rik van Riel <riel@redhat.com>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "quintela@redhat.com" <quintela@redhat.com>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "agraf@suse.de" <agraf@suse.de>, "borntraeger@de.ibm.com" <borntraeger@de.ibm.com>

On Mon, Apr 25, 2016 at 03:11:05AM +0000, Li, Liang Z wrote:
> > On Fri, Apr 22, 2016 at 10:48:38AM +0100, Dr. David Alan Gilbert wrote:
> > > * Michael S. Tsirkin (mst@redhat.com) wrote:
> > > > On Tue, Apr 19, 2016 at 03:02:09PM +0000, Li, Liang Z wrote:
> > > > > > On Tue, 2016-04-19 at 22:34 +0800, Liang Li wrote:
> > > > > > > The free page bitmap will be sent to QEMU through virtio
> > > > > > > interface and used for live migration optimization.
> > > > > > > Drop the cache before building the free page bitmap can get
> > > > > > > more free pages. Whether dropping the cache is decided by user.
> > > > > > >
> > > > > >
> > > > > > How do you prevent the guest from using those recently-freed
> > > > > > pages for something else, between when you build the bitmap and
> > > > > > the live migration completes?
> > > > >
> > > > > Because the dirty page logging is enabled before building the
> > > > > bitmap, there is no need to prevent the guest from using the recently-
> > freed pages ...
> > > > >
> > > > > Liang
> > > >
> > > > Well one point of telling host that page is free is so that it can
> > > > mark it clean even if it was dirty previously.
> > > > So I think you must pass the pages to guest under the lock.
> > > > This will allow host optimizations such as marking these pages
> > > > MADV_DONTNEED or MADV_FREE.
> > > > Otherwise it's all too tied up to a specific usecase - you aren't
> > > > telling host that a page is free, you are telling it that a page was
> > > > free in the past.
> > >
> > > But doing it under lock sounds pretty expensive, especially given how
> > > long the userspace side is going to take to work through the bitmap
> > > and device what to do.
> > >
> > > Dave
> > 
> > We need to make it as fast as we can since the VCPU is stopped on exit
> > anyway. This just means e.g. sizing the bitmap reasonably - don't always try
> > to fit all memory in a single bitmap.
> 
> Then we should pause the whole VM when using the bitmap, too expensive?

Why should we? I don't get it. Just make sure that at the point
when you give a page to host, it's not in use. Host can clear
the dirty bitmap, discard the page, or whatever.

> > Really, if the page can in fact be in use when you tell host it's free, then it's
> > rather hard to explain what does it mean from host/guest interface point of
> > view.
> > 
> 
> How about rename the interface to a more appropriate name other than 'free page' ?
> 
> Liang.

Maybe. But start with a description.

The way I figured is passing a page to host meant
putting it in the balloon and immediately taking it out
again. this allows things like discarding it since
while page is in the balloon, it is owned by the balloon.

This aligns well with how balloon works today.


If not that, then what can it actually mean?

Without a lock, the only thing we can make it mean
is that the page is in the balloon at some point after
the report is requested and before it's passed to balloon.

This happens to work if you only have one page in the balloon,
but to make it asynchronous you really have to
pass in a request ID, and then return it back
with the bitmap. This way we can say "this
page was free sometime after host sent request
with this ID and before it received response with
the same ID".

And then, what host is supposed to do for pre-copy, copy
the dirty bitmap before sending request,
then on response we clear bit in this bitmap copy,
then we set bits received from kvm (or another backend)
afterwards.

Of course just not retrieving the bitmap from kvm until we get a
response also works (this is what your patches did) and then you do not
need a copy, but that's inelegant because this means guest can defer
completing migration.


So this works for migration but not for discarding pages.

For this reason I think as a first step, we should focus on the simpler
approach where we keep the lock.  Then add a feature bit that allows
dropping the lock.




> > It probably can be defined but the interface seems very complex.
> > 
> > Let's start with a simple thing instead unless it can be shown that there's a
> > performance problem.
> > 
> > 
> > > >
> > > > --
> > > > MST
> > > --
> > > Dr. David Alan Gilbert / dgilbert@redhat.com / Manchester, UK

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
