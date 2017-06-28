Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 63C5C6B0292
	for <linux-mm@kvack.org>; Wed, 28 Jun 2017 11:02:14 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id k14so25741909qkl.11
        for <linux-mm@kvack.org>; Wed, 28 Jun 2017 08:02:14 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q49si2209849qte.104.2017.06.28.08.02.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Jun 2017 08:02:13 -0700 (PDT)
Date: Wed, 28 Jun 2017 18:01:58 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [virtio-dev] Re: [PATCH v11 6/6] virtio-balloon:
 VIRTIO_BALLOON_F_CMD_VQ
Message-ID: <20170628175956-mutt-send-email-mst@kernel.org>
References: <1497004901-30593-1-git-send-email-wei.w.wang@intel.com>
 <1497004901-30593-7-git-send-email-wei.w.wang@intel.com>
 <20170620190343-mutt-send-email-mst@kernel.org>
 <5949E7C0.3050106@intel.com>
 <20170621151922-mutt-send-email-mst@kernel.org>
 <594B8287.6000706@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <594B8287.6000706@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "david@redhat.com" <david@redhat.com>, "Hansen, Dave" <dave.hansen@intel.com>, "cornelia.huck@de.ibm.com" <cornelia.huck@de.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "aarcange@redhat.com" <aarcange@redhat.com>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "liliang.opensource@gmail.com" <liliang.opensource@gmail.com>, "riel@redhat.com" <riel@redhat.com>, "nilal@redhat.com" <nilal@redhat.com>

On Thu, Jun 22, 2017 at 04:40:39PM +0800, Wei Wang wrote:
> On 06/21/2017 08:28 PM, Michael S. Tsirkin wrote:
> > On Wed, Jun 21, 2017 at 11:28:00AM +0800, Wei Wang wrote:
> > > On 06/21/2017 12:18 AM, Michael S. Tsirkin wrote:
> > > > On Fri, Jun 09, 2017 at 06:41:41PM +0800, Wei Wang wrote:
> > > > > -	if (!virtqueue_indirect_desc_table_add(vq, desc, num)) {
> > > > > +	if (!virtqueue_indirect_desc_table_add(vq, desc, *num)) {
> > > > >    		virtqueue_kick(vq);
> > > > > -		wait_event(vb->acked, virtqueue_get_buf(vq, &len));
> > > > > -		vb->balloon_page_chunk.chunk_num = 0;
> > > > > +		if (busy_wait)
> > > > > +			while (!virtqueue_get_buf(vq, &len) &&
> > > > > +			       !virtqueue_is_broken(vq))
> > > > > +				cpu_relax();
> > > > > +		else
> > > > > +			wait_event(vb->acked, virtqueue_get_buf(vq, &len));
> > > > This is something I didn't previously notice.
> > > > As you always keep a single buffer in flight, you do not
> > > > really need indirect at all. Just add all descriptors
> > > > in the ring directly, then kick.
> > > > 
> > > > E.g.
> > > > 	virtqueue_add_first
> > > > 	virtqueue_add_next
> > > > 	virtqueue_add_last
> > > > 
> > > > ?
> > > > 
> > > > You also want a flag to avoid allocations but there's no need to do it
> > > > per descriptor, set it on vq.
> > > > 
> > > Without using the indirect table, I'm thinking about changing to use
> > > the standard sg (i.e. struct scatterlist), instead of vring_desc, so that
> > > we don't need to modify or add any new functions of virtqueue_add().
> > > 
> > > In this case, we will kmalloc an array of sgs in probe(), and we can add
> > > the sgs one by one to the vq, which won't trigger the allocation of an
> > > indirect table inside virtqueue_add(), and then kick when all are added.
> > > 
> > > Best,
> > > Wei
> > And allocate headers too? This can work. API extensions aren't
> > necessarily a bad idea though. The API I suggest above is preferable
> > for the simple reason that it can work without INDIRECT flag
> > support in hypervisor.
> 
> OK, probably we don't need to add a desc to the vq - we can just use
> the vq's desc, like this:
> 
> int virtqueue_add_first(struct virtqueue *_vq,
>                                      uint64_t addr,
>                                      uint32_t len,
>                                      bool in,
>                                      unsigned int *idx) {
> 
>     ...
>    uint16_t desc_flags = in ? VRING_DESC_F_NEXT | VRING_DESC_F_WRITE :
>                                              VRING_DESC_F_NEXT;
> 
>     vq->vring.desc[vq->free_head].addr = addr;
>     vq->vring.desc[vq->free_head].len = len;
>     vq->vring.desc[vq->free_head].flags = cpu_to_virtio16(_vq->vdev, flags);
>     /* return to the caller the desc id */
>     *idx = vq->free_head;
>     ...
> }
> 
> int virtqueue_add_next(struct virtqueue *_vq,
>                                      uint64_t addr,
>                                      uint32_t len,
>                                      bool in,
>                                      bool end,
>                                      unsigned int *idx) {
>     ...
>     vq->vring.desc[*idx].next = vq->free_head;
>     vq->vring.desc[vq->free_head].addr = addr;
>     ...
>     if (end)
>         remove the VRING_DESC_F_NEXT flag
> }
> 

Add I would say add-last.

> 
> What do you think? We can also combine the two functions into one.
> 
> 
> 
> Best,
> Wei

With an enum? Yes that's also an option.

-- 
MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
