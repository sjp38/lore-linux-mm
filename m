Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7F2A5280289
	for <linux-mm@kvack.org>; Fri,  4 Nov 2016 14:10:13 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id r13so42594534pag.1
        for <linux-mm@kvack.org>; Fri, 04 Nov 2016 11:10:13 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id m26si15161601pfg.240.2016.11.04.11.10.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 04 Nov 2016 11:10:12 -0700 (PDT)
Subject: Re: [PATCH kernel v4 7/7] virtio-balloon: tell host vm's unused page
 info
References: <1478067447-24654-1-git-send-email-liang.z.li@intel.com>
 <1478067447-24654-8-git-send-email-liang.z.li@intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <b25eac6e-3744-3874-93a8-02f814549adf@intel.com>
Date: Fri, 4 Nov 2016 11:10:11 -0700
MIME-Version: 1.0
In-Reply-To: <1478067447-24654-8-git-send-email-liang.z.li@intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Liang Li <liang.z.li@intel.com>, mst@redhat.com
Cc: pbonzini@redhat.com, amit.shah@redhat.com, quintela@redhat.com, dgilbert@redhat.com, qemu-devel@nongnu.org, kvm@vger.kernel.org, virtio-dev@lists.oasis-open.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, mgorman@techsingularity.net, cornelia.huck@de.ibm.com

Please squish this and patch 5 together.  It makes no sense to separate
them.

> +static void send_unused_pages_info(struct virtio_balloon *vb,
> +				unsigned long req_id)
> +{
> +	struct scatterlist sg_in;
> +	unsigned long pfn = 0, bmap_len, pfn_limit, last_pfn, nr_pfn;
> +	struct virtqueue *vq = vb->req_vq;
> +	struct virtio_balloon_resp_hdr *hdr = vb->resp_hdr;
> +	int ret = 1, used_nr_bmap = 0, i;
> +
> +	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_PAGE_BITMAP) &&
> +		vb->nr_page_bmap == 1)
> +		extend_page_bitmap(vb);
> +
> +	pfn_limit = PFNS_PER_BMAP * vb->nr_page_bmap;
> +	mutex_lock(&vb->balloon_lock);
> +	last_pfn = get_max_pfn();
> +
> +	while (ret) {
> +		clear_page_bitmap(vb);
> +		ret = get_unused_pages(pfn, pfn + pfn_limit, vb->page_bitmap,
> +			 PFNS_PER_BMAP, vb->nr_page_bmap);

This changed the underlying data structure without changing the way that
the structure is populated.

This algorithm picks a "PFNS_PER_BMAP * vb->nr_page_bmap"-sized set of
pfns, allocates a bitmap for them, the loops through all zones looking
for pages in any free list that are in that range.

Unpacking all the indirection, it looks like this:

for (pfn = 0; pfn < get_max_pfn(); pfn += BITMAP_SIZE_IN_PFNS)
	for_each_populated_zone(zone)
		for_each_migratetype_order(order, t)
			list_for_each(..., &zone->free_area[order])...

Let's say we do a 32k bitmap that can hold ~1M pages.  That's 4GB of
RAM.  On a 1TB system, that's 256 passes through the top-level loop.
The bottom-level lists have tens of thousands of pages in them, even on
my laptop.  Only 1/256 of these pages will get consumed in a given pass.

That's an awfully inefficient way of doing it.  This patch essentially
changed the data structure without changing the algorithm to populate it.

Please change the *algorithm* to use the new data structure efficiently.
 Such a change would only do a single pass through each freelist, and
would choose whether to use the extent-based (pfn -> range) or
bitmap-based approach based on the contents of the free lists.

You should not be using get_max_pfn().  Any patch set that continues to
use it is not likely to be using a proper algorithm.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
