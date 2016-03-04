Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f176.google.com (mail-pf0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 0B48A6B007E
	for <linux-mm@kvack.org>; Fri,  4 Mar 2016 10:13:08 -0500 (EST)
Received: by mail-pf0-f176.google.com with SMTP id 63so36768860pfe.3
        for <linux-mm@kvack.org>; Fri, 04 Mar 2016 07:13:08 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id hq1si6363724pac.56.2016.03.04.07.13.07
        for <linux-mm@kvack.org>;
        Fri, 04 Mar 2016 07:13:07 -0800 (PST)
From: "Li, Liang Z" <liang.z.li@intel.com>
Subject: RE: [Qemu-devel] [RFC qemu 0/4] A PV solution for live migration
 optimization
Date: Fri, 4 Mar 2016 15:13:03 +0000
Message-ID: <F2CBF3009FA73547804AE4C663CAB28E04145231@shsmsx102.ccr.corp.intel.com>
References: <1457001868-15949-1-git-send-email-liang.z.li@intel.com>
 <20160303174615.GF2115@work-vm> <20160304075538.GC9100@rkaganb.sw.ru>
 <F2CBF3009FA73547804AE4C663CAB28E037714DA@SHSMSX101.ccr.corp.intel.com>
 <20160304083550.GE9100@rkaganb.sw.ru> <20160304090820.GA2149@work-vm>
 <F2CBF3009FA73547804AE4C663CAB28E03771639@SHSMSX101.ccr.corp.intel.com>
 <20160304114519-mutt-send-email-mst@redhat.com>
 <F2CBF3009FA73547804AE4C663CAB28E037717B5@SHSMSX101.ccr.corp.intel.com>
 <20160304122456-mutt-send-email-mst@redhat.com>
In-Reply-To: <20160304122456-mutt-send-email-mst@redhat.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Roman Kagan <rkagan@virtuozzo.com>, "ehabkost@redhat.com" <ehabkost@redhat.com>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "quintela@redhat.com" <quintela@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "rth@twiddle.net" <rth@twiddle.net>

> > Maybe I am not clear enough.
> >
> > I mean if we inflate balloon before live migration, for a 8GB guest, it=
 takes
> about 5 Seconds for the inflating operation to finish.
>=20
> And these 5 seconds are spent where?
>=20

The time is spent on allocating the pages and send the allocated pages pfns=
 to QEMU
through virtio.

> > For the PV solution, there is no need to inflate balloon before live
> > migration, the only cost is to traversing the free_list to  construct
> > the free pages bitmap, and it takes about 20ms for a 8GB idle guest( le=
ss if
> there is less free pages),  passing the free pages info to host will take=
 about
> extra 3ms.
> >
> >
> > Liang
>=20
> So now let's please stop talking about solutions at a high level and disc=
uss the
> interface changes you make in detail.
> What makes it faster? Better host/guest interface? No need to go through
> buddy allocator within guest? Less interrupts? Something else?
>=20

I assume you are familiar with the current virtio-balloon and how it works.=
=20
The new interface is very simple, send a request to the virtio-balloon driv=
er,
The virtio-driver will travers the '&zone->free_area[order].free_list[t])' =
to=20
construct a 'free_page_bitmap', and then the driver will send the content
of  'free_page_bitmap' back to QEMU. That all the new interface does and
there are no ' alloc_page' related affairs, so it's faster.


Some code snippet:
----------------------------------------------
+static void mark_free_pages_bitmap(struct zone *zone,
+		 unsigned long *free_page_bitmap, unsigned long pfn_gap) {
+	unsigned long pfn, flags, i;
+	unsigned int order, t;
+	struct list_head *curr;
+
+	if (zone_is_empty(zone))
+		return;
+
+	spin_lock_irqsave(&zone->lock, flags);
+
+	for_each_migratetype_order(order, t) {
+		list_for_each(curr, &zone->free_area[order].free_list[t]) {
+
+			pfn =3D page_to_pfn(list_entry(curr, struct page, lru));
+			for (i =3D 0; i < (1UL << order); i++) {
+				if ((pfn + i) >=3D PFN_4G)
+					set_bit_le(pfn + i - pfn_gap,
+						   free_page_bitmap);
+				else
+					set_bit_le(pfn + i, free_page_bitmap);
+			}
+		}
+	}
+
+	spin_unlock_irqrestore(&zone->lock, flags); }
----------------------------------------------------
Sorry for my poor English and expression, if you still can't understand,
you could glance at the patch, total about 400 lines.
>=20
> > > --
> > > MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
