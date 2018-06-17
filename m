Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 877EC6B0005
	for <linux-mm@kvack.org>; Sat, 16 Jun 2018 20:07:50 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id d6-v6so4628137plo.15
        for <linux-mm@kvack.org>; Sat, 16 Jun 2018 17:07:50 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id p11-v6si10825910plk.294.2018.06.16.17.07.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 16 Jun 2018 17:07:48 -0700 (PDT)
From: "Wang, Wei W" <wei.w.wang@intel.com>
Subject: RE: [PATCH v33 1/4] mm: add a function to get free page blocks
Date: Sun, 17 Jun 2018 00:07:40 +0000
Message-ID: <286AC319A985734F985F78AFA26841F7396A6415@shsmsx102.ccr.corp.intel.com>
References: <1529037793-35521-1-git-send-email-wei.w.wang@intel.com>
 <1529037793-35521-2-git-send-email-wei.w.wang@intel.com>
 <20180616045005.GA14936@bombadil.infradead.org>
In-Reply-To: <20180616045005.GA14936@bombadil.infradead.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Matthew Wilcox' <willy@infradead.org>
Cc: "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mst@redhat.com" <mst@redhat.com>, "mhocko@kernel.org" <mhocko@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "liliang.opensource@gmail.com" <liliang.opensource@gmail.com>, "yang.zhang.wz@gmail.com" <yang.zhang.wz@gmail.com>, "quan.xu0@gmail.com" <quan.xu0@gmail.com>, "nilal@redhat.com" <nilal@redhat.com>, "riel@redhat.com" <riel@redhat.com>, "peterx@redhat.com" <peterx@redhat.com>

On Saturday, June 16, 2018 12:50 PM, Matthew Wilcox wrote:
> On Fri, Jun 15, 2018 at 12:43:10PM +0800, Wei Wang wrote:
> > +/**
> > + * get_from_free_page_list - get free page blocks from a free page
> > +list
> > + * @order: the order of the free page list to check
> > + * @buf: the array to store the physical addresses of the free page
> > +blocks
> > + * @size: the array size
> > + *
> > + * This function offers hints about free pages. There is no guarantee
> > +that
> > + * the obtained free pages are still on the free page list after the
> > +function
> > + * returns. pfn_to_page on the obtained free pages is strongly
> > +discouraged
> > + * and if there is an absolute need for that, make sure to contact MM
> > +people
> > + * to discuss potential problems.
> > + *
> > + * The addresses are currently stored to the array in little endian.
> > +This
> > + * avoids the overhead of converting endianness by the caller who
> > +needs data
> > + * in the little endian format. Big endian support can be added on
> > +demand in
> > + * the future.
> > + *
> > + * Return the number of free page blocks obtained from the free page l=
ist.
> > + * The maximum number of free page blocks that can be obtained is
> > +limited to
> > + * the caller's array size.
> > + */
>=20
> Please use:
>=20
>  * Return: The number of free page blocks obtained from the free page lis=
t.
>=20
> Also, please include a
>=20
>  * Context: Any context.
>=20
> or
>=20
>  * Context: Process context.
>=20
> or whatever other conetext this function can be called from.  Since you'r=
e
> taking the lock irqsafe, I assume this can be called from any context, bu=
t I
> wonder if it makes sense to have this function callable from interrupt co=
ntext.
> Maybe this should be callable from process context only.

Thanks, sounds better to make it process context only.

>=20
> > +uint32_t get_from_free_page_list(int order, __le64 buf[], uint32_t
> > +size) {
> > +	struct zone *zone;
> > +	enum migratetype mt;
> > +	struct page *page;
> > +	struct list_head *list;
> > +	unsigned long addr, flags;
> > +	uint32_t index =3D 0;
> > +
> > +	for_each_populated_zone(zone) {
> > +		spin_lock_irqsave(&zone->lock, flags);
> > +		for (mt =3D 0; mt < MIGRATE_TYPES; mt++) {
> > +			list =3D &zone->free_area[order].free_list[mt];
> > +			list_for_each_entry(page, list, lru) {
> > +				addr =3D page_to_pfn(page) << PAGE_SHIFT;
> > +				if (likely(index < size)) {
> > +					buf[index++] =3D cpu_to_le64(addr);
> > +				} else {
> > +					spin_unlock_irqrestore(&zone->lock,
> > +							       flags);
> > +					return index;
> > +				}
> > +			}
> > +		}
> > +		spin_unlock_irqrestore(&zone->lock, flags);
> > +	}
> > +
> > +	return index;
> > +}
>=20
> I wonder if (to address Michael's concern), you shouldn't instead use the=
 first
> free chunk of pages to return the addresses of all the pages.
> ie something like this:
>=20
> 	__le64 *ret =3D NULL;
> 	unsigned int max =3D (PAGE_SIZE << order) / sizeof(__le64);
>=20
> 	for_each_populated_zone(zone) {
> 		spin_lock_irq(&zone->lock);
> 		for (mt =3D 0; mt < MIGRATE_TYPES; mt++) {
> 			list =3D &zone->free_area[order].free_list[mt];
> 			list_for_each_entry_safe(page, list, lru, ...) {
> 				if (index =3D=3D size)
> 					break;
> 				addr =3D page_to_pfn(page) << PAGE_SHIFT;
> 				if (!ret) {
> 					list_del(...);

Thanks for sharing. But probably we would not take this approach for the re=
asons below:

1) I'm not sure if getting a block of free pages to use could be that simpl=
e (just pluck it from the list as above). I think it is more prudent to let=
 the callers allocate the array via the regular allocation functions.=20

2) Callers may need to use this with their own defined protocols, and they =
want the header and payload (i.e. the obtained hints) to locate in physical=
ly continuous memory (there are tricks they can use to make it work with no=
n-physically continuous memory, but that would just complicate all the thin=
gs) . In this case, it is better to have callers allocate the memory on the=
ir own, and pass the payload part memory to this API to get the payload fil=
led.

Best,
Wei
