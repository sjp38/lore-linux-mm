Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 34EAD6B0253
	for <linux-mm@kvack.org>; Thu, 28 Jul 2016 17:37:34 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id l2so76114119qkf.2
        for <linux-mm@kvack.org>; Thu, 28 Jul 2016 14:37:34 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o129si9533035qka.188.2016.07.28.14.37.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Jul 2016 14:37:33 -0700 (PDT)
Date: Fri, 29 Jul 2016 00:37:24 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v2 repost 7/7] virtio-balloon: tell host vm's free page
 info
Message-ID: <20160729003622-mutt-send-email-mst@kernel.org>
References: <1469582616-5729-1-git-send-email-liang.z.li@intel.com>
 <1469582616-5729-8-git-send-email-liang.z.li@intel.com>
 <20160728004606-mutt-send-email-mst@kernel.org>
 <F2CBF3009FA73547804AE4C663CAB28E042141EE@shsmsx102.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <F2CBF3009FA73547804AE4C663CAB28E042141EE@shsmsx102.ccr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Li, Liang Z" <liang.z.li@intel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "dgilbert@redhat.com" <dgilbert@redhat.com>, "quintela@redhat.com" <quintela@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Paolo Bonzini <pbonzini@redhat.com>, Cornelia Huck <cornelia.huck@de.ibm.com>, Amit Shah <amit.shah@redhat.com>

On Thu, Jul 28, 2016 at 07:50:52AM +0000, Li, Liang Z wrote:
> > >  }
> > >
> > > +static void update_free_pages_stats(struct virtio_balloon *vb,
> > 
> > why _stats?
> 
> Will change.
> 
> > > +	max_pfn = get_max_pfn();
> > > +	mutex_lock(&vb->balloon_lock);
> > > +	while (pfn < max_pfn) {
> > > +		memset(vb->page_bitmap, 0, vb->bmap_len);
> > > +		ret = get_free_pages(pfn, pfn + vb->pfn_limit,
> > > +			vb->page_bitmap, vb->bmap_len * BITS_PER_BYTE);
> > > +		hdr->cmd = cpu_to_virtio16(vb->vdev,
> > BALLOON_GET_FREE_PAGES);
> > > +		hdr->page_shift = cpu_to_virtio16(vb->vdev, PAGE_SHIFT);
> > > +		hdr->req_id = cpu_to_virtio64(vb->vdev, req_id);
> > > +		hdr->start_pfn = cpu_to_virtio64(vb->vdev, pfn);
> > > +		bmap_len = vb->pfn_limit / BITS_PER_BYTE;
> > > +		if (!ret) {
> > > +			hdr->flag = cpu_to_virtio16(vb->vdev,
> > > +
> > 	BALLOON_FLAG_DONE);
> > > +			if (pfn + vb->pfn_limit > max_pfn)
> > > +				bmap_len = (max_pfn - pfn) /
> > BITS_PER_BYTE;
> > > +		} else
> > > +			hdr->flag = cpu_to_virtio16(vb->vdev,
> > > +
> > 	BALLOON_FLAG_CONT);
> > > +		hdr->bmap_len = cpu_to_virtio64(vb->vdev, bmap_len);
> > > +		sg_init_one(&sg_out, hdr,
> > > +			 sizeof(struct balloon_bmap_hdr) + bmap_len);
> > 
> > Wait a second. This adds the same buffer multiple times in a loop.
> > We will overwrite the buffer without waiting for hypervisor to process it.
> > What did I miss?
> 
> I am no quite sure about this part, I though the virtqueue_kick(vq) will prevent
> the buffer from overwrite, I realized it's wrong.
> 
> > > +
> > > +		virtqueue_add_outbuf(vq, &sg_out, 1, vb, GFP_KERNEL);
> > 
> > this can fail. you want to maybe make sure vq has enough space before you
> > use it or check error and wait.
> > 
> > > +		virtqueue_kick(vq);
> > 
> > why kick here within loop? wait until done. in fact kick outside lock is better
> > for smp.
> 
> I will change this part in v3.
> 
> > 
> > > +		pfn += vb->pfn_limit;
> > > +	static const char * const names[] = { "inflate", "deflate", "stats",
> > > +						 "misc" };
> > >  	int err, nvqs;
> > >
> > >  	/*
> > >  	 * We expect two virtqueues: inflate and deflate, and
> > >  	 * optionally stat.
> > >  	 */
> > > -	nvqs = virtio_has_feature(vb->vdev,
> > VIRTIO_BALLOON_F_STATS_VQ) ? 3 : 2;
> > > +	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_MISC_VQ))
> > > +		nvqs = 4;
> > 
> > Does misc vq depend on stats vq feature then? if yes please validate that.
> 
> Yes, what's you mean by 'validate' that?

Either handle misc vq without a stats vq, or
clear VIRTIO_BALLOON_F_MISC_VQ if stats vq is off.

> > 
> > 
> > > +	else
> > > +		nvqs = virtio_has_feature(vb->vdev,
> > > +					  VIRTIO_BALLOON_F_STATS_VQ) ? 3 :
> > 2;
> > 
> > Replace that ? with else too pls.
> 
> Will change.
> 
> Thanks!
> Liang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
