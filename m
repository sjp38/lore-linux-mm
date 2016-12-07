Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id BF8A06B0038
	for <linux-mm@kvack.org>; Wed,  7 Dec 2016 08:35:30 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id c4so601045449pfb.7
        for <linux-mm@kvack.org>; Wed, 07 Dec 2016 05:35:30 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id z21si24086972pgi.50.2016.12.07.05.35.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Dec 2016 05:35:29 -0800 (PST)
From: "Li, Liang Z" <liang.z.li@intel.com>
Subject: RE: [PATCH kernel v5 0/5] Extend virtio-balloon for fast
 (de)inflating & fast live migration
Date: Wed, 7 Dec 2016 13:35:26 +0000
Message-ID: <F2CBF3009FA73547804AE4C663CAB28E3A130C01@shsmsx102.ccr.corp.intel.com>
References: <1480495397-23225-1-git-send-email-liang.z.li@intel.com>
 <f67ca79c-ad34-59dd-835f-e7bc9dcaef58@redhat.com>
In-Reply-To: <f67ca79c-ad34-59dd-835f-e7bc9dcaef58@redhat.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>
Cc: "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "mhocko@suse.com" <mhocko@suse.com>, "mst@redhat.com" <mst@redhat.com>, "Hansen, Dave" <dave.hansen@intel.com>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "dgilbert@redhat.com" <dgilbert@redhat.com>

> Am 30.11.2016 um 09:43 schrieb Liang Li:
> > This patch set contains two parts of changes to the virtio-balloon.
> >
> > One is the change for speeding up the inflating & deflating process,
> > the main idea of this optimization is to use bitmap to send the page
> > information to host instead of the PFNs, to reduce the overhead of
> > virtio data transmission, address translation and madvise(). This can
> > help to improve the performance by about 85%.
>=20
> Do you have some statistics/some rough feeling how many consecutive bits =
are
> usually set in the bitmaps? Is it really just purely random or is there s=
ome
> granularity that is usually consecutive?
>=20

I did something similar. Filled the balloon with 15GB for a 16GB idle guest=
, by
using bitmap, the madvise count was reduced to 605. when using the PFNs, th=
e madvise count
was 3932160. It means there are quite a lot consecutive bits in the bitmap.
I didn't test for a guest with heavy memory workload.=20

> IOW in real examples, do we have really large consecutive areas or are al=
l
> pages just completely distributed over our memory?
>=20

The buddy system of Linux kernel memory management shows there should be qu=
ite a lot of
 consecutive pages as long as there are a portion of free memory in the gue=
st.
If all pages just completely distributed over our memory, it means the memo=
ry=20
fragmentation is very serious, the kernel has the mechanism to avoid this h=
appened.
In the other hand, the inflating should not happen at this time because the=
 guest is almost
'out of memory'.

Liang

> Thanks!
>=20
> --
>=20
> David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
