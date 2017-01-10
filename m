Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9F1016B0038
	for <linux-mm@kvack.org>; Tue, 10 Jan 2017 01:43:29 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 127so707226201pfg.5
        for <linux-mm@kvack.org>; Mon, 09 Jan 2017 22:43:29 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id d1si1104525pld.20.2017.01.09.22.43.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Jan 2017 22:43:28 -0800 (PST)
From: "Li, Liang Z" <liang.z.li@intel.com>
Subject: RE: [PATCH v6 kernel 0/5] Extend virtio-balloon for fast
 (de)inflating & fast live migration
Date: Tue, 10 Jan 2017 06:43:23 +0000
Message-ID: <F2CBF3009FA73547804AE4C663CAB28E3C34EE1E@shsmsx102.ccr.corp.intel.com>
References: <1482303148-22059-1-git-send-email-liang.z.li@intel.com>
In-Reply-To: <1482303148-22059-1-git-send-email-liang.z.li@intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "kvm@vger.kernel.org" <kvm@vger.kernel.org>
Cc: "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "Hansen, Dave" <dave.hansen@intel.com>, "cornelia.huck@de.ibm.com" <cornelia.huck@de.ibm.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "mst@redhat.com" <mst@redhat.com>, "david@redhat.com" <david@redhat.com>, "aarcange@redhat.com" <aarcange@redhat.com>, "dgilbert@redhat.com" <dgilbert@redhat.com>, "quintela@redhat.com" <quintela@redhat.com>

Hi guys,

Could you help to review this patch set?

Thanks!
Liang

> -----Original Message-----
> From: Li, Liang Z
> Sent: Wednesday, December 21, 2016 2:52 PM
> To: kvm@vger.kernel.org
> Cc: virtio-dev@lists.oasis-open.org; qemu-devel@nongnu.org; linux-
> mm@kvack.org; linux-kernel@vger.kernel.org; virtualization@lists.linux-
> foundation.org; amit.shah@redhat.com; Hansen, Dave;
> cornelia.huck@de.ibm.com; pbonzini@redhat.com; mst@redhat.com;
> david@redhat.com; aarcange@redhat.com; dgilbert@redhat.com;
> quintela@redhat.com; Li, Liang Z
> Subject: [PATCH v6 kernel 0/5] Extend virtio-balloon for fast (de)inflati=
ng &
> fast live migration
>=20
> This patch set contains two parts of changes to the virtio-balloon.
>=20
> One is the change for speeding up the inflating & deflating process, the =
main
> idea of this optimization is to use {pfn|length} to present the page
> information instead of the PFNs, to reduce the overhead of virtio data
> transmission, address translation and madvise(). This can help to improve=
 the
> performance by about 85%.
>=20
> Another change is for speeding up live migration. By skipping process gue=
st's
> unused pages in the first round of data copy, to reduce needless data
> processing, this can help to save quite a lot of CPU cycles and network
> bandwidth. We put guest's unused page information in a {pfn|length} array
> and send it to host with the virt queue of virtio-balloon. For an idle gu=
est with
> 8GB RAM, this can help to shorten the total live migration time from 2Sec=
 to
> about 500ms in 10Gbps network environment. For an guest with quite a lot
> of page cache and with little unused pages, it's possible to let the gues=
t drop
> it's page cache before live migration, this case can benefit from this ne=
w
> feature too.
>=20
> Changes from v5 to v6:
>     * Drop the bitmap from the virtio ABI, use {pfn|length} only.
>     * Enhance the API to get the unused page information from mm.
>=20
> Changes from v4 to v5:
>     * Drop the code to get the max_pfn, use another way instead.
>     * Simplify the API to get the unused page information from mm.
>=20
> Changes from v3 to v4:
>     * Use the new scheme suggested by Dave Hansen to encode the bitmap.
>     * Add code which is missed in v3 to handle migrate page.
>     * Free the memory for bitmap intime once the operation is done.
>     * Address some of the comments in v3.
>=20
> Changes from v2 to v3:
>     * Change the name of 'free page' to 'unused page'.
>     * Use the scatter & gather bitmap instead of a 1MB page bitmap.
>     * Fix overwriting the page bitmap after kicking.
>     * Some of MST's comments for v2.
>=20
> Changes from v1 to v2:
>     * Abandon the patch for dropping page cache.
>     * Put some structures to uapi head file.
>     * Use a new way to determine the page bitmap size.
>     * Use a unified way to send the free page information with the bitmap
>     * Address the issues referred in MST's comments
>=20
> Liang Li (5):
>   virtio-balloon: rework deflate to add page to a list
>   virtio-balloon: define new feature bit and head struct
>   virtio-balloon: speed up inflate/deflate process
>   virtio-balloon: define flags and head for host request vq
>   virtio-balloon: tell host vm's unused page info
>=20
>  drivers/virtio/virtio_balloon.c     | 510
> ++++++++++++++++++++++++++++++++----
>  include/linux/mm.h                  |   3 +
>  include/uapi/linux/virtio_balloon.h |  34 +++
>  mm/page_alloc.c                     | 120 +++++++++
>  4 files changed, 621 insertions(+), 46 deletions(-)
>=20
> --
> 1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
