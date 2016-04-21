Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f72.google.com (mail-qg0-f72.google.com [209.85.192.72])
	by kanga.kvack.org (Postfix) with ESMTP id AC117828E8
	for <linux-mm@kvack.org>; Thu, 21 Apr 2016 09:49:01 -0400 (EDT)
Received: by mail-qg0-f72.google.com with SMTP id t38so111317033qge.3
        for <linux-mm@kvack.org>; Thu, 21 Apr 2016 06:49:01 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e24si406830qkj.236.2016.04.21.06.49.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Apr 2016 06:49:00 -0700 (PDT)
Date: Thu, 21 Apr 2016 16:48:54 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH kernel 1/2] mm: add the related functions to build the
 free page bitmap
Message-ID: <20160421134854.GA6858@redhat.com>
References: <1461076474-3864-1-git-send-email-liang.z.li@intel.com>
 <1461076474-3864-2-git-send-email-liang.z.li@intel.com>
 <1461077659.3200.8.camel@redhat.com>
 <F2CBF3009FA73547804AE4C663CAB28E04182594@shsmsx102.ccr.corp.intel.com>
 <20160419191111-mutt-send-email-mst@redhat.com>
 <F2CBF3009FA73547804AE4C663CAB28E0418339F@shsmsx102.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <F2CBF3009FA73547804AE4C663CAB28E0418339F@shsmsx102.ccr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Li, Liang Z" <liang.z.li@intel.com>
Cc: Rik van Riel <riel@redhat.com>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "quintela@redhat.com" <quintela@redhat.com>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "dgilbert@redhat.com" <dgilbert@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "agraf@suse.de" <agraf@suse.de>, "borntraeger@de.ibm.com" <borntraeger@de.ibm.com>

On Wed, Apr 20, 2016 at 01:41:24AM +0000, Li, Liang Z wrote:
> > Cc: Rik van Riel; viro@zeniv.linux.org.uk; linux-kernel@vger.kernel.org;
> > quintela@redhat.com; amit.shah@redhat.com; pbonzini@redhat.com;
> > dgilbert@redhat.com; linux-mm@kvack.org; kvm@vger.kernel.org; qemu-
> > devel@nongnu.org; agraf@suse.de; borntraeger@de.ibm.com
> > Subject: Re: [PATCH kernel 1/2] mm: add the related functions to build the
> > free page bitmap
> > 
> > On Tue, Apr 19, 2016 at 03:02:09PM +0000, Li, Liang Z wrote:
> > > > On Tue, 2016-04-19 at 22:34 +0800, Liang Li wrote:
> > > > > The free page bitmap will be sent to QEMU through virtio interface
> > > > > and used for live migration optimization.
> > > > > Drop the cache before building the free page bitmap can get more
> > > > > free pages. Whether dropping the cache is decided by user.
> > > > >
> > > >
> > > > How do you prevent the guest from using those recently-freed pages
> > > > for something else, between when you build the bitmap and the live
> > > > migration completes?
> > >
> > > Because the dirty page logging is enabled before building the bitmap,
> > > there is no need to prevent the guest from using the recently-freed
> > pages ...
> > >
> > > Liang
> > 
> > Well one point of telling host that page is free is so that it can mark it clean
> > even if it was dirty previously.
> > So I think you must pass the pages to guest under the lock.
> 
> Thanks! You mean save the free page bitmap in host pages?

No, I literally mean don't release &zone->lock before you pass
the list of pages to host.

> > This will allow host optimizations such as marking these pages
> > MADV_DONTNEED or MADV_FREE
> > Otherwise it's all too tied up to a specific usecase - you aren't telling host that
> > a page is free, you are telling it that a page was free in the past.
> > 
> 
> Then we should prevent the guest from using those recently-freed pages, 
> before doing the MADV_DONTNEED or MADV_FREE, or the pages in the
> free page bitmap may be not free any more. In which case we will do something
> like this? Balloon?
> 
> Liang
> 

Wouldn't keeping &zone->lock make sure these pages aren't used?


> > --
> > MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
