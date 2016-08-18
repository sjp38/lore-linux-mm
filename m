Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id CDC356B0038
	for <linux-mm@kvack.org>; Wed, 17 Aug 2016 21:06:02 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id ag5so8048626pad.2
        for <linux-mm@kvack.org>; Wed, 17 Aug 2016 18:06:02 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id t3si40378622pfd.290.2016.08.17.18.06.01
        for <linux-mm@kvack.org>;
        Wed, 17 Aug 2016 18:06:01 -0700 (PDT)
From: "Li, Liang Z" <liang.z.li@intel.com>
Subject: RE: [PATCH v3 kernel 0/7] Extend virtio-balloon for fast
 (de)inflating & fast live migration
Date: Thu, 18 Aug 2016 01:05:53 +0000
Message-ID: <F2CBF3009FA73547804AE4C663CAB28E04220EDA@shsmsx102.ccr.corp.intel.com>
References: <1470638134-24149-1-git-send-email-liang.z.li@intel.com>
In-Reply-To: <1470638134-24149-1-git-send-email-liang.z.li@intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "quintela@redhat.com" <quintela@redhat.com>, "dgilbert@redhat.com" <dgilbert@redhat.com>, "Hansen, Dave" <dave.hansen@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Hi Michael,

Could you help to review this version when you have time?=20

Thanks!
Liang

> -----Original Message-----
> From: Li, Liang Z
> Sent: Monday, August 08, 2016 2:35 PM
> To: linux-kernel@vger.kernel.org
> Cc: virtualization@lists.linux-foundation.org; linux-mm@kvack.org; virtio=
-
> dev@lists.oasis-open.org; kvm@vger.kernel.org; qemu-devel@nongnu.org;
> quintela@redhat.com; dgilbert@redhat.com; Hansen, Dave; Li, Liang Z
> Subject: [PATCH v3 kernel 0/7] Extend virtio-balloon for fast (de)inflati=
ng &
> fast live migration
>=20
> This patch set contains two parts of changes to the virtio-balloon.
>=20
> One is the change for speeding up the inflating & deflating process, the =
main
> idea of this optimization is to use bitmap to send the page information t=
o
> host instead of the PFNs, to reduce the overhead of virtio data transmiss=
ion,
> address translation and madvise(). This can help to improve the performan=
ce
> by about 85%.
>=20
> Another change is for speeding up live migration. By skipping process gue=
st's
> free pages in the first round of data copy, to reduce needless data proce=
ssing,
> this can help to save quite a lot of CPU cycles and network bandwidth. We
> put guest's free page information in bitmap and send it to host with the =
virt
> queue of virtio-balloon. For an idle 8GB guest, this can help to shorten =
the
> total live migration time from 2Sec to about 500ms in the 10Gbps network
> environment.
>=20
> Dave Hansen suggested a new scheme to encode the data structure,
> because of additional complexity, it's not implemented in v3.
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
>=20
> Liang Li (7):
>   virtio-balloon: rework deflate to add page to a list
>   virtio-balloon: define new feature bit and page bitmap head
>   mm: add a function to get the max pfn
>   virtio-balloon: speed up inflate/deflate process
>   mm: add the related functions to get unused page
>   virtio-balloon: define feature bit and head for misc virt queue
>   virtio-balloon: tell host vm's unused page info
>=20
>  drivers/virtio/virtio_balloon.c     | 390
> ++++++++++++++++++++++++++++++++----
>  include/linux/mm.h                  |   3 +
>  include/uapi/linux/virtio_balloon.h |  41 ++++
>  mm/page_alloc.c                     |  94 +++++++++
>  4 files changed, 485 insertions(+), 43 deletions(-)
>=20
> --
> 1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
