Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7D8D36B025F
	for <linux-mm@kvack.org>; Fri, 29 Sep 2017 00:01:13 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id t46so90514qtj.5
        for <linux-mm@kvack.org>; Thu, 28 Sep 2017 21:01:13 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z19si60609qtb.125.2017.09.28.21.01.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Sep 2017 21:01:11 -0700 (PDT)
Date: Fri, 29 Sep 2017 07:01:01 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [virtio-dev] Re: [PATCH v15 3/5] virtio-balloon:
 VIRTIO_BALLOON_F_SG
Message-ID: <20170929070049-mutt-send-email-mst@kernel.org>
References: <1503914913-28893-1-git-send-email-wei.w.wang@intel.com>
 <1503914913-28893-4-git-send-email-wei.w.wang@intel.com>
 <20170828204659-mutt-send-email-mst@kernel.org>
 <59A4DADE.5050303@intel.com>
 <20170908062748-mutt-send-email-mst@kernel.org>
 <59B27A64.4040604@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <59B27A64.4040604@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com, david@redhat.com, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, willy@infradead.org, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com

On Fri, Sep 08, 2017 at 07:09:24PM +0800, Wei Wang wrote:
> On 09/08/2017 11:36 AM, Michael S. Tsirkin wrote:
> > On Tue, Aug 29, 2017 at 11:09:18AM +0800, Wei Wang wrote:
> > > On 08/29/2017 02:03 AM, Michael S. Tsirkin wrote:
> > > > On Mon, Aug 28, 2017 at 06:08:31PM +0800, Wei Wang wrote:
> > > > > Add a new feature, VIRTIO_BALLOON_F_SG, which enables the transfer
> > > > > of balloon (i.e. inflated/deflated) pages using scatter-gather lists
> > > > > to the host.
> > > > > 
> > > > > The implementation of the previous virtio-balloon is not very
> > > > > efficient, because the balloon pages are transferred to the
> > > > > host one by one. Here is the breakdown of the time in percentage
> > > > > spent on each step of the balloon inflating process (inflating
> > > > > 7GB of an 8GB idle guest).
> > > > > 
> > > > > 1) allocating pages (6.5%)
> > > > > 2) sending PFNs to host (68.3%)
> > > > > 3) address translation (6.1%)
> > > > > 4) madvise (19%)
> > > > > 
> > > > > It takes about 4126ms for the inflating process to complete.
> > > > > The above profiling shows that the bottlenecks are stage 2)
> > > > > and stage 4).
> > > > > 
> > > > > This patch optimizes step 2) by transferring pages to the host in
> > > > > sgs. An sg describes a chunk of guest physically continuous pages.
> > > > > With this mechanism, step 4) can also be optimized by doing address
> > > > > translation and madvise() in chunks rather than page by page.
> > > > > 
> > > > > With this new feature, the above ballooning process takes ~597ms
> > > > > resulting in an improvement of ~86%.
> > > > > 
> > > > > TODO: optimize stage 1) by allocating/freeing a chunk of pages
> > > > > instead of a single page each time.
> > > > > 
> > > > > Signed-off-by: Wei Wang <wei.w.wang@intel.com>
> > > > > Signed-off-by: Liang Li <liang.z.li@intel.com>
> > > > > Suggested-by: Michael S. Tsirkin <mst@redhat.com>
> > > > > ---
> > > > >    drivers/virtio/virtio_balloon.c     | 171 ++++++++++++++++++++++++++++++++----
> > > > >    include/uapi/linux/virtio_balloon.h |   1 +
> > > > >    2 files changed, 155 insertions(+), 17 deletions(-)
> > > > > 
> > > > > diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
> > > > > index f0b3a0b..8ecc1d4 100644
> > > > > --- a/drivers/virtio/virtio_balloon.c
> > > > > +++ b/drivers/virtio/virtio_balloon.c
> > > > > @@ -32,6 +32,8 @@
> > > > >    #include <linux/mm.h>
> > > > >    #include <linux/mount.h>
> > > > >    #include <linux/magic.h>
> > > > > +#include <linux/xbitmap.h>
> > > > > +#include <asm/page.h>
> > > > >    /*
> > > > >     * Balloon device works in 4K page units.  So each page is pointed to by
> > > > > @@ -79,6 +81,9 @@ struct virtio_balloon {
> > > > >    	/* Synchronize access/update to this struct virtio_balloon elements */
> > > > >    	struct mutex balloon_lock;
> > > > > +	/* The xbitmap used to record balloon pages */
> > > > > +	struct xb page_xb;
> > > > > +
> > > > >    	/* The array of pfns we tell the Host about. */
> > > > >    	unsigned int num_pfns;
> > > > >    	__virtio32 pfns[VIRTIO_BALLOON_ARRAY_PFNS_MAX];
> > > > > @@ -141,13 +146,111 @@ static void set_page_pfns(struct virtio_balloon *vb,
> > > > >    					  page_to_balloon_pfn(page) + i);
> > > > >    }
> > > > > +static int add_one_sg(struct virtqueue *vq, void *addr, uint32_t size)
> > > > > +{
> > > > > +	struct scatterlist sg;
> > > > > +
> > > > > +	sg_init_one(&sg, addr, size);
> > > > > +	return virtqueue_add_inbuf(vq, &sg, 1, vq, GFP_KERNEL);
> > > > > +}
> > > > > +
> > > > > +static void send_balloon_page_sg(struct virtio_balloon *vb,
> > > > > +				 struct virtqueue *vq,
> > > > > +				 void *addr,
> > > > > +				 uint32_t size,
> > > > > +				 bool batch)
> > > > > +{
> > > > > +	unsigned int len;
> > > > > +	int err;
> > > > > +
> > > > > +	err = add_one_sg(vq, addr, size);
> > > > > +	/* Sanity check: this can't really happen */
> > > > > +	WARN_ON(err);
> > > > It might be cleaner to detect that add failed due to
> > > > ring full and kick then. Just an idea, up to you
> > > > whether to do it.
> > > > 
> > > > > +
> > > > > +	/* If batching is in use, we batch the sgs till the vq is full. */
> > > > > +	if (!batch || !vq->num_free) {
> > > > > +		virtqueue_kick(vq);
> > > > > +		wait_event(vb->acked, virtqueue_get_buf(vq, &len));
> > > > > +		/* Release all the entries if there are */
> > > > Meaning
> > > > 	Account for all used entries if any
> > > > ?
> > > > 
> > > > > +		while (virtqueue_get_buf(vq, &len))
> > > > > +			;
> > > > Above code is reused below. Add a function?
> > > > 
> > > > > +	}
> > > > > +}
> > > > > +
> > > > > +/*
> > > > > + * Send balloon pages in sgs to host. The balloon pages are recorded in the
> > > > > + * page xbitmap. Each bit in the bitmap corresponds to a page of PAGE_SIZE.
> > > > > + * The page xbitmap is searched for continuous "1" bits, which correspond
> > > > > + * to continuous pages, to chunk into sgs.
> > > > > + *
> > > > > + * @page_xb_start and @page_xb_end form the range of bits in the xbitmap that
> > > > > + * need to be searched.
> > > > > + */
> > > > > +static void tell_host_sgs(struct virtio_balloon *vb,
> > > > > +			  struct virtqueue *vq,
> > > > > +			  unsigned long page_xb_start,
> > > > > +			  unsigned long page_xb_end)
> > > > > +{
> > > > > +	unsigned long sg_pfn_start, sg_pfn_end;
> > > > > +	void *sg_addr;
> > > > > +	uint32_t sg_len, sg_max_len = round_down(UINT_MAX, PAGE_SIZE);
> > > > > +
> > > > > +	sg_pfn_start = page_xb_start;
> > > > > +	while (sg_pfn_start < page_xb_end) {
> > > > > +		sg_pfn_start = xb_find_next_bit(&vb->page_xb, sg_pfn_start,
> > > > > +						page_xb_end, 1);
> > > > > +		if (sg_pfn_start == page_xb_end + 1)
> > > > > +			break;
> > > > > +		sg_pfn_end = xb_find_next_bit(&vb->page_xb, sg_pfn_start + 1,
> > > > > +					      page_xb_end, 0);
> > > > > +		sg_addr = (void *)pfn_to_kaddr(sg_pfn_start);
> > > > > +		sg_len = (sg_pfn_end - sg_pfn_start) << PAGE_SHIFT;
> > > > > +		while (sg_len > sg_max_len) {
> > > > > +			send_balloon_page_sg(vb, vq, sg_addr, sg_max_len, 1);
> > > > Last argument should be true, not 1.
> > > > 
> > > > > +			sg_addr += sg_max_len;
> > > > > +			sg_len -= sg_max_len;
> > > > > +		}
> > > > > +		send_balloon_page_sg(vb, vq, sg_addr, sg_len, 1);
> > > > > +		xb_zero(&vb->page_xb, sg_pfn_start, sg_pfn_end);
> > > > > +		sg_pfn_start = sg_pfn_end + 1;
> > > > > +	}
> > > > > +
> > > > > +	/*
> > > > > +	 * The last few sgs may not reach the batch size, but need a kick to
> > > > > +	 * notify the device to handle them.
> > > > > +	 */
> > > > > +	if (vq->num_free != virtqueue_get_vring_size(vq)) {
> > > > > +		virtqueue_kick(vq);
> > > > > +		wait_event(vb->acked, virtqueue_get_buf(vq, &sg_len));
> > > > > +		while (virtqueue_get_buf(vq, &sg_len))
> > > > > +			;
> > > > Some entries can get used after a pause. Looks like they will leak then?
> > > > One fix would be to convert above if to a while loop.
> > > > I don't know whether to do it like this in send_balloon_page_sg too.
> > > > 
> > > Thanks for the above comments. I've re-written this part of code.
> > > Please have a check below if there is anything more we could improve:
> > > 
> > > static void kick_and_wait(struct virtqueue *vq, wait_queue_head_t wq_head)
> > > {
> > >          unsigned int len;
> > > 
> > >          virtqueue_kick(vq);
> > >          wait_event(wq_head, virtqueue_get_buf(vq, &len));
> > >          /* Detach all the used buffers from the vq */
> > >          while (virtqueue_get_buf(vq, &len))
> > >                  ;
> > I would move this last part to before add_buf. Increases chances
> > it succeeds even in case of a bug.
> 
> > 
> > > }
> > > 
> > > static int add_one_sg(struct virtqueue *vq, void *addr, uint32_t size)
> > > {
> > >          struct scatterlist sg;
> > >          int ret;
> > > 
> > >          sg_init_one(&sg, addr, size);
> > >          ret = virtqueue_add_inbuf(vq, &sg, 1, vq, GFP_KERNEL);
> > >          if (unlikely(ret == -ENOSPC))
> > >                  dev_warn(&vq->vdev->dev, "%s: failed due to ring full\n",
> > >                                   __func__);
> > So if this ever triggers then kick and wait might fail, right?
> > I think you should not special-case this one then.
> 
> OK, I will remove the check above, and take other suggestions as well.
> Thanks.
> 
> Best,
> Wei

Any updates here? It's been a while.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
