Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 30F386B05A9
	for <linux-mm@kvack.org>; Sun, 30 Jul 2017 01:59:22 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id j79so281219538pfj.9
        for <linux-mm@kvack.org>; Sat, 29 Jul 2017 22:59:22 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id r3si13502822plb.972.2017.07.29.22.59.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 29 Jul 2017 22:59:21 -0700 (PDT)
From: "Wang, Wei W" <wei.w.wang@intel.com>
Subject: RE: [PATCH v12 5/8] virtio-balloon: VIRTIO_BALLOON_F_SG
Date: Sun, 30 Jul 2017 05:59:17 +0000
Message-ID: <286AC319A985734F985F78AFA26841F739288D85@shsmsx102.ccr.corp.intel.com>
References: <20170712163746-mutt-send-email-mst@kernel.org>
 <5967246B.9030804@intel.com> <20170713210819-mutt-send-email-mst@kernel.org>
 <59686EEB.8080805@intel.com> <20170723044036-mutt-send-email-mst@kernel.org>
 <59781119.8010200@intel.com> <20170726155856-mutt-send-email-mst@kernel.org>
 <597954E3.2070801@intel.com> <20170729020231-mutt-send-email-mst@kernel.org>
 <597C83CC.7060702@intel.com> <20170730043922-mutt-send-email-mst@kernel.org>
In-Reply-To: <20170730043922-mutt-send-email-mst@kernel.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "david@redhat.com" <david@redhat.com>, "cornelia.huck@de.ibm.com" <cornelia.huck@de.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "aarcange@redhat.com" <aarcange@redhat.com>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "liliang.opensource@gmail.com" <liliang.opensource@gmail.com>, "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "yang.zhang.wz@gmail.com" <yang.zhang.wz@gmail.com>, "quan.xu@aliyun.com" <quan.xu@aliyun.com>

On Sunday, July 30, 2017 12:23 PM, Michael S. Tsirkin wrote:
> On Sat, Jul 29, 2017 at 08:47:08PM +0800, Wei Wang wrote:
> > On 07/29/2017 07:08 AM, Michael S. Tsirkin wrote:
> > > On Thu, Jul 27, 2017 at 10:50:11AM +0800, Wei Wang wrote:
> > > > > > > OK I thought this over. While we might need these new APIs
> > > > > > > in the future, I think that at the moment, there's a way to
> > > > > > > implement this feature that is significantly simpler. Just
> > > > > > > add each s/g as a separate input buffer.
> > > > > > Should it be an output buffer?
> > > > > Hypervisor overwrites these pages with zeroes. Therefore it is
> > > > > writeable by device: DMA_FROM_DEVICE.
> > > > Why would the hypervisor need to zero the buffer?
> > > The page is supplied to hypervisor and can lose the value that is
> > > there.  That is the definition of writeable by device.
> >
> > I think for the free pages, it should be clear that they will be added
> > as output buffer to the device, because (as we discussed) they are
> > just hints, and some of them may be used by the guest after the report_=
 API is
> invoked.
> > The device/hypervisor should not use or discard them.
>=20
> Discarding contents is exactly what you propose doing if migration is goi=
ng on,
> isn't it?

That's actually a different concept. Please let me explain it with this exa=
mple:

The hypervisor receives the hint saying the guest PageX is a free page, but=
 as we know,=20
after that report_ API exits, the guest kernel may take PageX to use, so Pa=
geX is not free
page any more. At this time, if the hypervisor writes to the page, that wou=
ld crash the guest.
So, I think the cornerstone of this work is that the hypervisor should not =
touch the
reported pages.

Best,
Wei   =20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
