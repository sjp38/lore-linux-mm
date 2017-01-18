Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 885AD6B0033
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 08:30:15 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id d185so16502337pgc.2
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 05:30:15 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id 63si235423pgi.211.2017.01.18.05.30.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jan 2017 05:30:14 -0800 (PST)
From: "Li, Liang Z" <liang.z.li@intel.com>
Subject: RE: [PATCH v6 kernel 0/5] Extend virtio-balloon for fast
 (de)inflating & fast live migration
Date: Wed, 18 Jan 2017 13:29:59 +0000
Message-ID: <F2CBF3009FA73547804AE4C663CAB28E3C356F1B@shsmsx102.ccr.corp.intel.com>
References: <1482303148-22059-1-git-send-email-liang.z.li@intel.com>
 <2a32f616-25a8-ba5a-f74c-d619fc8ab333@redhat.com>
In-Reply-To: <2a32f616-25a8-ba5a-f74c-d619fc8ab333@redhat.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>
Cc: "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "Hansen, Dave" <dave.hansen@intel.com>, "cornelia.huck@de.ibm.com" <cornelia.huck@de.ibm.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "mst@redhat.com" <mst@redhat.com>, "aarcange@redhat.com" <aarcange@redhat.com>, "dgilbert@redhat.com" <dgilbert@redhat.com>, "quintela@redhat.com" <quintela@redhat.com>

> Am 21.12.2016 um 07:52 schrieb Liang Li:
> > This patch set contains two parts of changes to the virtio-balloon.
> >
> > One is the change for speeding up the inflating & deflating process,
> > the main idea of this optimization is to use {pfn|length} to present
> > the page information instead of the PFNs, to reduce the overhead of
> > virtio data transmission, address translation and madvise(). This can
> > help to improve the performance by about 85%.
> >
> > Another change is for speeding up live migration. By skipping process
> > guest's unused pages in the first round of data copy, to reduce
> > needless data processing, this can help to save quite a lot of CPU
> > cycles and network bandwidth. We put guest's unused page information
> > in a {pfn|length} array and send it to host with the virt queue of
> > virtio-balloon. For an idle guest with 8GB RAM, this can help to
> > shorten the total live migration time from 2Sec to about 500ms in
> > 10Gbps network environment. For an guest with quite a lot of page
> > cache and with little unused pages, it's possible to let the guest
> > drop it's page cache before live migration, this case can benefit from =
this
> new feature too.
>=20
> I agree that both changes make sense (although the second change just
> smells very racy, as you also pointed out in the patch description), howe=
ver I
> am not sure if virtio-balloon is really the right place for the latter ch=
ange.
>=20
> virtio-balloon is all about ballooning, nothing else. What you're doing i=
s using
> it as a way to communicate balloon-unrelated data from/to the hypervisor.
> Yes, it is also about guest memory, but completely unrelated to the purpo=
se
> of the balloon device.
>=20
> Maybe using virtio-balloon for this purpose is okay - I have mixed feelin=
gs
> (especially as I can't tell where else this could go). I would like to ge=
t a second
> opinion on this.
>=20

We have ever discussed the implementation for a long time, making use the c=
urrent
virtio balloon seems better than the other solutions and is recommended by =
Michael.

Thanks!
Liang
> --
>=20
> David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
