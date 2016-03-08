Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f47.google.com (mail-qg0-f47.google.com [209.85.192.47])
	by kanga.kvack.org (Postfix) with ESMTP id 089DC6B0257
	for <linux-mm@kvack.org>; Tue,  8 Mar 2016 09:03:41 -0500 (EST)
Received: by mail-qg0-f47.google.com with SMTP id y89so12482884qge.2
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 06:03:41 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k67si3134663qgd.10.2016.03.08.06.03.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Mar 2016 06:03:38 -0800 (PST)
Date: Tue, 8 Mar 2016 16:03:31 +0200
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [Qemu-devel] [RFC qemu 0/4] A PV solution for live migration
 optimization
Message-ID: <20160308160145-mutt-send-email-mst@redhat.com>
References: <20160303174615.GF2115@work-vm>
 <20160304075538.GC9100@rkaganb.sw.ru>
 <F2CBF3009FA73547804AE4C663CAB28E037714DA@SHSMSX101.ccr.corp.intel.com>
 <20160304083550.GE9100@rkaganb.sw.ru>
 <20160304090820.GA2149@work-vm>
 <F2CBF3009FA73547804AE4C663CAB28E03771639@SHSMSX101.ccr.corp.intel.com>
 <20160304114519-mutt-send-email-mst@redhat.com>
 <F2CBF3009FA73547804AE4C663CAB28E037717B5@SHSMSX101.ccr.corp.intel.com>
 <20160304122456-mutt-send-email-mst@redhat.com>
 <F2CBF3009FA73547804AE4C663CAB28E04145231@shsmsx102.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <F2CBF3009FA73547804AE4C663CAB28E04145231@shsmsx102.ccr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Li, Liang Z" <liang.z.li@intel.com>
Cc: "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Roman Kagan <rkagan@virtuozzo.com>, "ehabkost@redhat.com" <ehabkost@redhat.com>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "quintela@redhat.com" <quintela@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "rth@twiddle.net" <rth@twiddle.net>

On Fri, Mar 04, 2016 at 03:13:03PM +0000, Li, Liang Z wrote:
> > > Maybe I am not clear enough.
> > >
> > > I mean if we inflate balloon before live migration, for a 8GB guest, it takes
> > about 5 Seconds for the inflating operation to finish.
> > 
> > And these 5 seconds are spent where?
> > 
> 
> The time is spent on allocating the pages and send the allocated pages pfns to QEMU
> through virtio.

What if we skip allocating pages but use the existing interface to send pfns
to QEMU?

> > > For the PV solution, there is no need to inflate balloon before live
> > > migration, the only cost is to traversing the free_list to  construct
> > > the free pages bitmap, and it takes about 20ms for a 8GB idle guest( less if
> > there is less free pages),  passing the free pages info to host will take about
> > extra 3ms.
> > >
> > >
> > > Liang
> > 
> > So now let's please stop talking about solutions at a high level and discuss the
> > interface changes you make in detail.
> > What makes it faster? Better host/guest interface? No need to go through
> > buddy allocator within guest? Less interrupts? Something else?
> > 
> 
> I assume you are familiar with the current virtio-balloon and how it works. 
> The new interface is very simple, send a request to the virtio-balloon driver,
> The virtio-driver will travers the '&zone->free_area[order].free_list[t])' to 
> construct a 'free_page_bitmap', and then the driver will send the content
> of  'free_page_bitmap' back to QEMU. That all the new interface does and
> there are no ' alloc_page' related affairs, so it's faster.
> 
> 
> Some code snippet:
> ----------------------------------------------
> +static void mark_free_pages_bitmap(struct zone *zone,
> +		 unsigned long *free_page_bitmap, unsigned long pfn_gap) {
> +	unsigned long pfn, flags, i;
> +	unsigned int order, t;
> +	struct list_head *curr;
> +
> +	if (zone_is_empty(zone))
> +		return;
> +
> +	spin_lock_irqsave(&zone->lock, flags);
> +
> +	for_each_migratetype_order(order, t) {
> +		list_for_each(curr, &zone->free_area[order].free_list[t]) {
> +
> +			pfn = page_to_pfn(list_entry(curr, struct page, lru));
> +			for (i = 0; i < (1UL << order); i++) {
> +				if ((pfn + i) >= PFN_4G)
> +					set_bit_le(pfn + i - pfn_gap,
> +						   free_page_bitmap);
> +				else
> +					set_bit_le(pfn + i, free_page_bitmap);
> +			}
> +		}
> +	}
> +
> +	spin_unlock_irqrestore(&zone->lock, flags); }
> ----------------------------------------------------
> Sorry for my poor English and expression, if you still can't understand,
> you could glance at the patch, total about 400 lines.
> > 
> > > > --
> > > > MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
