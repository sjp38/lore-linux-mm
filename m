Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 64B806B03EA
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 08:29:05 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id z22so21306090qka.4
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 05:29:05 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a195si2692905qkc.122.2017.06.21.05.29.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Jun 2017 05:29:04 -0700 (PDT)
Date: Wed, 21 Jun 2017 15:28:56 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [virtio-dev] Re: [PATCH v11 6/6] virtio-balloon:
 VIRTIO_BALLOON_F_CMD_VQ
Message-ID: <20170621151922-mutt-send-email-mst@kernel.org>
References: <1497004901-30593-1-git-send-email-wei.w.wang@intel.com>
 <1497004901-30593-7-git-send-email-wei.w.wang@intel.com>
 <20170620190343-mutt-send-email-mst@kernel.org>
 <5949E7C0.3050106@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5949E7C0.3050106@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, david@redhat.com, dave.hansen@intel.com, cornelia.huck@de.ibm.com, akpm@linux-foundation.org, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com, riel@redhat.com, nilal@redhat.com

On Wed, Jun 21, 2017 at 11:28:00AM +0800, Wei Wang wrote:
> On 06/21/2017 12:18 AM, Michael S. Tsirkin wrote:
> > On Fri, Jun 09, 2017 at 06:41:41PM +0800, Wei Wang wrote:
> > > -	if (!virtqueue_indirect_desc_table_add(vq, desc, num)) {
> > > +	if (!virtqueue_indirect_desc_table_add(vq, desc, *num)) {
> > >   		virtqueue_kick(vq);
> > > -		wait_event(vb->acked, virtqueue_get_buf(vq, &len));
> > > -		vb->balloon_page_chunk.chunk_num = 0;
> > > +		if (busy_wait)
> > > +			while (!virtqueue_get_buf(vq, &len) &&
> > > +			       !virtqueue_is_broken(vq))
> > > +				cpu_relax();
> > > +		else
> > > +			wait_event(vb->acked, virtqueue_get_buf(vq, &len));
> > 
> > This is something I didn't previously notice.
> > As you always keep a single buffer in flight, you do not
> > really need indirect at all. Just add all descriptors
> > in the ring directly, then kick.
> > 
> > E.g.
> > 	virtqueue_add_first
> > 	virtqueue_add_next
> > 	virtqueue_add_last
> > 
> > ?
> > 
> > You also want a flag to avoid allocations but there's no need to do it
> > per descriptor, set it on vq.
> > 
> 
> Without using the indirect table, I'm thinking about changing to use
> the standard sg (i.e. struct scatterlist), instead of vring_desc, so that
> we don't need to modify or add any new functions of virtqueue_add().
> 
> In this case, we will kmalloc an array of sgs in probe(), and we can add
> the sgs one by one to the vq, which won't trigger the allocation of an
> indirect table inside virtqueue_add(), and then kick when all are added.
> 
> Best,
> Wei

And allocate headers too? This can work. API extensions aren't
necessarily a bad idea though. The API I suggest above is preferable
for the simple reason that it can work without INDIRECT flag
support in hypervisor.

I wonder which APIs would Nitesh find useful.

-- 
MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
