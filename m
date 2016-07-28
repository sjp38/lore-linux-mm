Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id A7DB26B025F
	for <linux-mm@kvack.org>; Wed, 27 Jul 2016 20:10:23 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id o124so23886273pfg.1
        for <linux-mm@kvack.org>; Wed, 27 Jul 2016 17:10:23 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id dv15si8978429pac.75.2016.07.27.17.10.22
        for <linux-mm@kvack.org>;
        Wed, 27 Jul 2016 17:10:22 -0700 (PDT)
From: "Li, Liang Z" <liang.z.li@intel.com>
Subject: RE: [PATCH v2 repost 6/7] mm: add the related functions to get free
 page info
Date: Thu, 28 Jul 2016 00:10:16 +0000
Message-ID: <F2CBF3009FA73547804AE4C663CAB28E04213C27@shsmsx102.ccr.corp.intel.com>
References: <1469582616-5729-1-git-send-email-liang.z.li@intel.com>
 <1469582616-5729-7-git-send-email-liang.z.li@intel.com>
 <5798E418.7080608@intel.com>
In-Reply-To: <5798E418.7080608@intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Hansen, Dave" <dave.hansen@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Cc: "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "dgilbert@redhat.com" <dgilbert@redhat.com>, "quintela@redhat.com" <quintela@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil
 Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, "Michael
 S. Tsirkin" <mst@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, Cornelia
 Huck <cornelia.huck@de.ibm.com>, Amit Shah <amit.shah@redhat.com>

> Subject: Re: [PATCH v2 repost 6/7] mm: add the related functions to get f=
ree
> page info
>=20
> On 07/26/2016 06:23 PM, Liang Li wrote:
> > +	for_each_migratetype_order(order, t) {
> > +		list_for_each(curr, &zone->free_area[order].free_list[t]) {
> > +			pfn =3D page_to_pfn(list_entry(curr, struct page, lru));
> > +			if (pfn >=3D start_pfn && pfn <=3D end_pfn) {
> > +				page_num =3D 1UL << order;
> > +				if (pfn + page_num > end_pfn)
> > +					page_num =3D end_pfn - pfn;
> > +				bitmap_set(bitmap, pfn - start_pfn,
> page_num);
> > +			}
> > +		}
> > +	}
>=20
> Nit:  The 'page_num' nomenclature really confused me here.  It is the
> number of bits being set in the bitmap.  Seems like calling it nr_pages o=
r
> num_pages would be more appropriate.
>=20

You are right,  will change.

> Isn't this bitmap out of date by the time it's send up to the hypervisor?=
  Is
> there something that makes the inaccuracy OK here?

Yes. The dirty page logging will be used to correct the inaccuracy.
The dirty page logging should be started before getting the free page bitma=
p, then if some of the free pages become no free for writing, these pages w=
ill be tracked by the dirty page logging mechanism.

Thanks!
Liang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
