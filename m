Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 626AC6B004D
	for <linux-mm@kvack.org>; Fri, 20 Jan 2012 08:23:50 -0500 (EST)
From: Laurent Pinchart <laurent.pinchart@ideasonboard.com>
Subject: Re: [Linaro-mm-sig] [PATCH 1/3] dma-buf: Introduce dma buffer sharing mechanism
Date: Fri, 20 Jan 2012 14:23:45 +0100
References: <1324891397-10877-1-git-send-email-sumit.semwal@ti.com> <1324891397-10877-2-git-send-email-sumit.semwal@ti.com>
In-Reply-To: <1324891397-10877-2-git-send-email-sumit.semwal@ti.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <201201201423.46858.laurent.pinchart@ideasonboard.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linaro-mm-sig@lists.linaro.org
Cc: Sumit Semwal <sumit.semwal@ti.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, dri-devel@lists.freedesktop.org, linux-media@vger.kernel.org, arnd@arndb.de, airlied@redhat.com, linux@arm.linux.org.uk, patches@linaro.org, jesse.barker@linaro.org, daniel@ffwll.ch

Hi Summit,

Sorry for the late review. I know that this code is now in mainline, but I 
still have a couple of comments. I'll send patches if you agree with them.

On Monday 26 December 2011 10:23:15 Sumit Semwal wrote:
> This is the first step in defining a dma buffer sharing mechanism.
> 
> A new buffer object dma_buf is added, with operations and API to allow easy
> sharing of this buffer object across devices.
> 
> The framework allows:
> - creation of a buffer object, its association with a file pointer, and
>    associated allocator-defined operations on that buffer. This operation
> is called the 'export' operation.
> - different devices to 'attach' themselves to this exported buffer object,
> to facilitate backing storage negotiation, using dma_buf_attach() API. -
> the exported buffer object to be shared with the other entity by asking
> for its 'file-descriptor (fd)', and sharing the fd across.
> - a received fd to get the buffer object back, where it can be accessed
> using the associated exporter-defined operations.
> - the exporter and user to share the scatterlist associated with this
> buffer object using map_dma_buf and unmap_dma_buf operations.
> 
> Atleast one 'attach()' call is required to be made prior to calling the
> map_dma_buf() operation.
> 
> Couple of building blocks in map_dma_buf() are added to ease introduction
> of sync'ing across exporter and users, and late allocation by the exporter.
> 
> For this first version, this framework will work with certain conditions:
> - *ONLY* exporter will be allowed to mmap to userspace (outside of this
>    framework - mmap is not a buffer object operation),
> - currently, *ONLY* users that do not need CPU access to the buffer are
>    allowed.
> 
> More details are there in the documentation patch.
> 
> This is based on design suggestions from many people at the
> mini-summits[1], most notably from Arnd Bergmann <arnd@arndb.de>, Rob
> Clark <rob@ti.com> and Daniel Vetter <daniel@ffwll.ch>.
> 
> The implementation is inspired from proof-of-concept patch-set from
> Tomasz Stanislawski <t.stanislaws@samsung.com>, who demonstrated buffer
> sharing between two v4l2 devices. [2]
> 
> [1]: https://wiki.linaro.org/OfficeofCTO/MemoryManagement
> [2]: http://lwn.net/Articles/454389
> 
> Signed-off-by: Sumit Semwal <sumit.semwal@linaro.org>
> Signed-off-by: Sumit Semwal <sumit.semwal@ti.com>
> Reviewed-by: Daniel Vetter <daniel.vetter@ffwll.ch>
> Reviewed-by: Dave Airlie <airlied@redhat.com>
> Reviewed-and-Tested-by: Rob Clark <rob.clark@linaro.org>
> ---
>  drivers/base/Kconfig    |   10 ++
>  drivers/base/Makefile   |    1 +
>  drivers/base/dma-buf.c  |  291
> +++++++++++++++++++++++++++++++++++++++++++++++ include/linux/dma-buf.h | 
> 176 ++++++++++++++++++++++++++++
>  4 files changed, 478 insertions(+), 0 deletions(-)
>  create mode 100644 drivers/base/dma-buf.c
>  create mode 100644 include/linux/dma-buf.h
> 

[snip]

> diff --git a/drivers/base/dma-buf.c b/drivers/base/dma-buf.c
> new file mode 100644
> index 0000000..e38ad24
> --- /dev/null
> +++ b/drivers/base/dma-buf.c
> @@ -0,0 +1,291 @@

[snip]

> +/**
> + * dma_buf_export - Creates a new dma_buf, and associates an anon file
> + * with this buffer, so it can be exported.
> + * Also connect the allocator specific data and ops to the buffer.
> + *
> + * @priv:	[in]	Attach private data of allocator to this buffer
> + * @ops:	[in]	Attach allocator-defined dma buf ops to the new buffer.
> + * @size:	[in]	Size of the buffer
> + * @flags:	[in]	mode flags for the file.
> + *
> + * Returns, on success, a newly created dma_buf object, which wraps the
> + * supplied private data and operations for dma_buf_ops. On either missing
> + * ops, or error in allocating struct dma_buf, will return negative error.
> + *
> + */
> +struct dma_buf *dma_buf_export(void *priv, struct dma_buf_ops *ops,
> +				size_t size, int flags)
> +{
> +	struct dma_buf *dmabuf;
> +	struct file *file;
> +
> +	if (WARN_ON(!priv || !ops
> +			  || !ops->map_dma_buf
> +			  || !ops->unmap_dma_buf
> +			  || !ops->release)) {
> +		return ERR_PTR(-EINVAL);
> +	}
> +
> +	dmabuf = kzalloc(sizeof(struct dma_buf), GFP_KERNEL);
> +	if (dmabuf == NULL)
> +		return ERR_PTR(-ENOMEM);
> +
> +	dmabuf->priv = priv;
> +	dmabuf->ops = ops;

dmabuf->ops will never but NULL, but (see below)

> +	dmabuf->size = size;
> +
> +	file = anon_inode_getfile("dmabuf", &dma_buf_fops, dmabuf, flags);
> +
> +	dmabuf->file = file;
> +
> +	mutex_init(&dmabuf->lock);
> +	INIT_LIST_HEAD(&dmabuf->attachments);
> +
> +	return dmabuf;
> +}
> +EXPORT_SYMBOL_GPL(dma_buf_export);

[snip]

> +/**
> + * dma_buf_attach - Add the device to dma_buf's attachments list;
> optionally, + * calls attach() of dma_buf_ops to allow device-specific
> attach functionality + * @dmabuf:	[in]	buffer to attach device to.
> + * @dev:	[in]	device to be attached.
> + *
> + * Returns struct dma_buf_attachment * for this attachment; may return
> negative + * error codes.
> + *
> + */
> +struct dma_buf_attachment *dma_buf_attach(struct dma_buf *dmabuf,
> +					  struct device *dev)
> +{
> +	struct dma_buf_attachment *attach;
> +	int ret;
> +
> +	if (WARN_ON(!dmabuf || !dev || !dmabuf->ops))

you still check dmabuf->ops here, as well as in several places below. 
Shouldn't these checks be removed ?

> +		return ERR_PTR(-EINVAL);
> +
> +	attach = kzalloc(sizeof(struct dma_buf_attachment), GFP_KERNEL);
> +	if (attach == NULL)
> +		goto err_alloc;

What about returning ERR_PTR(-ENOMEM) directly here ?

> +
> +	mutex_lock(&dmabuf->lock);
> +
> +	attach->dev = dev;
> +	attach->dmabuf = dmabuf;

These two lines can be moved before mutex_lock().

> +	if (dmabuf->ops->attach) {
> +		ret = dmabuf->ops->attach(dmabuf, dev, attach);
> +		if (ret)
> +			goto err_attach;
> +	}
> +	list_add(&attach->node, &dmabuf->attachments);
> +
> +	mutex_unlock(&dmabuf->lock);
> +	return attach;
> +
> +err_alloc:
> +	return ERR_PTR(-ENOMEM);
> +err_attach:
> +	kfree(attach);
> +	mutex_unlock(&dmabuf->lock);
> +	return ERR_PTR(ret);
> +}
> +EXPORT_SYMBOL_GPL(dma_buf_attach);

-- 
Regards,

Laurent Pinchart

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
