Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 51C5B28094A
	for <linux-mm@kvack.org>; Sat, 11 Mar 2017 20:59:59 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id v190so235611651pfb.5
        for <linux-mm@kvack.org>; Sat, 11 Mar 2017 17:59:59 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id t8si7558881pgo.353.2017.03.11.17.59.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 11 Mar 2017 17:59:58 -0800 (PST)
From: "Wang, Wei W" <wei.w.wang@intel.com>
Subject: RE: [PATCH v7 kernel 3/5] virtio-balloon: implementation of
 VIRTIO_BALLOON_F_CHUNK_TRANSFER
Date: Sun, 12 Mar 2017 01:59:54 +0000
Message-ID: <286AC319A985734F985F78AFA26841F73919E524@shsmsx102.ccr.corp.intel.com>
References: <1488519630-89058-1-git-send-email-wei.w.wang@intel.com>
 <1488519630-89058-4-git-send-email-wei.w.wang@intel.com>
 <20170309141411.GZ16328@bombadil.infradead.org> <58C28FF8.5040403@intel.com>
 <20170310175349-mutt-send-email-mst@kernel.org>
 <20170310171143.GA16328@bombadil.infradead.org> <58C3E6A3.1000000@intel.com>
 <20170311140946.GA1860@bombadil.infradead.org>
In-Reply-To: <20170311140946.GA1860@bombadil.infradead.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Paolo Bonzini <pbonzini@redhat.com>, Cornelia Huck <cornelia.huck@de.ibm.com>, Amit Shah <amit.shah@redhat.com>, "Hansen, Dave" <dave.hansen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, David
 Hildenbrand <david@redhat.com>, Liang Li <liliang324@gmail.com>

On 03/11/2017 10:10 PM, Matthew Wilcox wrote:
> On Sat, Mar 11, 2017 at 07:59:31PM +0800, Wei Wang wrote:
> > I'm thinking what if the guest needs to transfer these much physically
> > continuous memory to host: 1GB+2MB+64KB+32KB+16KB+4KB.
> > Is it going to use Six 64-bit chunks? Would it be simpler if we just
> > use the 128-bit chunk format (we can drop the previous normal 64-bit
> > format)?
>=20
> Is that a likely thing for the guest to need to do though?  Freeing a 1GB=
 page is
> much more liikely, IMO.

Yes, I think it's very possible. The host can ask for any number of pages (=
e.g. 1.5GB) that the guest can afford.  Also, the ballooned 1.5G memory is =
not guaranteed to be continuous in any pattern like 1GB+512MB. That's why w=
e need to use a bitmap to draw the whole picture first, and then seek for c=
ontinuous bits to chunk.

Best,
Wei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
