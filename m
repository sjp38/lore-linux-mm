Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5E1636B0069
	for <linux-mm@kvack.org>; Thu, 15 Dec 2016 19:48:10 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 144so98400907pfv.5
        for <linux-mm@kvack.org>; Thu, 15 Dec 2016 16:48:10 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id m8si4716556pli.198.2016.12.15.16.48.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Dec 2016 16:48:09 -0800 (PST)
From: "Li, Liang Z" <liang.z.li@intel.com>
Subject: RE: [Qemu-devel] [PATCH kernel v5 0/5] Extend virtio-balloon for
 fast (de)inflating & fast live migration
Date: Fri, 16 Dec 2016 00:48:07 +0000
Message-ID: <F2CBF3009FA73547804AE4C663CAB28E3C32985A@shsmsx102.ccr.corp.intel.com>
References: <1480495397-23225-1-git-send-email-liang.z.li@intel.com>
 <f67ca79c-ad34-59dd-835f-e7bc9dcaef58@redhat.com>
 <F2CBF3009FA73547804AE4C663CAB28E3A130C01@shsmsx102.ccr.corp.intel.com>
 <0b18c636-ee67-cbb4-1ba3-81a06150db76@redhat.com>
 <0b83db29-ebad-2a70-8d61-756d33e33a48@intel.com>
 <2171e091-46ee-decd-7348-772555d3a5e3@redhat.com>
 <d3ff453c-56fa-19de-317c-1c82456f2831@intel.com>
 <20161207183817.GE28786@redhat.com>
 <b58fd9f6-d9dd-dd56-d476-dd342174dac5@intel.com>
 <20161207202824.GH28786@redhat.com>
 <F2CBF3009FA73547804AE4C663CAB28E3A14E2AD@SHSMSX104.ccr.corp.intel.com>
 <060287c7-d1af-45d5-70ea-ad35d4bbeb84@intel.com>
 <F2CBF3009FA73547804AE4C663CAB28E3C31D0E6@SHSMSX104.ccr.corp.intel.com>
 <01886693-c73e-3696-860b-086417d695e1@intel.com>
In-Reply-To: <01886693-c73e-3696-860b-086417d695e1@intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Hansen, Dave" <dave.hansen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>
Cc: David Hildenbrand <david@redhat.com>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "mhocko@suse.com" <mhocko@suse.com>, "mst@redhat.com" <mst@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "dgilbert@redhat.com" <dgilbert@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>

> Subject: Re: [Qemu-devel] [PATCH kernel v5 0/5] Extend virtio-balloon for
> fast (de)inflating & fast live migration
>=20
> On 12/14/2016 12:59 AM, Li, Liang Z wrote:
> >> Subject: Re: [Qemu-devel] [PATCH kernel v5 0/5] Extend virtio-balloon
> >> for fast (de)inflating & fast live migration
> >>
> >> On 12/08/2016 08:45 PM, Li, Liang Z wrote:
> >>> What's the conclusion of your discussion? It seems you want some
> >>> statistic before deciding whether to  ripping the bitmap from the
> >>> ABI, am I right?
> >>
> >> I think Andrea and David feel pretty strongly that we should remove
> >> the bitmap, unless we have some data to support keeping it.  I don't
> >> feel as strongly about it, but I think their critique of it is pretty
> >> valid.  I think the consensus is that the bitmap needs to go.
> >>
> >> The only real question IMNHO is whether we should do a power-of-2 or
> >> a length.  But, if we have 12 bits, then the argument for doing
> >> length is pretty strong.  We don't need anywhere near 12 bits if doing
> power-of-2.
> >
> > Just found the MAX_ORDER should be limited to 12 if use length instead
> > of order, If the MAX_ORDER is configured to a value bigger than 12, it
> > will make things more complex to handle this case.
> >
> > If use order, we need to break a large memory range whose length is
> > not the power of 2 into several small ranges, it also make the code com=
plex.
>=20
> I can't imagine it makes the code that much more complex.  It adds a for =
loop.
> Right?
>=20

Yes, just a little. :)

> > It seems we leave too many bit  for the pfn, and the bits leave for
> > length is not enough, How about keep 45 bits for the pfn and 19 bits
> > for length, 45 bits for pfn can cover 57 bits physical address, that sh=
ould be
> enough in the near feature.
> >
> > What's your opinion?
>=20
> I still think 'order' makes a lot of sense.  But, as you say, 57 bits is =
enough for
> x86 for a while.  Other architectures.... who knows?

Yes.=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
