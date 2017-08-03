Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id D82466B06D8
	for <linux-mm@kvack.org>; Thu,  3 Aug 2017 11:55:59 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id 6so7835834qts.7
        for <linux-mm@kvack.org>; Thu, 03 Aug 2017 08:55:59 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n50si31299576qta.15.2017.08.03.08.55.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Aug 2017 08:55:58 -0700 (PDT)
Date: Thu, 3 Aug 2017 18:55:50 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v13 3/5] virtio-balloon: VIRTIO_BALLOON_F_SG
Message-ID: <20170803185508-mutt-send-email-mst@kernel.org>
References: <1501742299-4369-1-git-send-email-wei.w.wang@intel.com>
 <1501742299-4369-4-git-send-email-wei.w.wang@intel.com>
 <20170803151212-mutt-send-email-mst@kernel.org>
 <286AC319A985734F985F78AFA26841F73928C952@shsmsx102.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <286AC319A985734F985F78AFA26841F73928C952@shsmsx102.ccr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Wang, Wei W" <wei.w.wang@intel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mhocko@kernel.org" <mhocko@kernel.org>, "mawilcox@microsoft.com" <mawilcox@microsoft.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "david@redhat.com" <david@redhat.com>, "cornelia.huck@de.ibm.com" <cornelia.huck@de.ibm.com>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "aarcange@redhat.com" <aarcange@redhat.com>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "liliang.opensource@gmail.com" <liliang.opensource@gmail.com>, "yang.zhang.wz@gmail.com" <yang.zhang.wz@gmail.com>, "quan.xu@aliyun.com" <quan.xu@aliyun.com>

On Thu, Aug 03, 2017 at 03:17:59PM +0000, Wang, Wei W wrote:
> On Thursday, August 3, 2017 10:23 PM, Michael S. Tsirkin wrote:
> > On Thu, Aug 03, 2017 at 02:38:17PM +0800, Wei Wang wrote:
> > > +static void send_one_sg(struct virtio_balloon *vb, struct virtqueue *vq,
> > > +			void *addr, uint32_t size)
> > > +{
> > > +	struct scatterlist sg;
> > > +	unsigned int len;
> > > +
> > > +	sg_init_one(&sg, addr, size);
> > > +	while (unlikely(virtqueue_add_inbuf(vq, &sg, 1, vb, GFP_KERNEL)
> > > +			== -ENOSPC)) {
> > > +		/*
> > > +		 * It is uncommon to see the vq is full, because the sg is sent
> > > +		 * one by one and the device is able to handle it in time. But
> > > +		 * if that happens, we kick and wait for an entry is released.
> > 
> > is released -> to get used.
> > 
> > > +		 */
> > > +		virtqueue_kick(vq);
> > > +		while (!virtqueue_get_buf(vq, &len) &&
> > > +		       !virtqueue_is_broken(vq))
> > > +			cpu_relax();
> > 
> > Please rework to use wait_event in that case too.
> 
> For the balloon page case here, it is fine to use wait_event. But for the free page
> case, I think it might not be suitable because the mm lock is being held.
> 
> Best,
> Wei

You will have to find a way to drop the lock and restart from where you
stopped then.

-- 
MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
