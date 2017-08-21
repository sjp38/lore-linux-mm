Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id A3B7728042F
	for <linux-mm@kvack.org>; Mon, 21 Aug 2017 16:22:22 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id z10so6861594qtz.2
        for <linux-mm@kvack.org>; Mon, 21 Aug 2017 13:22:22 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i93si6021476qtd.217.2017.08.21.13.22.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Aug 2017 13:22:21 -0700 (PDT)
Date: Mon, 21 Aug 2017 23:22:17 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v14 3/5] virtio-balloon: VIRTIO_BALLOON_F_SG
Message-ID: <20170821232052-mutt-send-email-mst@kernel.org>
References: <1502940416-42944-1-git-send-email-wei.w.wang@intel.com>
 <1502940416-42944-4-git-send-email-wei.w.wang@intel.com>
 <20170818051451-mutt-send-email-mst@kernel.org>
 <599699AF.1090705@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <599699AF.1090705@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com, david@redhat.com, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, willy@infradead.org, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com

On Fri, Aug 18, 2017 at 03:39:27PM +0800, Wei Wang wrote:
> On 08/18/2017 10:22 AM, Michael S. Tsirkin wrote:
> > +static void send_balloon_page_sg(struct virtio_balloon *vb,
> > +				 struct virtqueue *vq,
> > +				 void *addr,
> > +				 uint32_t size)
> > +{
> > +	unsigned int len;
> > +	int ret;
> > +
> > +	do {
> > +		ret = add_one_sg(vq, addr, size);
> > +		virtqueue_kick(vq);
> > +		wait_event(vb->acked, virtqueue_get_buf(vq, &len));
> > +		/*
> > +		 * It is uncommon to see the vq is full, because the sg is sent
> > +		 * one by one and the device is able to handle it in time. But
> > +		 * if that happens, we go back to retry after an entry gets
> > +		 * released.
> > +		 */
> > Why send one by one though? Why not batch some s/gs and wait for all
> > of them to be completed? If memory if fragmented, waiting every time is
> > worse than what we have now (VIRTIO_BALLOON_ARRAY_PFNS_MAX at a time).
> > 
> 
> OK, I'll do batching in some fashion.
> 
> 
> Best,
> Wei
> 
> 

btw you need to address the build errors that kbot has found.

-- 
MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
