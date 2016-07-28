Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 69A1D6B025F
	for <linux-mm@kvack.org>; Thu, 28 Jul 2016 01:30:50 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id ag5so31407382pad.2
        for <linux-mm@kvack.org>; Wed, 27 Jul 2016 22:30:50 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id t90si10486921pfa.50.2016.07.27.22.30.49
        for <linux-mm@kvack.org>;
        Wed, 27 Jul 2016 22:30:49 -0700 (PDT)
From: "Li, Liang Z" <liang.z.li@intel.com>
Subject: RE: [virtio-dev] Re: [PATCH v2 repost 6/7] mm: add the related
 functions to get free page info
Date: Thu, 28 Jul 2016 05:30:39 +0000
Message-ID: <F2CBF3009FA73547804AE4C663CAB28E04213F20@shsmsx102.ccr.corp.intel.com>
References: <1469582616-5729-1-git-send-email-liang.z.li@intel.com>
 <1469582616-5729-7-git-send-email-liang.z.li@intel.com>
 <20160728010921-mutt-send-email-mst@kernel.org>
In-Reply-To: <20160728010921-mutt-send-email-mst@kernel.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "dgilbert@redhat.com" <dgilbert@redhat.com>, "quintela@redhat.com" <quintela@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil
 Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Paolo
 Bonzini <pbonzini@redhat.com>, Cornelia Huck <cornelia.huck@de.ibm.com>, Amit Shah <amit.shah@redhat.com>

> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c index 7da61ad..3ad8b10
> > 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -4523,6 +4523,52 @@ unsigned long get_max_pfn(void)  }
> > EXPORT_SYMBOL(get_max_pfn);
> >
> > +static void mark_free_pages_bitmap(struct zone *zone, unsigned long
> start_pfn,
> > +	unsigned long end_pfn, unsigned long *bitmap, unsigned long len) {
> > +	unsigned long pfn, flags, page_num;
> > +	unsigned int order, t;
> > +	struct list_head *curr;
> > +
> > +	if (zone_is_empty(zone))
> > +		return;
> > +	end_pfn =3D min(start_pfn + len, end_pfn);
> > +	spin_lock_irqsave(&zone->lock, flags);
> > +
> > +	for_each_migratetype_order(order, t) {
>=20
> Why not do each order separately? This way you can use a single bit to pa=
ss a
> huge page to host.
>=20

I thought about that before, and did not that because of complexity and sma=
ll benefits.
Use separated page bitmaps for each order won't help to reduce the data tra=
ffic, except
ignoring the pages with small order.=20

> Not a requirement but hey.
>=20
> Alternatively (and maybe that is a better idea0 if you wanted to, you cou=
ld
> just skip lone 4K pages.
> It's not clear that they are worth bothering with.
> Add a flag to start with some reasonably large order and go from there.
>=20
One of the main reason of this patch is to reduce the network traffic as mu=
ch as possible,
it looks strange to skip the lone 4K pages. Skipping these pages can made l=
ive migration
faster? I think it depends on the amount of lone 4K pages.

In the other hand, it's faster to send one bit through virtio than that sen=
d 4K bytes=20
through even 10Gps network, is that true?

Liang


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
