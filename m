Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9E8BA6B02FA
	for <linux-mm@kvack.org>; Sun,  7 May 2017 00:20:56 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id o25so41643721pgc.1
        for <linux-mm@kvack.org>; Sat, 06 May 2017 21:20:56 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id y64si10027975plh.78.2017.05.06.21.20.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 06 May 2017 21:20:55 -0700 (PDT)
From: "Wang, Wei W" <wei.w.wang@intel.com>
Subject: RE: [PATCH v9 5/5] virtio-balloon: VIRTIO_BALLOON_F_MISC_VQ
Date: Sun, 7 May 2017 04:20:51 +0000
Message-ID: <286AC319A985734F985F78AFA26841F7391FFBCB@shsmsx102.ccr.corp.intel.com>
References: <1492076108-117229-1-git-send-email-wei.w.wang@intel.com>
 <1492076108-117229-6-git-send-email-wei.w.wang@intel.com>
 <20170413194732-mutt-send-email-mst@kernel.org> <590190C8.6030609@intel.com>
 <20170506011928-mutt-send-email-mst@kernel.org>
In-Reply-To: <20170506011928-mutt-send-email-mst@kernel.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "david@redhat.com" <david@redhat.com>, "Hansen, Dave" <dave.hansen@intel.com>, "cornelia.huck@de.ibm.com" <cornelia.huck@de.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "aarcange@redhat.com" <aarcange@redhat.com>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "liliang.opensource@gmail.com" <liliang.opensource@gmail.com>

On 05/06/2017 06:21 AM, Michael S. Tsirkin wrote:
> On Thu, Apr 27, 2017 at 02:33:44PM +0800, Wei Wang wrote:
> > On 04/14/2017 01:08 AM, Michael S. Tsirkin wrote:
> > > On Thu, Apr 13, 2017 at 05:35:08PM +0800, Wei Wang wrote:
> > > > Add a new vq, miscq, to handle miscellaneous requests between the
> > > > device and the driver.
> > > >
> > > > This patch implemnts the
> VIRTIO_BALLOON_MISCQ_INQUIRE_UNUSED_PAGES
> > > implements
> > >
> > > > request sent from the device.
> > > Commands are sent from host and handled on guest.
> > > In fact how is this so different from stats?
> > > How about reusing the stats vq then? You can use one buffer for
> > > stats and one buffer for commands.
> > >
> >
> > The meaning of the two vqs is a little different. statq is used for
> > reporting statistics, while miscq is intended to be used to handle
> > miscellaneous requests from the guest or host
>=20
> misc just means "anything goes". If you want it to mean "commands" name i=
t so.

Ok, will change it.

> > (I think it can
> > also be used the other way around in the future when other new
> > features are added which need the guest to send requests and the host
> > to provide responses).
> >
> > I would prefer to have them separate, because:
> > If we plan to combine them, we need to put the previous statq related
> > implementation under miscq with a new command (I think we can't
> > combine them without using commands to distinguish the two features).
>=20
> Right.

> > In this way, an old driver won't work with a new QEMU or a new driver
> > won't work with an old QEMU. Would this be considered as an issue
> > here?
>=20
> Compatibility is and should always be handled using feature flags.  There=
's a
> feature flag for this, isn't it?

The negotiation of the existing feature flag, VIRTIO_BALLOON_F_STATS_VQ
only indicates the support of the old statq implementation. To move the sta=
tq
implementation under cmdq, I think we would need a new feature flag for the
new statq implementation:
#define VIRTIO_BALLOON_F_CMDQ_STATS      5

What do you think?

Best,
Wei




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
