Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f200.google.com (mail-yw0-f200.google.com [209.85.161.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1FD346B0260
	for <linux-mm@kvack.org>; Tue, 19 Apr 2016 12:15:06 -0400 (EDT)
Received: by mail-yw0-f200.google.com with SMTP id o131so44815502ywc.2
        for <linux-mm@kvack.org>; Tue, 19 Apr 2016 09:15:06 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u11si5797736qhu.103.2016.04.19.09.15.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Apr 2016 09:15:05 -0700 (PDT)
Date: Tue, 19 Apr 2016 19:15:00 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH kernel 1/2] mm: add the related functions to build the
 free page bitmap
Message-ID: <20160419191111-mutt-send-email-mst@redhat.com>
References: <1461076474-3864-1-git-send-email-liang.z.li@intel.com>
 <1461076474-3864-2-git-send-email-liang.z.li@intel.com>
 <1461077659.3200.8.camel@redhat.com>
 <F2CBF3009FA73547804AE4C663CAB28E04182594@shsmsx102.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <F2CBF3009FA73547804AE4C663CAB28E04182594@shsmsx102.ccr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Li, Liang Z" <liang.z.li@intel.com>
Cc: Rik van Riel <riel@redhat.com>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "quintela@redhat.com" <quintela@redhat.com>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "dgilbert@redhat.com" <dgilbert@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "agraf@suse.de" <agraf@suse.de>, "borntraeger@de.ibm.com" <borntraeger@de.ibm.com>

On Tue, Apr 19, 2016 at 03:02:09PM +0000, Li, Liang Z wrote:
> > On Tue, 2016-04-19 at 22:34 +0800, Liang Li wrote:
> > > The free page bitmap will be sent to QEMU through virtio interface and
> > > used for live migration optimization.
> > > Drop the cache before building the free page bitmap can get more free
> > > pages. Whether dropping the cache is decided by user.
> > >
> > 
> > How do you prevent the guest from using those recently-freed pages for
> > something else, between when you build the bitmap and the live migration
> > completes?
> 
> Because the dirty page logging is enabled before building the bitmap, there is no need
> to prevent the guest from using the recently-freed pages ...
> 
> Liang

Well one point of telling host that page is free is so that
it can mark it clean even if it was dirty previously.
So I think you must pass the pages to guest under the lock.
This will allow host optimizations such as marking these
pages MADV_DONTNEED or MADV_FREE.
Otherwise it's all too tied up to a specific usecase -
you aren't telling host that a page is free, you are telling it
that a page was free in the past.

-- 
MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
