Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 48B066B0038
	for <linux-mm@kvack.org>; Thu, 29 Jan 2015 09:39:34 -0500 (EST)
Received: by mail-wg0-f47.google.com with SMTP id n12so23346437wgh.6
        for <linux-mm@kvack.org>; Thu, 29 Jan 2015 06:39:33 -0800 (PST)
Received: from pandora.arm.linux.org.uk (pandora.arm.linux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id ht7si3924334wib.3.2015.01.29.06.39.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 29 Jan 2015 06:39:32 -0800 (PST)
Date: Thu, 29 Jan 2015 14:39:08 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [RFCv3 2/2] dma-buf: add helpers for sharing attacher
 constraints with dma-parms
Message-ID: <20150129143908.GA26493@n2100.arm.linux.org.uk>
References: <1422347154-15258-1-git-send-email-sumit.semwal@linaro.org>
 <1422347154-15258-2-git-send-email-sumit.semwal@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1422347154-15258-2-git-send-email-sumit.semwal@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sumit Semwal <sumit.semwal@linaro.org>
Cc: linux-kernel@vger.kernel.org, linux-media@vger.kernel.org, dri-devel@lists.freedesktop.org, linaro-mm-sig@lists.linaro.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org, stanislawski.tomasz@googlemail.com, robdclark@gmail.com, daniel@ffwll.ch, robin.murphy@arm.com, m.szyprowski@samsung.com

On Tue, Jan 27, 2015 at 01:55:54PM +0530, Sumit Semwal wrote:
> +/*
> + * recalc_constraints - recalculates constraints for all attached devices;
> + *  useful for detach() recalculation, and for dma_buf_recalc_constraints()
> + *  helper.
> + *  Returns recalculated constraints in recalc_cons, or error in the unlikely
> + *  case when constraints of attached devices might have changed.
> + */

Please see kerneldoc documentation for the proper format of these comments.

> +static int recalc_constraints(struct dma_buf *dmabuf,
> +			      struct device_dma_parameters *recalc_cons)
> +{
> +	struct device_dma_parameters calc_cons;
> +	struct dma_buf_attachment *attach;
> +	int ret = 0;
> +
> +	init_constraints(&calc_cons);
> +
> +	list_for_each_entry(attach, &dmabuf->attachments, node) {
> +		ret = calc_constraints(attach->dev, &calc_cons);
> +		if (ret)
> +			return ret;
> +	}
> +	*recalc_cons = calc_cons;
> +	return 0;
> +}
> +
>  /**
>   * dma_buf_export_named - Creates a new dma_buf, and associates an anon file
>   * with this buffer, so it can be exported.
> @@ -313,6 +373,9 @@ struct dma_buf *dma_buf_export_named(void *priv, const struct dma_buf_ops *ops,
>  	dmabuf->ops = ops;
>  	dmabuf->size = size;
>  	dmabuf->exp_name = exp_name;
> +
> +	init_constraints(&dmabuf->constraints);
> +
>  	init_waitqueue_head(&dmabuf->poll);
>  	dmabuf->cb_excl.poll = dmabuf->cb_shared.poll = &dmabuf->poll;
>  	dmabuf->cb_excl.active = dmabuf->cb_shared.active = 0;
> @@ -422,7 +485,7 @@ struct dma_buf_attachment *dma_buf_attach(struct dma_buf *dmabuf,
>  					  struct device *dev)
>  {
>  	struct dma_buf_attachment *attach;
> -	int ret;
> +	int ret = 0;
>  
>  	if (WARN_ON(!dmabuf || !dev))
>  		return ERR_PTR(-EINVAL);
> @@ -436,6 +499,9 @@ struct dma_buf_attachment *dma_buf_attach(struct dma_buf *dmabuf,
>  
>  	mutex_lock(&dmabuf->lock);
>  
> +	if (calc_constraints(dev, &dmabuf->constraints))
> +		goto err_constraints;
> +
>  	if (dmabuf->ops->attach) {
>  		ret = dmabuf->ops->attach(dmabuf, dev, attach);
>  		if (ret)
> @@ -448,6 +514,7 @@ struct dma_buf_attachment *dma_buf_attach(struct dma_buf *dmabuf,
>  
>  err_attach:
>  	kfree(attach);
> +err_constraints:
>  	mutex_unlock(&dmabuf->lock);
>  	return ERR_PTR(ret);
>  }
> @@ -470,6 +537,8 @@ void dma_buf_detach(struct dma_buf *dmabuf, struct dma_buf_attachment *attach)
>  	if (dmabuf->ops->detach)
>  		dmabuf->ops->detach(dmabuf, attach);
>  
> +	recalc_constraints(dmabuf, &dmabuf->constraints);
> +

To me, this whole thing seems horribly racy.

What happens if subsystem X creates a dmabuf, which is passed to
userspace. It's then passed to subsystem Y, which starts making use
of it, calling dma_buf_map_attachment() on it.

The same buffer is also passed (via unix domain sockets) to another
program, which then passes it independently into subsystem Z, and
subsystem Z has more restrictive DMA constraints.

What happens at this point?

Subsystems such as DRM cache the scatter table, and return it for
subsequent attach calls, so DRM drivers using the default
drm_gem_map_dma_buf() implementation would not see the restrictions
placed upon the dmabuf.  Moreover, the returned scatterlist would not
be modified for those restrictions either.

What would other subsystems do?

This needs more thought before it's merged.

For example, in the above situation, should we deny the ability to
create a new attachment when a dmabuf has already been mapped by an
existing attachment?  Should we deny it only when the new attachment
has more restrictive DMA constraints?

Please consider the possible sequences of use (such as the scenario
above) when creating or augmenting an API.

-- 
FTTC broadband for 0.8mile line: currently at 10.5Mbps down 400kbps up
according to speedtest.net.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
