Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id DAE996B0033
	for <linux-mm@kvack.org>; Mon,  2 Oct 2017 09:45:08 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id a12so2648356qka.7
        for <linux-mm@kvack.org>; Mon, 02 Oct 2017 06:45:08 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n200si38376qke.281.2017.10.02.06.45.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Oct 2017 06:45:07 -0700 (PDT)
Date: Mon, 2 Oct 2017 16:44:52 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v16 3/5] virtio-balloon: VIRTIO_BALLOON_F_SG
Message-ID: <20171002160757-mutt-send-email-mst@kernel.org>
References: <1506744354-20979-1-git-send-email-wei.w.wang@intel.com>
 <1506744354-20979-4-git-send-email-wei.w.wang@intel.com>
 <20171002072106-mutt-send-email-mst@kernel.org>
 <286AC319A985734F985F78AFA26841F73931FDB5@shsmsx102.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <286AC319A985734F985F78AFA26841F73931FDB5@shsmsx102.ccr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Wang, Wei W" <wei.w.wang@intel.com>
Cc: "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mhocko@kernel.org" <mhocko@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mawilcox@microsoft.com" <mawilcox@microsoft.com>, "david@redhat.com" <david@redhat.com>, "cornelia.huck@de.ibm.com" <cornelia.huck@de.ibm.com>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "aarcange@redhat.com" <aarcange@redhat.com>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "willy@infradead.org" <willy@infradead.org>, "liliang.opensource@gmail.com" <liliang.opensource@gmail.com>, "yang.zhang.wz@gmail.com" <yang.zhang.wz@gmail.com>, "quan.xu@aliyun.com" <quan.xu@aliyun.com>

On Mon, Oct 02, 2017 at 12:39:30PM +0000, Wang, Wei W wrote:
> On Monday, October 2, 2017 12:30 PM, Michael S. Tsirkin wrote:
> > On Sat, Sep 30, 2017 at 12:05:52PM +0800, Wei Wang wrote:
> > > +static int send_balloon_page_sg(struct virtio_balloon *vb,
> > > +				 struct virtqueue *vq,
> > > +				 void *addr,
> > > +				 uint32_t size,
> > > +				 bool batch)
> > > +{
> > > +	int err;
> > > +
> > > +	err = add_one_sg(vq, addr, size);
> > > +
> > > +	/* If batchng is requested, we batch till the vq is full */
> > 
> > typo
> > 
> > > +	if (!batch || !vq->num_free)
> > > +		kick_and_wait(vq, vb->acked);
> > > +
> > > +	return err;
> > > +}
> > 
> > If add_one_sg fails, kick_and_wait will hang forever.
> > 
> > The reason this might work in because
> > 1. with 1 sg there are no memory allocations 2. if adding fails on vq full, then
> > something
> >    is in queue and will wake up kick_and_wait.
> > 
> > So in short this is expected to never fail.
> > How about a BUG_ON here then?
> > And make it void, and add a comment with above explanation.
> > 
> 
> 
> Yes, agree that this wouldn't fail - the worker thread performing the ballooning operations has been put into sleep when the vq is full, so I think there shouldn't be anyone else to put more sgs onto the vq then.
> Btw, not sure if we need to mention memory allocation in the comment, I found virtqueue_add() doesn't return any error when allocation (for indirect desc-s) fails - it simply avoids the use of indirect desc.
> 
> What do you think of the following? 
> 
> err = add_one_sg(vq, addr, size);
> /* 
>   * This is expected to never fail: there is always at least 1 entry available on the vq,
>   * because when the vq is full the worker thread that adds the sg will be put into
>   * sleep until at least 1 entry is available to use.
>   */
> BUG_ON(err);
> 
> Best,
> Wei
> 
> 
> 
>  

Sounds good.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
