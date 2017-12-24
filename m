Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 096DF6B0033
	for <linux-mm@kvack.org>; Sat, 23 Dec 2017 23:45:53 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id r6so14578732itr.1
        for <linux-mm@kvack.org>; Sat, 23 Dec 2017 20:45:53 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id r96si10857680ioi.90.2017.12.23.20.45.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 23 Dec 2017 20:45:51 -0800 (PST)
Subject: Re: [PATCH v20 4/7] virtio-balloon: VIRTIO_BALLOON_F_SG
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1513685879-21823-1-git-send-email-wei.w.wang@intel.com>
	<1513685879-21823-5-git-send-email-wei.w.wang@intel.com>
	<20171224032121.GA5273@bombadil.infradead.org>
In-Reply-To: <20171224032121.GA5273@bombadil.infradead.org>
Message-Id: <201712241345.DIG21823.SLFOOJtQFOMVFH@I-love.SAKURA.ne.jp>
Date: Sun, 24 Dec 2017 13:45:10 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: willy@infradead.org, wei.w.wang@intel.com
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com, david@redhat.com, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, riel@redhat.com

Matthew Wilcox wrote:
> > +	unsigned long pfn = page_to_pfn(page);
> > +	int ret;
> > +
> > +	*pfn_min = min(pfn, *pfn_min);
> > +	*pfn_max = max(pfn, *pfn_max);
> > +
> > +	do {
> > +		if (xb_preload(GFP_NOWAIT | __GFP_NOWARN) < 0)
> > +			return -ENOMEM;
> > +
> > +		ret = xb_set_bit(&vb->page_xb, pfn);
> > +		xb_preload_end();
> > +	} while (unlikely(ret == -EAGAIN));
> 
> OK, so you don't need a spinlock because you're under a mutex?  But you
> can't allocate memory because you're in the balloon driver, and so a
> GFP_KERNEL allocation might recurse into your driver?

Right. We can't (directly or indirectly) depend on __GFP_DIRECT_RECLAIM && !__GFP_NORETRY
allocations because the balloon driver needs to handle OOM notifier callback.

>                                                        Would GFP_NOIO
> do the job?  I'm a little hazy on exactly how the balloon driver works.

GFP_NOIO implies __GFP_DIRECT_RECLAIM. In the worst case, it can lockup due to
the too small to fail memory allocation rule. GFP_NOIO | __GFP_NORETRY would work
if there is really a guarantee that GFP_NOIO | __GFP_NORETRY never depend on
__GFP_DIRECT_RECLAIM && !__GFP_NORETRY allocations, which is too subtle for me to
validate. The direct reclaim dependency is too complicated to validate.
I consider that !__GFP_DIRECT_RECLAIM is the future-safe choice.

> 
> If you can't preload with anything better than that, I think that
> xb_set_bit() should attempt an allocation with GFP_NOWAIT | __GFP_NOWARN,
> and then you can skip the preload; it has no value for you.

Yes, that's why I suggest directly using kzalloc() at xb_set_bit().

> 
> > @@ -173,8 +292,15 @@ static unsigned fill_balloon(struct virtio_balloon *vb, size_t num)
> >  
> >  	while ((page = balloon_page_pop(&pages))) {
> >  		balloon_page_enqueue(&vb->vb_dev_info, page);
> > +		if (use_sg) {
> > +			if (xb_set_page(vb, page, &pfn_min, &pfn_max) < 0) {
> > +				__free_page(page);
> > +				continue;
> > +			}
> > +		} else {
> > +			set_page_pfns(vb, vb->pfns + vb->num_pfns, page);
> > +		}
> 
> Is this the right behaviour?

I don't think so. In the worst case, we can set no bit using xb_set_page().

>                               If we can't record the page in the xb,
> wouldn't we rather send it across as a single page?
> 

I think that we need to be able to fallback to !use_sg path when OOM.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
