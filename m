Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id DD5E56B0038
	for <linux-mm@kvack.org>; Mon, 13 Mar 2017 08:41:43 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id y17so296685430pgh.2
        for <linux-mm@kvack.org>; Mon, 13 Mar 2017 05:41:43 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id y18si11321906pgf.390.2017.03.13.05.41.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Mar 2017 05:41:42 -0700 (PDT)
From: "Wang, Wei W" <wei.w.wang@intel.com>
Subject: RE: [PATCH v7 kernel 3/5] virtio-balloon: implementation of
 VIRTIO_BALLOON_F_CHUNK_TRANSFER
Date: Mon, 13 Mar 2017 12:41:39 +0000
Message-ID: <286AC319A985734F985F78AFA26841F73919FFDB@shsmsx102.ccr.corp.intel.com>
References: <1488519630-89058-1-git-send-email-wei.w.wang@intel.com>
 <1488519630-89058-4-git-send-email-wei.w.wang@intel.com>
 <20170309141411.GZ16328@bombadil.infradead.org> <58C28FF8.5040403@intel.com>
 <20170310175349-mutt-send-email-mst@kernel.org>
 <20170310171143.GA16328@bombadil.infradead.org> <58C3E6A3.1000000@intel.com>
 <20170311140946.GA1860@bombadil.infradead.org>
 <286AC319A985734F985F78AFA26841F73919E524@shsmsx102.ccr.corp.intel.com>
 <20170312055658-mutt-send-email-mst@kernel.org>
In-Reply-To: <20170312055658-mutt-send-email-mst@kernel.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Matthew Wilcox <willy@infradead.org>, "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Paolo Bonzini <pbonzini@redhat.com>, Cornelia Huck <cornelia.huck@de.ibm.com>, Amit Shah <amit.shah@redhat.com>, "Hansen, Dave" <dave.hansen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, David
 Hildenbrand <david@redhat.com>, Liang Li <liliang324@gmail.com>

On Sunday, March 12, 2017 12:04 PM, Michael S. Tsirkin wrote:
> On Sun, Mar 12, 2017 at 01:59:54AM +0000, Wang, Wei W wrote:
> > On 03/11/2017 10:10 PM, Matthew Wilcox wrote:
> > > On Sat, Mar 11, 2017 at 07:59:31PM +0800, Wei Wang wrote:
> > > > I'm thinking what if the guest needs to transfer these much
> > > > physically continuous memory to host: 1GB+2MB+64KB+32KB+16KB+4KB.
> > > > Is it going to use Six 64-bit chunks? Would it be simpler if we
> > > > just use the 128-bit chunk format (we can drop the previous normal
> > > > 64-bit format)?
> > >
> > > Is that a likely thing for the guest to need to do though?  Freeing
> > > a 1GB page is much more liikely, IMO.
> >
> > Yes, I think it's very possible. The host can ask for any number of pag=
es (e.g.
> 1.5GB) that the guest can afford.  Also, the ballooned 1.5G memory is not
> guaranteed to be continuous in any pattern like 1GB+512MB. That's why we
> need to use a bitmap to draw the whole picture first, and then seek for
> continuous bits to chunk.
> >
> > Best,
> > Wei
>=20
> While I like the clever format that Matthew came up with, I'm also inclin=
ed to
> say let's keep things simple.
> the simplest thing seems to be to use the ext format all the time.
> Except let's reserve the low 12 bits in both address and size, since they=
 are
> already 0, we might be able to use them for flags down the road.

Thanks for reminding us about the hugepage story. I'll use the ext format i=
n the implementation if no further objections from others.

Best,
Wei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
