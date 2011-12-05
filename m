Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id C276B6B004F
	for <linux-mm@kvack.org>; Mon,  5 Dec 2011 12:19:14 -0500 (EST)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [RFC v2 1/2] dma-buf: Introduce dma buffer sharing mechanism
Date: Mon, 5 Dec 2011 17:18:48 +0000
References: <1322816252-19955-1-git-send-email-sumit.semwal@ti.com> <1322816252-19955-2-git-send-email-sumit.semwal@ti.com>
In-Reply-To: <1322816252-19955-2-git-send-email-sumit.semwal@ti.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Message-Id: <201112051718.48324.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sumit Semwal <sumit.semwal@ti.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, dri-devel@lists.freedesktop.org, linux-media@vger.kernel.org, linux@arm.linux.org.uk, jesse.barker@linaro.org, m.szyprowski@samsung.com, rob@ti.com, daniel@ffwll.ch, t.stanislaws@samsung.com, Sumit Semwal <sumit.semwal@linaro.org>

On Friday 02 December 2011, Sumit Semwal wrote:
> This is the first step in defining a dma buffer sharing mechanism.

This looks very nice, but there are a few things I don't understand yet
and a bunch of trivial comments I have about things I spotted.

Do you have prototype exporter and consumer drivers that you can post
for clarification?

In the patch 2, you have a section about migration that mentions that
it is possible to export a buffer that can be migrated after it
is already mapped into one user driver. How does that work when
the physical addresses are mapped into a consumer device already?

> diff --git a/drivers/base/Kconfig b/drivers/base/Kconfig
> index 21cf46f..07d8095 100644
> --- a/drivers/base/Kconfig
> +++ b/drivers/base/Kconfig
> @@ -174,4 +174,14 @@ config SYS_HYPERVISOR
>  
>  source "drivers/base/regmap/Kconfig"
>  
> +config DMA_SHARED_BUFFER
> +	bool "Buffer framework to be shared between drivers"
> +	default n
> +	depends on ANON_INODES

I would make this 'select ANON_INODES', like the other users of this
feature.

> +	return dmabuf;
> +}
> +EXPORT_SYMBOL(dma_buf_export);

I agree with Konrad, this should definitely be EXPORT_SYMBOL_GPL,
because it's really a low-level function that I would expect
to get used by in-kernel subsystems providing the feature to
users and having back-end drivers, but it's not the kind of thing
we want out-of-tree drivers to mess with.

> +/**
> + * dma_buf_fd - returns a file descriptor for the given dma_buf
> + * @dmabuf:	[in]	pointer to dma_buf for which fd is required.
> + *
> + * On success, returns an associated 'fd'. Else, returns error.
> + */
> +int dma_buf_fd(struct dma_buf *dmabuf)
> +{
> +	int error, fd;
> +
> +	if (!dmabuf->file)
> +		return -EINVAL;
> +
> +	error = get_unused_fd_flags(0);

Why not simply get_unused_fd()?

> +/**
> + * dma_buf_attach - Add the device to dma_buf's attachments list; optionally,
> + * calls attach() of dma_buf_ops to allow device-specific attach functionality
> + * @dmabuf:	[in]	buffer to attach device to.
> + * @dev:	[in]	device to be attached.
> + *
> + * Returns struct dma_buf_attachment * for this attachment; may return NULL.
> + *

Or may return a negative error code. It's better to be consistent here:
either always return NULL on error, or change the allocation error to
ERR_PTR(-ENOMEM).

> + */
> +struct dma_buf_attachment *dma_buf_attach(struct dma_buf *dmabuf,
> +						struct device *dev)
> +{
> +	struct dma_buf_attachment *attach;
> +	int ret;
> +
> +	BUG_ON(!dmabuf || !dev);
> +
> +	attach = kzalloc(sizeof(struct dma_buf_attachment), GFP_KERNEL);
> +	if (attach == NULL)
> +		goto err_alloc;
> +
> +	mutex_lock(&dmabuf->lock);
> +
> +	attach->dev = dev;
> +	attach->dmabuf = dmabuf;
> +	if (dmabuf->ops->attach) {
> +		ret = dmabuf->ops->attach(dmabuf, dev, attach);
> +		if (!ret)
> +			goto err_attach;

You probably mean "if (ret)" here instead of "if (!ret)", right?

> +	/* allow allocator to take care of cache ops */
> +	void (*sync_sg_for_cpu) (struct dma_buf *, struct device *);
> +	void (*sync_sg_for_device)(struct dma_buf *, struct device *);

I don't see how this works with multiple consumers: For the streaming
DMA mapping, there must be exactly one owner, either the device or
the CPU. Obviously, this rule needs to be extended when you get to
multiple devices and multiple device drivers, plus possibly user
mappings. Simply assigning the buffer to "the device" from one
driver does not block other drivers from touching the buffer, and
assigning it to "the cpu" does not stop other hardware that the
code calling sync_sg_for_cpu is not aware of.

The only way to solve this that I can think of right now is to
mandate that the mappings are all coherent (i.e. noncachable
on noncoherent architectures like ARM). If you do that, you no
longer need the sync_sg_for_* calls.

> +#ifdef CONFIG_DMA_SHARED_BUFFER

Do you have a use case for making the interface compile-time disabled?
I had assumed that any code using it would make no sense if it's not
available so you don't actually need this.

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
