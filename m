Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f200.google.com (mail-yw0-f200.google.com [209.85.161.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3388F6B007E
	for <linux-mm@kvack.org>; Fri, 22 Apr 2016 09:58:46 -0400 (EDT)
Received: by mail-yw0-f200.google.com with SMTP id i22so226747787ywc.3
        for <linux-mm@kvack.org>; Fri, 22 Apr 2016 06:58:46 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n74si3678265qgn.119.2016.04.22.06.58.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Apr 2016 06:58:45 -0700 (PDT)
Date: Fri, 22 Apr 2016 16:58:39 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH kernel 1/2] mm: add the related functions to build the
 free page bitmap
Message-ID: <20160422164936-mutt-send-email-mst@redhat.com>
References: <1461076474-3864-1-git-send-email-liang.z.li@intel.com>
 <1461076474-3864-2-git-send-email-liang.z.li@intel.com>
 <1461077659.3200.8.camel@redhat.com>
 <F2CBF3009FA73547804AE4C663CAB28E04182594@shsmsx102.ccr.corp.intel.com>
 <20160419191111-mutt-send-email-mst@redhat.com>
 <20160422094837.GC2239@work-vm>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160422094837.GC2239@work-vm>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Dr. David Alan Gilbert" <dgilbert@redhat.com>
Cc: "Li, Liang Z" <liang.z.li@intel.com>, Rik van Riel <riel@redhat.com>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "quintela@redhat.com" <quintela@redhat.com>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "agraf@suse.de" <agraf@suse.de>, "borntraeger@de.ibm.com" <borntraeger@de.ibm.com>

On Fri, Apr 22, 2016 at 10:48:38AM +0100, Dr. David Alan Gilbert wrote:
> * Michael S. Tsirkin (mst@redhat.com) wrote:
> > On Tue, Apr 19, 2016 at 03:02:09PM +0000, Li, Liang Z wrote:
> > > > On Tue, 2016-04-19 at 22:34 +0800, Liang Li wrote:
> > > > > The free page bitmap will be sent to QEMU through virtio interface and
> > > > > used for live migration optimization.
> > > > > Drop the cache before building the free page bitmap can get more free
> > > > > pages. Whether dropping the cache is decided by user.
> > > > >
> > > > 
> > > > How do you prevent the guest from using those recently-freed pages for
> > > > something else, between when you build the bitmap and the live migration
> > > > completes?
> > > 
> > > Because the dirty page logging is enabled before building the bitmap, there is no need
> > > to prevent the guest from using the recently-freed pages ...
> > > 
> > > Liang
> > 
> > Well one point of telling host that page is free is so that
> > it can mark it clean even if it was dirty previously.
> > So I think you must pass the pages to guest under the lock.
> > This will allow host optimizations such as marking these
> > pages MADV_DONTNEED or MADV_FREE.
> > Otherwise it's all too tied up to a specific usecase -
> > you aren't telling host that a page is free, you are telling it
> > that a page was free in the past.
> 
> But doing it under lock sounds pretty expensive, especially given
> how long the userspace side is going to take to work through the bitmap
> and device what to do.
> 
> Dave

We need to make it as fast as we can since the VCPU is stopped on exit
anyway. This just means e.g. sizing the bitmap reasonably -
don't always try to fit all memory in a single bitmap.

Really, if the page can in fact be in use when you tell host it's free,
then it's rather hard to explain what does it mean from host/guest
interface point of view.

It probably can be defined but the interface seems very complex.

Let's start with a simple thing instead unless it can be shown
that there's a performance problem.


> > 
> > -- 
> > MST
> --
> Dr. David Alan Gilbert / dgilbert@redhat.com / Manchester, UK

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
