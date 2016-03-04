Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 5D4656B007E
	for <linux-mm@kvack.org>; Fri,  4 Mar 2016 10:49:43 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id fy10so36775325pac.1
        for <linux-mm@kvack.org>; Fri, 04 Mar 2016 07:49:43 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id sf6si6524893pac.76.2016.03.04.07.49.42
        for <linux-mm@kvack.org>;
        Fri, 04 Mar 2016 07:49:42 -0800 (PST)
From: "Li, Liang Z" <liang.z.li@intel.com>
Subject: RE: [Qemu-devel] [RFC qemu 0/4] A PV solution for live migration
 optimization
Date: Fri, 4 Mar 2016 15:49:37 +0000
Message-ID: <F2CBF3009FA73547804AE4C663CAB28E041452EA@shsmsx102.ccr.corp.intel.com>
References: <1457001868-15949-1-git-send-email-liang.z.li@intel.com>
 <20160303174615.GF2115@work-vm>
 <F2CBF3009FA73547804AE4C663CAB28E03770E33@SHSMSX101.ccr.corp.intel.com>
 <20160304081411.GD9100@rkaganb.sw.ru>
 <F2CBF3009FA73547804AE4C663CAB28E0377160A@SHSMSX101.ccr.corp.intel.com>
 <20160304102346.GB2479@rkaganb.sw.ru>
 <F2CBF3009FA73547804AE4C663CAB28E0414516C@shsmsx102.ccr.corp.intel.com>
 <20160304163246-mutt-send-email-mst@redhat.com>
In-Reply-To: <20160304163246-mutt-send-email-mst@redhat.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Roman Kagan <rkagan@virtuozzo.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, "ehabkost@redhat.com" <ehabkost@redhat.com>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "quintela@redhat.com" <quintela@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "rth@twiddle.net" <rth@twiddle.net>

> > > > > > Only detect the unmapped/zero mapped pages is not enough.
> > > Consider
> > > > > the
> > > > > > situation like case 2, it can't achieve the same result.
> > > > >
> > > > > Your case 2 doesn't exist in the real world.  If people could
> > > > > stop their main memory consumer in the guest prior to migration
> > > > > they wouldn't need live migration at all.
> > > >
> > > > The case 2 is just a simplified scenario, not a real case.
> > > > As long as the guest's memory usage does not keep increasing, or
> > > > not always run out, it can be covered by the case 2.
> > >
> > > The memory usage will keep increasing due to ever growing caches,
> > > etc, so you'll be left with very little free memory fairly soon.
> > >
> >
> > I don't think so.
>=20
> Here's my laptop:
> KiB Mem : 16048560 total,  8574956 free,  3360532 used,  4113072 buff/cac=
he
>=20
> But here's a server:
> KiB Mem:  32892768 total, 20092812 used, 12799956 free,   368704 buffers
>=20
> What is the difference? A ton of tiny daemons not doing anything, staying
> resident in memory.
>=20
> > > > > I tend to think you can safely assume there's no free memory in
> > > > > the guest, so there's little point optimizing for it.
> > > >
> > > > If this is true, we should not inflate the balloon either.
> > >
> > > We certainly should if there's "available" memory, i.e. not free but
> > > cheap to reclaim.
> > >
> >
> > What's your mean by "available" memory? if they are not free, I don't t=
hink
> it's cheap.
>=20
> clean pages are cheap to drop as they don't have to be written.
> whether they will be ever be used is another matter.
>=20
> > > > > OTOH it makes perfect sense optimizing for the unmapped memory
> > > > > that's made up, in particular, by the ballon, and consider
> > > > > inflating the balloon right before migration unless you already
> > > > > maintain it at the optimal size for other reasons (like e.g. a
> > > > > global resource manager
> > > optimizing the VM density).
> > > > >
> > > >
> > > > Yes, I believe the current balloon works and it's simple. Do you
> > > > take the
> > > performance impact for consideration?
> > > > For and 8G guest, it takes about 5s to  inflating the balloon. But
> > > > it only takes 20ms to  traverse the free_list and construct the
> > > > free pages
> > > bitmap.
> > >
> > > I don't have any feeling of how important the difference is.  And if
> > > the limiting factor for balloon inflation speed is the granularity
> > > of communication it may be worth optimizing that, because quick
> > > balloon reaction may be important in certain resource management
> scenarios.
> > >
> > > > By inflating the balloon, all the guest's pages are still be
> > > > processed (zero
> > > page checking).
> > >
> > > Not sure what you mean.  If you describe the current state of
> > > affairs that's exactly the suggested optimization point: skip unmappe=
d
> pages.
> > >
> >
> > You'd better check the live migration code.
>=20
> What's there to check in migration code?
> Here's the extent of what balloon does on output:
>=20
>=20
>         while (iov_to_buf(elem->out_sg, elem->out_num, offset, &pfn, 4) =
=3D=3D 4)
> {
>             ram_addr_t pa;
>             ram_addr_t addr;
>             int p =3D virtio_ldl_p(vdev, &pfn);
>=20
>             pa =3D (ram_addr_t) p << VIRTIO_BALLOON_PFN_SHIFT;
>             offset +=3D 4;
>=20
>             /* FIXME: remove get_system_memory(), but how? */
>             section =3D memory_region_find(get_system_memory(), pa, 1);
>             if (!int128_nz(section.size) || !memory_region_is_ram(section=
.mr))
>                 continue;
>=20
>=20
> trace_virtio_balloon_handle_output(memory_region_name(section.mr),
>                                                pa);
>             /* Using memory_region_get_ram_ptr is bending the rules a bit=
, but
>                should be OK because we only want a single page.  */
>             addr =3D section.offset_within_region;
>             balloon_page(memory_region_get_ram_ptr(section.mr) + addr,
>                          !!(vq =3D=3D s->dvq));
>             memory_region_unref(section.mr);
>         }
>=20
> so all that happens when we get a page is balloon_page.
> and
>=20
> static void balloon_page(void *addr, int deflate) { #if defined(__linux__=
)
>     if (!qemu_balloon_is_inhibited() && (!kvm_enabled() ||
>                                          kvm_has_sync_mmu())) {
>         qemu_madvise(addr, TARGET_PAGE_SIZE,
>                 deflate ? QEMU_MADV_WILLNEED : QEMU_MADV_DONTNEED);
>     }
> #endif
> }
>=20
>=20
> Do you see anything that tracks pages to help migration skip the balloone=
d
> memory? I don't.
>=20

No. And it's exactly what I mean. The ballooned memory is still processed d=
uring
live migration without skipping. The live migration code is in migration/ra=
m.c.

>=20
> > > > The only advantage of ' inflating the balloon before live
> > > > migration' is simple,
> > > nothing more.
> > >
> > > That's a big advantage.  Another one is that it does something
> > > useful in real- world scenarios.
> > >
> >
> > I don't think the heave performance impaction is something useful in re=
al
> world scenarios.
> >
> > Liang
> > > Roman.
>=20
> So fix the performance then. You will have to try harder if you want to
> convince people that the performance is due to bad host/guest interface,
> and so we have to change *that*.
>=20

Actually, the PV solution is irrelevant with the balloon mechanism, I just =
use it
to transfer information between host and guest.=20
I am not sure if I should implement a new virtio device, and I want to get =
the answer from
the community.
In this RFC patch, to make things simple, I choose to extend the virtio-bal=
loon and use the
extended interface to transfer the request and free_page_bimap content.

I am not intend to change the current virtio-balloon implementation.

Liang

> --
> MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
