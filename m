Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f174.google.com (mail-pf0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id D0D316B0005
	for <linux-mm@kvack.org>; Thu, 10 Mar 2016 05:22:00 -0500 (EST)
Received: by mail-pf0-f174.google.com with SMTP id 124so65903796pfg.0
        for <linux-mm@kvack.org>; Thu, 10 Mar 2016 02:22:00 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id a70si5118804pfj.109.2016.03.10.02.21.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Mar 2016 02:21:59 -0800 (PST)
Date: Thu, 10 Mar 2016 13:21:30 +0300
From: Roman Kagan <rkagan@virtuozzo.com>
Subject: Re: [Qemu-devel] [RFC qemu 0/4] A PV solution for live migration
 optimization
Message-ID: <20160310102129.GB14065@rkaganb.sw.ru>
References: <F2CBF3009FA73547804AE4C663CAB28E0414516C@shsmsx102.ccr.corp.intel.com>
 <20160304163246-mutt-send-email-mst@redhat.com>
 <F2CBF3009FA73547804AE4C663CAB28E041452EA@shsmsx102.ccr.corp.intel.com>
 <20160305214748-mutt-send-email-mst@redhat.com>
 <F2CBF3009FA73547804AE4C663CAB28E04146308@shsmsx102.ccr.corp.intel.com>
 <20160307110852-mutt-send-email-mst@redhat.com>
 <20160309142851.GA9715@rkaganb.sw.ru>
 <20160309173017-mutt-send-email-mst@redhat.com>
 <20160309170438.GB9715@rkaganb.sw.ru>
 <20160309193137-mutt-send-email-mst@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20160309193137-mutt-send-email-mst@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: "Li, Liang Z" <liang.z.li@intel.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, "ehabkost@redhat.com" <ehabkost@redhat.com>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "quintela@redhat.com" <quintela@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "rth@twiddle.net" <rth@twiddle.net>, riel@redhat.com

On Wed, Mar 09, 2016 at 07:39:18PM +0200, Michael S. Tsirkin wrote:
> On Wed, Mar 09, 2016 at 08:04:39PM +0300, Roman Kagan wrote:
> > On Wed, Mar 09, 2016 at 05:41:39PM +0200, Michael S. Tsirkin wrote:
> > > On Wed, Mar 09, 2016 at 05:28:54PM +0300, Roman Kagan wrote:
> > > > For (1) I've been trying to make a point that skipping clean pages is
> > > > much more likely to result in noticable benefit than free pages only.
> > > 
> > > I guess when you say clean you mean zero?
> > 
> > No I meant clean, i.e. those that could be evicted from RAM without
> > causing I/O.
> 
> They must be migrated unless guest actually evicts them.

If the balloon is inflated the guest will.

> It's not at all clear to me that it's always preferable
> to drop all clean pages from pagecache. It is clearly is
> going to slow the guest down significantly.

That's a matter for optimization.  The current value for
/proc/meminfo:MemAvailable (which is being proposed as a member of
balloon stats, too) is a conservative estimate which will probably cover
a good deal of cases.

> > I must be missing something obvious, but how is that different from
> > inflating and then immediately deflating the balloon?
> 
> It's exactly the same except
> - we do not initiate this from host - it's guest doing
>   things for its own reasons
> - a bit less guest/host interaction this way

I don't quite understand why you need to deflate the balloon until the
VM is on the destination host.  deflate_on_oom will do it if the guest
is really tight on memory; otherwise there appears to be no reason for
it.  But then inflation followed immediately by deflation doubles the
guest/host interactions rather than reduces them, no?

> > it's just the granularity that makes things slow and
> > stands in the way.
> 
> So we could request a specific page size/alignment from guest.
> Send guest request to give us memory in aligned units of 2Mbytes,
> and then host can treat each of these as a single huge page.

I'd guess just coalescing contiguous pages would already speed things
up.  I'll try to find some time to experiment with it.

Roman.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
