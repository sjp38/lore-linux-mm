Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f171.google.com (mail-pf0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 913C96B0255
	for <linux-mm@kvack.org>; Fri,  4 Mar 2016 09:27:08 -0500 (EST)
Received: by mail-pf0-f171.google.com with SMTP id x188so12626896pfb.2
        for <linux-mm@kvack.org>; Fri, 04 Mar 2016 06:27:08 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id z86si4366879pfa.67.2016.03.04.06.27.07
        for <linux-mm@kvack.org>;
        Fri, 04 Mar 2016 06:27:07 -0800 (PST)
From: "Li, Liang Z" <liang.z.li@intel.com>
Subject: RE: [Qemu-devel] [RFC qemu 0/4] A PV solution for live migration
 optimization
Date: Fri, 4 Mar 2016 14:26:49 +0000
Message-ID: <F2CBF3009FA73547804AE4C663CAB28E0414516C@shsmsx102.ccr.corp.intel.com>
References: <1457001868-15949-1-git-send-email-liang.z.li@intel.com>
 <20160303174615.GF2115@work-vm>
 <F2CBF3009FA73547804AE4C663CAB28E03770E33@SHSMSX101.ccr.corp.intel.com>
 <20160304081411.GD9100@rkaganb.sw.ru>
 <F2CBF3009FA73547804AE4C663CAB28E0377160A@SHSMSX101.ccr.corp.intel.com>
 <20160304102346.GB2479@rkaganb.sw.ru>
In-Reply-To: <20160304102346.GB2479@rkaganb.sw.ru>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Kagan <rkagan@virtuozzo.com>
Cc: "Dr. David Alan Gilbert" <dgilbert@redhat.com>, "ehabkost@redhat.com" <ehabkost@redhat.com>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "mst@redhat.com" <mst@redhat.com>, "quintela@redhat.com" <quintela@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "rth@twiddle.net" <rth@twiddle.net>

> Subject: Re: [Qemu-devel] [RFC qemu 0/4] A PV solution for live migration
> optimization
>=20
> On Fri, Mar 04, 2016 at 09:08:44AM +0000, Li, Liang Z wrote:
> > > On Fri, Mar 04, 2016 at 01:52:53AM +0000, Li, Liang Z wrote:
> > > > >   I wonder if it would be possible to avoid the kernel changes
> > > > > by parsing /proc/self/pagemap - if that can be used to detect
> > > > > unmapped/zero mapped pages in the guest ram, would it achieve
> > > > > the
> > > same result?
> > > >
> > > > Only detect the unmapped/zero mapped pages is not enough.
> Consider
> > > the
> > > > situation like case 2, it can't achieve the same result.
> > >
> > > Your case 2 doesn't exist in the real world.  If people could stop
> > > their main memory consumer in the guest prior to migration they
> > > wouldn't need live migration at all.
> >
> > The case 2 is just a simplified scenario, not a real case.
> > As long as the guest's memory usage does not keep increasing, or not
> > always run out, it can be covered by the case 2.
>=20
> The memory usage will keep increasing due to ever growing caches, etc, so
> you'll be left with very little free memory fairly soon.
>=20

I don't think so.

> > > I tend to think you can safely assume there's no free memory in the
> > > guest, so there's little point optimizing for it.
> >
> > If this is true, we should not inflate the balloon either.
>=20
> We certainly should if there's "available" memory, i.e. not free but chea=
p to
> reclaim.
>=20

What's your mean by "available" memory? if they are not free, I don't think=
 it's cheap.

> > > OTOH it makes perfect sense optimizing for the unmapped memory
> > > that's made up, in particular, by the ballon, and consider inflating
> > > the balloon right before migration unless you already maintain it at
> > > the optimal size for other reasons (like e.g. a global resource manag=
er
> optimizing the VM density).
> > >
> >
> > Yes, I believe the current balloon works and it's simple. Do you take t=
he
> performance impact for consideration?
> > For and 8G guest, it takes about 5s to  inflating the balloon. But it
> > only takes 20ms to  traverse the free_list and construct the free pages
> bitmap.
>=20
> I don't have any feeling of how important the difference is.  And if the
> limiting factor for balloon inflation speed is the granularity of communi=
cation
> it may be worth optimizing that, because quick balloon reaction may be
> important in certain resource management scenarios.
>=20
> > By inflating the balloon, all the guest's pages are still be processed =
(zero
> page checking).
>=20
> Not sure what you mean.  If you describe the current state of affairs tha=
t's
> exactly the suggested optimization point: skip unmapped pages.
>=20

You'd better check the live migration code.

> > The only advantage of ' inflating the balloon before live migration' is=
 simple,
> nothing more.
>=20
> That's a big advantage.  Another one is that it does something useful in =
real-
> world scenarios.
>=20

I don't think the heave performance impaction is something useful in real w=
orld scenarios.

Liang
> Roman.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
