Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 779796B0010
	for <linux-mm@kvack.org>; Mon, 23 Jul 2018 10:13:26 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id l11-v6so561819qkk.0
        for <linux-mm@kvack.org>; Mon, 23 Jul 2018 07:13:26 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id b49-v6si2030029qta.299.2018.07.23.07.13.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Jul 2018 07:13:19 -0700 (PDT)
Date: Mon, 23 Jul 2018 17:13:11 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v36 2/5] virtio_balloon: replace oom notifier with
 shrinker
Message-ID: <20180723170826-mutt-send-email-mst@kernel.org>
References: <1532075585-39067-1-git-send-email-wei.w.wang@intel.com>
 <1532075585-39067-3-git-send-email-wei.w.wang@intel.com>
 <20180722174125-mutt-send-email-mst@kernel.org>
 <5B55AE56.5030404@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5B55AE56.5030404@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org, akpm@linux-foundation.org, torvalds@linux-foundation.org, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, riel@redhat.com, peterx@redhat.com

On Mon, Jul 23, 2018 at 06:30:46PM +0800, Wei Wang wrote:
> On 07/22/2018 10:48 PM, Michael S. Tsirkin wrote:
> > On Fri, Jul 20, 2018 at 04:33:02PM +0800, Wei Wang wrote:
> > > +static unsigned long virtio_balloon_shrinker_scan(struct shrinker *shrinker,
> > > +						  struct shrink_control *sc)
> > > +{
> > > +	unsigned long pages_to_free = balloon_pages_to_shrink,
> > > +		      pages_freed = 0;
> > > +	struct virtio_balloon *vb = container_of(shrinker,
> > > +					struct virtio_balloon, shrinker);
> > > +
> > > +	/*
> > > +	 * One invocation of leak_balloon can deflate at most
> > > +	 * VIRTIO_BALLOON_ARRAY_PFNS_MAX balloon pages, so we call it
> > > +	 * multiple times to deflate pages till reaching
> > > +	 * balloon_pages_to_shrink pages.
> > > +	 */
> > > +	while (vb->num_pages && pages_to_free) {
> > > +		pages_to_free = balloon_pages_to_shrink - pages_freed;
> > > +		pages_freed += leak_balloon(vb, pages_to_free);
> > > +	}
> > > +	update_balloon_size(vb);
> > Are you sure that this is never called if count returned 0?
> 
> Yes. Please see do_shrink_slab, it just returns if count is 0.
> 
> > 
> > > +
> > > +	return pages_freed / VIRTIO_BALLOON_PAGES_PER_PAGE;
> > > +}
> > > +
> > > +static unsigned long virtio_balloon_shrinker_count(struct shrinker *shrinker,
> > > +						   struct shrink_control *sc)
> > > +{
> > > +	struct virtio_balloon *vb = container_of(shrinker,
> > > +					struct virtio_balloon, shrinker);
> > > +
> > > +	/*
> > > +	 * We continue to use VIRTIO_BALLOON_F_DEFLATE_ON_OOM to handle the
> > > +	 * case when shrinker needs to be invoked to relieve memory pressure.
> > > +	 */
> > > +	if (!virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_DEFLATE_ON_OOM))
> > > +		return 0;
> > So why not skip notifier registration when deflate on oom
> > is clear?
> 
> Sounds good, thanks.
> 
> 
> >   	vb->vb_dev_info.inode->i_mapping->a_ops = &balloon_aops;
> >   #endif
> > +	err = virtio_balloon_register_shrinker(vb);
> > +	if (err)
> > +		goto out_del_vqs;
> > So we can get scans before device is ready. Leak will fail
> > then. Why not register later after device is ready?
> 
> Probably no.
> 
> - it would be better not to set device ready when register_shrinker failed.

That's very rare so I won't be too worried.

> - When the device isn't ready, ballooning won't happen, that is,
> vb->num_pages will be 0, which results in shrinker_count=0 and shrinker_scan
> won't be called.
> 
> So I think it would be better to have shrinker registered before
> device_ready.
> 
> Best,
> Wei
