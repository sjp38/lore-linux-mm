Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 93B0F6B0038
	for <linux-mm@kvack.org>; Wed, 31 Aug 2016 02:28:23 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id o124so87645023pfg.1
        for <linux-mm@kvack.org>; Tue, 30 Aug 2016 23:28:23 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id kv2si49168221pab.145.2016.08.30.23.28.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Aug 2016 23:28:22 -0700 (PDT)
From: "Li, Liang Z" <liang.z.li@intel.com>
Subject: RE: [PATCH v3 kernel 0/7] Extend virtio-balloon for fast
 (de)inflating & fast live migration
Date: Wed, 31 Aug 2016 06:28:10 +0000
Message-ID: <F2CBF3009FA73547804AE4C663CAB28E3A01BCFE@shsmsx102.ccr.corp.intel.com>
References: <1470638134-24149-1-git-send-email-liang.z.li@intel.com>
 <F2CBF3009FA73547804AE4C663CAB28E04220EDA@shsmsx102.ccr.corp.intel.com>
In-Reply-To: <F2CBF3009FA73547804AE4C663CAB28E04220EDA@shsmsx102.ccr.corp.intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "'Michael S. Tsirkin'" <mst@redhat.com>
Cc: "'virtualization@lists.linux-foundation.org'" <virtualization@lists.linux-foundation.org>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>, "'virtio-dev@lists.oasis-open.org'" <virtio-dev@lists.oasis-open.org>, "'kvm@vger.kernel.org'" <kvm@vger.kernel.org>, "'qemu-devel@nongnu.org'" <qemu-devel@nongnu.org>, "'quintela@redhat.com'" <quintela@redhat.com>, "'dgilbert@redhat.com'" <dgilbert@redhat.com>, "Hansen, Dave" <dave.hansen@intel.com>, "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>

Hi Michael,

I know you are very busy. If you have time, could you help to take a look a=
t this patch set?

Thanks!
Liang

> -----Original Message-----
> From: Li, Liang Z
> Sent: Thursday, August 18, 2016 9:06 AM
> To: Michael S. Tsirkin
> Cc: virtualization@lists.linux-foundation.org; linux-mm@kvack.org; virtio=
-
> dev@lists.oasis-open.org; kvm@vger.kernel.org; qemu-devel@nongnu.org;
> quintela@redhat.com; dgilbert@redhat.com; Hansen, Dave; linux-
> kernel@vger.kernel.org
> Subject: RE: [PATCH v3 kernel 0/7] Extend virtio-balloon for fast (de)inf=
lating
> & fast live migration
>=20
> Hi Michael,
>=20
> Could you help to review this version when you have time?
>=20
> Thanks!
> Liang
>=20
> > -----Original Message-----
> > From: Li, Liang Z
> > Sent: Monday, August 08, 2016 2:35 PM
> > To: linux-kernel@vger.kernel.org
> > Cc: virtualization@lists.linux-foundation.org; linux-mm@kvack.org;
> > virtio- dev@lists.oasis-open.org; kvm@vger.kernel.org;
> > qemu-devel@nongnu.org; quintela@redhat.com; dgilbert@redhat.com;
> > Hansen, Dave; Li, Liang Z
> > Subject: [PATCH v3 kernel 0/7] Extend virtio-balloon for fast
> > (de)inflating & fast live migration
> >
> > This patch set contains two parts of changes to the virtio-balloon.
> >
> > One is the change for speeding up the inflating & deflating process,
> > the main idea of this optimization is to use bitmap to send the page
> > information to host instead of the PFNs, to reduce the overhead of
> > virtio data transmission, address translation and madvise(). This can
> > help to improve the performance by about 85%.
> >
> > Another change is for speeding up live migration. By skipping process
> > guest's free pages in the first round of data copy, to reduce needless
> > data processing, this can help to save quite a lot of CPU cycles and
> > network bandwidth. We put guest's free page information in bitmap and
> > send it to host with the virt queue of virtio-balloon. For an idle 8GB
> > guest, this can help to shorten the total live migration time from
> > 2Sec to about 500ms in the 10Gbps network environment.
> >
> > Dave Hansen suggested a new scheme to encode the data structure,
> > because of additional complexity, it's not implemented in v3.
> >
> > Changes from v2 to v3:
> >     * Change the name of 'free page' to 'unused page'.
> >     * Use the scatter & gather bitmap instead of a 1MB page bitmap.
> >     * Fix overwriting the page bitmap after kicking.
> >     * Some of MST's comments for v2.
> >
> > Changes from v1 to v2:
> >     * Abandon the patch for dropping page cache.
> >     * Put some structures to uapi head file.
> >     * Use a new way to determine the page bitmap size.
> >     * Use a unified way to send the free page information with the bitm=
ap
> >     * Address the issues referred in MST's comments
> >
> >
> > Liang Li (7):
> >   virtio-balloon: rework deflate to add page to a list
> >   virtio-balloon: define new feature bit and page bitmap head
> >   mm: add a function to get the max pfn
> >   virtio-balloon: speed up inflate/deflate process
> >   mm: add the related functions to get unused page
> >   virtio-balloon: define feature bit and head for misc virt queue
> >   virtio-balloon: tell host vm's unused page info
> >
> >  drivers/virtio/virtio_balloon.c     | 390
> > ++++++++++++++++++++++++++++++++----
> >  include/linux/mm.h                  |   3 +
> >  include/uapi/linux/virtio_balloon.h |  41 ++++
> >  mm/page_alloc.c                     |  94 +++++++++
> >  4 files changed, 485 insertions(+), 43 deletions(-)
> >
> > --
> > 1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
