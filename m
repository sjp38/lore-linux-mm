Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id CE5C828092C
	for <linux-mm@kvack.org>; Fri, 10 Mar 2017 16:25:48 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id v190so182413605pfb.5
        for <linux-mm@kvack.org>; Fri, 10 Mar 2017 13:25:48 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id y21si4055788pgi.329.2017.03.10.13.25.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Mar 2017 13:25:47 -0800 (PST)
Date: Fri, 10 Mar 2017 13:25:41 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v7 kernel 3/5] virtio-balloon: implementation of
 VIRTIO_BALLOON_F_CHUNK_TRANSFER
Message-ID: <20170310212541.GC16328@bombadil.infradead.org>
References: <1488519630-89058-1-git-send-email-wei.w.wang@intel.com>
 <1488519630-89058-4-git-send-email-wei.w.wang@intel.com>
 <20170309141411.GZ16328@bombadil.infradead.org>
 <58C28FF8.5040403@intel.com>
 <20170310175349-mutt-send-email-mst@kernel.org>
 <20170310171143.GA16328@bombadil.infradead.org>
 <20170310211102-mutt-send-email-mst@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170310211102-mutt-send-email-mst@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Wei Wang <wei.w.wang@intel.com>, virtio-dev@lists.oasis-open.org, kvm@vger.kernel.org, qemu-devel@nongnu.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, linux-mm@kvack.org, Liang Li <liang.z.li@intel.com>, Paolo Bonzini <pbonzini@redhat.com>, Cornelia Huck <cornelia.huck@de.ibm.com>, Amit Shah <amit.shah@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, David Hildenbrand <david@redhat.com>, Liang Li <liliang324@gmail.com>

On Fri, Mar 10, 2017 at 09:35:21PM +0200, Michael S. Tsirkin wrote:
> > bit 0 clear => bits 1-11 encode a page count, bits 12-63 encode a PFN, page size 4k.
> > bit 0 set, bit 1 clear => bits 2-12 encode a page count, bits 13-63 encode a PFN, page size 8k
> > bits 0+1 set, bit 2 clear => bits 3-13 for page count, bits 14-63 for PFN, page size 16k.
> > bits 0-2 set, bit 3 clear => bits 4-14 for page count, bits 15-63 for PFN, page size 32k
> > bits 0-3 set, bit 4 clear => bits 5-15 for page count, bits 16-63 for PFN, page size 64k
> > That means we can always pass 2048 pages (of whatever page size) in a single chunk.  And
> > we support arbitrary power of two page sizes.  I suggest something like this:
> > 
> > u64 page_to_chunk(struct page *page)
> > {
> > 	u64 chunk = page_to_pfn(page) << PAGE_SHIFT;
> > 	chunk |= (1UL << compound_order(page)) - 1;
> > }
> 
> You need to fill in the size, do you not?

I think I did ... (1UL << compound_order(page)) - 1 sets the bottom
N bits.  Bit N+1 will already be clear.  What am I missing?

> > > - host should pass its base page size to guest
> > >   this can be a separate patch and for now we can fall back on 12 bit if not there
> > 
> > With this encoding scheme, I don't think we need to do this?  As long as
> > it's *at least* 12 bit, then we're fine.
> 
> I think we will still need something like this down the road.  The point
> is that not all hosts are able to use 4k pages in a balloon.
> So it's pointless for guest to pass 4k pages to such a host,
> and we need host to tell guest the page size it needs.
> 
> However that's a separate feature that can wait until
> another day.

Ah, the TRIM/DISCARD debate all over again ... should the guest batch
up or should the host do that work ... probably easier to account it in
the guest.  Might be better to frame it as 'balloon chunk size' rather than
host page size as it might have nothing to do with the host page size.

> > What per-chunk flags are you thinking would be useful?
> 
> Not entirely sure but I think would have been prudent to leave some free
> if possible. Your encoding seems to use them all up, so be it.

We don't necessarily have to support 2048 pages in a single chunk.
If it's worth reserving some bits, we can do that at the expense of
reducing the maximum number of pages per chunk.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
