Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f179.google.com (mail-qk0-f179.google.com [209.85.220.179])
	by kanga.kvack.org (Postfix) with ESMTP id 26AEB6B0253
	for <linux-mm@kvack.org>; Wed,  9 Mar 2016 12:39:25 -0500 (EST)
Received: by mail-qk0-f179.google.com with SMTP id x1so23340917qkc.1
        for <linux-mm@kvack.org>; Wed, 09 Mar 2016 09:39:25 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 77si8851655qgf.22.2016.03.09.09.39.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Mar 2016 09:39:24 -0800 (PST)
Date: Wed, 9 Mar 2016 19:39:18 +0200
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [Qemu-devel] [RFC qemu 0/4] A PV solution for live migration
 optimization
Message-ID: <20160309193137-mutt-send-email-mst@redhat.com>
References: <20160304102346.GB2479@rkaganb.sw.ru>
 <F2CBF3009FA73547804AE4C663CAB28E0414516C@shsmsx102.ccr.corp.intel.com>
 <20160304163246-mutt-send-email-mst@redhat.com>
 <F2CBF3009FA73547804AE4C663CAB28E041452EA@shsmsx102.ccr.corp.intel.com>
 <20160305214748-mutt-send-email-mst@redhat.com>
 <F2CBF3009FA73547804AE4C663CAB28E04146308@shsmsx102.ccr.corp.intel.com>
 <20160307110852-mutt-send-email-mst@redhat.com>
 <20160309142851.GA9715@rkaganb.sw.ru>
 <20160309173017-mutt-send-email-mst@redhat.com>
 <20160309170438.GB9715@rkaganb.sw.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160309170438.GB9715@rkaganb.sw.ru>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Kagan <rkagan@virtuozzo.com>, "Li, Liang Z" <liang.z.li@intel.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, "ehabkost@redhat.com" <ehabkost@redhat.com>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "quintela@redhat.com" <quintela@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "rth@twiddle.net" <rth@twiddle.net>, riel@redhat.com

On Wed, Mar 09, 2016 at 08:04:39PM +0300, Roman Kagan wrote:
> On Wed, Mar 09, 2016 at 05:41:39PM +0200, Michael S. Tsirkin wrote:
> > On Wed, Mar 09, 2016 at 05:28:54PM +0300, Roman Kagan wrote:
> > > For (1) I've been trying to make a point that skipping clean pages is
> > > much more likely to result in noticable benefit than free pages only.
> > 
> > I guess when you say clean you mean zero?
> 
> No I meant clean, i.e. those that could be evicted from RAM without
> causing I/O.

They must be migrated unless guest actually evicts them.
It's not at all clear to me that it's always preferable
to drop all clean pages from pagecache. It is clearly is
going to slow the guest down significantly.


> > Yea. In fact, one can zero out any number of pages
> > quickly by putting them in balloon and immediately
> > taking them out.
> > 
> > Access will fault a zero page in, then COW kicks in.
> 
> I must be missing something obvious, but how is that different from
> inflating and then immediately deflating the balloon?

It's exactly the same except
- we do not initiate this from host - it's guest doing
  things for its own reasons
- a bit less guest/host interaction this way


> > We could have a new zero VQ (or some other option)
> > to pass these pages guest to host, but this only
> > works well if page size matches the host page size.
> 
> I'm afraid I don't yet understand what kind of pages that would be and
> how they are different from ballooned pages.
> 
> I still tend to think that ballooning is a sensible solution to the
> problem at hand;

I think it is, too. This does not mean we can't improve things though.
This patchset is reported to improve things, it should be
split up so we improve them for everyone and not just
one specific workload.


> it's just the granularity that makes things slow and
> stands in the way.

So we could request a specific page size/alignment from guest.
Send guest request to give us memory in aligned units of 2Mbytes,
and then host can treat each of these as a single huge page.


> Roman.
-- 
MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
