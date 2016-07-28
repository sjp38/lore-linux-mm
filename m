Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id A96DE6B025F
	for <linux-mm@kvack.org>; Thu, 28 Jul 2016 00:37:03 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id ez1so29603344pab.1
        for <linux-mm@kvack.org>; Wed, 27 Jul 2016 21:37:03 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id n6si7540472pav.118.2016.07.27.21.37.02
        for <linux-mm@kvack.org>;
        Wed, 27 Jul 2016 21:37:02 -0700 (PDT)
From: "Li, Liang Z" <liang.z.li@intel.com>
Subject: RE: [PATCH v2 repost 6/7] mm: add the related functions to get free
 page info
Date: Thu, 28 Jul 2016 04:36:46 +0000
Message-ID: <F2CBF3009FA73547804AE4C663CAB28E04213EBF@shsmsx102.ccr.corp.intel.com>
References: <1469582616-5729-1-git-send-email-liang.z.li@intel.com>
 <1469582616-5729-7-git-send-email-liang.z.li@intel.com>
 <5798E418.7080608@intel.com> <20160728010030-mutt-send-email-mst@kernel.org>
 <579932D9.6000106@intel.com>
In-Reply-To: <579932D9.6000106@intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Hansen, Dave" <dave.hansen@intel.com>, "Michael S. Tsirkin" <mst@redhat.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "dgilbert@redhat.com" <dgilbert@redhat.com>, "quintela@redhat.com" <quintela@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil
 Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Paolo
 Bonzini <pbonzini@redhat.com>, Cornelia Huck <cornelia.huck@de.ibm.com>, Amit Shah <amit.shah@redhat.com>

> On 07/27/2016 03:05 PM, Michael S. Tsirkin wrote:
> > On Wed, Jul 27, 2016 at 09:40:56AM -0700, Dave Hansen wrote:
> >> On 07/26/2016 06:23 PM, Liang Li wrote:
> >>> +	for_each_migratetype_order(order, t) {
> >>> +		list_for_each(curr, &zone->free_area[order].free_list[t]) {
> >>> +			pfn =3D page_to_pfn(list_entry(curr, struct page, lru));
> >>> +			if (pfn >=3D start_pfn && pfn <=3D end_pfn) {
> >>> +				page_num =3D 1UL << order;
> >>> +				if (pfn + page_num > end_pfn)
> >>> +					page_num =3D end_pfn - pfn;
> >>> +				bitmap_set(bitmap, pfn - start_pfn,
> page_num);
> >>> +			}
> >>> +		}
> >>> +	}
> >>
> >> Nit:  The 'page_num' nomenclature really confused me here.  It is the
> >> number of bits being set in the bitmap.  Seems like calling it
> >> nr_pages or num_pages would be more appropriate.
> >>
> >> Isn't this bitmap out of date by the time it's send up to the
> >> hypervisor?  Is there something that makes the inaccuracy OK here?
> >
> > Yes. Calling these free pages is unfortunate. It's likely to confuse
> > people thinking they can just discard these pages.
> >
> > Hypervisor sends a request. We respond with this list of pages, and
> > the guarantee hypervisor needs is that these were free sometime
> > between request and response, so they are safe to free if they are
> > unmodified since the request. hypervisor can detect modifications so
> > it can detect modifications itself and does not need guest help.
>=20
> Ahh, that makes sense.
>=20
> So the hypervisor is trying to figure out: "Which pages do I move?".  It =
wants
> to know which pages the guest thinks have good data and need to move.
> But, the list of free pages is (likely) smaller than the list of pages wi=
th good
> data, so it asks for that instead.
>=20
> A write to a page means that it has valuable data, regardless of whether =
it
> was in the free list or not.
>=20
> The hypervisor only skips moving pages that were free *and* were never
> written to.  So we never lose data, even if this "get free page info"
> stuff is totally out of date.
>=20
> The patch description and code comments are, um, a _bit_ light for this l=
evel
> of subtlety. :)

I will add more description about this in v3.

Thanks!
Liang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
