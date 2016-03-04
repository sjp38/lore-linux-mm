Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 5FCA26B0254
	for <linux-mm@kvack.org>; Fri,  4 Mar 2016 05:23:59 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id fi3so30834825pac.3
        for <linux-mm@kvack.org>; Fri, 04 Mar 2016 02:23:59 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id 26si4980761pfj.93.2016.03.04.02.23.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Mar 2016 02:23:58 -0800 (PST)
Date: Fri, 4 Mar 2016 13:23:47 +0300
From: Roman Kagan <rkagan@virtuozzo.com>
Subject: Re: [Qemu-devel] [RFC qemu 0/4] A PV solution for live migration
 optimization
Message-ID: <20160304102346.GB2479@rkaganb.sw.ru>
References: <1457001868-15949-1-git-send-email-liang.z.li@intel.com>
 <20160303174615.GF2115@work-vm>
 <F2CBF3009FA73547804AE4C663CAB28E03770E33@SHSMSX101.ccr.corp.intel.com>
 <20160304081411.GD9100@rkaganb.sw.ru>
 <F2CBF3009FA73547804AE4C663CAB28E0377160A@SHSMSX101.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <F2CBF3009FA73547804AE4C663CAB28E0377160A@SHSMSX101.ccr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Li, Liang Z" <liang.z.li@intel.com>
Cc: "Dr. David Alan Gilbert" <dgilbert@redhat.com>, "ehabkost@redhat.com" <ehabkost@redhat.com>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "mst@redhat.com" <mst@redhat.com>, "quintela@redhat.com" <quintela@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "rth@twiddle.net" <rth@twiddle.net>

On Fri, Mar 04, 2016 at 09:08:44AM +0000, Li, Liang Z wrote:
> > On Fri, Mar 04, 2016 at 01:52:53AM +0000, Li, Liang Z wrote:
> > > >   I wonder if it would be possible to avoid the kernel changes by
> > > > parsing /proc/self/pagemap - if that can be used to detect
> > > > unmapped/zero mapped pages in the guest ram, would it achieve the
> > same result?
> > >
> > > Only detect the unmapped/zero mapped pages is not enough. Consider
> > the
> > > situation like case 2, it can't achieve the same result.
> > 
> > Your case 2 doesn't exist in the real world.  If people could stop their main
> > memory consumer in the guest prior to migration they wouldn't need live
> > migration at all.
> 
> The case 2 is just a simplified scenario, not a real case.
> As long as the guest's memory usage does not keep increasing, or not always run out,
> it can be covered by the case 2.

The memory usage will keep increasing due to ever growing caches, etc,
so you'll be left with very little free memory fairly soon.

> > I tend to think you can safely assume there's no free memory in the guest, so
> > there's little point optimizing for it.
> 
> If this is true, we should not inflate the balloon either.

We certainly should if there's "available" memory, i.e. not free but
cheap to reclaim.

> > OTOH it makes perfect sense optimizing for the unmapped memory that's
> > made up, in particular, by the ballon, and consider inflating the balloon right
> > before migration unless you already maintain it at the optimal size for other
> > reasons (like e.g. a global resource manager optimizing the VM density).
> > 
> 
> Yes, I believe the current balloon works and it's simple. Do you take the performance impact for consideration?
> For and 8G guest, it takes about 5s to  inflating the balloon. But it only takes 20ms to  traverse the free_list and
> construct the free pages bitmap.

I don't have any feeling of how important the difference is.  And if the
limiting factor for balloon inflation speed is the granularity of
communication it may be worth optimizing that, because quick balloon
reaction may be important in certain resource management scenarios.

> By inflating the balloon, all the guest's pages are still be processed (zero page checking).

Not sure what you mean.  If you describe the current state of affairs
that's exactly the suggested optimization point: skip unmapped pages.

> The only advantage of ' inflating the balloon before live migration' is simple, nothing more.

That's a big advantage.  Another one is that it does something useful in
real-world scenarios.

Roman.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
