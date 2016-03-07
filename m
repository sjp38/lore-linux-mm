Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 9D9556B0254
	for <linux-mm@kvack.org>; Mon,  7 Mar 2016 10:06:30 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id bj10so80427034pad.2
        for <linux-mm@kvack.org>; Mon, 07 Mar 2016 07:06:30 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id lf12si3626894pab.207.2016.03.07.07.06.29
        for <linux-mm@kvack.org>;
        Mon, 07 Mar 2016 07:06:29 -0800 (PST)
From: "Li, Liang Z" <liang.z.li@intel.com>
Subject: RE: [Qemu-devel] [RFC qemu 0/4] A PV solution for live migration
 optimization
Date: Mon, 7 Mar 2016 15:06:25 +0000
Message-ID: <F2CBF3009FA73547804AE4C663CAB28E04146E09@shsmsx102.ccr.corp.intel.com>
References: <20160303174615.GF2115@work-vm>
 <F2CBF3009FA73547804AE4C663CAB28E03770E33@SHSMSX101.ccr.corp.intel.com>
 <20160304081411.GD9100@rkaganb.sw.ru>
 <F2CBF3009FA73547804AE4C663CAB28E0377160A@SHSMSX101.ccr.corp.intel.com>
 <20160304102346.GB2479@rkaganb.sw.ru>
 <F2CBF3009FA73547804AE4C663CAB28E0414516C@shsmsx102.ccr.corp.intel.com>
 <20160304163246-mutt-send-email-mst@redhat.com>
 <F2CBF3009FA73547804AE4C663CAB28E041452EA@shsmsx102.ccr.corp.intel.com>
 <20160305214748-mutt-send-email-mst@redhat.com>
 <F2CBF3009FA73547804AE4C663CAB28E04146308@shsmsx102.ccr.corp.intel.com>
 <20160307110852-mutt-send-email-mst@redhat.com>
In-Reply-To: <20160307110852-mutt-send-email-mst@redhat.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Roman Kagan <rkagan@virtuozzo.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, "ehabkost@redhat.com" <ehabkost@redhat.com>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "quintela@redhat.com" <quintela@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "rth@twiddle.net" <rth@twiddle.net>, "riel@redhat.com" <riel@redhat.com>

> Cc: Roman Kagan; Dr. David Alan Gilbert; ehabkost@redhat.com;
> kvm@vger.kernel.org; quintela@redhat.com; linux-kernel@vger.kernel.org;
> qemu-devel@nongnu.org; linux-mm@kvack.org; amit.shah@redhat.com;
> pbonzini@redhat.com; akpm@linux-foundation.org;
> virtualization@lists.linux-foundation.org; rth@twiddle.net; riel@redhat.c=
om
> Subject: Re: [Qemu-devel] [RFC qemu 0/4] A PV solution for live migration
> optimization
>=20
> On Mon, Mar 07, 2016 at 06:49:19AM +0000, Li, Liang Z wrote:
> > > > No. And it's exactly what I mean. The ballooned memory is still
> > > > processed during live migration without skipping. The live
> > > > migration code is
> > > in migration/ram.c.
> > >
> > > So if guest acknowledged VIRTIO_BALLOON_F_MUST_TELL_HOST, we
> can
> > > teach qemu to skip these pages.
> > > Want to write a patch to do this?
> > >
> >
> > Yes, we really can teach qemu to skip these pages and it's not hard.
> > The problem is the poor performance, this PV solution
>=20
> Balloon is always PV. And do not call patches solutions please.
>=20

OK.
 =20
> > is aimed to make it more
> > efficient and reduce the performance impact on guest.
>=20
> We need to get a bit beyond this.  You are making multiple changes, it se=
ems
> to make sense to split it all up, and analyse each change separately.  If=
 you
> don't this patchset will be stuck: as you have seen people aren't convinc=
ed it
> actually helps with real workloads.
>=20
Really, changing the virtio spec must have good reasons.

> > > > >
> > > > > > > > The only advantage of ' inflating the balloon before live
> > > > > > > > migration' is simple,
> > > > > > > nothing more.
> > > > > > >
> > > > > > > That's a big advantage.  Another one is that it does
> > > > > > > something useful in real- world scenarios.
> > > > > > >
> > > > > >
> > > > > > I don't think the heave performance impaction is something
> > > > > > useful in real
> > > > > world scenarios.
> > > > > >
> > > > > > Liang
> > > > > > > Roman.
> > > > >
> > > > > So fix the performance then. You will have to try harder if you
> > > > > want to convince people that the performance is due to bad
> > > > > host/guest interface, and so we have to change *that*.
> > > > >
> > > >
> > > > Actually, the PV solution is irrelevant with the balloon
> > > > mechanism, I just use it to transfer information between host and
> guest.
> > > > I am not sure if I should implement a new virtio device, and I
> > > > want to get the answer from the community.
> > > > In this RFC patch, to make things simple, I choose to extend the
> > > > virtio-balloon and use the extended interface to transfer the
> > > > request and
> > > free_page_bimap content.
> > > >
> > > > I am not intend to change the current virtio-balloon implementation=
.
> > > >
> > > > Liang
> > >
> > > And the answer would depend on the answer to my question above.
> > > Does balloon need an interface passing page bitmaps around?
> >
> > Yes, I need a new interface.
>=20
> Possibly, but you will need to justify this at some level if you care abo=
ut
> upstreaming your patches.
>=20
> > > Does this speed up any operations?
> >
> > No, a new interface will not speed up anything, but it is the easiest w=
ay to
> solve the compatibility issue.
>=20
> A bunch of new code is often easier to write than to figure out the old o=
ne,
> but if we keep piling it up we'll end up with an unmaintainable mess. So =
we
> are rather careful about adding new interfaces, and we try to make them
> generic sometimes even at cost of slight inefficiencies.
>=20
> > > OTOH what if you use the regular balloon interface with your patches?
> > >
> >
> > The regular balloon interfaces have their specific function and I can't=
 use
> them in my patches.
> > If using these regular interface, I have to do a lot of changes to keep=
 the
> compatibility.
>=20
> Why can't you?
>=20
> What exactly do we need to change?
>=20
> If we put things in terms of the balloon, that supports adding and removi=
ng
> pages.
>=20
> Using these terms, let's enumerate:
> - a new method (e.g. new virtqueue) that adds and immediately removes
> page in a balloon
> 	clearly, you can add then remove using the existing interfaces
> 	is a single command significantly faster than using existing two vqs?
> - a new kind of request that says "add (and immediately remove?) as many
> pages as you can"
> 	sounds rather benign
> - a new kind of message that adds multiple pages using a bitmap
>   	(instead of an address list)
> 	again, is this significantly faster?

More of less faster because of less data traffic. I didn't measure this,  I=
 will do it and take a deep look
at the way you suggest if we choose to make use of the virtio-balloon inter=
face.

>=20
> Does not look like compatibility is an issue, to me.
>=20
>=20
> At some level, your patches look like page hints.
> If we have more patches in mind that use page hints, then a new hint devi=
ce
> might make sense.
>=20

Yes, I have ever considered to implement a new device, use the virtio-ballo=
on to
transfer the free pages information which is irrelevant  with the balloon m=
echanism
is some more or less confusing.

> However, people experimented with page hints in the past, so far this alw=
ays
> went nowhere.  E.g. I CC Rick who saw some problems when page hints
> interact with huge pages. Rick, could you elaborate please?
>=20

Thanks a lot. Can't wait to know the problems.

Liang
>=20
> --
> MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
