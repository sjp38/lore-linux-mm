Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3C14B6B0253
	for <linux-mm@kvack.org>; Thu, 28 Jul 2016 18:18:08 -0400 (EDT)
Received: by mail-vk0-f72.google.com with SMTP id x130so77566373vkc.3
        for <linux-mm@kvack.org>; Thu, 28 Jul 2016 15:18:08 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b194si9693386qkg.230.2016.07.28.15.18.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Jul 2016 15:18:07 -0700 (PDT)
Date: Fri, 29 Jul 2016 01:17:59 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v2 repost 4/7] virtio-balloon: speed up inflate/deflate
 process
Message-ID: <20160729011553-mutt-send-email-mst@kernel.org>
References: <1469582616-5729-1-git-send-email-liang.z.li@intel.com>
 <1469582616-5729-5-git-send-email-liang.z.li@intel.com>
 <20160728002243-mutt-send-email-mst@kernel.org>
 <F2CBF3009FA73547804AE4C663CAB28E04213E1D@shsmsx102.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <F2CBF3009FA73547804AE4C663CAB28E04213E1D@shsmsx102.ccr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Li, Liang Z" <liang.z.li@intel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "dgilbert@redhat.com" <dgilbert@redhat.com>, "quintela@redhat.com" <quintela@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Paolo Bonzini <pbonzini@redhat.com>, Cornelia Huck <cornelia.huck@de.ibm.com>, Amit Shah <amit.shah@redhat.com>

On Thu, Jul 28, 2016 at 03:06:37AM +0000, Li, Liang Z wrote:
> > > + * VIRTIO_BALLOON_PFNS_LIMIT is used to limit the size of page bitmap
> > > + * to prevent a very large page bitmap, there are two reasons for this:
> > > + * 1) to save memory.
> > > + * 2) allocate a large bitmap may fail.
> > > + *
> > > + * The actual limit of pfn is determined by:
> > > + * pfn_limit = min(max_pfn, VIRTIO_BALLOON_PFNS_LIMIT);
> > > + *
> > > + * If system has more pages than VIRTIO_BALLOON_PFNS_LIMIT, we will
> > > +scan
> > > + * the page list and send the PFNs with several times. To reduce the
> > > + * overhead of scanning the page list. VIRTIO_BALLOON_PFNS_LIMIT
> > > +should
> > > + * be set with a value which can cover most cases.
> > 
> > So what if it covers 1/32 of the memory? We'll do 32 exits and not 1, still not a
> > big deal for a big guest.
> > 
> 
> The issue here is the overhead is too high for scanning the page list for 32 times.
> Limit the page bitmap size to a fixed value is better for a big guest?
> 

I'd say avoid scanning free lists completely. Scan pages themselves and
check the refcount to see whether they are free.
This way each page needs to be tested once.

And skip the whole optimization if less than e.g. 10% is free.

> > > + */
> > > +#define VIRTIO_BALLOON_PFNS_LIMIT ((32 * (1ULL << 30)) >>
> > PAGE_SHIFT)
> > > +/* 32GB */
> > 
> > I already said this with a smaller limit.
> > 
> > 	2<< 30  is 2G but that is not a useful comment.
> > 	pls explain what is the reason for this selection.
> > 
> > Still applies here.
> > 
> 
> I will add the comment for this.
> 
> > > -	sg_init_one(&sg, vb->pfns, sizeof(vb->pfns[0]) * vb->num_pfns);
> > > +	if (virtio_has_feature(vb->vdev,
> > VIRTIO_BALLOON_F_PAGE_BITMAP)) {
> > > +		struct balloon_bmap_hdr *hdr = vb->bmap_hdr;
> > > +		unsigned long bmap_len;
> > > +
> > > +		/* cmd and req_id are not used here, set them to 0 */
> > > +		hdr->cmd = cpu_to_virtio16(vb->vdev, 0);
> > > +		hdr->page_shift = cpu_to_virtio16(vb->vdev, PAGE_SHIFT);
> > > +		hdr->reserved = cpu_to_virtio16(vb->vdev, 0);
> > > +		hdr->req_id = cpu_to_virtio64(vb->vdev, 0);
> > 
> > no need to swap 0, just fill it in. in fact you allocated all 0s so no need to touch
> > these fields at all.
> > 
> 
> Will change in v3.
> 
> > > @@ -489,7 +612,7 @@ static int virtballoon_migratepage(struct
> > > balloon_dev_info *vb_dev_info,  static int virtballoon_probe(struct
> > > virtio_device *vdev)  {
> > >  	struct virtio_balloon *vb;
> > > -	int err;
> > > +	int err, hdr_len;
> > >
> > >  	if (!vdev->config->get) {
> > >  		dev_err(&vdev->dev, "%s failure: config access disabled\n",
> > @@
> > > -508,6 +631,18 @@ static int virtballoon_probe(struct virtio_device *vdev)
> > >  	spin_lock_init(&vb->stop_update_lock);
> > >  	vb->stop_update = false;
> > >  	vb->num_pages = 0;
> > > +	vb->pfn_limit = VIRTIO_BALLOON_PFNS_LIMIT;
> > > +	vb->pfn_limit = min(vb->pfn_limit, get_max_pfn());
> > > +	vb->bmap_len = ALIGN(vb->pfn_limit, BITS_PER_LONG) /
> > > +		 BITS_PER_BYTE + 2 * sizeof(unsigned long);
> > 
> > What are these 2 longs in aid of?
> > 
> The rounddown(vb->start_pfn,  BITS_PER_LONG) and roundup(vb->end_pfn, BITS_PER_LONG) 
> may cause (vb->end_pfn - vb->start_pfn) > vb->pfn_limit, so we need extra space to save the
> bitmap for this case. 2 longs are enough.
> 
> > > +	hdr_len = sizeof(struct balloon_bmap_hdr);
> > > +	vb->bmap_hdr = kzalloc(hdr_len + vb->bmap_len, GFP_KERNEL);
> > 
> > So it can go up to 1MByte but adding header size etc you need a higher order
> > allocation. This is a waste, there is no need to have a power of two allocation.
> > Start from the other side. Say "I want to allocate 32KBytes for the bitmap".
> > Subtract the header and you get bitmap size.
> > Calculate the pfn limit from there.
> > 
> 
> Indeed, will change. Thanks a lot!
> 
> Liang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
