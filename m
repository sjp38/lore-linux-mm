Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id C5BC96B0038
	for <linux-mm@kvack.org>; Fri,  3 Mar 2017 06:06:47 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id e12so94155211ioj.0
        for <linux-mm@kvack.org>; Fri, 03 Mar 2017 03:06:47 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id q9si2007248ite.39.2017.03.03.03.06.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Mar 2017 03:06:47 -0800 (PST)
Date: Fri, 3 Mar 2017 14:04:26 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [RFC PATCH 04/12] staging: android: ion: Call dma_map_sg for
 syncing and mapping
Message-ID: <20170303110329.GA4132@mwanda>
References: <1488491084-17252-1-git-send-email-labbott@redhat.com>
 <1488491084-17252-5-git-send-email-labbott@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1488491084-17252-5-git-send-email-labbott@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: Sumit Semwal <sumit.semwal@linaro.org>, Riley Andrews <riandrews@android.com>, arve@android.com, devel@driverdev.osuosl.org, romlem@google.com, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, Mark Brown <broonie@kernel.org>, Benjamin Gaignard <benjamin.gaignard@linaro.org>, Daniel Vetter <daniel.vetter@intel.com>, Brian Starkey <brian.starkey@arm.com>, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org

On Thu, Mar 02, 2017 at 01:44:36PM -0800, Laura Abbott wrote:
>  static struct sg_table *ion_map_dma_buf(struct dma_buf_attachment *attachment,
>  					enum dma_data_direction direction)
>  {
>  	struct dma_buf *dmabuf = attachment->dmabuf;
>  	struct ion_buffer *buffer = dmabuf->priv;
> +	struct sg_table *table;
> +	int ret;
> +
> +	/*
> +	 * TODO: Need to sync wrt CPU or device completely owning?
> +	 */
> +
> +	table = dup_sg_table(buffer->sg_table);
>  
> -	ion_buffer_sync_for_device(buffer, attachment->dev, direction);
> -	return dup_sg_table(buffer->sg_table);
> +	if (!dma_map_sg(attachment->dev, table->sgl, table->nents,
> +			direction)){
> +		ret = -ENOMEM;
> +		goto err;
> +	}
> +
> +err:
> +	free_duped_table(table);
> +	return ERR_PTR(ret);

ret isn't initialized on success.

>  }
>  

regards,
dan carpenter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
