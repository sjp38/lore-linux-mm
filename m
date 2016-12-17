Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 286F16B0261
	for <linux-mm@kvack.org>; Sat, 17 Dec 2016 06:56:45 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id g1so17721322pgn.3
        for <linux-mm@kvack.org>; Sat, 17 Dec 2016 03:56:45 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id z21si12258029pgi.50.2016.12.17.03.56.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 17 Dec 2016 03:56:44 -0800 (PST)
From: "Li, Liang Z" <liang.z.li@intel.com>
Subject: RE: [Qemu-devel] [PATCH kernel v5 0/5] Extend virtio-balloon for
 fast (de)inflating & fast live migration
Date: Sat, 17 Dec 2016 11:56:40 +0000
Message-ID: <F2CBF3009FA73547804AE4C663CAB28E3C32C4A1@shsmsx102.ccr.corp.intel.com>
References: <d3ff453c-56fa-19de-317c-1c82456f2831@intel.com>
 <20161207183817.GE28786@redhat.com>
 <b58fd9f6-d9dd-dd56-d476-dd342174dac5@intel.com>
 <20161207202824.GH28786@redhat.com>
 <F2CBF3009FA73547804AE4C663CAB28E3A14E2AD@SHSMSX104.ccr.corp.intel.com>
 <060287c7-d1af-45d5-70ea-ad35d4bbeb84@intel.com>
 <F2CBF3009FA73547804AE4C663CAB28E3C31D0E6@SHSMSX104.ccr.corp.intel.com>
 <01886693-c73e-3696-860b-086417d695e1@intel.com>
 <20161215173901-mutt-send-email-mst@kernel.org>
 <F2CBF3009FA73547804AE4C663CAB28E3C32A899@shsmsx102.ccr.corp.intel.com>
 <20161216154049.GB6168@redhat.com>
In-Reply-To: <20161216154049.GB6168@redhat.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, "Hansen, Dave" <dave.hansen@intel.com>, David Hildenbrand <david@redhat.com>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "mhocko@suse.com" <mhocko@suse.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "dgilbert@redhat.com" <dgilbert@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>

> On Fri, Dec 16, 2016 at 01:12:21AM +0000, Li, Liang Z wrote:
> > There still exist the case if the MAX_ORDER is configured to a large
> > value, e.g. 36 for a system with huge amount of memory, then there is o=
nly
> 28 bits left for the pfn, which is not enough.
>=20
> Not related to the balloon but how would it help to set MAX_ORDER to 36?
>=20

My point here is  MAX_ORDER may be configured to a big value.

> What the MAX_ORDER affects is that you won't be able to ask the kernel
> page allocator for contiguous memory bigger than 1<<(MAX_ORDER-1), but
> that's a driver issue not relevant to the amount of RAM. Drivers won't
> suddenly start to ask the kernel allocator to allocate compound pages at
> orders >=3D 11 just because more RAM was added.
>=20
> The higher the MAX_ORDER the slower the kernel runs simply so the smaller
> the MAX_ORDER the better.
>=20
> > Should  we limit the MAX_ORDER? I don't think so.
>=20
> We shouldn't strictly depend on MAX_ORDER value but it's mostly limited
> already even if configurable at build time.
>=20

I didn't know that and will take a look, thanks for your information.


Liang
> We definitely need it to reach at least the hugepage size, then it's most=
ly
> driver issue, but drivers requiring large contiguous allocations should r=
ely on
> CMA only or vmalloc if they only require it virtually contiguous, and not=
 rely
> on larger MAX_ORDER that would slowdown all kernel allocations/freeing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
