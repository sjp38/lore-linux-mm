Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id C833728094E
	for <linux-mm@kvack.org>; Sat, 11 Mar 2017 23:04:15 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id 9so220959067qkk.6
        for <linux-mm@kvack.org>; Sat, 11 Mar 2017 20:04:15 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 39si11773645qkv.128.2017.03.11.20.04.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 11 Mar 2017 20:04:14 -0800 (PST)
Date: Sun, 12 Mar 2017 06:04:10 +0200
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v7 kernel 3/5] virtio-balloon: implementation of
 VIRTIO_BALLOON_F_CHUNK_TRANSFER
Message-ID: <20170312055658-mutt-send-email-mst@kernel.org>
References: <1488519630-89058-1-git-send-email-wei.w.wang@intel.com>
 <1488519630-89058-4-git-send-email-wei.w.wang@intel.com>
 <20170309141411.GZ16328@bombadil.infradead.org>
 <58C28FF8.5040403@intel.com>
 <20170310175349-mutt-send-email-mst@kernel.org>
 <20170310171143.GA16328@bombadil.infradead.org>
 <58C3E6A3.1000000@intel.com>
 <20170311140946.GA1860@bombadil.infradead.org>
 <286AC319A985734F985F78AFA26841F73919E524@shsmsx102.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <286AC319A985734F985F78AFA26841F73919E524@shsmsx102.ccr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Wang, Wei W" <wei.w.wang@intel.com>
Cc: Matthew Wilcox <willy@infradead.org>, "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Paolo Bonzini <pbonzini@redhat.com>, Cornelia Huck <cornelia.huck@de.ibm.com>, Amit Shah <amit.shah@redhat.com>, "Hansen, Dave" <dave.hansen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, David Hildenbrand <david@redhat.com>, Liang Li <liliang324@gmail.com>

On Sun, Mar 12, 2017 at 01:59:54AM +0000, Wang, Wei W wrote:
> On 03/11/2017 10:10 PM, Matthew Wilcox wrote:
> > On Sat, Mar 11, 2017 at 07:59:31PM +0800, Wei Wang wrote:
> > > I'm thinking what if the guest needs to transfer these much physically
> > > continuous memory to host: 1GB+2MB+64KB+32KB+16KB+4KB.
> > > Is it going to use Six 64-bit chunks? Would it be simpler if we just
> > > use the 128-bit chunk format (we can drop the previous normal 64-bit
> > > format)?
> > 
> > Is that a likely thing for the guest to need to do though?  Freeing a 1GB page is
> > much more liikely, IMO.
> 
> Yes, I think it's very possible. The host can ask for any number of pages (e.g. 1.5GB) that the guest can afford.  Also, the ballooned 1.5G memory is not guaranteed to be continuous in any pattern like 1GB+512MB. That's why we need to use a bitmap to draw the whole picture first, and then seek for continuous bits to chunk.
> 
> Best,
> Wei

While I like the clever format that Matthew came up with, I'm also
inclined to say let's keep things simple.
the simplest thing seems to be to use the ext format all the time.
Except let's reserve the low 12 bits in both address and size,
since they are already 0, we might be able to use them for flags down the road.

-- 
MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
