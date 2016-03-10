Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f182.google.com (mail-qk0-f182.google.com [209.85.220.182])
	by kanga.kvack.org (Postfix) with ESMTP id 2D12B6B0005
	for <linux-mm@kvack.org>; Thu, 10 Mar 2016 07:29:43 -0500 (EST)
Received: by mail-qk0-f182.google.com with SMTP id o6so33363327qkc.2
        for <linux-mm@kvack.org>; Thu, 10 Mar 2016 04:29:43 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g17si3368628qhc.119.2016.03.10.04.29.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Mar 2016 04:29:42 -0800 (PST)
Date: Thu, 10 Mar 2016 14:29:34 +0200
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [Qemu-devel] [RFC qemu 0/4] A PV solution for live migration
 optimization
Message-ID: <20160310122934.GB8144@redhat.com>
References: <F2CBF3009FA73547804AE4C663CAB28E0414516C@shsmsx102.ccr.corp.intel.com>
 <20160304163246-mutt-send-email-mst@redhat.com>
 <F2CBF3009FA73547804AE4C663CAB28E041452EA@shsmsx102.ccr.corp.intel.com>
 <20160305214748-mutt-send-email-mst@redhat.com>
 <F2CBF3009FA73547804AE4C663CAB28E04146308@shsmsx102.ccr.corp.intel.com>
 <20160307110852-mutt-send-email-mst@redhat.com>
 <20160309142851.GA9715@rkaganb.sw.ru>
 <F2CBF3009FA73547804AE4C663CAB28E041498BA@shsmsx102.ccr.corp.intel.com>
 <20160309172929-mutt-send-email-mst@redhat.com>
 <F2CBF3009FA73547804AE4C663CAB28E0414A41D@shsmsx102.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <F2CBF3009FA73547804AE4C663CAB28E0414A41D@shsmsx102.ccr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Li, Liang Z" <liang.z.li@intel.com>
Cc: Roman Kagan <rkagan@virtuozzo.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, "ehabkost@redhat.com" <ehabkost@redhat.com>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "quintela@redhat.com" <quintela@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "rth@twiddle.net" <rth@twiddle.net>, "riel@redhat.com" <riel@redhat.com>

On Thu, Mar 10, 2016 at 01:41:16AM +0000, Li, Liang Z wrote:
> > > > > > Yes, we really can teach qemu to skip these pages and it's not hard.
> > > > > > The problem is the poor performance, this PV solution
> > > > >
> > > > > Balloon is always PV. And do not call patches solutions please.
> > > > >
> > > > > > is aimed to make it more
> > > > > > efficient and reduce the performance impact on guest.
> > > > >
> > > > > We need to get a bit beyond this.  You are making multiple
> > > > > changes, it seems to make sense to split it all up, and analyse
> > > > > each change separately.
> > > >
> > > > Couldn't agree more.
> > > >
> > > > There are three stages in this optimization:
> > > >
> > > > 1) choosing which pages to skip
> > > >
> > > > 2) communicating them from guest to host
> > > >
> > > > 3) skip transferring uninteresting pages to the remote side on
> > > > migration
> > > >
> > > > For (3) there seems to be a low-hanging fruit to amend
> > > > migration/ram.c:iz_zero_range() to consult /proc/self/pagemap.  This
> > > > would work for guest RAM that hasn't been touched yet or which has
> > > > been ballooned out.
> > > >
> > > > For (1) I've been trying to make a point that skipping clean pages
> > > > is much more likely to result in noticable benefit than free pages only.
> > > >
> > >
> > > I am considering to drop the pagecache before getting the free pages.
> > >
> > > > As for (2), we do seem to have a problem with the existing balloon:
> > > > according to your measurements it's very slow; besides, I guess it
> > > > plays badly
> > >
> > > I didn't say communicating is slow. Even this is very slow, my
> > > solution use bitmap instead of PFNs, there is fewer data traffic, so it's
> > faster than the existing balloon which use PFNs.
> > 
> > By how much?
> > 
> 
> Haven't measured yet. 
> To identify a page, 1 bit is needed if using bitmap, 4 Bytes(32bit) is needed if using PFN, 
> 
> For a guest with 8GB RAM,  the corresponding free page bitmap size is 256KB.
> And the corresponding total PFNs size is 8192KB. Assuming the inflating size
> is 7GB, the total PFNs size is 7168KB.

Yes but this is not how balloon works, instead, it will reuse a single
4K page multiple times. We can also trade off more memory for speed
if we want to, it's completely up to guest.

> 
> Maybe this is not the point.
> 
> Liang



> > > > with transparent huge pages (as both the guest and the host work
> > > > with one 4k page at a time).  This is a problem for other use cases
> > > > of balloon (e.g. as a facility for resource management); tackling
> > > > that appears a more natural application for optimization efforts.
> > > >
> > > > Thanks,
> > > > Roman.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
