Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0D8696B0343
	for <linux-mm@kvack.org>; Wed, 22 Mar 2017 06:52:41 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id q126so396642653pga.0
        for <linux-mm@kvack.org>; Wed, 22 Mar 2017 03:52:41 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id x188si1343991pgb.304.2017.03.22.03.52.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Mar 2017 03:52:40 -0700 (PDT)
From: "Wang, Wei W" <wei.w.wang@intel.com>
Subject: RE: [PATCH kernel v8 3/4] mm: add inerface to offer info about
 unused	pages
Date: Wed, 22 Mar 2017 10:52:36 +0000
Message-ID: <286AC319A985734F985F78AFA26841F7391A770E@shsmsx102.ccr.corp.intel.com>
References: <1489648127-37282-1-git-send-email-wei.w.wang@intel.com>
	<1489648127-37282-4-git-send-email-wei.w.wang@intel.com>
	<20170316142842.69770813b98df70277431b1e@linux-foundation.org>
 <58CB8865.5030707@intel.com>
In-Reply-To: <58CB8865.5030707@intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Wang, Wei W" <wei.w.wang@intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: "aarcange@redhat.com" <aarcange@redhat.com>, "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "mst@redhat.com" <mst@redhat.com>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "liliang.opensource@gmail.com" <liliang.opensource@gmail.com>, "Hansen, Dave" <dave.hansen@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "cornelia.huck@de.ibm.com" <cornelia.huck@de.ibm.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>

Hi Andrew,=20

Do you have any comments on my thoughts? Thanks.

> On 03/17/2017 05:28 AM, Andrew Morton wrote:
> > On Thu, 16 Mar 2017 15:08:46 +0800 Wei Wang <wei.w.wang@intel.com>
> wrote:
> >
> >> From: Liang Li <liang.z.li@intel.com>
> >>
> >> This patch adds a function to provides a snapshot of the present
> >> system unused pages. An important usage of this function is to
> >> provide the unsused pages to the Live migration thread, which skips
> >> the transfer of thoses unused pages. Newly used pages can be
> >> re-tracked by the dirty page logging mechanisms.
> > I don't think this will be useful for anything other than
> > virtio-balloon.  I guess it would be better to keep this code in the
> > virtio-balloon driver if possible, even though that's rather a
> > layering violation :( What would have to be done to make that
> > possible?  Perhaps we can put some *small* helpers into page_alloc.c
> > to prevent things from becoming too ugly.
>=20
> The patch description was too narrowed and may have caused some confusion=
,
> sorry about that. This function is aimed to be generic. I agree with the
> description suggested by Michael.
>=20
> Since the main body of the function is related to operating on the free_l=
ist. I
> think it is better to have them located here.
> Small helpers may be less efficient and thereby causing some performance =
loss
> as well.
> I think one improvement we can make is to remove the "chunk format"
> related things from this function. The function can generally offer the b=
ase pfn
> to the caller's recording buffer. Then it will be the caller's responsibi=
lity to
> format the pfn if they need.
>=20
> >> --- a/mm/page_alloc.c
> >> +++ b/mm/page_alloc.c
> >> @@ -4498,6 +4498,120 @@ void show_free_areas(unsigned int filter)
> >>   	show_swap_cache_info();
> >>   }
> >>
> >> +static int __record_unused_pages(struct zone *zone, int order,
> >> +				 __le64 *buf, unsigned int size,
> >> +				 unsigned int *offset, bool part_fill) {
> >> +	unsigned long pfn, flags;
> >> +	int t, ret =3D 0;
> >> +	struct list_head *curr;
> >> +	__le64 *chunk;
> >> +
> >> +	if (zone_is_empty(zone))
> >> +		return 0;
> >> +
> >> +	spin_lock_irqsave(&zone->lock, flags);
> >> +
> >> +	if (*offset + zone->free_area[order].nr_free > size && !part_fill) {
> >> +		ret =3D -ENOSPC;
> >> +		goto out;
> >> +	}
> >> +	for (t =3D 0; t < MIGRATE_TYPES; t++) {
> >> +		list_for_each(curr, &zone->free_area[order].free_list[t]) {
> >> +			pfn =3D page_to_pfn(list_entry(curr, struct page, lru));
> >> +			chunk =3D buf + *offset;
> >> +			if (*offset + 2 > size) {
> >> +				ret =3D -ENOSPC;
> >> +				goto out;
> >> +			}
> >> +			/* Align to the chunk format used in virtio-balloon */
> >> +			*chunk =3D cpu_to_le64(pfn << 12);
> >> +			*(chunk + 1) =3D cpu_to_le64((1 << order) << 12);
> >> +			*offset +=3D 2;
> >> +		}
> >> +	}
> >> +
> >> +out:
> >> +	spin_unlock_irqrestore(&zone->lock, flags);
> >> +
> >> +	return ret;
> >> +}
> > This looks like it could disable interrupts for a long time.  Too long?
>=20
> What do you think if we give "budgets" to the above function?
> For example, budget=3D1000, and there are 2000 nodes on the list.
> record() returns with "incomplete" status in the first round, along with =
the status
> info, "*continue_node".
>=20
> *continue_node: pointer to the starting node of the leftover. If *continu=
e_node
> has been used at the time of the second call (i.e. continue_node->next =
=3D=3D NULL),
> which implies that the previous 1000 nodes have been used, then the recor=
d()
> function can simply start from the head of the list.
>=20
> It is up to the caller whether it needs to continue the second round when=
 getting
> "incomplete".
>=20
> >
> >> +/*
> >> + * The record_unused_pages() function is used to record the system
> >> +unused
> >> + * pages. The unused pages can be skipped to transfer during live mig=
ration.
> >> + * Though the unused pages are dynamically changing, dirty page
> >> +logging
> >> + * mechanisms are able to capture the newly used pages though they
> >> +were
> >> + * recorded as unused pages via this function.
> >> + *
> >> + * This function scans the free page list of the specified order to
> >> +record
> >> + * the unused pages, and chunks those continuous pages following the
> >> +chunk
> >> + * format below:
> >> + * --------------------------------------
> >> + * |	Base (52-bit)	| Rsvd (12-bit) |
> >> + * --------------------------------------
> >> + * --------------------------------------
> >> + * |	Size (52-bit)	| Rsvd (12-bit) |
> >> + * --------------------------------------
> >> + *
> >> + * @start_zone: zone to start the record operation.
> >> + * @order: order of the free page list to record.
> >> + * @buf: buffer to record the unused page info in chunks.
> >> + * @size: size of the buffer in __le64 to record
> >> + * @offset: offset in the buffer to record.
> >> + * @part_fill: indicate if partial fill is used.
> >> + *
> >> + * return -EINVAL if parameter is invalid
> >> + * return -ENOSPC when the buffer is too small to record all the
> >> +unsed pages
> >> + * return 0 when sccess
> >> + */
> > It's a strange thing - it returns information which will instantly
> > become incorrect.
>=20
> I didn't get the point, could you please explain more? Thanks.

Best,
Wei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
