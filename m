Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6C9166B0033
	for <linux-mm@kvack.org>; Sat, 23 Dec 2017 22:21:31 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id a10so18960070pgq.3
        for <linux-mm@kvack.org>; Sat, 23 Dec 2017 19:21:31 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id 92si19126198pli.692.2017.12.23.19.21.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 23 Dec 2017 19:21:29 -0800 (PST)
Date: Sat, 23 Dec 2017 19:21:21 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v20 4/7] virtio-balloon: VIRTIO_BALLOON_F_SG
Message-ID: <20171224032121.GA5273@bombadil.infradead.org>
References: <1513685879-21823-1-git-send-email-wei.w.wang@intel.com>
 <1513685879-21823-5-git-send-email-wei.w.wang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1513685879-21823-5-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com, david@redhat.com, penguin-kernel@I-love.SAKURA.ne.jp, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, riel@redhat.com

On Tue, Dec 19, 2017 at 08:17:56PM +0800, Wei Wang wrote:
> +/*
> + * Send balloon pages in sgs to host. The balloon pages are recorded in the
> + * page xbitmap. Each bit in the bitmap corresponds to a page of PAGE_SIZE.
> + * The page xbitmap is searched for continuous "1" bits, which correspond
> + * to continuous pages, to chunk into sgs.
> + *
> + * @page_xb_start and @page_xb_end form the range of bits in the xbitmap that
> + * need to be searched.
> + */
> +static void tell_host_sgs(struct virtio_balloon *vb,
> +			  struct virtqueue *vq,
> +			  unsigned long page_xb_start,
> +			  unsigned long page_xb_end)

I'm not crazy about the naming here.  I'd use pfn_min and pfn_max like
you use in the caller.

> +{
> +	unsigned long pfn_start, pfn_end;
> +	uint32_t max_len = round_down(UINT_MAX, PAGE_SIZE);
> +	uint64_t len;
> +
> +	pfn_start = page_xb_start;

And I think pfn_start is actually just 'pfn'.

'pfn_end' is perhaps just 'end'.  Or 'gap'.

> +	while (pfn_start < page_xb_end) {
> +		pfn_start = xb_find_set(&vb->page_xb, page_xb_end + 1,
> +					pfn_start);
> +		if (pfn_start == page_xb_end + 1)
> +			break;
> +		pfn_end = xb_find_zero(&vb->page_xb, page_xb_end + 1,
> +				       pfn_start);
> +		len = (pfn_end - pfn_start) << PAGE_SHIFT;

> +static inline int xb_set_page(struct virtio_balloon *vb,
> +			       struct page *page,
> +			       unsigned long *pfn_min,
> +			       unsigned long *pfn_max)
> +{

I really don't like it that you're naming things after the 'xb'.
Things should be named by something that makes sense to the user, not
after the particular implementation.  If you changed the underlying
representation from an xbitmap to, say, a BTree, you wouldn't want to
rename this function to 'btree_set_page'.  Maybe this function is really
"vb_set_page".  Or "record_page".  Or something.  Someone who understands
this driver better than I do can probably weigh in with a better name.

> +	unsigned long pfn = page_to_pfn(page);
> +	int ret;
> +
> +	*pfn_min = min(pfn, *pfn_min);
> +	*pfn_max = max(pfn, *pfn_max);
> +
> +	do {
> +		if (xb_preload(GFP_NOWAIT | __GFP_NOWARN) < 0)
> +			return -ENOMEM;
> +
> +		ret = xb_set_bit(&vb->page_xb, pfn);
> +		xb_preload_end();
> +	} while (unlikely(ret == -EAGAIN));

OK, so you don't need a spinlock because you're under a mutex?  But you
can't allocate memory because you're in the balloon driver, and so a
GFP_KERNEL allocation might recurse into your driver?  Would GFP_NOIO
do the job?  I'm a little hazy on exactly how the balloon driver works.

If you can't preload with anything better than that, I think that
xb_set_bit() should attempt an allocation with GFP_NOWAIT | __GFP_NOWARN,
and then you can skip the preload; it has no value for you.

> @@ -173,8 +292,15 @@ static unsigned fill_balloon(struct virtio_balloon *vb, size_t num)
>  
>  	while ((page = balloon_page_pop(&pages))) {
>  		balloon_page_enqueue(&vb->vb_dev_info, page);
> +		if (use_sg) {
> +			if (xb_set_page(vb, page, &pfn_min, &pfn_max) < 0) {
> +				__free_page(page);
> +				continue;
> +			}
> +		} else {
> +			set_page_pfns(vb, vb->pfns + vb->num_pfns, page);
> +		}

Is this the right behaviour?  If we can't record the page in the xb,
wouldn't we rather send it across as a single page?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
