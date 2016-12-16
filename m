Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id AC0226B0069
	for <linux-mm@kvack.org>; Thu, 15 Dec 2016 20:38:07 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id c4so100018244pfb.7
        for <linux-mm@kvack.org>; Thu, 15 Dec 2016 17:38:07 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id a23si4919687pfe.35.2016.12.15.17.38.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Dec 2016 17:38:06 -0800 (PST)
From: "Li, Liang Z" <liang.z.li@intel.com>
Subject: RE: [Qemu-devel] [PATCH kernel v5 0/5] Extend virtio-balloon for
 fast (de)inflating & fast live migration
Date: Fri, 16 Dec 2016 01:38:01 +0000
Message-ID: <F2CBF3009FA73547804AE4C663CAB28E3C32A8D6@shsmsx102.ccr.corp.intel.com>
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
 <F2CBF3009FA73547804AE4C663CAB28E3C32985A@shsmsx102.ccr.corp.intel.com>
 <f517bfbe-18b8-6962-5c57-545f6ef47ad0@intel.com>
In-Reply-To: <f517bfbe-18b8-6962-5c57-545f6ef47ad0@intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Hansen, Dave" <dave.hansen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>
Cc: David Hildenbrand <david@redhat.com>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "mhocko@suse.com" <mhocko@suse.com>, "mst@redhat.com" <mst@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "dgilbert@redhat.com" <dgilbert@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>

> On 12/15/2016 04:48 PM, Li, Liang Z wrote:
> >>> It seems we leave too many bit  for the pfn, and the bits leave for
> >>> length is not enough, How about keep 45 bits for the pfn and 19 bits
> >>> for length, 45 bits for pfn can cover 57 bits physical address, that
> >>> should be
> >> enough in the near feature.
> >>> What's your opinion?
> >> I still think 'order' makes a lot of sense.  But, as you say, 57 bits
> >> is enough for
> >> x86 for a while.  Other architectures.... who knows?
>=20
> Thinking about this some more...  There are really only two cases that
> matter: 4k pages and "much bigger" ones.
>=20
> Squeezing each 4k page into 8 bytes of metadata helps guarantee that this
> scheme won't regress over the old scheme in any cases.  For bigger ranges=
, 8
> vs 16 bytes means *nothing*.  And 16 bytes will be as good or better than
> the old scheme for everything which is >4k.
>=20
> How about this:
>  * 52 bits of 'pfn', 5 bits of 'order', 7 bits of 'length'
>  * One special 'length' value to mean "actual length in next 8 bytes"
>=20
> That should be pretty simple to produce and decode.  We have two record
> sizes, but I think it is manageable.

It works,  Now that we intend to use another 8 bytes for length

Why not:

Use 52 bits for 'pfn', 12 bits for 'length', when the 12 bits is not long e=
nough for the 'length'
Set the 'length' to a special value to indicate the "actual length in next =
8 bytes".

That will be much more simple. Right?

Liang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
